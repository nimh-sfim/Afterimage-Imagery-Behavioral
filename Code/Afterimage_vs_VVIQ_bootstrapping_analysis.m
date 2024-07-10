%% Bootstrapping Correlation of Afterimage/Image VVIQ

% Written by: Sharif I. Kronemer
% Date: 3/16/2024

clear all

%% Define data vectors

% VVIQ
%VVIQ = [58	63	55	60	60	53	72	63	44	64	47	68	67	64	58	57	69	68	78	48	66	55	80	64	53	52	76	80	60	70	65	51	54	72	53	55	64	54	64	66	77	55	56	67	45	67	61	72	50	56	60	50	38	75	78	66	48	50	57	57	24	75];
VVIQ = [58
60
64
58
57
69
68
78
64
53
52
76
80
60
70
65
51
54
72
53
55
64
54
64
66
77
55
56
67
45
67
61
72
50
56
60
50
38
75
78
66
48
50
57]';
% Afterimage contrast
%afterimage_contrast = [0.170454545000000	0.227500000000000	0.188750000000000	0.195416667000000	0.165217391000000	0.228232759000000	0.255000000000000	0.187276786000000	0.0788135590000000	0.185208333000000	0.145955882000000	0.327850877000000	0.290000000000000	0.189166667000000	0.264583333000000	0.206041667000000	0.206034483000000	0.182838983000000	0.282236842000000	0.241875000000000	0.129347826000000	0.129605263000000	0.294791667000000	0.238125000000000	0.254166667000000	0.168632075000000	0.304385965000000	0.196458333000000	0.0673387100000000	0.152370690000000	0.264460784000000	0.174305556000000	0.209090909000000	0.302455357000000	0.121000000000000	0.249576271000000	0.213958333000000	0.168103448000000	0.132812500000000	0.332112069000000	0.368125000000000	0.234375000000000	0.176179245000000	0.133783784000000	0.266250000000000	0.112500000000000	0.184583333000000	0.385416667000000	0.170601852000000	0.158541667000000	0.243333333000000	0.309957627000000	0.225669643000000	0.161864407000000	0.330625000000000	0.197708333000000	0.185197368000000	0.176041667000000	0.128537736000000	0.238333333000000	0.215000000000000	0.253601695000000];
afterimage_contrast = [0.170454545454545
0.195416666666667
0.189166666666667
0.264583333333333
0.206041666666667
0.206034482758621
0.182838983050847
0.282236842105263
0.238125
0.254166666666667
0.168632075471698
0.304385964912281
0.196458333333333
0.0673387096774193
0.152370689655172
0.264460784313726
0.174305555555556
0.209090909090909
0.302455357142857
0.121
0.249576271186441
0.213958333333333
0.168103448275862
0.1328125
0.332112068965517
0.368125
0.234375
0.176179245283019
0.133783783783784
0.26625
0.1125
0.184583333333333
0.385416666666667
0.170601851851852
0.158541666666667
0.243333333333333
0.309957627118644
0.225669642857143
0.161864406779661
0.330625
0.197708333333333
0.185197368421053
0.176041666666667
0.238333333333333]';

