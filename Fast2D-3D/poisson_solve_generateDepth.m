
function output = poisson_solve_generateDepth(Gy,Gx,boundary_query)

warning('off','all')

H = size(Gx,1);
W = size(Gx,2);


%%%%% Boundary Cuts  %%%%%%%%%%%%%%%%%%%%%%

boundary_query = imresize(boundary_query, size(Gx));

boundary_query_obj = imfill(boundary_query,'holes');

if min(boundary_query_obj(:))~=0 % in case the mask is pure white, make a point black so canny wont go crazy.
    boundary_query_obj(1,1)=0;
end

[boundary_query, thresh] = edge(boundary_query_obj,'canny',[0.07    0.0808]);

% cut lower 25% of each object
L = bwconncomp(boundary_query_obj',8);
boundary_query_T = boundary_query';
boundary_query_T = boundary_query_T(:);

for id = 1:L.NumObjects
    object_pix = cell2mat(L.PixelIdxList(id));
    if sum(object_pix>(H-1)*W)>W/10 && sum(rem(object_pix,W)==0)>H/20 && sum(rem(object_pix,W)==1)>H/20 % if its well connected to the 3 edges (left, right, bottom)
      boundary_query_T(object_pix(1:end)) = 0; % we shouldn't include it's boundaries in the boundary cut
    else
      boundary_query_T(object_pix(0.75*length(object_pix):end)) = 0;
    end
end

boundary_query = reshape (boundary_query_T,size(boundary_query'));
boundary_query = imfill(boundary_query','holes');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computing divergence

divGx = Gx(:,2:end) - Gx(:,1:end-1);
divGy = Gy(2:end,:) - Gy(1:end-1,:);
divGx = [Gx(:,1) divGx];
divGy = [Gy(1,:); divGy];
divG = divGx + divGy;


% vector b
b = double(divG(:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constructing sparse matrix A:

  % initialize
is = zeros(1,5*H*W);
js = is;
ss = is;
count = 0;
inds = 1:(H*W);
inds = reshape(inds, [H,W]);


  % diagonal
for i=1:H*W
    count = count + 1;
    is(count) = i;
    js(count) = i;
    ss(count) = -4;
end


 % connetions with neighbours
for i=1:H*W
   
    r = rem(i-1,H)+1;
    c = (i-r)/H + 1;
    
    
    % top
    if r > 1 && ((boundary_query(r,c)==0 && boundary_query(r-1,c)==0) || (boundary_query(r,c) && boundary_query(r-1,c)) || (~boundary_query(r,c) && boundary_query(r-1,c))) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r-1,c);
        ss(count) = 1;
        
    elseif r <= 1
        ss(i) = ss(i) + 1;
         
    else
       ss(i) = ss(i) + 1;
       b(i) = b(i)+ Gy(r-1,c);
    end
    
    
    % bottom
    if r < H && ((boundary_query(r+1,c)==0 && boundary_query(r,c)==0) || (boundary_query(r+1,c)&& boundary_query(r,c)) || (boundary_query(r,c) && ~boundary_query(r+1,c))) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r+1,c);
        ss(count) = 1;
      
    elseif r >= H
        ss(i) = ss(i) + 1;
        b(i) = b(i)- Gy(r,c);
        
    else
        ss(i) = ss(i) + 1;
        b(i) = b(i)- Gy(r,c);
    end
    
    
    % left
    if c > 1 && ((boundary_query(r,c)==0 && boundary_query(r,c-1)==0) ) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r,c-1);
        ss(count) = 1;
        
    elseif c<=1
        ss(i) = ss(i) + 1;
        
    else
        ss(i) = ss(i) + 1;
        b(i) = b(i)+ Gx(r,c-1);
    end
    
    
    % right
    if c < W && ((boundary_query(r,c)==0 && boundary_query(r,c+1)==0 ) ) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r,c+1);
        ss(count) = 1;
        
    elseif c >= W
        ss(i) = ss(i) + 1;
        b(i) = b(i)- Gx(r,c);
        
    else
        ss(i) = ss(i) + 1;
        b(i) = b(i)- Gx(r,c);
    end  
    
end


A = sparse(is(1:count),js(1:count),ss(1:count));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = A\b;   

output = reshape(x,[H,W]);
output = 255*(output - min(output(:)))/(max(output(:))- min(output(:)));
