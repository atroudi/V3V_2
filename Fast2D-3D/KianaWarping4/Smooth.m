rootin = 'U:\SterorWarp\Tennis6\MatchColor\';
rootout = 'U:\SterorWarp\Tennis6\MatchColor\Smooth';

W = 5;

rootout = [rootout num2str(W) '\'];
mkdir(rootout);

FR = 1:451;


I = double(imread([rootin 'match_color' num2str(FR(1)) '.png']));
[vres hres u] = size(I);
num_frames = W;

for fr = FR(1)+W:FR(end)-W,
    
    fr
   
    I_r = zeros(vres,hres/2,num_frames);
%     I_g = zeros(vres,hres/2,num_frames);
%     I_b = zeros(vres,hres/2,num_frames);
    
    i = 0;
    for k = fr-W:fr+W,
        
        i = i + 1;
       I = double(imread([rootin 'match_color' num2str(k) '.png']));
       [vres hres u] = size(I);
       I = I(:,hres/2+1:end,:);
        
       I_r(:,:,i) = I(:,:,1);
%        I_g(:,:,i) = I(:,:,2);
%        I_b(:,:,i) = I(:,:,3);
       
        
    end
    
    B(:,:,1) = mean(I_r,3);
    B(:,:,2) = mean(I_r,3);
    B(:,:,3) = mean(I_r,3);
    
    imwrite(B/255,[rootout num2str(fr) '.png']);
    
end