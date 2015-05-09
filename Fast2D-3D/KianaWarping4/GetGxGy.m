function [Gx, Gy, xx, yy, YY] = GetGxGy(vres,hres,R)

flows = imresize(zeros(vres,hres),R);

[Gx, Gy] = getVideoGradients_noMotion(flows);

[xx,yy]=meshgrid(1:hres,1:vres);
YY=yy;
YY=min(max(YY,1),vres);