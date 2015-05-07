%% main

warning('off','all')

%%%% Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Query_Paths= ['Data_Size_Seq/';];
Ref_Path=['Database/Run1         ';'Database/Run2         ';'Database/Run3         ';'Database/Run4         ';'Database/Run5         ';'Database/Run6         ';'Database/Run-game1    ';'Database/Run-game2    ';'Database/Run-game4    ';'Database/Run-game5    ';'Database/Run-game7    ';'Database/Run-game9    ';'Database/Run-game10   ';'Database/V1S4         ';'Database/V1S4-1       ';'Database/V1S4-2       ';'Database/V1S7         ';'Database/V1S7-1       ';'Database/V1S7-2       ';'Database/V1S8         ';'Database/V1S8-1       ';'Database/V1S8-2       ';'Database/V1S10        ';'Database/V1S10-1      ';'Database/V1S10-2      ';'Database/V1S15-1      ';'Database/V1S15-2      ';'Database/V1S16-1      ';'Database/V1S16-2      ';'Database/V1S18-1      ';'Database/V1S18-2      ';'Database/V2S6-1       ';'Database/V2S13-1      ';'Database/V2S23-1      ';'Database/V4S3-1       ';'Database/V4S5-1       ';'Database/V4S5-2       ';'Database/V4S9-1       ';'Database/V4S10-1      ';'Database/V4S10-2      '];

addpath('KianaWarping2');
% Parameters
clear p
p.block_size=9 ;%9
p.color_weight=1; %% for block descriptor
p.alpha=60; %% gradient refinement
p.beta= 0.01; %% smoothness
p.k=1; %% KNN
p.resize_factor=1/4;
p.max_disp=20;
p.GIST_Size=512;
p.Max_images=110; % max number of images in each ref file
poolobj=parpool(4);

% Gist Parameters:
clear param
param.imageSize = [256 256];
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;


%%%% Load database %%%%%%%%%%%%%%%%%%%%%%%%%%

Dataset_GIST=Inf(p.Max_images,p.GIST_Size,size(Ref_Path,1));

for R_ref=1:size(Ref_Path,1)
    
    N_ref = dir([deblank(Ref_Path(R_ref,:)),'/*_int.txt']);   N_ref= char(N_ref.name);
      
    for n_ref=1:size(N_ref,1)
         
        fid=fopen([deblank(Ref_Path(R_ref,:)),'/',deblank(N_ref(n_ref,:))]);
        fseek(fid, 0,'eof');
        filelength = ftell(fid);
        fseek(fid, 0,'bof');
        
        if fid ~= -1 && filelength ~=0
           Dataset_GIST(n_ref,1:p.GIST_Size, R_ref)=single(uint8(fscanf(fid,'%u\n',p.GIST_Size)));  
        end
        fclose(fid);
    end
      
end
Dataset_GIST= gpuArray(Dataset_GIST(:,1:p.GIST_Size,:));   
ind= gpuArray(zeros(size(Ref_Path,1),1));
temp= gpuArray(ones(size(Dataset_GIST,1),1));

%%%% For Each Video %%%%%%%%%%%%%%%%%%%%%%%%

for Query_Path_idx=1:size(Query_Paths,1)
    
    clear Query_Path
    Query_Path=deblank(Query_Paths(Query_Path_idx,:));
    mkdir(Query_Path,'Output')
    mkdir('mask')
    delete([Query_Path,'Output/*'])
    delete('mask/*')

    N_query = dir([Query_Path,'*.png']);   N_query= char(N_query.name);  Number_of_Frames= size(N_query,1);
   
    %%%% Scene Cut and Cassification   %%%%%%%
    tic
    %Cuts = GetSceneCuts(Query_Path,1:Number_of_Frames,p.resize_factor);
    %Cuts= ones(1,Number_of_Frames);
    %toc
    CLASS = GetSceneClassification_WithoutCuts(Query_Path,pwd,Number_of_Frames,p.resize_factor* (1/8));
    toc

    %%%% For Each Frame %%%%%%%%%%%%%%%%%%%%%%%%
    Query_fr= 1:Number_of_Frames;
    
    Query_no_long= Query_fr(logical(CLASS==1));
    Query_no_medium= Query_fr(logical(CLASS==2));
    Query_no_short= Query_fr(logical(CLASS==3));
    
    %%% long 
    clear Query_no
    
    parfor Query_no=1:size(Query_no_long,2)
      
      fid_b=fopen([Query_Path, num2str(Query_no_long(Query_no)),'.png']);

      if fid_b ~= -1

          fclose(fid_b);
          Query_rgb_original= imread([Query_Path, num2str(Query_no_long(Query_no)),'.png']);
          Query_rgb_original= imresize(Query_rgb_original,[size(Query_rgb_original,1) size(Query_rgb_original,2)/2]); % Half the Width
          
          stereo= tilt(Query_rgb_original, p.max_disp);
          imwrite(uint8(stereo), [Query_Path,'Output/',num2str(Query_no_long(Query_no)),'.png'],'png');
      end
    end
    Class1_Frames=size(Query_no_long,2)
    toc
    
    %%% medium
    clear Query_no
    
    parfor Query_no=1:size(Query_no_medium,2)
      
      fid_b=fopen([Query_Path, num2str(Query_no_medium(Query_no)),'.png']);

      if fid_b ~= -1

          fclose(fid_b);
          Query_rgb_original= imread([Query_Path, num2str(Query_no_medium(Query_no)),'.png']);
          Query_rgb_original= imresize(Query_rgb_original,[size(Query_rgb_original,1) size(Query_rgb_original,2)/2]); % Half the Width
          mask=imread(['mask/', num2str(Query_no_medium(Query_no)),'.png']);
          Query_txt_name=[num2str(Query_no_medium(Query_no)),'.png'];
          
          stereo= DGC(Query_rgb_original, mask, param, p, Dataset_GIST, Query_txt_name,Ref_Path,Query_Path,ind,temp);
          %imwrite(uint8(stereo), [Query_Path,'Output/',num2str(Query_no_medium(Query_no)),'.png'],'png');
      
      end
    end
    
    Class2_Frames=size(Query_no_medium,2)
    toc
    
    %%% short
    clear Query_no
    
    parfor Query_no=1:size(Query_no_short,2)
      
      fid_b=fopen([Query_Path, num2str(Query_no_short(Query_no)),'.png']);

      if fid_b ~= -1

          fclose(fid_b);
          Query_rgb_original= imread([Query_Path, num2str(Query_no_short(Query_no)),'.png']);
          Query_rgb_original= imresize(Query_rgb_original,[size(Query_rgb_original,1) size(Query_rgb_original,2)/2]); % Half the Width
          
          stereo= [Query_rgb_original Query_rgb_original]; % do nothing
          %imwrite(uint8(stereo), [Query_Path,'Output/',num2str(Query_no_short(Query_no)),'.png'],'png');
      end
    end  
    Class3_Frames=size(Query_no_short,2)
    toc
    
end

delete(poolobj)
