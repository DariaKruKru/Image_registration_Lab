%% read the images
im_ref=  imread('im2_ref.jpg');
im_sen=  imread('im2_sen.jpg');

im_ref_gr = rgb2gray(im_ref);
im_sen_gr = rgb2gray(im_sen);

%% apply registration
[optimizer, metric] = imregconfig('multimodal');

optimizer.InitialRadius = 0.001;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 600;

im_reg = imregister(im_sen_gr, im_ref_gr, 'affine', optimizer, metric);

figure; imshowpair(im_ref_gr, im_reg,'Scaling','joint')

%% quality estimation

%Intensity-based
pix_ref_gr=im_ref_gr(:);
pix_reg=im_reg(:);

N= size(im_ref_gr,1)*size(im_ref_gr,2);
sumI=sum((pix_ref_gr-pix_reg).^2);

RMSE=sqrt(double(sumI/(N-1)))

RMSE_rel=(RMSE)/double(max(pix_ref_gr)-min(pix_ref_gr));

%CP-based

% Step 3. Implement a CP-location-based quality metric. 

% 3.1. Extract anew CP in the original and registered images, using a
% different feature than the one you used for solving the registration
% problem

CPs_eval_ref=detectFASTFeatures(im_ref_gr);
CPs_eval_reg=detectFASTFeatures(im_reg);

[CPs_eval_ref_feat,  CPs_eval_ref_ext]  = extractFeatures(im_ref_gr,  CPs_eval_ref);
[CPs_eval_reg_feat,  CPs_eval_reg_ext]  = extractFeatures(im_reg,  CPs_eval_reg);

%3.2. Match both and show the results

[indexPairs,matchmetric] = matchFeatures(CPs_eval_ref_feat, CPs_eval_reg_feat);
matched_set_ref=CPs_eval_ref_ext(indexPairs(:,1));
matched_set_reg=CPs_eval_reg_ext(indexPairs(:,2));

% Show the results Using showMatchedFeatures function
figure, ax=axes;
showMatchedFeatures(im_ref_gr, im_reg, matched_set_ref, matched_set_reg,'Parent',ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points Ref','Matched points Registered');

% Show the results using a plot of CP locations with different symbols
%figure, imshow(im_ref),hold on, plot(matched_set_ref.Location(:,1), matched_set_ref.Location(:,2), 'ro'),plot(matched_set_reg.Location(:,1),matched_set_reg.Location(:,2),'bx');legend(' Original', 'Registered');


% 3.3. Refine previous steps if you don't get a full set of correct matches

% 3.4. Compute the Euclidean average distance between matched CPs
dif_x = matched_set_ref.Location(:,1) - matched_set_reg.Location(:,1);
dif_y = matched_set_ref.Location(:,2) - matched_set_reg.Location(:,2);

max_hor = max(abs(dif_x));
max_ver = max(abs(dif_y));

CP_Loc_error=(1/(size(matched_set_ref,1)-1))* sum(sqrt(dif_x.^2 + dif_y.^2 ));

