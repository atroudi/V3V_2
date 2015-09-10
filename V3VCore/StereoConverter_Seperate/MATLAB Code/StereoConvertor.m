function StereoConvertor(rgb_rootin,d_rootin,st,endi,R,Thresh,w,sigma,SpatialSmoothness)

rootout = [d_rootin '\Warped\'];
mkdir(rootout);

RAW = double(imread([rgb_rootin num2str(st) '.png']));
[vres hres u] = size(RAW);

num_frames = 2*w+1;
g = fspecial('gaussian',[1 num_frames],sigma);
D = zeros(vres,hres,num_frames);

if(SpatialSmoothness == 1)
    [Gx, Gy, xx, yy, YY] = WarpingInitilization(vres,hres,R);
else
    [xx, yy, YY] = WarpingInitilization_Simple(vres,hres);
end

for FR = st+w:endi-w,
    
    %%%%RAW Left Image
    RAW = double(imread([rgb_rootin num2str(FR) '.png']))/255;
    
    %%%%Read and temporally smooth Depth
    K = 0;
    for fr = FR-w:FR+w,
        
        if(and(fr>=st,fr<=endi))
            K = K + 1;
            d = double(imread([d_rootin num2str(fr) '.png']));
            D(:,:,K) = g(K)*d(:,:,1);
        end
    end
    D_smoothed = sum(D,3);
    
    if(max(max(abs(D_smoothed))) < 0.1) %%no need for warping
        
        SS = [RAW RAW];
        
    else
        
        %%actual Warping (added spatial smoothness swtich --> SpatialSmoothness)
        if(SpatialSmoothness == 1)
            SS = ViewInterpolation(RAW,D_smoothed,Thresh,R,Gx,Gy,xx,yy,YY);
        else
            SS = SimpleInterpolation(RAW,D_smoothed,Thresh,R,xx,yy,YY);
        end
        
    end
    
    %%Saving data
    imwrite(SS,[rootout num2str(FR) '.png']);
    
end

