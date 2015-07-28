function PrepareData

st = 522;
endi = 524;
R = 0.25;

I = double(imread([rootin 'out_color' num2str(st) '.png']));
[vres hres u] = size(I);

no_frames = endi - st + 1;

imgs = zeros(vres,hres/2,u,no_frames);
depths = zeros(vres,hres/2,1,no_frames);

k = 0;
for fr = st:endi,
    
    k = k + 1;
    
    I = double(imread([rootin 'out_color' num2str(fr) '.png']));
    imgs(:,:,:,k) = I(:,1:hres/2,:);
    depths(:,:,:,k) = I(:,hres/2+1:end,1);
    
end
    
    