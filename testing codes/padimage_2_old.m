function output=padimage_2(f,pd)

% padimage_2 is version 2, which has continuouse boundary.

%f is input image to be padded
% x is width of image
% y is height of image
% pd is number of pixels to be padded
[y x]= size(f);

output= [ fliplr(flipud(f))  flipud(f)   fliplr(flipud(f))
          fliplr(f)             f        fliplr(f)
          fliplr(flipud(f))  flipud(f)   fliplr(flipud(f))];

output= output(y+1-pd:y+y+pd, x+1-pd:x+x+pd);

return;