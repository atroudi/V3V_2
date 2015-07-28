function SS = Warp_temp_test(imgs,depths,Thresh,R)

%%takes in K images and their depths, and warps 
%%imgs: images
%%depths: depths
%%R: resize factor 
%%Thresh: warping paramter...we always set to 20 

flows = GetFlows_temp(imgs,R); %get optical flow 

[vres hres u no_frames] = size(imgs);
[Gx, Gy, xx, yy, YY, X, Y, IDX, rowidx, colidx] = GetGxGy_temp(vres,hres,flows); %%estimating some global paramters 


SS = 255*WarpFinal_temp(imgs,depths,Thresh,R,Gx,Gy,flows,xx,yy,YY,X,Y,IDX,rowidx,colidx);





