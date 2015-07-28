
function [CLASS_out, last_count, last_class] = CleanClass(Query_rgb_original_all, CLASS,pre_count, pre_class)

consistency_threshold=75; % Don't allow a segment smaller than this value

% Finding the length of each segment with the same class
class_lengths = zeros(length(CLASS),2);

count = 1;
j = 1;

for i=1:length(CLASS)-1
    
    if CLASS(i) == CLASS(i+1)
        count = count+1;
    else
        diff = abs(rgb2gray(Query_rgb_original_all(:,:,:,i))-rgb2gray(Query_rgb_original_all(:,:,:,i+1)));
        if mean(diff(:))<=5
          CLASS(i+1) = CLASS(i); 
          count = count+1;
        else
          class_lengths(j,:) = [CLASS(i) count];
          count = 1;
          j = j+1;
        end
    end   
end

class_lengths(j,:) = [CLASS(i) count];
class_lengths(j+1:end,:) = [];



% Cleaning CLASS

CLASS_out = CLASS;
j = 1;

while j<=size(class_lengths,1)-1
    
    % For the first segment if it's in the middle of a scene cut consider the previous count too
    Pre = zeros(1, size(class_lengths,1));
    if class_lengths(1,1) == pre_class
      Pre(1)= pre_count;
    end

    if (class_lengths(j,2)+ Pre(j)) < min(consistency_threshold, length(CLASS))  % if a segment is larger than consistency_threshold it doesn't need to be cleaned. 
        
        if j>1 && j<size(class_lengths,1) && class_lengths(j-1,1) == class_lengths(j+1,1)
           CLASS_out(sum(class_lengths(1:j-1,2))+1 : sum(class_lengths(1:j,2))) = class_lengths(j-1,1);
           class_lengths(j-1,2) = class_lengths(j-1,2)+class_lengths(j,2)+class_lengths(j+1,2);
           class_lengths(j+1,:) = []; % delete entry
           class_lengths(j,:) = []; % delete entry
           
        elseif (j>1 && j<size(class_lengths,1) && (class_lengths(j-1,2)+ Pre(j-1)) >= (class_lengths(j+1,2)+ Pre(j+1))) || j==size(class_lengths,1)
           CLASS_out(sum(class_lengths(1:j-1,2))+1 : sum(class_lengths(1:j,2))) = class_lengths(j-1,1);
           class_lengths(j-1,2) = class_lengths(j-1,2)+class_lengths(j,2);
           class_lengths(j,:) = []; % delete entry 
           
        elseif (j>1 && j<size(class_lengths,1) && (class_lengths(j-1,2)+ Pre(j-1)) < (class_lengths(j+1,2)+ Pre(j+1))) || j==1
           CLASS_out(sum(class_lengths(1:j,2))- class_lengths(j,2)+1 : sum(class_lengths(1:j,2))) = class_lengths(j+1,1);
           class_lengths(j+1,2) = class_lengths(j+1,2)+class_lengths(j,2);
           class_lengths(j,:) = []; % delete entry 
            
        end 
        
    else
       j = j+1; 
       
    end
end

last_class = class_lengths(end,1);
last_count = class_lengths(end,2);