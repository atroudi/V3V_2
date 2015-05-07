function CLASS = GetSceneClassification(rootin,root,Cuts)

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

Cuts(isnan(Cuts)) = 0;
Cuts = logical(Cuts);

green_longshot = 0.7;      %%%green_percentage threshold for long-shots
imfill_threshold = 0.05;   %%%imfill_gain thresold 
green_closeup = 0.4;       %%green_percentage thershold for closeups

%root = 'F:\SoccerFull\H1\TestX\';   %%rootin from TrainPitchModel.m
load([root '\LinePitchModel.mat']);
GMM_threshold = -20;

ALLFR = 1:numel(Cuts);
CutStFR = ALLFR(Cuts);

CLASS = nan(1,numel(ALLFR));

I = double(imread([rootin num2str(ALLFR(1)) '.png']));
[vres hres u] = size(I);
num_pels = vres*hres;

K = -1; 

for fr = CutStFR,
    
    K = K + 1;
    if(K == 0)
        st = 1;
    else
        st = CutStFR(K)+1;
    end
    
    endi = fr;
    
    imfill_sum = 0;
    green_sum = 0;
    
    for f = st:endi,
        
        
        I = double(imread([rootin num2str(f) '.png']));
        
        I_r = I(:,:,1);
        I_g = I(:,:,2);
        I_b = I(:,:,3);
        
        ll = GMClassLikelihood(optmixture, [I_r(:) I_g(:) I_b(:)]);
        
        
        pitchall = reshape(ll,[vres hres]);
        pitchall = pitchall>GMM_threshold;
        
        str = strel('disk',2);
        pitchall = imdilate(pitchall,str);
        pitchall = imerode(pitchall,str);
        
        
        imwrite(not(pitchall),[root num2str(f) '.png']);
        pitchall(end,:) = 1;
        
        filled = imfill(pitchall,'holes');
        
        before = numel(pitchall(pitchall));
        after = numel(filled(filled));
        
        imfill_sum = imfill_sum + (after - before);
        green_sum = green_sum + numel(pitchall(pitchall));
        
        
    end
    
    
    imfill_per = imfill_sum/(num_pels*numel(st:endi));
    green_per = green_sum/(num_pels*numel(st:endi));
    
    
    if(and(imfill_per<imfill_threshold,green_per<green_longshot))
        CLASS(st:endi) = 1; %%Longshot
    elseif(green_per<green_closeup)
        CLASS(st:endi) = 3;  %%Closeup
    else
        CLASS(st:endi) = 2; %%Medium
    end
    
    
end