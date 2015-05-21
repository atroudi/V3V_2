%% main

warning('off','all')

%%%% Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

change=0; % if there was any change in the Database , block_size, resize_factor or GIST.

Query_Paths= ['Data_Size_Seq/';];
Ref_Path=['Database/Run1         ';'Database/Run2         ';'Database/Run3         ';'Database/Run4         ';'Database/Run5         ';'Database/Run6         ';'Database/Run-game1    ';'Database/Run-game2    ';'Database/Run-game4    ';'Database/Run-game5    ';'Database/Run-game7    ';'Database/Run-game9    ';'Database/Run-game10   ';'Database/V1S4         ';'Database/V1S4-1       ';'Database/V1S4-2       ';'Database/V1S7         ';'Database/V1S7-1       ';'Database/V1S7-2       ';'Database/V1S8         ';'Database/V1S8-1       ';'Database/V1S8-2       ';'Database/V1S10        ';'Database/V1S10-1      ';'Database/V1S10-2      ';'Database/V1S15-1      ';'Database/V1S15-2      ';'Database/V1S16-1      ';'Database/V1S16-2      ';'Database/V1S18-1      ';'Database/V1S18-2      ';'Database/V2S6-1       ';'Database/V2S13-1      ';'Database/V2S23-1      ';'Database/V4S3-1       ';'Database/V4S5-1       ';'Database/V4S5-2       ';'Database/V4S9-1       ';'Database/V4S10-1      ';'Database/V4S10-2      '];
Output_Path=[Query_Paths,'Output/'];

poolobj=parpool(2);

addpath('KianaWarping4');

% Parameters
clear p
p.H_query=1080;%1058; % expected query resolution
p.W_query=960;
p.block_size=9 ;%9
p.color_weight=1; %% for block descriptor
p.alpha=60; %% gradient refinement
p.beta= 0.01; %% smoothness
p.k=1; %% KNN
p.resize_factor=1/4;
p.max_disp=10;
p.GIST_Size=512;
p.Max_images=110; % max number of images in each ref file
p.SIFT_size=32+3;

% Gist Parameters:
clear param
param.imageSize = [256 256];
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;



%%%% Save database SIFT and Gradients %%%%%%%%%%%%%%%%%%%%%%%%%%

if change
    
    
    Dataset_Gx= int8(nan(p.Max_images,size(Ref_Path,1),p.block_size*round(ceil(p.H_query*p.resize_factor)/p.block_size),p.block_size*round(ceil(p.W_query*p.resize_factor)/p.block_size)));
    Dataset_Gy= int8(nan(p.Max_images,size(Ref_Path,1),p.block_size*round(ceil(p.H_query*p.resize_factor)/p.block_size),p.block_size*round(ceil(p.W_query*p.resize_factor)/p.block_size))); 
    Dataset_SIFT= single(uint8(Inf(p.Max_images,p.SIFT_size,size(Ref_Path,1),round(ceil(p.H_query*p.resize_factor)/p.block_size)*round(ceil(p.W_query*p.resize_factor)/p.block_size))));
    
    for R_ref=1:size(Ref_Path,1)

        N_ref = dir([deblank(Ref_Path(R_ref,:)),'/*_int.txt']);   N_ref= char(N_ref.name);

        for n_ref=1:size(N_ref,1)

            fid=fopen([deblank(Ref_Path(R_ref,:)),'/',deblank(N_ref(n_ref,:))]);
            fseek(fid, 0,'eof');
            filelength = ftell(fid);
            fseek(fid, 0,'bof');
            
            if fid ~= -1 && filelength ~=0
          
                N_deblank = deblank(N_ref(n_ref,:));
                img = imresize(imread([deblank(Ref_Path(R_ref,:)),'/',N_deblank(1:end-8),'_d.png']),[p.H_query p.W_query]); 
                img = rgb2gray(imresize(img, p.resize_factor));
                img= imresize(img,[p.block_size*round(size(img,1)/p.block_size)   p.block_size*round(size(img,2)/p.block_size)]);
    
                img = double(img)/255;
                img = img - min(img(:));

                H = size(img,1);
                W = size(img,2);

                Gx_pre = img(1:H,2:W) - img(1:H,1:W-1);
                Gy_pre = img(2:H,1:W) - img(1:H-1,1:W);
                
                Gx=[Gx_pre zeros(H,1)];
                Gy=[Gy_pre; zeros(1,W)];
                
                Gx=Gx.*(1-1*exp(1-1./(p.alpha*abs(Gx)+eps))).* ((1-1*exp(1-1./(p.alpha*abs(Gx)+eps)))>0);
                Gy=Gy.*(1-1*exp(1-1./(p.alpha*abs(Gy)+eps))).* ((1-1*exp(1-1./(p.alpha*abs(Gy)+eps)))>0);

                Dataset_Gx(n_ref,R_ref,:,:) = int8(Gx*10000);
                Dataset_Gy(n_ref,R_ref,:,:) = int8(Gy*10000);
                 
                %%%%%%%%%%%%%%%%%%%%%%
                clear img
                img =imresize(imread([deblank(Ref_Path(R_ref,:)),'/',N_deblank(1:end-8),'.png']),[p.H_query p.W_query]);  
                img = imresize(img, p.resize_factor);
                
                img= imresize(img,[p.block_size*round(size(img,1)/p.block_size)   p.block_size*round(size(img,2)/p.block_size)]);
                img_padded= zeros(size(img,1)+4*p.block_size, size(img,2)+4*p.block_size);
                img_padded(2*p.block_size+1:size(img,1)+2*p.block_size, 2*p.block_size+1:size(img,2)+2*p.block_size)= rgb2gray(img);
                [SIFT_img, grid_x, grid_y] = sp_dense_sift(img_padded, p.block_size, 5*p.block_size);
                SIFT_img= round(SIFT_img*255);
                color_img= imresize(img, [size(grid_y,1) size(grid_x,2)]);
                Block_Discriptor = cat(2, reshape(SIFT_img,[],size(SIFT_img,3)), p.color_weight*reshape(color_img,[],3));
                Block_Discriptor= single(uint8(Block_Discriptor));
                Dataset_SIFT(n_ref,:,R_ref,:)= Block_Discriptor';
                
            end
            fclose(fid);
        end

    end
    
    save('Dataset_Gx.mat','Dataset_Gx');
    save('Dataset_Gy.mat','Dataset_Gy');
    save('Dataset_SIFT.mat','Dataset_SIFT');
