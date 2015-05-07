function [Ref_rgb_Dataset, Ref_depth_Dataset]= KNN(query_GIST,Ref_Path,k)

%read refs
IDX=size(Ref_Path,1);
D=size(Ref_Path,1);
IDX_name=size(Ref_Path);

for R_ref=1:size(Ref_Path,1)
    
    home_dir=pwd;
    cd (deblank(Ref_Path(R_ref,:)))
    
      N_ref = dir('*.txt');   N_ref= char(N_ref.name);
      
    cd (home_dir)
     
    ref_GIST_local=Inf(size(N_ref,1),size(query_GIST,2));
    
    for n_ref=1:size(N_ref,1)
         
        fid=fopen([deblank(Ref_Path(R_ref,:)),'/',deblank(N_ref(n_ref,:))]);
        fseek(fid, 0,'eof');
        filelength = ftell(fid);
        fseek(fid, 0,'bof');
        
        if fid ~= -1 && filelength ~=0
           ref_GIST_local(n_ref,:)=fscanf(fid,'%f\n');  
        end
        fclose(fid);
    end
     
    [IDX(R_ref),D(R_ref)] = knnsearch(ref_GIST_local,query_GIST,'K',1,'Distance','cityblock'); % One from each Ref folder
    
    IDX_name(R_ref,1:size(N_ref,2))= N_ref(IDX(R_ref),:);
end


%knn
[B,I]=sort(D);

j=1;
for i=1:size(I)
    
  R= I(i); %  Ref folder
  n=IDX_name(R,:); % Ref image in that folder
  
  N_deblank=deblank(n);
  fid1= fopen([deblank(Ref_Path(R,:)),'/',N_deblank(1:end-4),'.png']); 
  fid2= fopen([deblank(Ref_Path(R,:)),'/',N_deblank(1:end-4),'_d.png']);
  
  if fid1~=-1 && fid2~=-1
  
     candidate= imread([deblank(Ref_Path(R,:)),'/',N_deblank(1:end-4),'.png']); 
     candidate_d= rgb2gray(imread([deblank(Ref_Path(R,:)),'/',N_deblank(1:end-4),'_d.png']));
  
      if j<=k && sum(candidate_d(:)>50) 
          
          if j==1    
            Ref_rgb_Dataset= zeros(size(candidate,1), size(candidate,2),3,k); 
            Ref_depth_Dataset= zeros(size(candidate,1), size(candidate,2),k); 
          end

          Ref_rgb_Dataset(:,:,:,j)= candidate(:,:,:);
          Ref_depth_Dataset(:,:,j)= candidate_d;

          j=j+1;
      end
  end
  
  fclose('all');
  
end
