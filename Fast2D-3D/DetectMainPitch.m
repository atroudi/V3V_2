function optmixture= DetectMainPitch(frames,optmixture,R,bandWidth,thr_size,thr_imodel)

%%recall this function is exepnsive because it has color segmentation.
%%Hence we should only run it for few frames at the start of the video,
%%update the model and exit

%rootin: test images
%rootinData: pitch model directory: imodel.mat is the initial model,
%st: start frame
%endi: end frame
%STP: frame processing step
%model.mat is the updated one (if found)
%R: resize factor
%FR: frames to be processed
%bandwidth: Meanshift clustering bandwidth for color segmentation
%thr_size: min. size of the dominant color (in pels)
%thr_imodel: max difference in likelihood from initial color model

%load([rootinData 'iModel.mat']); %reading the initial color model

frames= double(frames);

for fr = 1:size(frames,4),
    
    I = frames(:,:,:,fr);
    
    I = imresize(I,R);
    I_r = I(:,:,1);
    I_g = I(:,:,2);
    I_b = I(:,:,3);
    
    dataPts(:,1) = I_r(:);
    dataPts(:,2) = I_g(:);
    dataPts(:,3) = I_b(:);
    
    %     bandWidth = 25;
    %     T2 = -150; %-100
    [clustCent,data2cluster,cluster2dataCell] = MeanShiftCluster(dataPts',bandWidth,0);
    
    no_clusters = max(data2cluster);
    X = [];
    for c = 1:no_clusters,
        
        X = [X; numel(data2cluster(data2cluster==c))];
        
    end
    
    X = X/numel(I_r);
    
    [max_X max_i] = max(X);
    [sorted sorted_i] = sort(X,'descend');
    
    
    main_color = clustCent(:,sorted_i(1));
    
    main_color_size = max_X; %%how big is the dominante color
    
    image_pels = 1:numel(I_r);
    main_pels = image_pels(data2cluster == sorted_i(1));
    
    
    X_r = I_r(main_pels);
    X_g = I_g(main_pels);
    X_b = I_b(main_pels);
    
    ll = GMClassLikelihood(optmixture, [X_r' X_g' X_b']); %%calculate error from model
    main_color_error = mean(ll); %% how far from the initial color model
    
    if(and (main_color_size > thr_size, main_color_error > thr_imodel) )
        %%estimate & update the model
        
        m = zeros(size(I,1),size(I,2));
        m(main_pels) = 1;
        str = strel('disk',4); % to avoid object borders where mixture of colors occur, also to reduce effect of errornus segmetend regions
        m = logical(imerode(m,str));
        data = [I_r(m) I_g(m) I_b(m)];
        [mixture, optmixture] = GaussianMixture(data, 5, 0, 'false');
        
        %save('/LinePitchModel.mat','optmixture');
        disp('LinePitchModel changed');
        
        %ll2 = GMClassLikelihood(optmixture, [X_r' X_g' X_b']); %%calculate error from model
        %error_reduction = -1*( mean(ll2) - mean(ll) )/mean(ll) %The bigger, the better
        break; %%found the model, exit the loop
    end
    
    
end

end
