function [Gx, Gy, xx, yy, YY, X, Y, IDX, rowidx, colidx] = GetGxGy_temp(vres,hres,flows)

[Gx, Gy] = getVideoGradients_noMotion(flows);

[xx,yy]=meshgrid(1:hres,1:vres);
YY=yy;
YY=min(max(YY,1),vres);
    
%%%%%%%%%%

[h,w,~,K] = size(flows);
Nk = w*h;

[X,Y] = meshgrid(1:w,1:h);
IDX = sub2ind([h,w],Y(:),X(:));
rowidx = zeros(Nk*(K-1),1);
colidx = zeros(Nk*(K-1),1);
