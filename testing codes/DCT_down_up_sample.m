function I_output=DCT_down_up_sample(I, mode, overlap)
% I - input image
% mode = 1 downsample factor is 2; repeat if nessesary
% mode = 2 upsample factor is 2: repeat if nessesary
% overlap - for mode 2 only the overlap for zero padding



% if downsample, dct block =8x, if upsample, dct block=4x

if mode==1    % downsample
modulo=8;

sz = size(I);

if mod(sz, modulo)~=0
    print('Warning, wrong size');
end

[soy,sox] =size(I);

Idct=zeros(soy,sox);
Idct_idct_ds=zeros(soy/2,sox/2);

for j=1:8:sox
    for i=1:8:soy
        % dct
        Idct(i:i+7,j:j+7)=dct2(I(i:i+7,j:j+7));
        % scale
        temp=Idct(i:i+3,j:j+3)./2;
        % idct
        Idct_idct_ds((i+1)/2:(i+7)/2,(j+1)/2:(j+7)/2)= idct2(temp);
    end
end

    I_output= Idct_idct_ds;
    
elseif mode==2 || mode==22
  modulo=4;
  
  
pd=4;
I=padimage_2_old(I, pd);  %pad image
  
  I_ori=I;
  sz = size(I);
  
if mod(sz, modulo)~=0
    print('Warning, wrong size');
end  
    
[soy,sox] =size(I);

% circular shifts for 16 times, then average all results
I_all= zeros(soy*2,sox*2,overlap);

% for shy=0
%     for shx=0:1
shift= overlap^0.5-1;

for shy=0:shift
    for shx=0:shift
        I = I_ori;
        I = circshift(I,shy,1); I = circshift(I,shx,2); 
   


Idct_pad_zero=zeros(soy*2,sox*2);
Idct_pad_zero_idct=zeros(soy*2,sox*2);

for j=1:4:sox
    for i=1:4:soy
        % scaled dct
        Idct_pad_zero(1+(i-1)*2:1+(i-1)*2+3,1+(j-1)*2:1+(j-1)*2+3)=(dct2(I(i:i+3,j:j+3)))*2;
        % idct
        Idct_pad_zero_idct(1+(i-1)*2:1+(i-1)*2+7,1+(j-1)*2:1+(j-1)*2+7)= idct2(Idct_pad_zero(1+(i-1)*2:1+(i-1)*2+7,1+(j-1)*2:1+(j-1)*2+7));
    end
end

Idct_pad_zero_idct = circshift(Idct_pad_zero_idct,-shx*2,2); 
Idct_pad_zero_idct = circshift(Idct_pad_zero_idct,-shy*2,1); 
    


    %replace Low freq components
%     I = I_ori;
%     
%     for j=1:4:sox
%     for i=1:4:soy
%         % scaled dct
%         temp_dct=dct2(Idct_pad_zero_idct(1+(i-1)*2:1+(i-1)*2+7,1+(j-1)*2:1+(j-1)*2+7));
%         
%         temp_dct(1:4,1:4)=(dct2(I(i:i+3,j:j+3)))*2;
%         % idct
%         Idct_pad_zero_idct(1+(i-1)*2:1+(i-1)*2+7,1+(j-1)*2:1+(j-1)*2+7)= idct2(temp_dct);
%     end
% end
    


   
%     (shy)*4+shx+1 

I_all(:,:,(shy)*4+shx+1)= Idct_pad_zero_idct;

    end
end

I_output= zeros(soy*2,sox*2);

% for no=1:2
for no=1:overlap
    
    I_output= I_output+I_all(:,:,no);
end

    I_output= I_output./overlap;

    
    %replace Low freq components
    I = I_ori;
    
    for j=1:4:sox
    for i=1:4:soy
        % scaled dct
        temp_dct=dct2(I_output(1+(i-1)*2:1+(i-1)*2+7,1+(j-1)*2:1+(j-1)*2+7));
        
        temp_dct(1:4,1:4)=(dct2(I(i:i+3,j:j+3)))*2;
        % idct
        if mode==2
        I_output(1+(i-1)*2:1+(i-1)*2+7,1+(j-1)*2:1+(j-1)*2+7)= idct2(temp_dct);
        elseif mode==22
          I_output(1+(i-1)*2:1+(i-1)*2+7,1+(j-1)*2:1+(j-1)*2+7)= (temp_dct);
        end
    end
end
    
    I_output= I_output(1+pd*2:1+pd*2+(soy*2-2*pd*2)-1,1+pd*2:1+pd*2+(sox*2-2*pd*2)-1);
    
    
    
    elseif mode==3
  % bicubic + dct domain
  
  modulo=4;
    
pd=4;
I=padimage_2_old(I, pd);  %pad image

I=twotime_1dbicubic(I, 1,1); 

  imwrite(uint8(I.*255),'temp_bic.bmp');
  
  sz = size(I);
  
if mod(sz(1), modulo)~=0 || mod(sz(2), modulo)~=0
    print('Warning, wrong size');
end  

% dct now

[soy,sox] =size(I);

for j=1:8:sox
    for i=1:8:soy
        % dct
        I(i:i+7,j:j+7)=dct2(I(i:i+7,j:j+7));
    end
end

    I_output= I(1+pd*2:1+pd*2+(soy-2*pd*2)-1,1+pd*2:1+pd*2+(sox-2*pd*2)-1);
    
  
      elseif mode==4
  % dct domain
  
  modulo=8;
  
  sz = size(I);
  
if mod(sz(1), modulo)~=0 || mod(sz(2), modulo)~=0
    print('Warning, wrong size');
  end  

  [soy,sox] =size(I);

for j=1:8:sox
    for i=1:8:soy
        % dct
        I(i:i+7,j:j+7)=dct2(I(i:i+7,j:j+7));
    end
end
    I_output=I;
    
    
    
        elseif mode==5
  % dct domain
  
  modulo=8;
  
  sz = size(I);
  
if mod(sz(1), modulo)~=0 || mod(sz(2), modulo)~=0
    print('Warning, wrong size');
  end  

  [soy,sox] =size(I);

for j=1:8:sox
    for i=1:8:soy
        % dct
        I(i:i+7,j:j+7)=idct2(I(i:i+7,j:j+7));
    end
end
    I_output=I;
    
    
end
    
    





end
    
%     
%     
% if soy/8)
% 
% Idct_ds=zeros(soy/2,sox/2);
% I=zeros(soy,sox);
% Iobserved=zeros(soy,sox);
% % dct and insert zeros
% for j=1:8:sox
%     for i=1:8:soy
%         Id(i:i+7,j:j+7)=dct2(I(i:i+7,j:j+7));
%         Iobserved(i:i+3,j:j+3)=Id(i:i+3,j:j+3)./2;
%     end
% end
% %idct
% % It=zeros(soy,sox);
% Its=zeros(soy/2,sox/2);
% for j=1:8:sox
%     for i=1:8:soy
% %         It(i:i+7,j:j+7)=idct2(Id(i:i+7,j:j+7));
% %           It(i:i+7,j:j+7)=idct2(Iobserved(i:i+7,j:j+7).*2);
%           Its((i+1)/2:(i+7)/2,(j+1)/2:(j+7)/2)= idct2(Iobserved(i:i+3,j:j+3));
%     end
% end
% % imshow(uint8(It));
% % csnr(double(uint8(It)), double(uint8(I)),0,0)  %csnr(double(It), double(I),0,0)
% % ssim_index(uint8(It), uint8(I))
% % imwrite(uint8(Its),'lena_DS_DCT.bmp');
% % imwrite(uint8(It),'lena_DCT.bmp');
% 
% 
% return