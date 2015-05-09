
function stereo= DGC(Query_rgb_original, mask, param, p, Dataset_GIST, Query_txt_name,Ref_Path,Query_Path, I,temp,Gx, Gy, xx, yy, YY)


%%%% Setup %%%%%%%%%%%%%%%%%%%%%%%%%

%{
Query_Paths= ['Query/';];
Ref_Path=['/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run1         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run2         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run3         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run4         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run5         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run6         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run-game1    ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run-game2    ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run-game4    ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run-game5    ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run-game7    ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run-game9    ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/Run-game10   ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S4         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S4-1       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S4-2       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S7         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S7-1       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S7-2       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S8         ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S8-1       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S8-2       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S10        ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S10-1      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S10-2      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S15-1      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S15-2      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S16-1      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S16-2      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S18-1      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V1S18-2      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V2S6-1       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V2S13-1      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V2S23-1      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V4S3-1       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V4S5-1       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V4S5-2       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V4S9-1       ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V4S10-1      ';'/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/V4S10-2      '];

% Parameters
block_size=9 ;%9
color_weight=50; %% for block descriptor
alpha=60; %% gradient refinement
beta= 0.01; %% smoothness
k=1; %% KNN
resize_factor=1/4;
%}

% Gist Parameters:
%{
clear param
param.imageSize = [256 256];
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;
GIST_Size=512;
Max_images=110; % max number of images in each ref file
%}

