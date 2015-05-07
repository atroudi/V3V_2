
function [Gy, Gx]= poisson_solve_generateDIV(img)

img = double(img)/255;
img = img - min(img(:));

H = size(img,1);
W = size(img,2);


% compute gradients
Gx = img(:,2:end) - img(:,1:end-1);
Gy = img(2:end,:) - img(1:end-1,:);
Gx = [Gx zeros(H,1)];
Gy = [Gy; zeros(1,W)];