end

%%%% Read database GIST %%%%%%%%%%%%%%%%%%%%%%%%%%
if change

Dataset_GIST=uint8(Inf(p.GIST_Size,p.Max_images,size(Ref_Path,1)));

for R_ref=1:size(Ref_Path,1)
    
    N_ref = dir([deblank(Ref_Path(R_ref,:)),'/*_int.txt']);   N_ref= char(N_ref.name);
      
    for n_ref=1:size(N_ref,1)
         
        fid=fopen([deblank(Ref_Path(R_ref,:)),'/',deblank(N_ref(n_ref,:))]);
        fseek(fid, 0,'eof');
        filelength = ftell(fid);
        fseek(fid, 0,'bof');
        
        if fid ~= -1 && filelength ~=0
           Dataset_GIST(1:p.GIST_Size,n_ref, R_ref)=uint8(fscanf(fid,'%u\n',p.GIST_Size));  
        end
        fclose(fid);
    end
      
end

save('Dataset_GIST.mat','Dataset_GIST')
end



%%%% Load database %%%%%%%%%%%%%%%%%%%%%%%%%%

 load('Dataset_GIST.mat','Dataset_GIST');
 load('Dataset_Gx.mat','Dataset_Gx');
 load('Dataset_Gy.mat','Dataset_Gy');
 load('Dataset_SIFT.mat','Dataset_SIFT');

 
Dataset_GIST= (uint8(Dataset_GIST));
Dataset_SIFT= (uint8(Dataset_SIFT));
Block_Discriptor_Dataset=(single(uint8(zeros(size(Dataset_SIFT,2),size(Dataset_SIFT,4),p.k))));
ind= (ones(1,size(Ref_Path,1)));

%%%% For Each Video %%%%%%%%%%%%%%%%%%%%%%%%

for Query_Path_idx=1:size(Query_Paths,1)
    
    clear Query_Path
    Query_Path=deblank(Query_Paths(Query_Path_idx,:));
    mkdir(Output_Path)
    delete([Output_Path,'*'])

    N_query = dir([Query_Path,'*.png']);   N_query= char(N_query.name);  Number_of_Frames_folder= size(N_query,1);
    
    frames_processed=0;
    
    I_original = imread([Query_Path, num2str(frames_processed+1), '.png']);
    [vres_original, hres_original, u] = size(I_original); 
    [Gx, Gy, xx, yy, YY] = GetGxGy(vres_original,hres_original/2,p.resize_factor);
    
    
    while frames_processed< Number_of_Frames_folder
        
        Number_of_Frames= min(Number_of_Frames_folder-frames_processed,250);% 10 sec
        
        % read all frames     
       Query_rgb_original_all= uint8(zeros(vres_original, hres_original, u,Number_of_Frames));
       
       
       for Query_no=1:Number_of_Frames
           Query_rgb_original_all(:,:,:,Query_no)= imread([Query_Path, num2str(frames_processed+Query_no),'.png']);
       end
           
       %{
        % reset gpu
        if mod(frames_processed, 750)==0
            reset(gpuDevice)
            load('Dataset_GIST.mat','Dataset_GIST');
            load('Dataset_SIFT.mat','Dataset_SIFT');
            Dataset_GIST= gpuArray(uint8(Dataset_GIST));
            Dataset_SIFT= gpuArray(uint8(Dataset_SIFT));
            Block_Discriptor_Dataset=gpuArray(single(uint8(zeros(size(Dataset_SIFT,2),size(Dataset_SIFT,4),p.k))));
            ind= gpuArray(ones(1,size(Ref_Path,1)));
            [Gx, Gy, xx, yy, YY] = GetGxGy(vres_original,hres_original/2,p.resize_factor);
            xx = gpuArray(xx);
            yy = gpuArray(yy);
            YY = gpuArray(YY);
        end
      %} 