% Image contrast
%image_contrast = [0.291666666666667	0.201470588235294	0.276388888888889	0.273611111111111	0.267187500000000	0.248529411764706	0.257812500000000	0.231944444444444	0.287500000000000	0.258333333333333	0.150000000000000	0.267647058823529	0.295588235294118	0.197222222222222	0.300000000000000	0.200000000000000	0.237500000000000	0.309375000000000	0.244444444444444	0.230555555555556	0.233333333333333	0.256944444444444	0.210294117647059	0.231944444444444	0.286111111111111	0.233333333333333	0.305555555555556	0.241666666666667	0.266666666666667	0.251388888888889	0.263888888888889	0.245833333333333	0.275000000000000	0.287500000000000	0.250000000000000	0.320833333333333	0.227941176470588	0.309722222222222	0.251388888888889	0.330555555555556	0.344444444444445	0.256944444444444	0.227777777777778	0.187500000000000	0.279166666666667	0.169444444444444	0.238888888888889	0.281944444444444	0.301388888888889	0.281944444444444	0.243055555555556	0.354166666666667	0.325000000000000	0.287500000000000	0.246875000000000	0.270833333333333	0.241176470588235	0.225000000000000	0.293055555555556	0.269444444444445	0.265277777777778	0.222222222222222];
image_contrast = [0.291666666666667
0.273611111111111
0.197222222222222
0.3
0.2
0.2375
0.309375
0.244444444444444
0.231944444444444
0.286111111111111
0.233333333333333
0.305555555555556
0.241666666666667
0.266666666666667
0.251388888888889
0.263888888888889
0.245833333333333
0.275
0.2875
0.25
0.320833333333333
0.227941176470588
0.309722222222222
0.251388888888889
0.330555555555556
0.344444444444445
0.256944444444444
0.227777777777778
0.1875
0.279166666666667
0.169444444444444
0.238888888888889
0.281944444444444
0.301388888888889
0.281944444444444
0.243055555555556
0.354166666666667
0.325
0.2875
0.246875
0.270833333333333
0.241176470588235
0.225
0.269444444444445]';
% Afterimage sharpness
afterimage_sharpness = [9.92857142900000	18.1428571400000	14.7000000000000	14.4444444400000	12.7500000000000	10.3928571400000	15.5333333300000	14.8518518500000	19.6206896600000	11.5666666700000	10.0555555600000	13.9666666700000	13.5666666700000	14.8666666700000	15.6666666700000	14.2333333300000	13.0689655200000	6.90000000000000	14.7666666700000	14.9666666700000	18.9642857100000	15.3103448300000	17.6333333300000	22.2333333300000	17.6000000000000	17.1666666700000	13.6785714300000	19.7000000000000	12.1052631600000	17.6000000000000	11.2500000000000	16.1379310300000	11.1904761900000	7	6.60000000000000	8.46153846200000	17.6666666700000	15.3157894700000	19.5714285700000	20.1000000000000	11.5862069000000	16.2916666700000	8.75862069000000	8.08333333300000	11.4000000000000	20.2142857100000	17.6896551700000	15.9333333300000	19.3571428600000	15.1000000000000	13.2000000000000	13.6000000000000	12.7200000000000	13.7931034500000	15.6000000000000	17.9333333300000	10.3888888900000	14.5862069000000	8.50000000000000	15.9666666700000	5.32000000000000	19.7037037000000];

% Image sharpness
image_sharpness = [15.7500000000000	9.89473684200000	17.8421052600000	15.8947368400000	11.6666666700000	16.1111111100000	16.8235294100000	16.6875000000000	15	13.3000000000000	13.1578947400000	14.0769230800000	13.4736842100000	12.4444444400000	17	17.7894736800000	13	14.9473684200000	12.8421052600000	13.8888888900000	14.1250000000000	15.5500000000000	14.4666666700000	17.4000000000000	15.2000000000000	11.3000000000000	16.3684210500000	14.4500000000000	11.1875000000000	16.7500000000000	15.8888888900000	17.2000000000000	16.6470588200000	15.1500000000000	13.5833333300000	17.3500000000000	16.3000000000000	16	16.2000000000000	17.2000000000000	18.2000000000000	14.8421052600000	13.3529411800000	12.1428571400000	13.3000000000000	14.2500000000000	13.3684210500000	14.4000000000000	12.9444444400000	17.0555555600000	17.5789473700000	15.6000000000000	17	13.7000000000000	15.4210526300000	12.4500000000000	12.2352941200000	14.9500000000000	16	15.2105263200000	13.4000000000000	14.5555555600000];

