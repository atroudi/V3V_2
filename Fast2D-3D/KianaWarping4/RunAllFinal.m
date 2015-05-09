function RunAllFinal

vres = 1080;
hres = 960;
[Gx Gy xx yy YY] = GetGxGy(vres,hres,0.25);

for fr = [522:650];
    I = im2double(imread(['/export/ds/Mohamed_Elgharib/SteroWarp/data/Medium/out_color' num2str(fr) '.png']));
    RAW = I(:,1:hres,:);
    D = I(:,hres+1:end,1);
    SS = WarpFinal(RAW,D,20,0.25,Gx,Gy,xx,yy,YY);
end

for fr = [1686:1730];
    I = im2double(imread(['/export/ds/Mohamed_Elgharib/SteroWarp/data/Medium/out_color' num2str(fr) '.png']));
    RAW = I(:,1:hres,:);
    D = I(:,hres+1:end,1);
    SS = WarpFinal(RAW,D,20,0.25,Gx,Gy,xx,yy,YY);
end

for fr = [2706:2986];
    I = im2double(imread(['/export/ds/Mohamed_Elgharib/SteroWarp/data/Medium/out_color' num2str(fr) '.png']));
    RAW = I(:,1:hres,:);
    D = I(:,hres+1:end,1);
    SS = WarpFinal(RAW,D,20,0.25,Gx,Gy,xx,yy,YY);
end