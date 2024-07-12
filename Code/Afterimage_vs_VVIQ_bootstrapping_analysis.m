%% Bootstrapping Correlation of Afterimage/Image vs VVIQ

% Kronemer, et al., Neuroscience of Consciousness, 2024

% This script will load the behavioral data and run bootstrap analyses on
% the correlation between VVIQ and image/afterimage sharpness, contrast,
% and duration.

% INPUT:
% Data file (.xlsx)

% OUTPUT:
% Boostrap results figures (see Kronemer et al., 2024 Figure 3)

% Written by: Sharif I. Kronemer
% Last Modified: 7/12/2024

clear all

%% Directories

% Data directory
data_dir = pwd;

%% Parameters

% Excluded subjects
excluded_subjects = '027';

% Number of iterations
num_it = 5000;

%% Load Data file

% Open data table
[num, text, raw] = xlsread(fullfile(data_dir,'Participant_Afterimage_Image_VVIQ_Data.xlsx'));

% Subject ID
subject_list = raw(2:end,1);

% VVIQ
VVIQ = cell2mat(raw(2:end,2)');

% Afterimage contrast
afterimage_contrast = cell2mat(raw(2:end,9)');

% Image contrast
image_contrast = cell2mat(raw(2:end,7)');

% Afterimage sharpness
afterimage_sharpness = cell2mat(raw(2:end,6)');

% Image sharpness
image_sharpness = cell2mat(raw(2:end,4)');

% Afterimage duration
afterimage_duration = cell2mat(raw(2:end,12)');

% Image duration
image_duration = cell2mat(raw(2:end,10)');

% Exclude subject(s) from data sets
if ~isempty(excluded_subjects)

    % Find subject index
    sub_idx = find(strcmp(subject_list,excluded_subjects));

    % Remove from data arrays
    VVIQ(sub_idx) = [];
    afterimage_contrast(sub_idx) = [];
    image_contrast(sub_idx) = [];
    afterimage_sharpness(sub_idx) = [];
    image_sharpness(sub_idx) = [];
    afterimage_duration(sub_idx) = [];
    image_duration(sub_idx) = [];

end

%% Calculate correlation coefficient

% VVIQ vs afterimage contrast
[R,P,RL,RU] = corrcoef(VVIQ,afterimage_contrast);

% Find r value
af_contrast_r = R(1,2);

% VVIQ vs image contrast
[R,P,RL,RU] = corrcoef(VVIQ,image_contrast);

% Find r value
img_contrast_r = R(1,2);

% VVIQ vs afterimage sharpness
[R,P,RL,RU] = corrcoef(VVIQ,afterimage_sharpness);

% Find r value
af_sharpness_r = R(1,2);

% VVIQ vs image sharpness
[R,P,RL,RU] = corrcoef(VVIQ,image_sharpness);

% Find r value
img_sharpness_r = R(1,2);

% VVIQ vs afterimage duration
[R,P,RL,RU] = corrcoef(VVIQ,afterimage_duration);

% Find r value
af_duration_r = R(1,2);

% VVIQ vs image duration
[R,P,RL,RU] = corrcoef(VVIQ,image_duration);

% Find r value
img_duration_r = R(1,2);

%% Bootstrapping

% Reproducibility
rng default

% VVIQ vs afterimage contrast
[bootstat_af_contrast,bootsam_af_contrast] = bootstrp(num_it,'corr',VVIQ,afterimage_contrast);
bootconfidence_af_contrast = bootci(num_it,@corr,VVIQ',afterimage_contrast');

% VVIQ vs image contrast
[bootstat_img_contrast,bootsam_img_contrast] = bootstrp(num_it,'corr',VVIQ,image_contrast);
bootconfidence_img_contrast = bootci(num_it,@corr,VVIQ',image_contrast');

% VVIQ vs afterimage sharpness
[bootstat_af_sharpness,bootsam_af_sharpness] = bootstrp(num_it,'corr',VVIQ,afterimage_sharpness);
bootconfidence_af_sharpness = bootci(num_it,@corr,VVIQ',afterimage_sharpness');

% VVIQ vs image sharpness
[bootstat_img_sharpness,bootsam_img_sharpness] = bootstrp(num_it,'corr',VVIQ,image_sharpness);
bootconfidence_img_sharpness = bootci(num_it,@corr,VVIQ',image_sharpness');

% VVIQ vs afterimage duration
[bootstat_af_duration,bootsam_af_duration] = bootstrp(num_it,'corr',VVIQ,afterimage_duration);
bootconfidence_af_duration = bootci(num_it,@corr,VVIQ',afterimage_duration');

% VVIQ vs image duration
[bootstat_img_duration,bootsam_img_duration] = bootstrp(num_it,'corr',VVIQ,image_duration);
bootconfidence_img_duration = bootci(num_it,@corr,VVIQ',image_duration');

% VVIQ vs afterimage VS VVIQ vs image contrast
bootstat_af_minus_img_contrast = bootstat_af_contrast-bootstat_img_contrast; 
sort_bootstat_af_minus_img_contrast = sort(bootstat_af_minus_img_contrast);

% VVIQ vs afterimage VS VVIQ vs image sharpness
bootstat_af_minus_img_sharpness = bootstat_af_sharpness-bootstat_img_sharpness; 
sort_bootstat_af_minus_img_sharpness = sort(bootstat_af_minus_img_sharpness);

% VVIQ vs afterimage VS VVIQ vs image duration
bootstat_af_minus_img_duration = bootstat_af_duration-bootstat_img_duration; 
sort_bootstat_af_minus_img_duration = sort(bootstat_af_minus_img_duration);

% Calculate confidence interval
bootstat_af_minus_img_contrast_CI = [sort_bootstat_af_minus_img_contrast(round(0.025*(num_it+1))), sort_bootstat_af_minus_img_contrast(round(0.975*(num_it+1)))];
bootstat_af_minus_img_duration_CI = [sort_bootstat_af_minus_img_duration(round(0.025*(num_it+1))), sort_bootstat_af_minus_img_duration(round(0.975*(num_it+1)))];
bootstat_af_minus_img_sharpness_CI = [sort_bootstat_af_minus_img_sharpness(round(0.025*(num_it+1))), sort_bootstat_af_minus_img_sharpness(round(0.975*(num_it+1)))];

%% Visualize Results

% Axis variables
ymax = 500;
xmin = -0.5;
xmax = 0.7;

% Plot image vs afterimage histogram - Contrast
figure
hold on

title('Contrast')
xlabel('Correlation (r)')
ylabel('Count')

% Limit labels
xlim([xmin xmax])
ylim([0 ymax])

% Histograms
h1 = histogram(bootstat_img_contrast,'FaceColor','b','EdgeColor','none');
h2 = histogram(bootstat_af_contrast,'FaceColor','red','EdgeColor','none');

% Set the bar width
h1.BinWidth = 0.025;
h2.BinWidth = 0.025;

% Plot the mean
plot([af_contrast_r,af_contrast_r],[0,ymax],'k')
plot([img_contrast_r,img_contrast_r],[0,ymax],'k')

% Plot confidence interval
plot([bootconfidence_img_contrast(1) bootconfidence_img_contrast(1)],[0,ymax],'--k')
plot([bootconfidence_img_contrast(2) bootconfidence_img_contrast(2)],[0,ymax],'--k')
plot([bootconfidence_af_contrast(1) bootconfidence_af_contrast(1)],[0,ymax],'--r')
plot([bootconfidence_af_contrast(2) bootconfidence_af_contrast(2)],[0,ymax],'--r')

% Zero ref line
plot([0 0],[0 ymax],'k')

% Plot image vs afterimage histogram - Sharpness
figure
hold on

title('Sharpness')
xlabel('Correlation (r)')
ylabel('Count')

% Limit labels
xlim([xmin xmax])
ylim([0 ymax])

% Histogram
h1 = histogram(bootstat_img_sharpness,'FaceColor','b','EdgeColor','none');
h2 = histogram(bootstat_af_sharpness,'FaceColor','red','EdgeColor','none');

% Set the bar width
h1.BinWidth = 0.025;
h2.BinWidth = 0.025;

% Plot the mean correlation
plot([af_sharpness_r,af_sharpness_r],[0,ymax],'k')
plot([img_sharpness_r,img_sharpness_r],[0,ymax],'k')

% Plot confidence interval
plot([bootconfidence_img_sharpness(1) bootconfidence_img_sharpness(1)],[0,ymax],'--k')
plot([bootconfidence_img_sharpness(2) bootconfidence_img_sharpness(2)],[0,ymax],'--k')
plot([bootconfidence_af_sharpness(1) bootconfidence_af_sharpness(1)],[0,ymax],'--r')
plot([bootconfidence_af_sharpness(2) bootconfidence_af_sharpness(2)],[0,ymax],'--r')

% Zero ref line
plot([0 0],[0 ymax],'k')

% Plot image vs afterimage histogram - Duration
figure
hold on

title('Duration')
xlabel('Correlation (r)')
ylabel('Count')

% Limit labels
xlim([xmin xmax])
ylim([0 ymax])

% Histogram
h1 = histogram(bootstat_img_duration,'FaceColor','b','EdgeColor','none');
h2 = histogram(bootstat_af_duration,'FaceColor','red','EdgeColor','none');

% Set the bar width
h1.BinWidth = 0.025;
h2.BinWidth = 0.025;

% Plot the mean
plot([af_duration_r,af_duration_r],[0,ymax],'k')
plot([img_duration_r,img_duration_r],[0,ymax],'k')

% Plot confidence interval
plot([bootconfidence_img_duration(1) bootconfidence_img_duration(1)],[0,ymax],'--k')
plot([bootconfidence_img_duration(2) bootconfidence_img_duration(2)],[0,ymax],'--k')
plot([bootconfidence_af_duration(1) bootconfidence_af_duration(1)],[0,ymax],'--r')
plot([bootconfidence_af_duration(2) bootconfidence_af_duration(2)],[0,ymax],'--r')

% Zero ref line
plot([0 0],[0 ymax],'k')

% VVIQ image vs VVIQ afterimage - Visualize Results

% Parameters
ymax = 350;
xmax = 1;
xmin = -0.5;

% Plot VVIQ image vs VVIQ afterimage histogram - Contrast
figure
hold on

title('VVIQ afterimage vs VVIQ image - Contrast')
xlabel('Correlation (r)')
ylabel('Count')

% Limit labels
xlim([xmin xmax])
ylim([0 ymax])
yticks([0 100 200 300])

% Histogram
h1 = histogram(bootstat_af_minus_img_contrast,'FaceColor','b','EdgeColor','none');

% Set the bar width
h1.BinWidth = 0.025;

% Plot confidence interval
plot([bootstat_af_minus_img_contrast_CI(1) bootstat_af_minus_img_contrast_CI(1)],[0,ymax],'--k')
plot([bootstat_af_minus_img_contrast_CI(2) bootstat_af_minus_img_contrast_CI(2)],[0,ymax],'--k')

% Zero ref line
plot([0 0],[0 ymax],'k')

% Plot VVIQ image vs VVIQ afterimage histogram - Sharpness
figure
hold on

title('VVIQ afterimage vs VVIQ image - Sharpness')
xlabel('Correlation (r)')
ylabel('Count')

% Limit labels
xlim([xmin xmax])
ylim([0 ymax])
yticks([0 100 200 300])

% Histogram
h1 = histogram(bootstat_af_minus_img_sharpness,'FaceColor','b','EdgeColor','none');

% Set the bar width
h1.BinWidth = 0.025;

% Plot confidence interval
plot([bootstat_af_minus_img_sharpness_CI(1) bootstat_af_minus_img_sharpness_CI(1)],[0,ymax],'--k')
plot([bootstat_af_minus_img_sharpness_CI(2) bootstat_af_minus_img_sharpness_CI(2)],[0,ymax],'--k')

% Zero ref line
plot([0 0],[0 ymax],'k')

% Plot VVIQ image vs VVIQ afterimage histogram - Duration
figure
hold on

title('VVIQ afterimage vs VVIQ image - Duration')
xlabel('Correlation (r)')
ylabel('Count')

% Limit labels
xlim([xmin xmax])
ylim([0 ymax])
yticks([0 100 200 300])

% Histogram
h1 = histogram(bootstat_af_minus_img_duration,'FaceColor','b','EdgeColor','none');

% Set the bar width
h1.BinWidth = 0.025;

% Plot confidence interval
plot([bootstat_af_minus_img_duration_CI(1) bootstat_af_minus_img_duration_CI(1)],[0,ymax],'--k')
plot([bootstat_af_minus_img_duration_CI(2) bootstat_af_minus_img_duration_CI(2)],[0,ymax],'--k')

% Zero ref line
plot([0 0],[0 ymax],'k')
