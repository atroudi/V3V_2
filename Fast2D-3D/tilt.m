function stereo= tilt(image, p)

H= size(image,1);
W= size(image,2);

TiltMethod = p.TiltMethod;
max_disp = p.max_disp;

%max_disp=max_disp/2; % if tilting both views

disp_per_row= max_disp/(H-1);

left=127*ones(H,W,3);
right=127*ones(H,W,3);

left= image;

if TiltMethod == 1
    
    %%% Using shifting %%%%%%%%%%%% 
    %
    %tic

    image= imresize(image,[H W*4]);

    for row=1:H   

        %left(row,1:end-round(disp_per_row*(H-row)),:)= image(row,round(disp_per_row*(H-row))+1:end,:); 
        right(row,round(disp_per_row*(H-row))+1:end,:)= image(row,round(linspace(1,4*W-round(4*disp_per_row*(H-row)),W-round(disp_per_row*(H-row)))),:);
    end

    %right_smooth = imresize(right,1/4); right_smooth= imresize(right_smooth,[size(right,1) size(right,2)]); % to blur it

    %white = right_smooth(:,:,1)>120 & right_smooth(:,:,2)>120 & right_smooth(:,:,3)>120;
    %white = repmat(white,1,1,3);

    %right = right.*~white + right_smooth.*white;
    %figure;imshow(uint8(255*white))
    %toc
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif TiltMethod ==2
    %
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
end

% Cutting the gray areas
stereo=[left(:,max_disp:end,:) right(:,max_disp:end,:)];
stereo= imresize(stereo,[size(left,1) 2*size(left,2)]);
