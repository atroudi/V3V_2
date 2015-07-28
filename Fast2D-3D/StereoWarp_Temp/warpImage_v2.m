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
    foo=interp2(xx,yy,im(:,:,i),XX,YY);
    %foo=qinterp2(xx,yy,im(:,:,i),XX,YY);
    foo(mask)=0.6;
    warpI2(:,:,i)=foo;
end
%toc

mask=1-mask;