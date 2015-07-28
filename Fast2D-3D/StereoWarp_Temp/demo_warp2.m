%Load data
rootinI = 'D:\\Users\\melgharib\\Downloads\\pami2013_MoSeg\\moseg\\TrainingSet\\Data\\sports6\\sports6_%03d.jpg';
rootinD = 'D:\\Users\\melgharib\\Downloads\\pami2013_MoSeg\\moseg\\TrainingSet\\Data\\sports6\\testyy\\%01d.png';
st = 19;
endi = 20;

ST = [1:3:300];

for k = 1:100,
    st = ST(k);
    endi = st+1;
    
    num_frames = endi - st + 1;
    imgs = cell(1,1,1,num_frames);
    depths = cell(1,1,1,num_frames);
    for fr=st:endi
        imgs{fr-st+1} = im2double(imread(sprintf(rootinI,fr)));
        d = im2double(imread(sprintf(rootinD,fr)));
        depths{fr-st+1} = d(:,:,1);
    end
    
    %Compute forward optical flow: flows are 2-channel images, i.e. flow(:,:,1) is horizontal, flow(:,:,2) is vertical
    flows = cell(size(imgs));
    for i=1:numel(imgs)-1
        flows{i} = opticalflow(imgs{i}, imgs{i+1});
    end
    flows{end} = zeros(size(flows{1})); %Don't know flow for last frame
    
    %Convert to 4D arrays (as stereoWarp.m expects)
    imgs = cell2mat(imgs);
    depths = cell2mat(depths);
    flows = cell2mat(flows);
    
    %Run stereoWarp
    [lefts, rights, anaglyphs disparity] = stereoWarp(imgs, depths, flows, 20);
    
    %Save results
    if(~exist('results','dir')); mkdir('results'); end
    for i=1:num_frames,
        imwrite(lefts(:,:,:,i), fullfile('results',sprintf('left%d.png',i+st-1)));
        imwrite(rights(:,:,:,i), fullfile('results',sprintf('right%d.png',i+st-1)));
        imwrite(anaglyphs(:,:,:,i), fullfile('results',sprintf('anaglyph%d.png',i+st-1)));
        imwrite(disparity(:,:,:,i)/20, fullfile('results',sprintf('disparity%d.png',i)));
    end
    save(fullfile('results',sprintf('disparity%d.mat',i)),'disparity');
    
    
end
