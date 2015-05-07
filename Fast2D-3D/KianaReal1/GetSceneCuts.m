function Cuts = GetSceneCuts(rootin,FR)

%A function to segment a sequence into scenes

%%input
%-------
%rootin: sequence directory
%FR: frame indices to be processed (need to be sequential)

%%rootout
%--------
%Cuts: size 1xnum_frames.........n has value 1 if
%Diff(n,n+n1)>cut_threshold....otherwise 0

cut_threshold = 40;           %%Diff>cut_threshold --> cut 

Cuts = nan(1,numel(FR));

for fr = 1:FR(end)-1,
        
    I1 = double(imread([rootin num2str(fr) '.png']));
    I2 = double(imread([rootin num2str(fr+1) '.png']));
   
    I1 = 0.1*I1(:,:,1) + 0.7*I1(:,:,2) + 0.2*I1(:,:,3);
    I2 = 0.1*I2(:,:,1) + 0.7*I2(:,:,2) + 0.2*I2(:,:,3);
    
    Diff = mean(mean(abs(I1 - I2)));
    
    Cuts(fr) = Diff > cut_threshold;

end