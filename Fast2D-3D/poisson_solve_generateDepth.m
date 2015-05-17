
function [output]= poisson_solve_generateDepth(Gy,Gx,boundary_query, alpha, beta)

warning('off','all')

H = size(Gx,1);
W = size(Gx,2);


%%%%% Boundary Cuts  %%%%%%%%%%%%%%%%%%%%%%

boundary_query= imresize(boundary_query, size(Gx));

boundary_query_obj=imfill(boundary_query,'holes') ;

[boundary_query_modify, thresh] = edge(boundary_query_obj,'canny',[0.07    0.0808]);

boundary_query= boundary_query_modify ;

L = bwlabel(boundary_query_obj,8);
C=max(L(:));
cluster_bottom= zeros(H,W);

for cluster_id=1:C
    count=0;
    cluster= (L==cluster_id);
    row=H;
    num=0.25 * sum(cluster(:)); %  25% of each cluster  
    
    while count<num && row>0
      for col=1:W
          if cluster(row, col)
              count=count+1;
              cluster_bottom(row, col)=1;
          end
      end
         row=row-1; 
    end
    
end

boundary_query=(boundary_query- cluster_bottom)>0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computing divergence

divGx = Gx(:,2:end) - Gx(:,1:end-1);
divGy = Gy(2:end,:) - Gy(1:end-1,:);
divGx = [Gx(:,1) divGx];
divGy = [Gy(1,:); divGy];
divG = divGx + divGy;


