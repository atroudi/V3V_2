function GetSidebySide(rootin,st,fr)

rootout = [rootin '/SS/'];
mkdir(rootout);

for fr = st:fr,
   %fr
    L = double(imread([rootin 'Left' num2str(fr) '.png']));
    R = double(imread([rootin 'Right' num2str(fr) '.png']));
    
    [vres hres u] = size(L);
    
    I = zeros(vres,hres*2,u);
    
    I(:,1:hres,:) = L;
    I(:,hres+1:end,:) = R;
    
    imwrite(I/255,[rootout 'SS' num2str(fr) '.png']);
    
end