tic    
    %%%% Cassification   %%%%%%%
    
    [CLASS, mask] = GetSceneClassification_WithoutCuts(Query_rgb_original_all, Query_Path,pwd,Number_of_Frames,p.resize_factor* (1/8),frames_processed);
%classify=toc 
    %%%% For Each Frame %%%%%%%%%%%%%%%%%%%%%%%
%tic 
    Query_fr= 1:Number_of_Frames;
    
    %Query_no_long_short= Query_fr(logical(CLASS==1 | CLASS==3));
    %Query_no_medium_short= Query_fr(logical(CLASS==2 | CLASS==3));
    Query_no_long= Query_fr(logical(CLASS==1));
    Query_no_medium= Query_fr(logical(CLASS==2));
    Query_no_short= Query_fr(logical(CLASS==3));
    
    %{
    %medium_ratio = Number_of_Frames/size(Query_no_medium,2);
    medium_ratio = Number_of_Frames/size(Query_no_medium_short,2);
    Frames = zeros(1,Number_of_Frames);
    mask_new= false(size(mask));
    CLASS_new=uint8(zeros(size(CLASS)));
    Query_rgb_original_all_new=uint8(zeros(size(Query_rgb_original_all)));
    
    i=1; j=1;
    
    for k=1:Number_of_Frames
        if (isnan(mod(k,medium_ratio)) || mod(k,medium_ratio) || j> length(Query_no_medium_short)) && i<= length(Query_no_long)
            Frames(k)= Query_no_long(i);
            mask_new(:,:,k)= mask(:,:,Query_no_long(i));
            CLASS_new(k)=CLASS(Query_no_long(i));
            Query_rgb_original_all_new(:,:,:,k)=Query_rgb_original_all(:,:,:,Query_no_long(i));
            i=i+1;
        else
            Frames(k)=Query_no_medium_short(j);
            mask_new(:,:,k)= mask(:,:,Query_no_medium_short(j));
            CLASS_new(k)=CLASS(Query_no_medium_short(j));
            Query_rgb_original_all_new(:,:,:,k)=Query_rgb_original_all(:,:,:,Query_no_medium_short(j));
            
            j=j+1;
        end
    end
    %}
%toc
%tic 
    parfor Query_no=1:Number_of_Frames
      
       
          Query_rgb_original=Query_rgb_original_all(:,:,:,Query_no);
          Query_rgb_original= imresize(Query_rgb_original,[size(Query_rgb_original,1) size(Query_rgb_original,2)/2]); % Half the Width
          
          
          if CLASS(Query_no)==1 %% Long    
              stereo= tilt(Query_rgb_original, p.max_disp);
          
          elseif CLASS(Query_no)==2 %% Medium     
              stereo= DGC(Query_rgb_original, mask(:,:,Query_no), param, p, Dataset_GIST,Ref_Path,ind,Gx, Gy, xx, yy, YY,Dataset_SIFT,Dataset_Gx,Dataset_Gy,Block_Discriptor_Dataset);
              
          elseif CLASS(Query_no)==3 %% Short
              %stereo= [Query_rgb_original Query_rgb_original]; % do nothing
              stereo= DGC(Query_rgb_original, mask(:,:,Query_no), param, p, Dataset_GIST,Ref_Path,ind,Gx, Gy, xx, yy, YY,Dataset_SIFT,Dataset_Gx,Dataset_Gy,Block_Discriptor_Dataset); 
          end
          
        
          stereo_all(:,:,:,Query_no)= stereo;
          
    end 
  %toc  
run_time=toc;
    
    % write results
    parfor Query_no=1:Number_of_Frames
           Stereo=stereo_all(:,:,:,Query_no);
           imwrite(uint8(Stereo), [Output_Path,num2str(frames_processed+Query_no),'.png'],'png');
    end
    
    clear stereo_all
    
    Class1_Frames=size(Query_no_long,2)
    Class2_Frames=size(Query_no_medium,2)
    Class3_Frames=size(Query_no_short,2)
    Runtime= run_time/ Number_of_Frames
    
    frames_processed=frames_processed+ Number_of_Frames;
    
   end
    
end
    
delete(poolobj)
%reset(gpuDevice)