RAW = double(imread('/Users/OmarEltobgy/Dropbox/WarpingTest1/RGB/3.png')) / 255;
D = double(imread('/Users/OmarEltobgy/Dropbox/WarpingTest1/Depth/3.png'));
D = D(:, :, 1) / 255;

[vres hres u] = size(RAW);

R = 0.25;

[Gx, Gy, xx, yy, YY] = WarpingInitilization(vres, hres, R);

Thresh = 20;
SS = ViewInterpolation(RAW, D, Thresh, R, Gx, Gy, xx, yy, YY);

% Testing output SS and SS1
x = double(imread('/Users/OmarEltobgy/Dropbox/WarpingTest1/SS/3.png'));
y = double(imread('/Users/OmarEltobgy/Dropbox/WarpingTest1/SS1/3.png'));
max(max(max(x-y)))

%{
fileID = fopen('test2.txt','w');
for i = 1:100
    for j = 1:100
        fprintf(fileID, '%f\n', disparity0(i, j));
    end
end
fclose(fileID);
%}

% imwrite(I, '/Users/OmarEltobgy/Dropbox/WarpingTest1/RGB/21.png', 'png');
