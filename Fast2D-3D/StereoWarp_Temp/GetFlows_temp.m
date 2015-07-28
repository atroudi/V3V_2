function flows = GetFlows_temp(RAW,R)

imgs = imresize(RAW,R);
[vres hres u no_frames] = size(imgs);

%Compute forward optical flow: flows are 2-channel images, i.e. flow(:,:,1) is horizontal, flow(:,:,2) is vertical
flows = zeros(vres,hres,2,no_frames);
for i=1:no_frames-1
    flows(:,:,:,i) = opticalflow(imgs(:,:,:,i), imgs(:,:,:,i+1));
end

