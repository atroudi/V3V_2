
function [I_Query_matched_rgb, Depth_Query]= Matching (Query,Query_rgb, Block_Discriptor_Query,Block_Discriptor_Dataset, Ref_depth_Dataset, Ref_rgb_Dataset, boundary_query, block_size, alpha, beta, Query_txt_name, Query_Path, grid_x)

%%%%%% Gradient Extraction %%%%%%%%%%%%%%%%%%%%

Gy_ref_database=zeros(size(Ref_depth_Dataset));
Gx_ref_database=zeros(size(Ref_depth_Dataset));

for d=1:size(Ref_depth_Dataset,3)
    
    Depth_ref= Ref_depth_Dataset(:,:,d);
    
    [Gy_ref, Gx_ref] = poisson_solve_generateDIV(Depth_ref);
    
    Gy_ref_database(:,:,d)= Gy_ref; 
    Gx_ref_database(:,:,d)= Gx_ref;
    
end

%%%%%%% Block Matching and Gradient Mapping %%%%%%%%%%%%%%%%%%%%%%%%

Matches=ones(size(grid_x,1),size(grid_x,2),3);
I_Query_matched_rgb=zeros(size(Query_rgb));

Gy_Query=zeros(size(Query)); 
Gx_Query=zeros(size(Query));

g_Block_Discriptor_Dataset= gpuArray(Block_Discriptor_Dataset);
g_Block_Discriptor_Query= gpuArray(Block_Discriptor_Query);
Block=gpuArray(zeros(size(Block_Discriptor_Dataset)));
temp=gpuArray(ones(size(Block_Discriptor_Dataset,1),1));


for i=1:size(Block_Discriptor_Query,1)
    
        Block(:,:,1)=temp * g_Block_Discriptor_Query(i,:);
        
        for j=2:size(Block_Discriptor_Query,3)
             Block(:,:,j)= Block(:,:,1);
        end
        
        error= (sum(((Block-g_Block_Discriptor_Dataset).^2) , 2));
        [min_val,g_index]= min(error(:));
          
        index=gather(g_index);
        
        r = rem(i-1,size(Matches,1))+1;
        c = (i-r)/size(Matches,1) + 1;
        
        r_index=rem(index-1,size(Matches,1))+1;
        c_index=(index-r_index)/size(Matches,1)+1;
    
        Matches(r,c,1:3)= [r_index  c_index ceil(index/(size(Matches,1)*size(Matches,2)))];

        %I_Query_matched_rgb((r-1)*block_size+1:r*block_size , (c-1)*block_size+1:c*block_size, : )= Ref_rgb_Dataset( (Matches(r,c,1)-1)*block_size+1:Matches(r,c,1)*block_size , (Matches(r,c,2)-1)*block_size+1:Matches(r,c,2)*block_size,:,Matches(r,c,3));
        Gy_Query( (r-1)*block_size+1:r*block_size, (c-1)*block_size+1:c*block_size)=  Gy_ref_database((Matches(r,c,1)-1)*block_size+1:Matches(r,c,1)*block_size , (Matches(r,c,2)-1)*block_size+1:Matches(r,c,2)*block_size, Matches(r,c,3));
        Gx_Query( (r-1)*block_size+1:r*block_size, (c-1)*block_size+1:c*block_size)=  Gx_ref_database((Matches(r,c,1)-1)*block_size+1:Matches(r,c,1)*block_size , (Matches(r,c,2)-1)*block_size+1:Matches(r,c,2)*block_size, Matches(r,c,3));
      
end


%%%%% Poisson Reconstruction  %%%%%%%%%%%%%%%%%%%%%%

Depth_Query= poisson_solve_generateDepth(Gy_Query, Gx_Query, boundary_query, alpha, beta);

