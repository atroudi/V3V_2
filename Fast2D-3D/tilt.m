function stereo= tilt(image, max_disp)

H= size(image,1);
W= size(image,2);

%max_disp=max_disp/2;

disp_per_row= max_disp/(H-1);

left=127*ones(H,W,3,'uint8');
right=127*ones(H,W,3, 'uint8');

%{
row=1;
image=gpuArray(image);
left= gpuArray(left);
right= gpuArray(right);
disp_per_row= gpuArray(disp_per_row);
row=gpuArray(row);
H=gpuArray(H);
W=gpuArray(W);
%}


for row=1:H
    
    %{
    for col=1:(W-round(disp_per_row*(H-row)))
        
        left(row,col)=image(row,round(disp_per_row*(H-row))+col);
        right(row,round(disp_per_row*(H-row))+col)=image(row,col);
    end
    %}
    
    
    %left(row,1:end-round(disp_per_row*(H-row)),:)= image(row,round(disp_per_row*(H-row))+1:end,:); 
    right(row,round(disp_per_row*(H-row))+1:end,:)= image(row,1:end-round(disp_per_row*(H-row)),:);

end

left= image;
right= imresize(right,1/4); right= imresize(right,4); % to smooth it down

stereo=[left(:,max_disp:end,:) right(:,max_disp:end,:)];
stereo= imresize(stereo,[size(image,1) 2*size(image,2)]);

%stereo=gather(stereo);