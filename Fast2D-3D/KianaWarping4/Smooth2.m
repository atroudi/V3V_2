rootin = 'U:\SterorWarp\Tennis6\MatchColor\';
rootout = 'U:\SterorWarp\Tennis6\MatchColor\Smooth2_';

rootinM = 'U:\SterorWarp\Tennis6\Mask\';

W = 5;

rootout = [rootout num2str(W) '\'];
mkdir(rootout);

FR = 1:451;


I = double(imread([rootin 'match_color' num2str(FR(1)) '.png']));
[vres hres u] = size(I);
num_frames = 2*W+1;

for fr = FR(1)+W:FR(end)-W,
    
    fr
   
    thisM = logical(imread([rootinM num2str(fr) '.png']));
    thisM = imresize(thisM,[vres hres/2]);
    
    I_r = zeros(vres,hres/2,num_frames);
    M = zeros(vres,hres/2,num_frames);

    d = double(imread([rootin 'match_color' num2str(k) '.png']));
    [vres hres u] = size(d);
    d = d(:,hres/2+1:end,1);
       
    i = 0;
    for k = fr-W:fr+W,
        
        i = i + 1;
       I = double(imread([rootin 'match_color' num2str(k) '.png']));
       [vres hres u] = size(I);
       I = I(:,hres/2+1:end,:);
        
       I_r(:,:,i) = I(:,:,1);
%        I_g(:,:,i) = I(:,:,2);
%        I_b(:,:,i) = I(:,:,3);


    m = double(logical(imread([rootinM num2str(fr) '.png'])));
    m = imresize(m,[vres hres/2]);
    M(:,:,i) = m;

       
        
    end
    
    I = I_r.*(1-M);
    D = sum(I,3);
    Msum = sum(M,3);
    D = D./(num_frames-Msum);
    
    D(thisM) = d(thisM);
    
    
    imwrite(D/255,[rootout num2str(fr) '.png']);
    
end