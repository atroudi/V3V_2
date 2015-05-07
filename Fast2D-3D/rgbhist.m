function H = rgbhist(I,nBins)

H=zeros([nBins(1) nBins(2) nBins(3)]);

im=reshape(I,[size(I,1)*size(I,2) 3]);
im_hsv=rgb2hsv(im);

for i=1:size(I,1)*size(I,2)
    
        p=double(im(i,:));
        p_hsv=double(im_hsv(i,:));
        
        if p(2)<p(1) || p(2)<p(3) % if not field
            
            p_hsv(1)= (p_hsv(1)+((1+eps)*3./(4*nBins(1)))); %rotating the bins 1/(2*nbin)
            p_hsv(1)= p_hsv(1) .* (p_hsv(1)<1);
            
            p=floor(p_hsv./((1+eps)./nBins))+1;
            H(p(1),p(2),p(3))=H(p(1),p(2),p(3))+1;
           
        end
end


H=H(:);
H=H./sum(H);
H=H>0.1;
