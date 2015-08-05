function stereo= tilt(image, max_disp)

H= size(image,1);
W= size(image,2);

%max_disp=max_disp/2; % if tilting both views

disp_per_row= max_disp/(H-1);

left=127*ones(H,W,3,'uint8');
right=127*ones(H,W,3, 'uint8');

%%% Using shifting %%%%%%%%%%%% 
%tic
for row=1:H   
    
    %left(row,1:end-round(disp_per_row*(H-row)),:)= image(row,round(disp_per_row*(H-row))+1:end,:); 
    right(row,round(disp_per_row*(H-row))+1:end,:)= image(row,1:end-round(disp_per_row*(H-row)),:);
end

left= image;
right= imresize(right,1/4); right= imresize(right,4); % to blur it
%toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
%%% Using interp2 %%%%%%%%%%%%

%For tilting we should use either 'Using shifting' or 'Using interp2'. The other section should be commented out. 
%Interp2 is to avoid the shagginessss of the white lines. It performs linear interpolation to generate the right view instead of shifting. 
%In this case we wont need to blur it but it will be around 12 times slower than shifting.

%tic
[X,Y] = meshgrid(1:W,1:H);
right(:,:,1) = interp2(X,Y,double(image(:,:,1)),X-disp_per_row*(H-Y),Y);
right(:,:,2) = interp2(X,Y,double(image(:,:,2)),X-disp_per_row*(H-Y),Y);
right(:,:,3) = interp2(X,Y,double(image(:,:,3)),X-disp_per_row*(H-Y),Y);
%toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

% Cutting the gray areas
stereo=[left(:,max_disp:end,:) right(:,max_disp:end,:)];
stereo= imresize(stereo,[size(image,1) 2*size(image,2)]);
