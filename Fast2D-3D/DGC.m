
function stereo= DGC(Query_rgb_original, mask, param, p, Dataset_GIST,Ref_Path,I, Gx, Gy, xx, yy, YY,Dataset_SIFT,Dataset_Gx,Dataset_Gy,Block_Discriptor_Dataset)


% Parameters
H_query=p.H_query;
W_query=p.W_query;
block_size=p.block_size;
color_weight=p.color_weight;
alpha=p.alpha;
beta= p.beta;
k=p.k;
resize_factor=p.resize_factor;
GIST_Size=p.GIST_Size;
Max_images=p.Max_images;
max_disp=p.max_disp;
SIFT_size=p.SIFT_size;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    Query_rgb = imresize(Query_rgb_original,[H_query W_query]);
    
    Query_rgb = imresize(Query_rgb,resize_factor);  
    Query_rgb = imresize(Query_rgb,[block_size*round(size(Query_rgb,1)/block_size)   block_size*round(size(Query_rgb,2)/block_size)]);

    Query = rgb2gray(Query_rgb);

    boundary_query= imresize(mask~=0, [size(Query_rgb,1) size(Query_rgb,2)]);

 %tic 
    %%%%%% Block Discriptor for Query

    H= size(Query,1);
    W= size(Query,2);

    Query_padded= zeros(H+4*block_size, W+4*block_size);
    Query_padded(2*block_size+1:H+2*block_size, 2*block_size+1:W+2*block_size)=Query;

    [SIFT_Query, grid_x, grid_y] = sp_dense_sift(Query_padded, block_size, 5*block_size);
    
    SIFT_Query= round(SIFT_Query*255);
    color_Query= imresize(Query_rgb, [size(grid_y,1) size(grid_x,2)]);
    Block_Discriptor_Query = cat(2, reshape(SIFT_Query,[],size(SIFT_Query,3)), color_weight*reshape(color_Query,[],3));
    Block_Discriptor_Query= (single(Block_Discriptor_Query));
    
%SIFT=toc
    %%%%%% Search (KNN + Block matching)
%tic   
    [gist, param1] = LMgist(Query_rgb, '', param);% gist size= 512

    Dataset_GIST= reshape(Dataset_GIST,size(Dataset_GIST,1),[]);

    ImageDescriptor= round(gist*255);
    
    ImageDescriptor= uint8((ImageDescriptor(1:GIST_Size)' * ones(1,size(Dataset_GIST,2))));%
    
    Difference= sum((Dataset_GIST - ImageDescriptor).^2,1);%
    
    Difference= reshape(Difference,[],size(Ref_Path,1));%
    
    [C,I]=min(Difference,[],1);%
  
    [B,IDX]=sort(C);%

    
   KNN_Gx= int8(nan(size(Dataset_Gx,3),size(Dataset_Gx,4),k));
   KNN_Gy= int8(nan(size(Dataset_Gy,3),size(Dataset_Gy,4),k));
   Gx_Query= int8(nan(size(Dataset_Gx,3),size(Dataset_Gx,4)));
   Gy_Query= int8(nan(size(Dataset_Gy,3),size(Dataset_Gy,4)));
   
     
    i=1;
    j=1;
                                    
    while j<=k && i<=length(IDX)
        
      Block_Discriptor_Dataset(:,:,j)=Dataset_SIFT(I(IDX(i)),:,IDX(i),:);%
      KNN_Gx(:,:,j)= Dataset_Gx(I(IDX(i)),IDX(i),:,:) ;
      KNN_Gy(:,:,j)= Dataset_Gy(I(IDX(i)),IDX(i),:,:) ;
      if sum(sum(Dataset_Gx(I(IDX(i)),IDX(i),:,:))) && sum(sum(Dataset_Gy(I(IDX(i)),IDX(i),:,:)))
       j=j+1;
      end
       i=i+1;
    end
    
    Block_Discriptor_Dataset= reshape(Block_Discriptor_Dataset,size(Block_Discriptor_Dataset,1),[]);%
 %%%%%%%%%%%%%%%%% 
 %{
    cell_Discriptor_Query=cell(size(Block_Discriptor_Query,1),1);
    cell_Discriptor_Dataset=cell(1,size(Block_Discriptor_Query,2));
    
    for j=1:size(Block_Discriptor_Query,1)
        cell_Discriptor_Query{j}= Block_Discriptor_Query(j,:);     
    end
    
    for j=1:size(Block_Discriptor_Dataset,2)
        cell_Discriptor_Dataset{j}= Block_Discriptor_Dataset(j,:);     
    end
    
    error= arrayfun(@B_match1,cell_Discriptor_Query);
    
    function error=B_match1(cell_Discriptor_Query)
       
        Block= single(uint8(cell2mat(cell_Discriptor_Query)' * ones(1,size(Block_Discriptor_Dataset,2))));%gpu
        error= sum(((Block_Discriptor_Dataset - Block).^2),1);%gpu     
    end

    [min_error,Match]= min(error);
    Match=gather(Match);%gpu
 %}
%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Match= (zeros(1,size(Dataset_SIFT,4)));

    for j=1:size(Block_Discriptor_Query,1)
          
        Block= single(uint8(Block_Discriptor_Query(j,:)' * ones(1,size(Block_Discriptor_Dataset,2))));%
        error= sum(((Block_Discriptor_Dataset - Block).^2),1);%
        [min_error,Match]= min(error);%
        
        r = rem(j-1,size(grid_x,1))+1;
        c = (j-r)/size(grid_x,1) + 1;
    
        r_match= rem(Match-1,size(grid_x,1))+1;
        c_match= rem((Match-r_match)/size(grid_x,1), size(grid_x,2))+1;
        f_match= ceil(Match/(size(grid_x,1)*size(grid_x,2)));
        %f_match = (Match-r_match-(c_match-1)*size(grid_x,1))/(size(grid_x,1)*size(grid_x,2)) + 1;
    
        Gy_Query( (r-1)*block_size+1:r*block_size, (c-1)*block_size+1:c*block_size)=  KNN_Gy((r_match-1)*block_size+1:r_match*block_size , (c_match-1)*block_size+1:c_match*block_size, f_match);
        Gx_Query( (r-1)*block_size+1:r*block_size, (c-1)*block_size+1:c*block_size)=  KNN_Gx((r_match-1)*block_size+1:r_match*block_size , (c_match-1)*block_size+1:c_match*block_size, f_match);
    
     end
     
%Matching=toc
   %%%%% Poisson Reconstruction  %%%%%%%%%%%%%%%%%%%%%%
%tic
   Depth_Query= poisson_solve_generateDepth(Gy_Query, Gx_Query, boundary_query, alpha, beta);
%Poisson=toc

%tic
   stereo = 255*WarpFinal(im2double(Query_rgb_original),im2double(Depth_Query),max_disp,resize_factor,Gx, Gy, xx, yy, YY);
%Warping=toc
   %stereo=Depth_Query;


end