% Parameters
block_size=p.block_size;
color_weight=p.color_weight;
alpha=p.alpha;
beta= p.beta;
k=p.k;
resize_factor=p.resize_factor;
GIST_Size=p.GIST_Size;
Max_images=p.Max_images;
max_disp=p.max_disp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Load database
%{
Dataset_GIST=Inf(Max_images,GIST_Size,size(Ref_Path,1));

for R_ref=1:size(Ref_Path,1)
    
    N_ref = dir([deblank(Ref_Path(R_ref,:)),'/*_int.txt']);   N_ref= char(N_ref.name);
      
    for n_ref=1:size(N_ref,1)
         
        fid=fopen([deblank(Ref_Path(R_ref,:)),'/',deblank(N_ref(n_ref,:))]);
        fseek(fid, 0,'eof');
        filelength = ftell(fid);
        fseek(fid, 0,'bof');
        
        if fid ~= -1 && filelength ~=0
           Dataset_GIST(n_ref,1:GIST_Size, R_ref)=single(uint8(fscanf(fid,'%u\n',GIST_Size)));  
        end
        fclose(fid);
    end
      
end
      
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tic

% Query Path

%for Query_Path_idx=1:size(Query_Paths,1)
    
    %clear Query_Path
    
    %Query_Path=deblank(Query_Paths(Query_Path_idx,:));
    %Mask_Path=[Query_Path,'mask/'];
    
    %mkdir(Query_Path,'Output')
    %delete([Query_Path,'Output/*'])

    %N_query = dir([Query_Path,'*.png']);   N_query= char(N_query.name);     
 


%%%%% For Each Frame %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for Query_no= 1:size(N_query,1)

    %Query_txt_name=deblank(N_query(Query_no,:));

    %fid_b=fopen([Query_Path, num2str(str2double(Query_txt_name(1:end-4))),'.png']);

    %if fid_b ~= -1

     %fclose(fid_b);

    %Query_rgb_original= imread([Query_Path, Query_txt_name(1:end-4),'.png']);

    H_original= size(Query_rgb_original,1);
    W_original= size(Query_rgb_original,2);
    
    Query_rgb=imresize(Query_rgb_original,resize_factor); 
    
    H= size(Query_rgb,1);
    W= size(Query_rgb,2);

    Query_rgb= imresize(Query_rgb,[block_size*round(H/block_size)   block_size*round(W/block_size)]);
    Query= rgb2gray(Query_rgb);
    Query_depth= NaN(size(Query));

    %boundary_query= imread([Mask_Path, num2str(str2double(Query_txt_name(1:end-4))),'.png']);
    boundary_query=mask;
    boundary_query= imresize(boundary_query==max(boundary_query(:)), [size(Query_rgb,1) size(Query_rgb,2)]);

    %%%%%% Visual Search (KNN)
    
    [gist, param1] = LMgist(Query_rgb, '', param);% gist size= 512
    %color_hist = rgbhist(Query_rgb,[6 1 1]);
    %ImageDescriptor=[gist color_hist'];


    ImageDescriptor= single(uint8(round(gist*255)));
    ImageDescriptor= gpuArray(ImageDescriptor(1:GIST_Size));
    
    %Dataset_GIST= gpuArray(Dataset_GIST(:,1:GIST_Size,:));
    
    %I= gpuArray(zeros(size(Ref_Path,1),1));
    %temp= gpuArray(ones(size(Dataset_GIST,1),1));
    
    for R_ref=1:size(I)
      [C,I(R_ref)]=min(sum((Dataset_GIST(:,:,R_ref)- temp*ImageDescriptor).^2,2));
    end
    
    [B,IDX]=sort(I);
    
    I=gather(I);
    IDX=gather(IDX);
    
    Ref_rgb_Dataset= zeros(size(Query,1), size(Query,2),3,k); 
    Ref_depth_Dataset= zeros(size(Query,1), size(Query,2),k); 
    
    i=1;
    while i<=k
        N_ref = dir([deblank(Ref_Path(IDX(i),:)),'/*_int.txt']);   
        N_ref= char(N_ref.name); N_deblank=deblank(N_ref);
        
        fid1= fopen([deblank(Ref_Path(IDX(i),:)),'/',N_deblank(I(IDX(i)),1:end-8),'.png']); 
        fid2= fopen([deblank(Ref_Path(IDX(i),:)),'/',N_deblank(I(IDX(i)),1:end-8),'_d.png']);
        
        
        if fid1~=-1 && fid2~=-1
  
          Ref_rgb_Dataset(:,:,:,i)= imresize(imread([deblank(Ref_Path(IDX(i),:)),'/',N_deblank(I(IDX(i)),1:end-8),'.png']),[size(Query,1) size(Query,2)]); 
          Ref_depth_Dataset(:,:,i)= imresize(rgb2gray(imread([deblank(Ref_Path(IDX(i),:)),'/',N_deblank(I(IDX(i)),1:end-8),'_d.png'])),[size(Query,1) size(Query,2)]);
          
          if sum(sum(Ref_depth_Dataset(:,:,i)>50))
              i=i+1;
          end
          
        end
          
      fclose('all');
    end
  
  
    
    %%%%%% Block Discriptor for Query

    H= size(Query,1);
    W= size(Query,2);

    Query_padded= zeros(H+4*block_size, W+4*block_size);
    Query_padded(2*block_size+1:H+2*block_size, 2*block_size+1:W+2*block_size)=Query;

    [SIFT_Query, grid_x, grid_y] = sp_dense_sift(Query_padded, block_size, 5*block_size);
    SIFT_Query= round(SIFT_Query*255);
    
    %{
    % grid 
    grid_x = (5*block_size)/2:block_size:size(Query_padded,2)-(5*block_size)/2+1;
    grid_y = (5*block_size)/2:block_size:size(Query_padded,1)-(5*block_size)/2+1;
    [grid_x,grid_y]= meshgrid(grid_x, grid_y);
    points= [grid_x(:) grid_y(:)];
    %}
    
    %[SURF_Query,validPoints] = extractFeatures(Query_padded,points,'Method','SURF', 'BlockSize',5*block_size);
    %[SURF_Query,validPoints] = extractHOGFeatures(Query_padded,points,'BlockSize',[1 1], 'CellSize',[5*block_size 5*block_size]);
    
    color_Query= imresize(Query_rgb, [size(grid_y,1) size(grid_x,2)]);
    Block_Discriptor_Query = cat(2, reshape(SIFT_Query,[],size(SIFT_Query,3)), color_weight*reshape(color_Query,[],3));
    Block_Discriptor_Query= single(uint8(Block_Discriptor_Query));
    
     %%%% Block Discriptor for Refs

     Ref_rgb_Dataset=imresize(Ref_rgb_Dataset, [size(Query,1) size(Query,2)]);
     Ref_depth_Dataset=imresize(Ref_depth_Dataset, [size(Query,1) size(Query,2)]);
     Block_Discriptor_Dataset=zeros(size(Block_Discriptor_Query,1), size(Block_Discriptor_Query,2), k);
      
      for Ref_no= 1:k 
             
            Ref_rgb=Ref_rgb_Dataset(:,:,:,Ref_no);
            Ref_depth=Ref_depth_Dataset(:,:,Ref_no);

            Ref=rgb2gray(Ref_rgb);

            H= size(Ref,1);
            W= size(Ref,2);
            
            Ref_padded= zeros(H+4*block_size, W+4*block_size);
            Ref_padded(2*block_size+1:H+2*block_size, 2*block_size+1:W+2*block_size)=Ref;
    
            [SIFT_Ref, grid_x, grid_y] = sp_dense_sift(Ref_padded, block_size, 5*block_size);
            SIFT_Ref= round(SIFT_Ref*255);

            %[SURF_Ref,validPoints] = extractFeatures(Ref_padded,points,'Method','SURF', 'BlockSize',5*block_size);
            %[SURF_Ref,validPoints] = extractHOGFeatures(Ref_padded,points,'BlockSize',[1 1], 'CellSize',[5*block_size 5*block_size]);
            
            color_Ref=imresize(Ref_rgb, [size(grid_y,1) size(grid_x,2)]);
            Block_Discriptor_Ref = cat(2, reshape(SIFT_Ref,[],size(SIFT_Ref,3)),color_weight*reshape(color_Ref,[],3)); 
            Block_Discriptor_Ref= single(uint8(Block_Discriptor_Ref));
    
       
            Block_Discriptor_Dataset(:,:,Ref_no)= Block_Discriptor_Ref;
   
     end    
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_Query_matched_rgb, Depth_Query]= Matching (Query,Query_rgb, Block_Discriptor_Query,Block_Discriptor_Dataset, Ref_depth_Dataset, Ref_rgb_Dataset, boundary_query, block_size, alpha, beta, Query_txt_name, Query_Path,grid_x);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Final Depth %%%%%%%%%%%%%%%%%%%%%%%%

%Query=imresize(Query,[H_original W_original]);
%Query_rgb_original= imresize(Query_rgb_original,[H_original W_original]);
%I_Query_matched_rgb=imresize(I_Query_matched_rgb,[H_original W_original]);
%Depth_Query=imresize(Depth_Query,[H_original W_original]);

%Depth_Query_rgb= zeros(H_original, W_original,3);
%Depth_Query_rgb(:,:,1)=Depth_Query;
%Depth_Query_rgb(:,:,2)=Depth_Query;
%Depth_Query_rgb(:,:,3)=Depth_Query;

%figure; imshow(uint8([I_Query_matched_rgb  Depth_Query_rgb]))
%figure; imshow(uint8([Query_rgb  Depth_Query_rgb]))

%imwrite(uint8([Query_rgb_original   Depth_Query_rgb]), [Query_Path,'Output/out_color',Query_txt_name(1:end-4),'.png'],'png');
%imwrite(uint8([I_Query_matched_rgb   Depth_Query_rgb]), [Query_Path,'Output/match_color',Query_txt_name(1:end-4),'.png'],'png');

%stereo= uint8([Query_rgb_original   Depth_Query_rgb]);
tic
stereo = 255*WarpFinal(im2double(Query_rgb_original),im2double(Depth_Query),max_disp,resize_factor,Gx, Gy, xx, yy, YY);
toc
%stereo=Depth_Query;

    %end
%end
%end
%toc