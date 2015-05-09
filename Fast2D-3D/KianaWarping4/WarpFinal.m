function SS = WarpFinal(RAW,D,Thresh,R,Gx,Gy,xx,yy,YY)

%%RAW: Original Left image
%%D: Depth from Poisson (2D)
%%Thresh: Disparity range...set to 20 
%%R: resize factor. Set to 0.25
%%Gx,Gy: See GetGxGy. Estimate ONLY ONCE for entire sequence and save in
%%RAM (saves time) 

%%SS: Side by Side output

%%Make sure RAW and D is in the range of 0-1 (you can convert them usnig
%%im2double

I = imresize(RAW,R);
D = imresize(D,[size(I,1) size(I,2)]);

%%%Warping

[lefts, rights, disparity] = stereoWarpK_noMotion_singleSided(I, RAW, D, Gx,Gy, Thresh,R,xx,yy,YY);

%%%Creat Side by Side
[vres hres u] = size(lefts);
SS = zeros(vres,hres*2,3);
SS(:,1:hres,:) = lefts;
SS(:,hres+1:end,:) = rights;



