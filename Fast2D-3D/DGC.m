
function Depth_Query = DGC(Query_rgb_original, mask, p, Dataset_Fm,Dataset_SIFT,Dataset_Gx,Dataset_Gy,Block_Discriptor_Dataset,Ref_Path)


    % Parameters
    H_query = p.H_query;
    W_query = p.W_query;
    block_size = p.block_size;
    color_weight = p.color_weight;
    alpha = p.alpha;
    k = p.k;
    resize_factor = p.resize_factor;
    Fm_Size = p.Fm_Size;
    Max_images = p.Max_images;
    max_disp = p.max_disp;
    SIFT_size = p.SIFT_size;
    temporal_window = p.temporal_window;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    Query_rgb = imresize(Query_rgb_original,[H_query W_query]);
    Query_rgb = imresize(Query_rgb,resize_factor);  
    Query_rgb = imresize(Query_rgb,[block_size*round(size(Query_rgb,1)/block_size)   block_size*round(size(Query_rgb,2)/block_size)]);

    Query = rgb2gray(Query_rgb);

    boundary_query = imresize(mask~=0, [size(Query_rgb,1) size(Query_rgb,2)]);

 %tic 
    %%%%%% Block Discriptor for Query

    H = size(Query,1);
    W = size(Query,2);

    Query_padded = zeros(H+4*block_size, W+4*block_size);
    Query_padded(2*block_size+1:H+2*block_size, 2*block_size+1:W+2*block_size) = Query;

    [sift_arr, grid_x, grid_y] = sp_dense_sift(Query_padded, block_size, 5*block_size);

    
    SIFT_Query = sift_arr ./ repmat(sqrt(sum(sift_arr.^2, 3)), [1 1 size(sift_arr,3)]);
    SIFT_Query= round(SIFT_Query*255);
    color_Query= imresize(double(Query_rgb), [size(grid_y,1) size(grid_x,2)]);
    Block_Discriptor_Query = cat(2, reshape(SIFT_Query,[],size(SIFT_Query,3)), color_weight*reshape(color_Query,[],3));
      
%SIFT=toc

    %%%%%% Search (KNN + Block matching)
    
%tic 
     Dataset_Fm= reshape(Dataset_Fm,size(Dataset_Fm,1),[]);
     
     
    %[gist, param1] = LMgist(Query_rgb, '', param);% gist size= 512
     sift_vectors = reshape(sift_arr,[],size(sift_arr,3));
     sift_sum = sum(sift_vectors,1);
     sift_sum = (sift_sum(1:length(sift_sum)/4)+sift_sum(1+length(sift_sum)/4:length(sift_sum)/2)+sift_sum(1+length(sift_sum)/2:3*length(sift_sum)/4)+sift_sum(1+3*length(sift_sum)/4:end))/4;
     ImageDescriptor = round(255*sift_sum/sqrt(sum(sift_sum.^2))); % normalize and round
     ImageDescriptor = uint8((ImageDescriptor(1:Fm_Size)' * ones(1,size(Dataset_Fm,2))));
    
     Difference = sum(uint16(Dataset_Fm - ImageDescriptor).^2,1);%
     Difference = reshape(Difference,[],size(Ref_Path,1));%
    
     [C,I] = min(Difference,[],1);%
     [B,IDX] = sort(C);

    
     KNN_Gx = int8(nan(size(Dataset_Gx,3),size(Dataset_Gx,4),k));
     KNN_Gy = int8(nan(size(Dataset_Gy,3),size(Dataset_Gy,4),k));
     Gx_Query = int8(nan(size(Dataset_Gx,3),size(Dataset_Gx,4)));
     Gy_Query = int8(nan(size(Dataset_Gy,3),size(Dataset_Gy,4)));
   
     
     i=1;
     j=1;
                                    
     while j<=k && i<=length(IDX)
        
      Block_Discriptor_Dataset(:,:,j) = Dataset_SIFT(I(IDX(i)),:,IDX(i),:);
      KNN_Gx(:,:,j) = Dataset_Gx(I(IDX(i)),IDX(i),:,:) ;
      KNN_Gy(:,:,j) = Dataset_Gy(I(IDX(i)),IDX(i),:,:) ;
      if sum(sum(Dataset_Gx(I(IDX(i)),IDX(i),:,:))) && sum(sum(Dataset_Gy(I(IDX(i)),IDX(i),:,:)))
       j=j+1;
      end
       i=i+1;
     end
    
     Block_Discriptor_Dataset = reshape(Block_Discriptor_Dataset,size(Block_Discriptor_Dataset,1),[]);
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     for j=1:size(Block_Discriptor_Query,1)
          
        Block = uint8(Block_Discriptor_Query(j,:)' * ones(1,size(Block_Discriptor_Dataset,2)));
        error = sum((uint16(Block_Discriptor_Dataset - Block).^2),1);% single so it won't overflow
        [min_error,Match] = min(error);
        
        r = rem(j-1,size(grid_x,1))+1;
        c = (j-r)/size(grid_x,1) + 1;
    
        r_match = rem(Match-1,size(grid_x,1))+1;
        c_match = rem((Match-r_match)/size(grid_x,1), size(grid_x,2))+1;
        f_match = ceil(Match/(size(grid_x,1)*size(grid_x,2)));
    
        Gy_Query( (r-1)*block_size+1:r*block_size, (c-1)*block_size+1:c*block_size) =  KNN_Gy((r_match-1)*block_size+1:r_match*block_size , (c_match-1)*block_size+1:c_match*block_size, f_match);
        Gx_Query( (r-1)*block_size+1:r*block_size, (c-1)*block_size+1:c*block_size) =  KNN_Gx((r_match-1)*block_size+1:r_match*block_size , (c_match-1)*block_size+1:c_match*block_size, f_match);
    
     end
     
     %%%%%%%%%%%%%%%%  Just for test document %%%%%%%%%%%%%%%%%%
     %{
     dlmwrite('/Users/kiana/Dropbox (QCRI-DS)/2D-3D/Testing/Depth Gradient Estimator/Gx/8.txt',Gx_Query)
     dlmwrite('/Users/kiana/Dropbox (QCRI-DS)/2D-3D/Testing/Depth Gradient Estimator/Gy/8.txt',Gy_Query)
     %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      
%Matching=toc


   %%%%% Poisson Reconstruction  %%%%%%%%%%%%%%%%%%%%%%
   
%tic
   Depth_Query = poisson_solve_generateDepth(Gy_Query, Gx_Query, boundary_query);
%Poisson=toc

%tic
   %stereo = 255*WarpFinal(im2double(Query_rgb_original),im2double(Depth_Query),max_disp,resize_factor,Gx, Gy, xx, yy, YY);

   %stereo=Depth_Query;
%Warping=toc
end