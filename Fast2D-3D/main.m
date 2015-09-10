%% main
function main(Profile)

warning('off','all')
%Profile = str2num(Profile);

%%%% Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

change = 0; % if there was any change in the Database , block_size, resize_factor or Fm.

Query_Paths = ['Data_Size_Seq/';];
Ref_Path =    ['Database/Run1         ';'Database/Run2         ';'Database/Run3         ';'Database/Run4         ';'Database/Run5         ';'Database/Run6         ';'Database/Run-game1    ';'Database/Run-game2    ';'Database/Run-game4    ';'Database/Run-game5    ';'Database/Run-game7    ';'Database/Run-game9    ';'Database/Run-game10   ';'Database/V1S4         ';'Database/V1S4-1       ';'Database/V1S4-2       ';'Database/V1S7         ';'Database/V1S7-1       ';'Database/V1S7-2       ';'Database/V1S8         ';'Database/V1S8-1       ';'Database/V1S8-2       ';'Database/V1S10        ';'Database/V1S10-1      ';'Database/V1S10-2      ';'Database/V1S15-1      ';'Database/V1S15-2      ';'Database/V1S16-1      ';'Database/V1S16-2      ';'Database/V1S18-1      ';'Database/V1S18-2      ';'Database/V2S6-1       ';'Database/V2S13-1      ';'Database/V2S23-1      ';'Database/V4S3-1       ';'Database/V4S5-1       ';'Database/V4S5-2       ';'Database/V4S9-1       ';'Database/V4S10-1      ';'Database/V4S10-2      '];

Output_Path = [Query_Paths,'Output/'];


addpath('KianaWarping4');
addpath('StereoWarp_Temp');

% Parameters
clear p
p.H_query = 1080;%1058; % expected query resolution
p.W_query = 960;
p.alpha = 60; %% gradient refinement
p.Fm_Size = 8;%512;
p.Max_images = 110; % max number of images in each ref file
p.SIFT_size = 32+3;
p.block_size = 9 ;%9
p.color_weight = 1; %% for block descriptor
p.max_disp = 20; 
p.SpatialSmoothness =0;
p.sigma = 3;
p.temporal_window = 5;
p.refine_pitch_model = 0; %if 1 then the pitch model will be updated based on the dominant color
maxNumCompThreads = 1;

switch Profile
    case 0                         % Lowest profile (low quality)
        p.k = 1; %% KNN
        p.resize_factor = 1/4;
        p.mask_resize_factor = 1/8;
        p.TiltMethod = 1;% 1 == shifting   , 2 == interp2
        %p.temporal_window = 1;

    case 1                         % Basic profile
        p.k = 6; %% KNN
        p.resize_factor = 1/4;
        p.mask_resize_factor = 1;
        p.TiltMethod = 2;% 1 == shifting   , 2 == interp2
        %p.temporal_window = 2;
   
    %{    
    case 2                         % 
        p.k = 10; %% KNN
        p.resize_factor = 1/2;
        p.mask_resize_factor = 1;
        p.TiltMethod = 2;% 1 == shifting   , 2 == interp2
        p.temporal_window = 2;
     %}
        
    case 3                         % Meduim profile
        p.k = 10; %% KNN
        p.resize_factor = 1/2;
        p.mask_resize_factor = 1;
        p.TiltMethod = 2;% 1 == shifting   , 2 == interp2
        %p.temporal_window = 5;
        
    case 4                         % High profile (not practical)
        p.k = 10; %% KNN
        p.resize_factor = 1;
        p.mask_resize_factor = 1;
        p.TiltMethod = 2;% 1 == shifting   , 2 == interp2
        %p.temporal_window = 5;
        
end

%%%% Save database SIFT and Gradients %%%%%%%%%%%%%%%%%%%%%%%%%%

