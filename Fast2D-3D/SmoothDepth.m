function SmoothDepth(rootin,rootout,st,endi,w,sigma)

mkdir(rootout);
num_frames = 2*w+1;

if(st<100000)
    d = double(imread([rootin '000' num2str(st) '.png']));
elseif(st<1000000)
    d = double(imread([rootin '00' num2str(st) '.png']));
end

[vres hres u] = size(d);
D = zeros(vres,hres,num_frames);

g = fspecial('gaussian',[1 num_frames],sigma);

for FR = st+w:endi-w,
%for FR = [st+w endi-w],
    
    K = 0;
    for fr = FR-w:FR+w,
        
        K = K + 1;
        if(fr<100000)
            d = double(imread([rootin '000' num2str(fr) '.png']));
        elseif(fr<1000000)
            d = double(imread([rootin '00' num2str(fr) '.png']));
        end
        
        D(:,:,K) = g(K)*d(:,:,1);
        
    end
    
    d_smoothed = sum(D,3);
    imwrite(d_smoothed/255,[rootout num2str(FR) '.png']);
    
end


