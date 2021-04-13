%% Lab - case 1

% Panoramic
clear all, close all, clc

I_ref = imread('im1_ref.jpg');
I_sen = imread('im1_sen.jpg');
regImg = imread('regImg.jpg');

A=0;
B=0;
endFlag = 0;

for i = 1:size(regImg,1)
    for j = 1:size(regImg,2)
        if (regImg(i,j) > 20) 
            A=i;
            B=j;
            endFlag = 1;
            break;     
        end
    end
    
    if endFlag==1
        break;
        
    end
end
   
pano = zeros(455+A,606+B,3);

for i=1:size(I_ref,1);
    for j=1:size(I_ref,2);
        for k = 1:size(I_ref,3);
     
            pano(i,j,k) = I_ref(i,j,k);
            
        end
        
    end
end


for i=1:size(I_sen,1)
    for j=1:size(I_sen,2)
        for k = 1:3
        
            pano(A+i,B+j,k) = I_sen(i,j,k);
            
        end
        
    end
end

imshow(uint8(pano))

%% quality estimation

%Intensity-based
im_ref_gr = rgb2gray(I_ref);
pix_ref_gr=im_ref_gr(:);
pix_reg=regImg(:);

N= size(im_ref_gr,1)*size(im_ref_gr,2);
sumI=sum((pix_ref_gr-pix_reg).^2);

RMSE=sqrt(double(sumI/(N-1)))

RMSE_rel=(RMSE)/double(max(pix_ref_gr)-min(pix_ref_gr));
% MSER - projection