% vector b
b = double(divG(:));
%b_smooth= zeros(size(b,1),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constructing sparse matrix A:

  % initialize
is = zeros(1,5*H*W);
js = is;
ss = is;

%is_sm=is;
%js_sm=is;
%ss_sm=is;

count = 0;
%count_sm =0;

  % diagonal
inds = 1:(H*W);
inds = reshape(inds, [H,W]);

for i=1:H*W
    count = count + 1;
    is(count) = i;
    js(count) = i;
    ss(count) = -4;
    
    %count_sm = count_sm + 1;
    %is_sm(count_sm) = i;
    %js_sm(count_sm) = i;
    %ss_sm(count_sm) = 12;
end


  % boundary pixels should connect to bottom or top
  
boundry_connect=char(zeros(H,W)); 
boundry_connect_m=char(zeros(H,W)); 
%{
for i=1:H*W
    
    r = rem(i-1,H)+1;
    c = (i-r)/H + 1;
    
    if boundary_query(r,c) 
       
        if  r==1     
            boundry_connect(r,c)= 'b';
            
        elseif r==H
            boundry_connect(r,c)='t';
            
        elseif boundary_query(r-1,c) 
            boundry_connect(r,c)= boundry_connect(r-1,c);
            
        elseif abs(Query(r,c)-Query(r+1,c)) <= abs(Query(r,c)-Query(r-1,c)) 
            boundry_connect(r,c)='b';
            
        elseif  abs(Query(r,c)-Query(r+1,c)) > abs(Query(r,c)-Query(r-1,c)) 
            boundry_connect(r,c)='t';
        end
        
        
        boundry_connect_m(r,c)='n';
        if boundary_query(r-1,c) && boundary_query(r+1,c) 
            boundry_connect_m(r,c)='m';% middle   
        end
       
    end
end
%}

  %boundry_connect_s=boundry_connect; % Boundary cuts for smoothing


 % connetions with neighbours
for i=1:H*W
   
    r = rem(i-1,H)+1;
    c = (i-r)/H + 1;
    
    boundry_connect(r,c)='b';
    boundry_connect_m(r,c)='n';
    
    % top
    if r > 1 && ((boundary_query(r,c)==0 && boundary_query(r-1,c)==0) || (boundary_query(r,c) && boundary_query(r-1,c) && ( strcmp(boundry_connect(r-1,c),'b') || strcmp(boundry_connect(r,c),'t') || strcmp(boundry_connect_m(r-1,c),'m') || strcmp(boundry_connect_m(r,c),'m'))) || (boundary_query(r,c) && ~boundary_query(r-1,c) && strcmp(boundry_connect(r,c),'t')) || (~boundary_query(r,c) && boundary_query(r-1,c) && strcmp(boundry_connect(r-1,c),'b'))) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r-1,c);
        ss(count) = 1;
        
    elseif r <= 1
        ss(i) = ss(i) + 1;
         
    else
       ss(i) = ss(i) + 1;
       b(i)=b(i)+ Gy(r-1,c);
    end
    %{
    if r > 1 && ((boundary_query(r,c)==0 && boundary_query(r-1,c)==0) || (boundary_query(r,c) && boundary_query(r-1,c) && ( strcmp(boundry_connect(r-1,c),'b') || strcmp(boundry_connect(r,c),'t') || strcmp(boundry_connect_m(r,c),'m') ||  strcmp(boundry_connect_m(r-1,c),'m'))) || (boundary_query(r,c) && ~boundary_query(r-1,c) && strcmp(boundry_connect_s(r,c),'t')) || (~boundary_query(r,c) && boundary_query(r-1,c) && strcmp(boundry_connect_s(r-1,c),'b')))
        count_sm = count_sm + 1;
        is_sm(count_sm) = i;
        js_sm(count_sm) = inds(r-1,c);
        ss_sm(count_sm) = -4;
           
            if r>2 && ((boundary_query(r-1,c)==0 && boundary_query(r-2,c)==0) || (boundary_query(r-1,c) && boundary_query(r-2,c) && ( strcmp(boundry_connect(r-2,c),'b') || strcmp(boundry_connect(r-1,c),'t') || (strcmp(boundry_connect_m(r-1,c),'m') ||  strcmp(boundry_connect_m(r-2,c),'m')))) || (~boundary_query(r-1,c) && boundary_query(r-2,c) && strcmp(boundry_connect_s(r-2,c),'b')) || (boundary_query(r-1,c) && ~boundary_query(r-2,c) && strcmp(boundry_connect_s(r-1,c),'t') )) 
               count_sm = count_sm + 1;
               is_sm(count_sm) = i;
               js_sm(count_sm) = inds(r-2,c);
               ss_sm(count_sm) = 1;
            else
               ss_sm(count_sm) = ss_sm(count_sm)+1;
            end
    else
            ss_sm(i) = ss_sm(i) -3;
    end
    %}
    
    % bottom
    if r < H && ((boundary_query(r+1,c)==0 && boundary_query(r,c)==0) || (boundary_query(r+1,c)&& boundary_query(r,c) && ( strcmp(boundry_connect(r,c),'b') || strcmp(boundry_connect(r+1,c),'t') || strcmp(boundry_connect_m(r,c),'m') ||  strcmp(boundry_connect_m(r+1,c),'m'))) || (boundary_query(r,c) && ~boundary_query(r+1,c) && strcmp(boundry_connect(r,c),'b')) || (~boundary_query(r,c) && boundary_query(r+1,c) && strcmp(boundry_connect(r+1,c),'t'))) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r+1,c);
        ss(count) = 1;
      
    elseif r >= H
        ss(i) = ss(i) + 1;
        b(i)=b(i)- Gy(r,c);
        
    else
        ss(i) = ss(i) + 1;
        b(i)=b(i)- Gy(r,c);
    end
    %{
    if r < H && ((boundary_query(r+1,c)==0 && boundary_query(r,c)==0) || (boundary_query(r+1,c)&& boundary_query(r,c) && ( strcmp(boundry_connect(r,c),'b') || strcmp(boundry_connect(r+1,c),'t') || strcmp(boundry_connect_m(r,c),'m') ||  strcmp(boundry_connect_m(r+1,c),'m'))) || (boundary_query(r,c) && ~boundary_query(r+1,c) && strcmp(boundry_connect_s(r,c),'b')) || (~boundary_query(r,c) && boundary_query(r+1,c) && strcmp(boundry_connect_s(r+1,c),'t'))) 
        count_sm = count_sm + 1;
        is_sm(count_sm) = i;
        js_sm(count_sm) = inds(r+1,c);
        ss_sm(count_sm) = -4;
        
            if r<H-1 && ((boundary_query(r+1,c)==0 && boundary_query(r+2,c)==0) || (boundary_query(r+1,c) && boundary_query(r+2,c) && ( strcmp(boundry_connect(r+1,c),'b') || strcmp(boundry_connect(r+2,c),'t') || (strcmp(boundry_connect_m(r+1,c),'m') ||  strcmp(boundry_connect_m(r+2,c),'m')))) || (boundary_query(r+1,c) && ~boundary_query(r+2,c) && strcmp(boundry_connect_s(r+1,c),'b')) || (~boundary_query(r+1,c) && boundary_query(r+2,c) && strcmp(boundry_connect_s(r+2,c),'t')))

               count_sm = count_sm + 1;
               is_sm(count_sm) = i;
               js_sm(count_sm) = inds(r+2,c);
               ss_sm(count_sm) = 1;
            else
               ss_sm(count_sm) = ss_sm(count_sm)+1;
            end
         else
           ss_sm(i) = ss_sm(i) -3; 
     end
    %}
    
    % left
    if c > 1 && ((boundary_query(r,c)==0 && boundary_query(r,c-1)==0) ) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r,c-1);
        ss(count) = 1;
        
        %count_sm = count_sm + 1;
        %is_sm(count_sm) = i;
        %js_sm(count_sm) = inds(r,c-1);
        %ss_sm(count_sm) = -4;
        %{
         if c > 2 && ((boundary_query(r,c-1)==0 && boundary_query(r,c-2)==0) ) 
           
           count_sm = count_sm + 1;
           is_sm(count_sm) = i;
           js_sm(count_sm) = inds(r,c-2);
           ss_sm(count_sm) = 1;
         else
           ss_sm(count_sm) = ss_sm(count_sm)+1;
         end
        %}
    elseif c<=1
        %ss_sm(i) = ss_sm(i) -3;
        ss(i) = ss(i) + 1;   
    else
        %ss_sm(i) = ss_sm(i) -3;
        ss(i) = ss(i) + 1;
        b(i)=b(i)+ Gx(r,c-1);
    end
    
    % right
    if c < W && ((boundary_query(r,c)==0 && boundary_query(r,c+1)==0 ) ) 
        count = count + 1;
        is(count) = i;
        js(count) = inds(r,c+1);
        ss(count) = 1;
        
        %count_sm = count_sm + 1;
        %is_sm(count_sm) = i;
        %js_sm(count_sm) = inds(r,c+1);
        %ss_sm(count_sm) = -4;
       %{
        if c < W-1 && ((boundary_query(r,c+1)==0 && boundary_query(r,c+2)==0) ) 
           
           count_sm = count_sm + 1;
           is_sm(count_sm) = i;
           js_sm(count_sm) = inds(r,c+2);
           ss_sm(count_sm) = 1;
        else
           ss_sm(count_sm) = ss_sm(count_sm)+1;
        end
        %}
    elseif c >= W
        %ss_sm(i) = ss_sm(i) -3;
        ss(i) = ss(i) + 1;
        b(i)=b(i)- Gx(r,c);
    else
        %ss_sm(i) = ss_sm(i) -3;
        ss(i) = ss(i) + 1;
        b(i)=b(i)- Gx(r,c);
    end  
    
end


A = sparse(is(1:count),js(1:count),ss(1:count));


%A_smooth = sparse(is_sm(1:count_sm),js_sm(1:count_sm),beta* ss_sm(1:count_sm)  );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


x = A\b;   %possion_error= reshape((A*x-b),[H,W]);  % solve without smooth


%A=[ double(A) ; double(A_smooth)];
%b=[ double(b) ; double(b_smooth)];

%x = A\b;   possion_error= reshape((A(1:H*W,:)*x-b(1:H*W)),[H,W]); % solve with smooth


output = reshape(x,[H,W]);
output = 255*(output - min(output(:)))/(max(output(:))- min(output(:)));
