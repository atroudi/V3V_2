function stereo_all = RunData(I,D,stereo_all,R,temp_wind,Thresh)

%rgb_rootin: RGB
%d_rootin: Depth
%ST: sequence start frame
%ENDI: sequence end frame
%R: resize factor...i.e. 0.25
%temp_wind: temporal smoothness window...if temp_wind = 2 , then images are
%I_1,I_2,I_3 
%I_3,I_4,I_5 
%I_5,I_6,I_7 
%Thresh: Disparity range...we always set to 20
%rootout: rootout directory for SidebySide SS


[vres hres u n] = size(I);
[vresd hresd ud nd] = size(D);



    NO_FRAMES = n; %% total number of frames in the sequence
    no_frames = temp_wind+1; %% per temporal window, for creating imgs and depths


    st_all = 1:temp_wind:NO_FRAMES-temp_wind;


    parfor FR = 1:length(st_all),

        st = st_all(FR);
        endi = st + temp_wind;
        
      if sum(sum(sum(sum(D(:,:,:,st:endi-1)))))
          
        imgs = zeros(vres,hres,u,no_frames);
        depths = zeros(vresd,hresd,1,no_frames);

        k = 0;
        for fr = st:endi,

            k = k + 1;

            imgs(:,:,:,k) = double(I(:,:,:,fr))/255;
            d = double(D(:,:,:,fr))/255;
            depths(:,:,:,k) = d(:,:,1);
        end

        SS = Warp_temp_test(imgs,depths,Thresh,R);
        
        SS_all(:,:,:,:,FR) = SS(:,:,:,1:temp_wind);

      end
    end
    

for FR = 1:length(st_all)
    
    st = st_all(FR);
    endi = st + temp_wind;
    
    for i= st:endi-1
     if sum(sum(sum(D(:,:,:,i))))
       stereo_all(1:vres,1:2*hres,1:3,i) = SS_all(:,:,:,i-st+1,FR);
     end
    end
end

%{
% Remove the last temp_wind black frames
for i= size(stereo_all,4)-temp_wind+1:size(stereo_all,4)
    stereo_all(1:vres,1:2*hres,1:3,i) = stereo_all(1:vres,1:2*hres,1:3,end-temp_wind); 
end
%}