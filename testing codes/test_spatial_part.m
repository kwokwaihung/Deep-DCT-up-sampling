clear;close all;
%% settings
folder = 'Test\Set5_14';
folder = 'result\dct';

size_input = 16;
size_input_2 = 16;
size_label = 16;
scale = 2;
stride = 8;
subpixel = 1;  % 1 means no subpixel, 0.5 means 0.5 subpixel shift
scale_b=1;
maximum_patch=1200000;
threshold = 0;

%% initialization
data = zeros(size_input, size_input, 1, 1);
data2 = zeros(size_input_2, size_input_2, 1, 1);
label = zeros(size_label, size_label, 1, 1);
padding = abs(size_input - size_label)/2;
count = 0;

marix_psnr_pad=zeros(100,19);
marix_psnr_our=zeros(100,19);

marix_ssim_pad=zeros(100,19);
marix_ssim_our=zeros(100,19);

addpath('D:\Projects2\caffe\matlab');
gpu_id =0;
addpath('utils');
use_gpu=0;

weights='model\proposed_33layer.caffemodel';
model_deepsr = 'model\proposed_33layer.prototxt';

index=0;
for weight_iter=6536:6536:6536
    index=index+1;
    
    if use_gpu
        caffe.set_mode_gpu(); % for GPU
        caffe.set_device(gpu_id);
    else
        caffe.set_mode_cpu(); % for CPU
    end
    
    
    %% generate data
    filepaths = [dir(fullfile(folder,'*.bmp'))
        dir(fullfile(folder,'*.jpg'))];
    
    for scale=2:1:2
        
        for i = 1 : length(filepaths)
            i
            image = imread(fullfile(folder,filepaths(i).name));
            im_label = imread(fullfile(folder1,filepaths(i).name));
            
            [sy,sx,chno]=size(im_label);
            
            if chno~=1
                im_label = rgb2ycbcr(im_label);
            end
            
            im_label = im2double(im_label(:, :, 1));
            im_label = modcrop(im_label, 8);
            image = im2double(image(:, :, 1));
            [hei,wid]=size(image);
            
            tic
            im_h_y_deepsr = do_cnn(model_deepsr,weights,image);
            im_h_y_deepsr = reshape(im_h_y_deepsr, hei,wid);
            toc
            
            [psnr1]=csnr_index(im_h_y_deepsr.*255,im_label.*255,0,0);
            [psnr2]=csnr_index(image.*255,im_label.*255,0,0);
            [ssim1]=ssim_index(im_h_y_deepsr.*255,im_label.*255);
            psnr1
            
            str1='result\dct_spat_33\label_';
            str2='result\dct_spat_33\whole_';
            str3=filepaths(i).name;
            name_pad=[str1,str3];
            name_proposed=[str2,str3]
            
            marix_psnr_pad(index,i)= psnr1;
            marix_ssim_pad(index,i)= ssim1;
            
            count
        end
        temp= sum(marix_psnr_pad'/5)
        save('psnr_4.mat',  'temp');
        
        temp= sum(marix_ssim_pad'/5)
        save('ssim_4.mat',  'temp');
    end
end