if change
    
    
    Dataset_Gx = int8(nan(p.Max_images,size(Ref_Path,1),p.block_size*round(ceil(p.H_query*p.resize_factor)/p.block_size),p.block_size*round(ceil(p.W_query*p.resize_factor)/p.block_size)));
    Dataset_Gy = int8(nan(p.Max_images,size(Ref_Path,1),p.block_size*round(ceil(p.H_query*p.resize_factor)/p.block_size),p.block_size*round(ceil(p.W_query*p.resize_factor)/p.block_size))); 
    Dataset_SIFT = uint8(Inf(p.Max_images,p.SIFT_size,size(Ref_Path,1),round(ceil(p.H_query*p.resize_factor)/p.block_size)*round(ceil(p.W_query*p.resize_factor)/p.block_size)));
    Dataset_Fm   = uint8(Inf(p.Fm_Size,p.Max_images,size(Ref_Path,1)));
    
    for R_ref = 1:size(Ref_Path,1)
        
        R_ref
        
        N_ref = dir([deblank(Ref_Path(R_ref,:)),'/*_d.png']);   N_ref = char(N_ref.name);
        
        for n_ref = 1:min(size(N_ref,1), p.Max_images)

            fid = fopen([deblank(Ref_Path(R_ref,:)),'/',deblank(N_ref(n_ref,:))]);
            fseek(fid, 0,'eof');
            filelength = ftell(fid);
            fseek(fid, 0,'bof');
            
            if fid ~= -1 && filelength ~= 0
          
                N_deblank = deblank(N_ref(n_ref,:));
                img = imresize(imread([deblank(Ref_Path(R_ref,:)),'/',N_deblank(1:end-6),'_d.png']),[p.H_query p.W_query]); 
                img = rgb2gray(imresize(img, p.resize_factor));
                img = imresize(img,[p.block_size*round(size(img,1)/p.block_size)   p.block_size*round(size(img,2)/p.block_size)]);
    
                img = double(img)/255;
                img = img - min(img(:));

                H = size(img,1);
                W = size(img,2);

                Gx_pre = img(1:H,2:W) - img(1:H,1:W-1);
                Gy_pre = img(2:H,1:W) - img(1:H-1,1:W);
                
                Gx = [Gx_pre zeros(H,1)];
                Gy = [Gy_pre; zeros(1,W)];
                
                Gx = Gx.*(1-1*exp(1-1./(p.alpha*abs(Gx)+eps))).* ((1-1*exp(1-1./(p.alpha*abs(Gx)+eps)))>0);
                Gy = Gy.*(1-1*exp(1-1./(p.alpha*abs(Gy)+eps))).* ((1-1*exp(1-1./(p.alpha*abs(Gy)+eps)))>0);

                Dataset_Gx(n_ref,R_ref,:,:) = int8(Gx*10000);
                Dataset_Gy(n_ref,R_ref,:,:) = int8(Gy*10000);
                 
                %%%%%%%%%%%%%%%%%%%%%%
                
                clear img
                img = imresize(imread([deblank(Ref_Path(R_ref,:)),'/',N_deblank(1:end-6),'.png']),[p.H_query p.W_query]);  
                img = imresize(img, p.resize_factor);
                
                img = imresize(img,[p.block_size*round(size(img,1)/p.block_size)   p.block_size*round(size(img,2)/p.block_size)]);
                img_padded = zeros(size(img,1)+4*p.block_size, size(img,2)+4*p.block_size);
                img_padded(2*p.block_size+1:size(img,1)+2*p.block_size, 2*p.block_size+1:size(img,2)+2*p.block_size) = rgb2gray(img);
                [sift_arr, grid_x, grid_y] = sp_dense_sift(img_padded, p.block_size, 5*p.block_size);
             
                %Bm
                SIFT_img = sift_arr ./ repmat(sqrt(sum(sift_arr.^2, 3)), [1 1 size(sift_arr,3)]);% normalize to unit length
                SIFT_img = round(SIFT_img*255);
                color_img = imresize(img, [size(grid_y,1) size(grid_x,2)]);
                Block_Discriptor = cat(2, reshape(SIFT_img,[],size(SIFT_img,3)), p.color_weight*reshape(color_img,[],3));
                Block_Discriptor = uint8(Block_Discriptor);
                Dataset_SIFT(n_ref,:,R_ref,:) = Block_Discriptor';
                
                % Fm
                sift_vectors = reshape(sift_arr,[],size(sift_arr,3));
                sift_sum = sum(sift_vectors,1); 
                sift_sum = (sift_sum(1:length(sift_sum)/4)+sift_sum(1+length(sift_sum)/4:length(sift_sum)/2)+sift_sum(1+length(sift_sum)/2:3*length(sift_sum)/4)+sift_sum(1+3*length(sift_sum)/4:end));% summing the 4 quarters
                Dataset_Fm(1:p.Fm_Size,n_ref, R_ref) = uint8(round(255*sift_sum/sqrt(sum(sift_sum.^2))));% normalize and round
                
            end
            fclose(fid);
        end

    end
    
    %%%%%%%%%%%%%%%%  Just for test document %%%%%%%%%%%%%%%%%%
    %{
    Dataset_SIFT=permute(Dataset_SIFT,[1 3 2 4]);
    Dataset_SIFT = reshape(Dataset_SIFT,[],size(Dataset_SIFT,3),size(Dataset_SIFT,4));
    size(Dataset_SIFT)
    Dataset_Fm = permute(Dataset_Fm,[2 3 1]);
    Dataset_Fm = reshape(Dataset_Fm,[],size(Dataset_Fm,3));
    Dataset_Fm=permute(Dataset_Fm,[2 1]);
    size(Dataset_Fm)
    Dataset_Gx = reshape(Dataset_Gx,[],size(Dataset_Gx,3),size(Dataset_Gx,4));
    size(Dataset_Gx)
    Dataset_Gy = reshape(Dataset_Gy,[],size(Dataset_Gy,3),size(Dataset_Gy,4));
    size(Dataset_Gy)
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch p.resize_factor
        
        case 1/4
            save('Dataset_Gx_4.mat','Dataset_Gx');
            save('Dataset_Gy_4.mat','Dataset_Gy');
            save('Dataset_SIFT_4.mat','Dataset_SIFT');
            save('Dataset_Fm_4.mat','Dataset_Fm');
            
        case 1/2
            save('Dataset_Gx_2.mat','Dataset_Gx');
            save('Dataset_Gy_2.mat','Dataset_Gy');
            save('Dataset_SIFT_2.mat','Dataset_SIFT');
            save('Dataset_Fm_2.mat','Dataset_Fm');
            
        case 1
            save('Dataset_Gx_1.mat','Dataset_Gx','-v7.3');
            save('Dataset_Gy_1.mat','Dataset_Gy','-v7.3');
            save('Dataset_SIFT_1.mat','Dataset_SIFT','-v7.3');
            save('Dataset_Fm_1.mat','Dataset_Fm','-v7.3');
    end
    
end


%%%% Load database %%%%%%%%%%%%%%%%%%%%%%%%%%

switch p.resize_factor
    
       case 1/4
         load('Dataset_Fm_4.mat','Dataset_Fm');
         load('Dataset_Gx_4.mat','Dataset_Gx');
         load('Dataset_Gy_4.mat','Dataset_Gy');
         load('Dataset_SIFT_4.mat','Dataset_SIFT');
         
       case 1/2
         load('Dataset_Fm_2.mat','Dataset_Fm');
         load('Dataset_Gx_2.mat','Dataset_Gx');
         load('Dataset_Gy_2.mat','Dataset_Gy');
         load('Dataset_SIFT_2.mat','Dataset_SIFT');
         
       case 1
         load('Dataset_Fm_1.mat','Dataset_Fm');
         load('Dataset_Gx_1.mat','Dataset_Gx');
         load('Dataset_Gy_1.mat','Dataset_Gy');
         load('Dataset_SIFT_1.mat','Dataset_SIFT');
end


%poolobj = parpool(maxNumCompThreads);
 
Dataset_Fm = uint8(Dataset_Fm);
Dataset_SIFT = uint8(Dataset_SIFT);
Block_Discriptor_Dataset = uint8(zeros(size(Dataset_SIFT,2),size(Dataset_SIFT,4),p.k));


%%%% For Each Video %%%%%%%%%%%%%%%%%%%%%%%%

for Query_Path_idx = 1:size(Query_Paths,1)
    
    clear Query_Path
    Query_Path = deblank(Query_Paths(Query_Path_idx,:));
    mkdir(Output_Path)
    mkdir([Output_Path,'Depth/'])
    delete([Output_Path,'*'])
    delete([Output_Path,'Depth/','*'])

    N_query = dir([Query_Path,'*.png']);   N_query = char(N_query.name);  Number_of_Frames_folder = size(N_query,1);
    
    frames_processed = 0;
    pre_count = 0;
    pre_class = 0;
    
    I_original = imread([Query_Path, num2str(frames_processed+1), '.png']);
    [vres_original, hres_original, u] = size(I_original); 
    d_vres = size(Dataset_Gx,3); 
    d_hres = size(Dataset_Gx,4);
    
    %[Gx, Gy, xx, yy, YY] = GetGxGy(vres_original,hres_original/2,p.resize_factor);
    if(p.SpatialSmoothness == 1)
        [Gx, Gy, xx, yy, YY] = WarpingInitilization(vres_original,hres_original/2,R);
    else
        [xx, yy, YY] = WarpingInitilization_Simple(vres_original,hres_original/2);
    end
    
    
    while frames_processed< Number_of_Frames_folder
        
        Number_of_Frames = min(Number_of_Frames_folder-frames_processed,250*6);% 10*6 sec
        
        % read all frames     
        Query_rgb_original_all = uint8(zeros(vres_original, hres_original/2, u, Number_of_Frames));
       
       
        for Query_no = 1:Number_of_Frames
            Query_rgb_original = imread([Query_Path, num2str(frames_processed+Query_no),'.png']); 
            Query_rgb_original_all(:,:,:,Query_no) = imresize(Query_rgb_original,[size(Query_rgb_original,1) size(Query_rgb_original,2)/2]);% Half the Width
            %Query_rgb_original_all(:,:,:,Query_no) = Query_rgb_original(1:size(Query_rgb_original,1),1: size(Query_rgb_original,2)/2,:);% Half the Width
        end
           
        
tic    
    %%%% Cassification   %%%%%%%
    
    [CLASS, mask] = GetSceneClassification_WithoutCuts(Query_rgb_original_all,pwd,p.resize_factor* p.mask_resize_factor,p.refine_pitch_model);

    [CLASS, last_count, last_class] = CleanClass(Query_rgb_original_all,CLASS,pre_count, pre_class);
    
    pre_count = last_count;
    pre_class = last_class;
    
%classify=toc 

    %%%% For Each Frame %%%%%%%%%%%%%%%%%%%%%%%
%tic 
    %Query_fr = 1:Number_of_Frames;
    
    %Query_no_long_short = Query_fr(logical(CLASS==1 | CLASS==3));
    %Query_no_medium_short = Query_fr(logical(CLASS==2 | CLASS==3));
    %Query_no_long = Query_fr(logical(CLASS==1));
    %Query_no_medium = Query_fr(logical(CLASS==2));
    %Query_no_short = Query_fr(logical(CLASS==3));
    
%toc
%tic 
    parfor Query_no = 1:Number_of_Frames
      
          Query_rgb_original = Query_rgb_original_all(:,:,:,Query_no);
         
          if CLASS(Query_no) == 1 %% Long    
              stereo_all(:,:,:,Query_no) = tilt(Query_rgb_original, p);
              ramp= imresize((0:255)',[d_vres 1]);
              depth_all(:,:,Query_no) = repmat(ramp,1,d_hres);
          
          elseif CLASS(Query_no) == 2 %% Medium     
              depth = DGC(Query_rgb_original, mask(:,:,Query_no), p, Dataset_Fm,Dataset_SIFT,Dataset_Gx,Dataset_Gy,Block_Discriptor_Dataset,Ref_Path);
              depth_all(:,:,Query_no) = depth;
              stereo_all(:,:,:,Query_no) = zeros(vres_original, hres_original, u);
              %{
              if p.temporal_window == 1
                  stereo_all(:,:,:,Query_no) = 255*WarpFinal(im2double(Query_rgb_original),im2double(depth),p.max_disp,p.resize_factor,Gx, Gy, xx, yy, YY);
              else
                  stereo_all(:,:,:,Query_no) = zeros(vres_original, hres_original, u);
              end
              %}
              
          elseif CLASS(Query_no) == 3 %% Short
              %stereo_all(:,:,:,Query_no)= [Query_rgb_original Query_rgb_original]; % do nothing
              %depth_all(:,:,Query_no) = 255*ones(d_vres,d_hres);
              
              depth = DGC(Query_rgb_original, zeros(size(mask(:,:,Query_no))), p, Dataset_Fm,Dataset_SIFT,Dataset_Gx,Dataset_Gy,Block_Discriptor_Dataset,Ref_Path); 
              depth_all(:,:,Query_no) = depth;
              stereo_all(:,:,:,Query_no) = zeros(vres_original, hres_original, u);
              
              %{
              if p.temporal_window == 1
                  stereo_all(:,:,:,Query_no) = 255*WarpFinal(im2double(Query_rgb_original),im2double(depth),p.max_disp,p.resize_factor,Gx, Gy, xx, yy, YY);
              else
                  stereo_all(:,:,:,Query_no) = zeros(vres_original, hres_original, u);
              end
              %}
          end
          
    end 
%toc  
%tic 

    % Warping
    depth_all_smoothed = depth_all;
    
    for FR = 2*p.temporal_window+1:Number_of_Frames-2*p.temporal_window
        if sum(sum(sum(stereo_all(:,:,:,FR))))== 0
            
          K = 0;
          w = p.temporal_window;
          sigma = p.sigma;
          
         if sum(sum(sum(sum(stereo_all(:,:,:,FR-2*w:FR+2*w)))))~=0 || CLASS(FR)==3 % if closeup or in a transition from other methods to DGC double the temporal smoothing parameters
             w = 2*w;
             sigma = 2*p.sigma;
         end
         
         num_frames = 2*w+1;
         D = zeros(d_vres,d_hres,num_frames);
         g = fspecial('gaussian',[1 num_frames],sigma);
         
         for fr = FR-w:FR+w,
            K = K + 1;
            D(:,:,K) = g(K)*depth_all(:,:,fr);
         end
         
         
         depth_all_smoothed(:,:,FR) = sum(D,3);
         
        end
    end
    
    parfor FR = 1:Number_of_Frames
        if sum(sum(sum(stereo_all(:,:,:,FR))))== 0
         
            if p.SpatialSmoothness == 1
                %stereo_all(:,:,:,FR) = ViewInterpolation(Query_rgb_original_all(:,:,:,FR),depth_all_smoothed(:,:,FR),20,0.25,Gx,Gy,xx,yy,YY);
            else
                stereo_all(:,:,:,FR) = 255*SimpleInterpolation(im2double(Query_rgb_original_all(:,:,:,FR)),im2double(depth_all_smoothed(:,:,FR)),20,0.25,xx,yy,YY);
            end
        end
    end
    
    %{
    if p.temporal_window >1
      stereo_all = RunData(Query_rgb_original_all,depth_all,stereo_all,p.resize_factor,p.temporal_window,p.max_disp); 
    end
    %}
%toc
    
%toc  
run_time = toc; 
    
    % write results
    parfor Query_no = 1:Number_of_Frames
           Stereo = stereo_all(:,:,:,Query_no);
           Depth = depth_all_smoothed(:,:,Query_no);
           if sum(Stereo(:)) % Remove the last temp_wind black frames
            imwrite(uint8(Stereo), [Output_Path,num2str(frames_processed+Query_no,'%08d'),'.png'],'png');
            imwrite(uint8(Depth), [Output_Path,'Depth/',num2str(frames_processed+Query_no,'%08d'),'.png'],'png');
           end
    end
    
    clear stereo_all
    
    %Class1_Frames = size(Query_no_long,2)
    %Class2_Frames = size(Query_no_medium,2)
    %Class3_Frames = size(Query_no_short,2)
    Runtime = run_time/ Number_of_Frames
    
    frames_processed = frames_processed+ Number_of_Frames;
    
   end
    
end
    