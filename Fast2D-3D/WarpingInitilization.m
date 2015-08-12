function [Gx, Gy, xx, yy, YY] = WarpingInitilization(vres,hres,R)

%vres,hres: vertical and horizontal resolutions of the original left frame
%R: resize factor: set to 4

flows = imresize(zeros(vres,hres),R);

[Gx, Gy] = getVideoGradients_noMotion(flows);

[xx,yy]=meshgrid(1:hres,1:vres);
YY=yy;
YY=min(max(YY,1),vres);

end

function [Gx, Gy] = getVideoGradients_noMotion( flow )
%flow: defined from GetGxGy

%FINDADJACENT flow - w x h x 2 x K flow feild
% Output vertical, horizontal, and temporal adjacencies

[h,w,~,K] = size(flow);
N = h*w*K; %number of pixels in entire video

%Horizontal adjacencies
left = -ones(N,1);
left( w*h*repmat(1:K,[h,1])' - repmat((1:h),[K,1])+1 ) = 0;
Gx = spdiags([left, ones(N,1)], [-h,0], N, N);

%Vertical adjacencies
top = -ones(N,1);
top(h:h:end) = 0;
Gy = spdiags([top,ones(N,1)], [-1,0], N, N);

end

