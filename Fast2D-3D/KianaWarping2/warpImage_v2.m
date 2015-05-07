% function to warp images with different dimensions
function [warpI2,mask]=warpImage_v2(im,vx,vy,R)

S = 1/R;

[height2,width2,nchannels]=size(im);
%[height1,width1]=size(vx);

height1 = height2;
width1 = width2;

%vx = imresize(vx,S);
%vy = imresize(vy,S);

[xx,yy]=meshgrid(1:width2,1:height2);
[XX,YY]=meshgrid(1:width1,1:height1);
XX=XX+vx;
YY=YY+vy;
mask=XX<1 | XX>width2 | YY<1 | YY>height2;
XX=min(max(XX,1),width2);
YY=min(max(YY,1),height2);

%tic
for i=1:nchannels
    %foo=interp2(xx,yy,im(:,:,i),XX,YY,'bicubic');
    foo=interp2(xx,yy,im(:,:,i),XX,YY);
    %foo=qinterp2(xx,yy,im(:,:,i),XX,YY);
    foo(mask)=0.6;
    warpI2(:,:,i)=foo;
end
%toc

mask=1-mask;