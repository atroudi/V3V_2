function SS = ViewInterpolation(RAW,D,Thresh,R,Gx,Gy,xx,yy,YY)

%%RAW: Original Left image
%%D: Depth Image (2D)
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

imwrite(SS, '/Users/OmarEltobgy/Dropbox/WarpingTest1/SS1/3.png', 'png');
imwrite(SS, '/Users/OmarEltobgy/Dropbox/WarpingTest1/RGB/21.png', 'png');

end

function [lefts, rights, disparity] = stereoWarpK_noMotion_singleSided( imgs, imgs_RAW, depths, Gx, Gy, displevels,R,xx,yy,YY)
%STEREOWARP warps an image sequence (with corresponding flow and depth) to a stereo sequence
%Input:
%Assuming [h,w] are the video dimensions and K is the number of frames:
%imgs is of size [h,w,3,K] - video frames
%depths of size [h,w,1,K] - depth frames
%flows of size [h,w,2,K] - optical flow results
%displevels - maximum amount of disparity between resulting stereo frames (in pixels)
%Output:
%lefts/rights - estimated stereo frames (same size as imgs)
%anaglyphs - stereo frames converted to anaglyph
%disparity - estimated disparity frames

%% Spatial + temporal smoothness parameters (higher => smoother)
smoothCoeff_x = 20; %20
smoothCoeff_y = 4; %4 %1
%smoothCoeff_tem = 0; %0

%% Prepare optimization
%fprintf('Preparing optimization...');
%preparetime = tic;

[h,w,~,K] = size(imgs);
if( ~exist('displevels','var') )
    displevels = floor(sqrt(h*w)/30);
end
N = h*w*K;
gr = mean(imgs,3);
grs = imfilter(gr, fspecial('gaussian', [5,5],1));
%eps = 1e-4;


%One heuristic for converting depth to disparity
disparity0 = imnormalize(1./(1+imnormalize(depths))).*displevels - displevels/2;

%%disparity0 = imnormalize(1./(1+imnormalize(depths))).*displevels - 0*displevels/2;

dx = imfilter(grs, [-1 1 0], 'replicate', 'same');
dy = imfilter(grs, [-1 1 0]', 'replicate', 'same');
W = (imnormalize(disparity0) + 1.*sigmoid(sqrt(dx.^2+dy.^2),0.01,500))./2;

%A = spdiags(W(:),0,N,N) + smoothCoeff_x.*(Gx'*Gx) + smoothCoeff_y.*(Gy'*Gy) + smoothCoeff_tem.*(Gt'*wt*Gt);
t2 = smoothCoeff_x.*(Gx'*Gx);
A = spdiags(W(:),0,N,N) + smoothCoeff_x.*(Gx'*Gx) + smoothCoeff_y.*(Gy'*Gy);
b = W(:).*disparity0(:);


%fprintf('done! (%.5fs)\n', toc(preparetime));

%% Optimize
%fprintf('Optimizing warps...\n');
%opttime = tic;

%x = A\b;
%fprintf('\tConstructing preconditioner...\n');
M = ichol(A,struct('michol','on'));
%fprintf('\tOptimizing...\n\t');
%tic
[x flag] = pcg(A,b,5e-1,150,M,M',disparity0(:)); %1-e6
%toc

disparity = reshape(x,[h,w,1,K]);
%warpleft = disparity./2;
warpright = -disparity./1;

%tic
%lefts = clip(warpImage_v2(imgs_RAW, warpleft, zeros(h,w),R));
lefts = imgs_RAW;
%rights = clip(warpImage_v2(imgs_RAW, warpright, zeros(h/R,w/R),R));
%rights = gather(clip(warpImage_v2(gpuArray(imgs_RAW), gpuArray(warpright), gpuArray(zeros(h,w)),R)));
warpright = imresize(warpright,[size(imgs_RAW,1) size(imgs_RAW,2)]);
%rights = clip(warpImage_v2(imgs_RAW, warpright,R,xx,yy,YY));

rights = (clip(warpImage_v2((imgs_RAW), (warpright), R, xx, yy, YY)));

end

function [ I_norm ] = imnormalize( img, low_prc, up_prc )
I = img;
if ~isfloat(I)
    I = double(I);
end
if( abs(max(I(:))-min(I(:)))<1e-8 )
    I_norm = img;
else
    if(nargin==1)
        I_norm = (I - min(I(:))) / (max(I(:)) - min(I(:)));
    else
        m = prctile(I(:),low_prc);
        M = prctile(I(:),up_prc);
        I_norm = (I-m)/(M-m);
    end
end
end

function sx = sigmoid(x, center, scale)
sx = 1./(1+exp(scale.*(center-x)));
end

function cv = clip(v, bds)
if(nargin<2)
    bds = [0,1];
end
cv = v;
cv(v(:)<bds(1)) = bds(1);
cv(v(:)>bds(2)) = bds(2);
end


% function to warp images with different dimensions
function [warpI2,mask]=warpImage_v2(im,vx,R,xx,yy,YY)

S = 1/R;

[height,width,nchannels]=size(im);
% [xx,yy]=meshgrid(1:width,1:height);
% YY=yy;
% YY=min(max(YY,1),height);

%vx = imresize(vx,S);
XX=xx+vx;

mask=XX<1 | XX>width | YY<1 | YY>height;
XX=min(max(XX,1),width);
XX = (XX);

%tic
for i=1:nchannels
    %foo=interp2(xx,yy,im(:,:,i),XX,YY,'bicubic');
    foo=interp2(xx(1,:),yy(:, 1),im(:,:,i),XX,YY);
    %foo=qinterp2(xx,yy,im(:,:,i),XX,YY);
    foo(mask)=0.6;
    warpI2(:,:,i)=foo;
end
%toc

mask=1-mask;

end
