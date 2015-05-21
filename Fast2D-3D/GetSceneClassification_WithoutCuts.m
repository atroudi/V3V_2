function [CLASS, masks] = GetSceneClassification_WithoutCuts(Query_rgb_original, rootin,root,no_frames,resize_factor,frames_processed)

%%A function to classify scenes 

%%input
%-------
%rootin: sequence directory
%root: rootin of TrainPitchModel.m ......where Trained Model is 
%Cuts: from GetSceneCuts

%%rootout
%--------
%CLASS: size 1xnum_frames.........1 --> longshot 2-->medium 3-->close-up
%Player detection is saved in root for each image


green_longshot = 0.7;      %%%green_percentage threshold for long-shots
imfill_threshold = 0.05;   %%%imfill_gain thresold 
green_closeup = 0.4;       %%green_percentage thershold for closeups

%root = 'F:\SoccerFull\H1\TestX\';   %%rootin from TrainPitchModel.m
%global optmixture;

optmixture_all=load([root '/LinePitchModel.mat']);
optmixture=optmixture_all.optmixture;

GMM_threshold = -20;

CLASS = uint8(nan(1,numel(no_frames)));


vres= ceil(size(Query_rgb_original,1)*resize_factor);
hres= ceil(size(Query_rgb_original,2)*resize_factor);
num_pels = vres*hres;

masks= false(vres, hres, no_frames);


parfor fr =1:no_frames
  
    imfill_sum = 0;
    green_sum = 0;
  
    I = Query_rgb_original(:,:,:,fr);
    I = double(imresize(I,resize_factor));
    
    I_r = I(:,:,1);
    I_g = I(:,:,2);
    I_b = I(:,:,3);
        
    ll = GMClassLikelihood(optmixture, [I_r(:) I_g(:) I_b(:)]);
        
        
    pitchall = reshape(ll,[vres hres]);
    pitchall = pitchall>GMM_threshold;
        
    str = strel('disk',2);
    pitchall = imdilate(pitchall,str);
    pitchall = imerode(pitchall,str);
        
     
    masks(:,:,fr)= not(pitchall);
    
    %imwrite(not(pitchall),[root,'/mask/', num2str(fr) '.png']);
        
        
    pitchall(end,:) = 1;
        
    filled = imfill(pitchall,'holes');
        
    before = numel(pitchall(pitchall));
    after = numel(filled(filled));
        
    imfill_sum = imfill_sum + (after - before);
    green_sum = green_sum + numel(pitchall(pitchall));
        
    
    imfill_per = imfill_sum/(num_pels);
    green_per = green_sum/(num_pels);
    
    
    if(and(imfill_per<imfill_threshold,green_per>green_longshot))
        CLASS(fr) = 1; %%Longshot
        
    elseif(green_per<green_closeup)
        CLASS(fr) = 3;  %%Closeup
        
    else
        CLASS(fr) = 2; %%Medium
    end
    
    
end