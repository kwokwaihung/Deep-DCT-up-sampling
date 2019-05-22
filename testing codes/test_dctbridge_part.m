clear;close all;
%% settings
folder = 'Test/Set5_14';

size_input = 16;
size_label = 16;
scale = 2;
stride = 8 ;
subpixel = 1;
pd =8;

%% initialization
data = zeros(size_input, size_input, 1, 1);
label = zeros(size_label, size_label, 1, 1);
padding = abs(size_input - size_label)/2;
count = 0;

% caffe here
addpath('D:\Projects2\caffe\matlab');
gpu_id = 1;
addpath('utils');
use_gpu=0;
weights='model\16x16_stage2.caffemodel';
model_deepsr = 'model\16x16_stage2.prototxt';

if use_gpu
    caffe.set_mode_gpu(); % for GPU
    caffe.set_device(gpu_id);
else
    caffe.set_mode_cpu(); % for CPU
end

%% generate data
filepaths = dir(fullfile(folder,'*.bmp'));

for scale=2:1:2
    marix_norm_pad=zeros(1,19);
    marix_norm_our=zeros(1,19);
    marix_psnr_pad=zeros(1,19);
    marix_psnr_our=zeros(1,19);
    for i = 1 : length(filepaths)
        i
        
        image = imread(fullfile(folder,filepaths(i).name));
        [sy,sx,chno]=size(image);
        
        if chno~=1
            image = rgb2ycbcr(image);
        end
        
        image = im2double(image(:, :, 1));
        im_label = modcrop(image, 8);
        
        %
        [sy,sx,chno]=size(im_label);
        image_pad=zeros(sy+2*pd,sx+2*pd,chno);
        for ch=1:1:chno
            image_pad(:,:,ch)=padimage_2_old(im_label(:,:,ch),pd);
        end
        im_label=(image_pad);
        %
        
        [hei,wid] = size(im_label);
        whole_image=zeros(hei,wid);
        num_calcul=zeros(hei,wid);
        
        im_input= DCT_down_up_sample(im_label, 1, 0);
        im_input= DCT_down_up_sample(im_input, 2, 1);
        im_input_DCT= DCT_down_up_sample(im_input, 4, 0);
        im_label_DCT= DCT_down_up_sample(im_label, 4, 0);
        
        inputdata = im_input_DCT(1 : 1+size_input-1, 1 : 1+size_input-1);
        model_1=model_deepsr;
        [wid_i,hei_i,channels_num] = size(inputdata);
        fidin1=fopen(model_1,'r+');
        ii=0;
        while ~feof(fidin1)
            tline=fgetl(fidin1);
            ii=ii+1;
            newtline{ii}=tline;
            if ii == 4
                newtline{ii}=[tline(1:11) num2str(channels_num)];
            end
            if ii == 5
                newtline{ii}=[tline(1:11) num2str(hei_i)];
            end
            if ii == 6
                newtline{ii}=[tline(1:11) num2str(wid_i)];
            end
        end
        fclose(fidin1);
        fidin1=fopen(model_1,'w+');
        for j=1:ii
            fprintf(fidin1,'%s\n',newtline{j});
        end
        fclose(fidin1);
        %%%%%%%%%%%%%%%%%%%%%%%%
        net_1 = caffe.Net(model_1, weights, 'test'); % create net and load weights
        
        tic
        
        for x = 1 : stride : hei-size_input+1
            for y = 1 :stride : wid-size_input+1
                
                subim_input_DCT = im_input_DCT(x : x+size_input-1, y : y+size_input-1);
                count=count+1;
                res = net_1.forward({subim_input_DCT});
                im_h_y_deepsr = res{1};
                im_h_y_deepsr = reshape(im_h_y_deepsr, 16,16);
                                
                whole_image(x : x+size_input-1, y : y+size_input-1)= whole_image(x : x+size_input-1, y : y+size_input-1)+im_h_y_deepsr;
                num_calcul(x : x+size_input-1, y : y+size_input-1)=num_calcul(x : x+size_input-1, y : y+size_input-1)+1;
                                
            end
        end
        caffe.reset_all();
        toc
        
        whole_image_DCT=whole_image./num_calcul;
        
        im_input=im_input(1+pd:hei-pd, 1+pd:wid-pd);
        im_label=im_label(1+pd:hei-pd, 1+pd:wid-pd);
        whole_image_DCT=whole_image_DCT(1+pd:hei-pd, 1+pd:wid-pd);
        
        [psnr1]=csnr_index(im_input.*255,im_label.*255,0,0);
        [psnr2]=csnr_index(whole_image_DCT.*255,im_label.*255,0,0);
        psnr1
        psnr2
        
        str1='result\dct\zero_padd_';  %result folder
        str2='result\dct\dct_';
        
        str3=num2str(i);
        str4='.bmp'
        name_pad=[str1,str3,str4];
        name_proposed=[str2,str3,str4]
        
%         imwrite(uint8(im_input.*255),name_pad);
        imwrite(uint8(whole_image_DCT.*255),name_proposed);
        
        marix_psnr_pad(i)= psnr1;
        marix_psnr_our(i)=psnr2;
        
    end
    
    sum_pad=sum(marix_psnr_pad);
    sum_our=sum(marix_psnr_our);
    sum_pad
    sum_our
    
end

order = randperm(count);
data = data(:, :, 1, order);
label = label(:, :, 1, order);
