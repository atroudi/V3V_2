
% vres,hres: vertical and horizontal resolutions of the original left frame
% R: resize factor: set to 4
% GetGxGy
function [Gx, Gy, xx, yy, YY] = WarpingInitilization(vres, hres, R)

% Make new image (flows) of size vres*hres resized by factor (R)
% initialized by all zeroes
flows = imresize(zeros(vres,hres),R);

[Gx, Gy] = getVideoGradients_noMotion(flows);

[xx,yy]=meshgrid(1:hres,1:vres); 
YY=yy;
% max(YY,1)??? no elements less than 1 in YY
% min(max(YY,1),vres)??? no elements more than vres in YY
YY=min(max(YY,1),vres);

end

% flow: defined from GetGxGy (zero image of pre defined size)
% FINDADJACENT flow - w x h x 2 x K flow field
% Output vertical, horizontal, and temporal (for videos) adjacencies
function [Gx, Gy] = getVideoGradients_noMotion( flow )

% Get height (h) and width (w) of the given image
% What is ~, K (They are normaly ones)
% I think they can be color value or something used in videos 
% While here we are only dealing with images
[h,w,~,K] = size(flow);

% Calculate Number of pixels in entire video (N)
N = h*w*K;

% Calculate Horizontal adjacencies (Gx)
% left: 1D array of size N filled by -1
left = -ones(N,1);
% set some indices in left by 0
% w*h*repmat((1:K), [h,1])': produce 2D array h*k each row(i) w*h*i
% repmat((1:h), [K,1]) + 1: prodeuce 2D array h*k each row(i) from 1 to h
% result: 2D array of size h*k from w*h*i to w*h*i-h+1 
% set left to zeros at results array values
left( w * h * repmat((1:K), [h,1])' - repmat((1:h), [K,1]) + 1 ) = 0;
% put left on the diagonal number "-h"
% put N ones in the main diagonal number "0"
Gx = spdiags([left, ones(N,1)], [-h,0], N, N);

% Calculate Vertical adjacencies (Gy)
top = -ones(N,1);
% each h indices put 0 instead of 1
top(h:h:end) = 0;
Gy = spdiags([top,ones(N,1)], [-1,0], N, N);

end