% Afterimage duration
afterimage_duration = [3.92199799000000	3.56293949800000	6.76779131800000	4.58081270800000	3.40030326700000	6.29865045900000	4.59784610300000	4.59406819500000	3.62267165700000	4.53840958300000	4.42307001800000	7.58401125900000	6.41088650500000	4.69209018800000	6.65787285700000	7.93247507400000	5.31301036900000	5.25639022700000	3.94874329200000	6.52007086600000	5.56621945800000	2.01946670800000	5.08242920600000	7.07350566400000	6.29009454000000	4.70240959500000	8.45934366800000	6.20140634500000	1.02501878700000	4.68493814000000	5.63613094200000	5.41246957300000	4.02974107800000	6.99606183700000	3.18849082900000	4.74930485600000	5.03741650000000	4.55042030400000	4.05184914900000	6.17697297300000	8.00770921900000	6.80595936100000	3.29000661500000	4.69820507200000	7.77907815500000	4.78300918400000	5.86455252100000	9.05919626900000	2.37072105600000	6.45218819400000	6.41171727300000	6.55999188800000	5.28167528800000	4.67714958800000	5.66013185500000	6.54977718300000	5.05244754700000	3.75394047400000	3.86905182100000	6.04435079300000	5.09638261500000	8.16445034400000];

% Image duration
image_duration = [3.43434042200000	1.95270663700000	4.19624727300000	2.91308363300000	3.47677500000000	3.36858823500000	2.56265625000000	3.64651666700000	3.03694444400000	2.26314262800000	2.82385197500000	3.56249936900000	4.08426911000000	3.86139212800000	5.52351560800000	3.37481964300000	2.81069777900000	2.17011867400000	4.59139096200000	3.01384804400000	3.34544702600000	3.70724882500000	2.09138117700000	3.75194379000000	3.12521353400000	2.91739397900000	4.24492506600000	2.80608144600000	3.48937256800000	2.98805380800000	3.24730787900000	3.39511201000000	3.31872204800000	5.06331135700000	5.06268718500000	3.72204104500000	2.84058275200000	4.25447527200000	4.77378193100000	4.35335087500000	4.07313741300000	3.15673320000000	1.96067946900000	3.89103437700000	3.67088923600000	5.52733644900000	6.28733074600000	4.76877518200000	4.20058584700000	4.23217765700000	4.72661940600000	3.58897688900000	3.93082561000000	3.29367281400000	3.34073283700000	3.69678571100000	6.32457440000000	3.40155811100000	3.47481408400000	3.92061773700000	3.49787533700000	3.59555507900000];

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

%% Bootstrap

% Reproducibility
rng default

% Number of iterations
num_it = 5000;%5000;

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
ylabel('Density')

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
ylabel('Density')

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
ylabel('Density')

% Limit labels
xlim([xmin xmax])
ylim([0 ymax])

% Histogram
h1 = histogram(bootstat_img_duration,'FaceColor','b','EdgeColor','none');
h2 = histogram(bootstat_af_duration,'FaceColor','red','EdgeColor','none');
%h3 = histogram(bootstat_af_minus_img_duration,'FaceColor','y','EdgeColor','none');

% Set the bar width
h1.BinWidth = 0.025;
h2.BinWidth = 0.025;
%h3.BinWidth = 0.025;

% Plot the mean
plot([af_duration_r,af_duration_r],[0,ymax],'k')
plot([img_duration_r,img_duration_r],[0,ymax],'k')

% Plot confidence interval
plot([bootconfidence_img_duration(1) bootconfidence_img_duration(1)],[0,ymax],'--k')
plot([bootconfidence_img_duration(2) bootconfidence_img_duration(2)],[0,ymax],'--k')
plot([bootconfidence_af_duration(1) bootconfidence_af_duration(1)],[0,ymax],'--r')
plot([bootconfidence_af_duration(2) bootconfidence_af_duration(2)],[0,ymax],'--r')
%plot([bootstat_af_minus_img_duration_CI(1) bootstat_af_minus_img_duration_CI(1)],[0,ymax],'--y')
%plot([bootstat_af_minus_img_duration_CI(2) bootstat_af_minus_img_duration_CI(2)],[0,ymax],'--y')

% Zero ref line
plot([0 0],[0 ymax],'k')

%% VVIQ image vs VVIQ afterimage

% Parameters
ymax = 350;
xmax = 1;
xmin = -0.5;

% Plot VVIQ image vs VVIQ afterimage histogram - Contrast
figure
hold on

title('VVIQ afterimage vs VVIQ image - Contrast')
xlabel('Correlation (r)')
ylabel('Density')

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
ylabel('Density')

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
ylabel('Density')

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
