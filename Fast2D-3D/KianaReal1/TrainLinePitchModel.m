function TrainLinePitchModel(rootin,FR)

%A function to train a color model based on few labelled regions

%inputs:
%------
%rootin: Directory containing sample frames and their ground-truth masks ...i.e. 5.png and M5.png
%FR = test frames indices

%rootout
%--------
%\LinePitchModel.mat saved in rootin

data = [];
for fr = FR,
    
    M = double(imread([rootin 'M' num2str(fr) '.png']));
    I = double(imread([rootin num2str(fr) '.png']));
    
    I_r = I(:,:,1);
    I_g = I(:,:,2);
    I_b = I(:,:,3);

    
    [vres hres u] = size(I);
    
    m = abs(I_g - M(:,:,2))>0.001;
    
%     figure,imshow(m)
%     figure,imshow(I/255)
    
    data = [data; I_r(m) I_g(m) I_b(m)];
    
end


[mixture, optmixture] = GaussianMixture(data, 5, 0, 'false');

save([rootin '\LinePitchModel.mat'],'optmixture');









