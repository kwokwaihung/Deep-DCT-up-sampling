function output=padimage_3(f)

% padimage_2 is version 2, which has continuouse boundary.

%f is input image to be padded
% x is width of image
% y is height of image
% pd is number of pixels to be padded
% [y x]= size(f);

output= [ fliplr(flipud(f))  flipud(f)  
          fliplr(f)             f        ];
% if nocrop==0
% output= output(y+1-pdy:y+y+pdy, x+1-pdx:x+x+pdx);
% end
return;