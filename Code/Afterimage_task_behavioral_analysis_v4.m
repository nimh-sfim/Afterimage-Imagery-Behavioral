%% Afterimage Paradigm - Full Behavioral Analysis

% This script will read the task log and text files and process them among
% various target analyses. This code can be used for all Afterimage session
% types: 7T and OP4. There is also a flag the allows for collecting data
% across subjects into group matrices that can be used in future analysis.

% Written By: Sharif I. Kronemer
% Last Modified: 3/25/2024

clear all

%% Group Directories

% Subject folders directory
subject_list = dir('/Users/kronemersi/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Afterimage_Neural_Mechanism_Study/Data');

% Root directory
root_dir = '/Users/kronemersi/OneDrive - National Institutes of Health/Afterimage_Neural_Mechanism_Study';

% Save group data? (1 = Yes; 0 = No)
% Note: If you are analyzing only one subject/subset set to 0
save_group_data = 1;

% If save group data
if save_group_data == 1

    group_dir = ['/Users/kronemersi/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/' ...
        'Afterimage_Neural_Mechanism_Study/Analysis/Group_Analysis/Behavior'];

end

% Study condition (Session type: OP4, 7T_Whole_Brain, 7T_V1)
modality_condition = 'OP4';

%% Main Behavioral Analysis

% Real/Image Stimulus image stats
real_image_duration = 4;
real_image_opacity = 0.25;
max_blur_value = 25;

% Initialize group variables
num_RIWAF = [];
num_RIWOAF = [];
num_MIWAF = [];
num_MIWOAF = [];

all_sub_IDs = {};

all_sub_mean_image_stim_sharpness = [];
all_sub_mean_image_stim_sharpness_flipped = [];
all_sub_mean_afterimage_sharpness = [];
all_sub_mean_afterimage_sharpness_flipped = [];

all_sub_mean_image_stim_max_contrast = [];
all_sub_mean_afterimage_max_contrast = [];

all_sub_selected_vs_image_stim_sharpness = [];
all_sub_selected_vs_image_stim_sharpness_flipped = [];
all_sub_selected_vs_image_stim_max_contrast = [];
all_sub_selected_vs_image_stim_duration = [];

all_sub_afterimage_perception_rate = [];

all_sub_image_stim_duration = [];
all_sub_image_stim_onset_latency = [];
all_sub_afterimage_duration = [];
all_sub_afterimage_onset_latency = [];

all_sub_real_inducer_afterimage_perception_rate = [];
all_sub_mock_ind_w_mock_afterimage_perception_rate = [];
all_sub_mock_ind_wo_mock_afterimage_perception_rate = [];

% Loop over subjects 
% OP4 Subjects [all subjects]: [5:22,24:68]
% Whole Brain fMRI Subjects: [5,7,8,29,31:40,42:49,55:60,62,64:68]
% V1 fMRI Subjects: [8,29,31,36,40,43,55,57,62,65,66,68]
subject_IDs = {'002','004','005','026','028','029','030','031',...
    '033','034','035','036','037','039','040','041','042',...
    '043','044','046','052','053','054','055','056','057',...
    '059','061','062','065','066','067'};
% subject_IDs = {'005','026','028',...
%     '033','037','040','052','054',...
%     '059','062','065','067'};

% Loop over subjects
for sub = 1:length(subject_IDs)
    
    % Current subject
    sub_ID = subject_IDs{sub};
    
    disp(['Running subject ', num2str(sub_ID)])
    
    % Store subject IDs
    all_sub_IDs = [all_sub_IDs; num2str(sub_ID)];
    
    %% Subject Directories 
    
    % Subject directory
    sub_dir = fullfile(root_dir,'Data',sub_ID,modality_condition,'Behavior');
    
    % Check if subject directory exists
    if exist(sub_dir)
    
        % Subject save directory
        save_dir = fullfile(root_dir,'/Analysis/Subject_Analysis',sub_ID,modality_condition,'Behavior');
        
        % Make save directory if it does not exist
        if ~isfolder(save_dir)
        
            mkdir(save_dir)
        
        end
    
    else
    
        disp('Subject directory does not exist - moving on!')
        continue
    
    end
    
    %% Load xls/txt Data
    
    % Note: May need to save the Psychopy output file in xls format manually to readable
    % format before using xlsread below
    
    % Find directories with xls extension
    data_file = dir(fullfile(sub_dir,'*.xls'));
    
    % If more than one file in directory
    if size(data_file,1) > 1
    
        % Prompt in command line which file to select among those found
        file_num = 'All'; %input(['There are ',num2str(size(data_file,1)),' files. Which one to run [1, 2, ..., All]: '],'s');
        
        % Convert string selection of 'All' to number
        if ~strcmp(file_num,'All')
        
            file_num = num2str(file_num);
        
        end
    
    % If no data file is found
    elseif isempty(data_file)
    
        disp('No data file found - moving on!')
        continue
    
    % If only one file present, use this one for analysis
    else
    
        file_num = 1;
    
    end
    
    % Include all files and combine them
    if isequal(file_num,'All')
    
        % Initialize raw matrix
        raw = {};
    
        % Loop over the files
        for current_file = 1:size(data_file,1)
    
            % Open data table
            [num, text, raw_current_file] = xlsread(fullfile(data_file(current_file).folder,data_file(current_file).name));
    
            % Add columns to raw array if necessary 
            if size(raw,2) < size(raw_current_file,2) && ~isempty(raw)
    
                % Define the column to add
                add_column = size(raw,2)+1;
    
                % Add NaNs
                for row = 1:size(raw, 1)
    
                    raw{row,add_column} = nan;
    
                end
    
            end
    
            % Combine file - Remove empty last to columns so that the
            % dimensions of the matrices being combined are the same
            if ismember(sub_ID,{'004','014'}) && current_file == 2
    
                raw_current_file(:,[9,10]) = [];
    
            end
    
            raw = [raw; raw_current_file];
    
        end
    
    % Read the individual data file
    else 
    
        % Open data table
        [num, text, raw] = xlsread(fullfile(data_file(file_num).folder,data_file(file_num).name));
    
    end
    
    %% Load Log Data
    
    % Find directories with log extension
    cd(sub_dir)
    log_file = dir('*.log');
    
    % Include All files and combine them
    if isequal(file_num,'All')
    
        % Initialize raw matrix
        log_data = {};
    
        % Loop over the files
        for current_file = 1:size(log_file,1)
    
            % Open log data file
            log_current_file = importdata(log_file(current_file).name);
    
            % Combine file
            log_data = [log_data; log_current_file];
    
        end
    
    % Read the individual log file
    else 
    
        % Open log data
        log_data = importdata(log_file(file_num).name);
    
    end
    
    %% Stats Text File
    
    % Create stats text file
    cd(save_dir)
    
    % If more than one file
    if size(data_file,1) > 1 && ~isequal(file_num,'All')
    
        stat_file = fopen([sub_ID,'_afterimage_task_stats_file_',num2str(file_num),'.txt'],'wt');
        fprintf(stat_file,'%s\n\r\n',['*** Subject ID - ',sub_ID,' ***']);
    
    % If one file only
    else
    
        stat_file = fopen([sub_ID,'_afterimage_task_stats.txt'],'wt');
        fprintf(stat_file,'%s\n\r\n',['*** Subject ID - ',sub_ID,' ***']);
    
    end
    
    % OP4 Session Analyses
    if isequal(modality_condition,'OP4')

        %% Real/Image Perceptual Blur/Sharpness Analysis
            
        % Cut table rows to relevant task type
        trial_type = find(strcmp('Real_Blur',raw(:,1)));
        
        % Cut raw data
        real_blur_data = raw(trial_type,:);
        
        % Only continue if rows are available
        if ~isempty(real_blur_data)
        
            % Cut table header
            real_blur_header = raw(trial_type(1)-1,:);
            
            % Find min blur and selected blur columns; Note: The min blur
            % refers to the minimum blur value (or maximum crispness/sharpness
            % value) of the on screen image stimulus. 
            min_blur_column = find(strcmp('Trial_Min_Blur_Value',real_blur_header));
            selected_blur_column = find(strcmp('Selected_Blur_Value',real_blur_header));
            
            % Pull out blur data
            min_blur_data = cell2mat(real_blur_data(:,min_blur_column));
            selected_image_blur_data = real_blur_data(:,selected_blur_column);
            
            % Replace None with Nans
            selected_blur_data_char = cellfun(@num2str,selected_image_blur_data,'un',0);
            selected_image_blur_data(ismember(selected_blur_data_char,'None'))= {nan}; 
            selected_image_blur_data = cell2mat(selected_image_blur_data);
        
            % Check that the arrays are the same length and equal 20 trials
            if ~isequal(length(min_blur_data),length(selected_image_blur_data),20)
        
                error('Blur data vectors are not the same length/wrong number!')
        
            end
            
            % Real minus selected blur value; Note: this calculates the error
            % in the participant selected blur values relative to the true blur
            % values of the image stimulus
            diff_blur_data = selected_image_blur_data-min_blur_data;
            diff_blur_data_flipped = abs(selected_image_blur_data-max_blur_value)-abs(min_blur_data-max_blur_value);
    
            % Mean Real minus Selected Blur Value
            mean_diff_blur = nanmean(diff_blur_data);
            mean_diff_blur_flipped = nanmean(diff_blur_data_flipped);
    
            % Find the Mean Selected Blur Value
            mean_selected_blur = nanmean(selected_image_blur_data);
    
            % Flip data; Note: In the current scale as the numbers
            % get larger the image is reported as less crisp. This is the
            % opposite of the contrast/brightness data set where as the numbers
            % get large the image is reported as brighter. To guide intuition
            % of the results, the sign of the data is flipped so that large
            % values correspond with sharper. The values are baselined to 25
            % because that is the maximum bluriness value that participants
            % coudl select.
            mean_selected_blur_flipped = abs(mean_selected_blur-max_blur_value);
    
            % Add blur data to all subject data varaible
            all_sub_mean_image_stim_sharpness = [all_sub_mean_image_stim_sharpness; mean_selected_blur];
            all_sub_mean_image_stim_sharpness_flipped = [all_sub_mean_image_stim_sharpness_flipped; mean_selected_blur_flipped];
            all_sub_selected_vs_image_stim_sharpness = [all_sub_selected_vs_image_stim_sharpness; mean_diff_blur];
            all_sub_selected_vs_image_stim_sharpness_flipped = [all_sub_selected_vs_image_stim_sharpness_flipped; mean_diff_blur_flipped];
            
            % *** Plot Blur Value ***
            figure 
            hold on
            
            % Figure parameters
            yticks([1:8])
            title(['Subject ', sub_ID, ' - Real Blur'])
            xlabel('Real Blur Value - Selected Blur Value (Pixels)')
            ylabel('Count')
            
            % Histogram
            histogram(diff_blur_data)
            
            % Mean Line
            plot([mean_diff_blur, mean_diff_blur],[0 8],'--r')
            
            %Save figure
            cd(save_dir)
            savefig('Real_blur.fig')
            close
            
            % *** Update Text File ***
            
            fprintf(stat_file,'%s\n\r\n','*** Real Blur Matching ***');
            fprintf(stat_file,'%s\n\r\n','Mean Real Blur vs Selected Blur Value');
            fprintf(stat_file,'%f\n\r',mean_diff_blur);
        
        end
       
        %% Afterimage Blur Analysis
        
        % Cut table rows to relevant task type
        trial_type = find(strcmp('Afterimage_Blur',raw(:,1)));
        
        % Cut table
        afterimage_blur_data = raw(trial_type,:);
        
        % Only continue if rows are available
        if ~isempty(afterimage_blur_data)
        
            % Cut table header
            afterimage_blur_header = raw(trial_type(1)-1,:);
            
            % Find min blur and selected blur columns
            selected_blur_column = find(strcmp('Selected_Blur_Value',afterimage_blur_header));
            
            % Pull out blur data
            selected_afterimage_blur_data = afterimage_blur_data(:,selected_blur_column);
            
            % Replace none with Nans
            selected_blur_data_char = cellfun(@num2str,selected_afterimage_blur_data,'un',0);
            selected_afterimage_blur_data(ismember(selected_blur_data_char,'[]'))= {nan}; 
            selected_afterimage_blur_data = cell2mat(selected_afterimage_blur_data);
        
            % Check if all trials are accounted for
            if ~length(selected_afterimage_blur_data) == 30
        
                error('All afterimage blur trials not accounted for!')
        
            end
            
            % Mean blur data
            mean_afterimage_blur = nanmean(selected_afterimage_blur_data);
    
            % Flip data; Note: In the current scale as the numbers
            % get larger the image is reported as less crisp. This is the
            % opposite of the contrast/brightness data set where as the numbers
            % get large the image is reported as brighter. To guide intuition
            % of the results, the sign of the data is flipped so that large
            % values correspond with sharper. The values are baselined to 25
            % because that is the maximum bluriness value that participants
            % coudl select.
            mean_afterimage_blur_flipped = abs(mean_afterimage_blur-max_blur_value);
    
            % Store all subject mean afterimage blur
            all_sub_mean_afterimage_sharpness = [all_sub_mean_afterimage_sharpness; mean_afterimage_blur];
            all_sub_mean_afterimage_sharpness_flipped = [all_sub_mean_afterimage_sharpness_flipped; mean_afterimage_blur_flipped];
    
            % *** Plot blur data ***
            figure 
            hold on
            
            % Figure Parameters
            yticks([1:10])
            xlim([0 25])
            title(['Subject ', sub_ID, ' - Afterimage Blur '])
            xlabel('Blur Value')
            ylabel('Count')
            
            % Mean line
            plot([mean_afterimage_blur,mean_afterimage_blur],[0,10], '--r')
            
            % Histogram
            histogram(selected_afterimage_blur_data)
            
            %Save figure
            cd(save_dir)
            savefig('Afterimage_blur.fig')
            close
            
            % *** Update Text File ***
            
            fprintf(stat_file,'%s\n\r\n','*** Afterimage Blur Matching ***');
            fprintf(stat_file,'%s\n\r\n','Mean Afterimage Selected Blur Value');
            fprintf(stat_file,'%f\n\r',mean_afterimage_blur);
        
        end
        
        %% Real/Image Stimulus Contrast Matching
        
        % Cut table rows to relevant task type
        trial_type = find(strcmp('Real_Contrast',raw(:,1)));
        
        % Cut table
        real_contrast_data = raw(trial_type,:);
        
        % Only continue if rows are available
        if ~isempty(real_contrast_data)
        
            % Index of trail start rows
            trial_start_rows = [];
            all_trial_image_time = [];
            all_trial_image_contrast = [];
            all_trial_image_matched_time = {};
            all_trial_image_matched_contrast = {};
            
            % Reset variable/Find onset
            find_onset = 0;
            
            % Mine log file for specific string variables
            for row = 1:size(log_data,1)
        
                % Find task onset
                if any(~cellfun('isempty',strfind(log_data(row),'REAL CONTRAST MATCHING'))) && find_onset == 0
            
                    % Define task onset row in phase
                    task_phase_onset_row = row;
        
                    % Switch onset
                    find_onset = 1;
        
                % Find trials
                elseif any(~cellfun('isempty',strfind(log_data(row),'Real Contrast Match Trial')))
                   
                    trial_start_rows = [trial_start_rows; row];
                
                % Find task end
                elseif any(~cellfun('isempty',strfind(log_data(row),'END REAL CONTRAST MATCHING')))
                   
                    % Define last row in phase
                    last_row = row;
                    
                    % Once found the end - break from loop
                    break
        
                % Find task end (use the onset of the next task phase as the end of
                % the current task phase)
                elseif any(~cellfun('isempty',strfind(log_data(row),'AFTERIMAGE CONTRAST MATCHING')))
                   
                    % Define last row in phase
                    last_row = row;
                    
                    % Once found the end - break from loop
                    break
    
                end
        
            end
        
            % Study each trial
            for trial = 1:length(trial_start_rows)
                    
                % Empty matrices
                trial_real_time = [];
                trial_real_opacity = [];
           
                % For all trials except the last
                if trial < length(trial_start_rows)
                    
                    % Define the begin_row and end_row
                    begin_row = trial_start_rows(trial);
                    end_row = trial_start_rows(trial+1);
            
                % Final trial
                else
            
                    % Define the begin_row and end_row
                    begin_row = trial_start_rows(trial);
                    end_row = last_row;
            
                end
            
                % Loop over trial rows
                for row = begin_row:end_row
                    
                    % Extract real stimulus time array
                    if any(~cellfun('isempty',strfind(log_data(row),['Real time array'])))
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_EXP = strfind(log_row,':');
                       
                       % Select opacity and time values
                       trial_time_values = str2num(log_row(begin_EXP+1:end)); 
                       
                       % Store time array
                       all_trial_image_time = [all_trial_image_time; trial_time_values];
        
                    % Extract real opacity array
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Real contrast array'])))
            
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_EXP = strfind(log_row,':');
                       
                       % Select opacity and time values
                       trial_contrast_values = str2num(log_row(begin_EXP+1:end)); 
                       
                       % Store time array
                       all_trial_image_contrast = [all_trial_image_contrast; trial_contrast_values];
        
                    % Extract mock matched time array
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Physical matched time array']))) && ...
                            ~ismember(sub_ID, {'006','007','008','009','010'}) || any(~cellfun('isempty',strfind(log_data(row),['Real matched time array']))) && ...
                            ~ismember(sub_ID, {'006','007','008','009','010'})
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_EXP = strfind(log_row,':');
                       
                       % Select opacity and time values
                       trial_time_values = str2num(log_row(begin_EXP+1:end)); 
        
                       % Alternative time value check
                       if isempty(trial_time_values)
                            
                            begin_EXP = strfind(log_row,'(');
                            end_EXP = strfind(log_row,')');
                            trial_time_values = str2num(log_row(begin_EXP+1:end_EXP-1));
        
                       end
                       
                       % If time_value is empty replace with NaN
                       if isempty(trial_time_values)
        
                           trial_time_values = NaN;
        
                       end
        
                       % Store time array
                       all_trial_image_matched_time = [all_trial_image_matched_time; trial_time_values];
        
                    % Extract mock matched contrast array
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Physical matched opacity array']))) && ...
                            ~ismember(sub_ID, {'006','007','008','009','010'}) || any(~cellfun('isempty',strfind(log_data(row),['Real matched opacity array']))) && ...
                            ~ismember(sub_ID, {'006','007','008','009','010'})
            
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_EXP = strfind(log_row,':');
                       
                       % Select contrast and time values
                       trial_contrast_values = str2num(log_row(begin_EXP+1:end)); 
        
                       % Alternative opacity value check
                       if isempty(trial_contrast_values)
        
                            begin_EXP = strfind(log_row,'(');
                            end_EXP = strfind(log_row,')');
                            trial_contrast_values = str2num(log_row(begin_EXP+1:end_EXP-1));
        
                       end
                       
                       % If contrast_value is empty replace with NaN
                       if isempty(trial_contrast_values)
        
                           trial_contrast_values = NaN;
        
                       end
        
                       % Store time array
                       all_trial_image_matched_contrast = [all_trial_image_matched_contrast; trial_contrast_values];
        
                    end
        
                end
                
                % Special consideration for some subjects; Note: These subjects
                % completed a slightly different task version that did not save
                % the array of the matched contrast/opacity values, so this
                % script goes through each row of the log file and extracts
                % that opacity/contrast info and corresponding timing
                if ismember(sub_ID, {'006','007','008','009','010'})
                  
                    % Find stimulus onset
    
                    % Reset variables
                    trial_contrast_values = [];
                    trial_time_values = [];
    
                    % Loop over trial rows
                    for row = begin_row:end_row
            
                       % Find stimulus onset
                        if any(~cellfun('isempty',strfind(log_data(row),['Stimulus onset'])))
        
                           % Stimulus onset row
                           stim_onset_row = row;
            
                           % Cut out log row 
                           log_row = cell2mat(log_data(row,:));
                           begin_EXP = strfind(log_row,'E');
                           
                           % Find stimulus time
                           stimulus_time = str2num(log_row(1:begin_EXP-1)); 
        
                        end 
        
                    end
    
                    % Find trial contrast values
            
                    % Loop over trial rows
                    for row = stim_onset_row:end_row
        
                        % Find opacity values
                        if any(~cellfun('isempty',strfind(log_data(row),['Update opacity value:'])))
            
                           % Initalize variable
                           if ~exist('trial_contrast_values','var')
            
                               trial_contrast_values = [];
            
                           end
            
                           % Cut out log row 
                           log_row = cell2mat(log_data(row,:));
                           begin_EXP = strfind(log_row,':');
                           
                           % Select contrast values
                           contrast_value = str2num(log_row(begin_EXP+1:end)); 
            
                           % Store opacity values one-by-one
                           trial_contrast_values = [trial_contrast_values; contrast_value];
            
                        end
        
                    end
        
                    % Find trial time values
    
                    % Loop over trial rows
                    for row = stim_onset_row:end_row
        
                        % Find time values
                        if any(~cellfun('isempty',strfind(log_data(row),['Keypress:'])))
            
                           % Initalize variable
                           if ~exist('trial_time_values','var')
                        
                               trial_time_values = [];
                        
                           end
                        
                           % Cut out log row 
                           log_row = cell2mat(log_data(row,:));
                           begin_EXP = strfind(log_row,'D');
                           
                           % Find keypress time
                           key_time = str2num(log_row(1:begin_EXP-1));
                        
                           % Subtract key time from stimulus onset
                           key_time = key_time - stimulus_time;
                        
                           % Store key values one-by-one
                           trial_time_values = [trial_time_values; key_time];
    
                        end
            
                    end  
        
                end
    
                % Special consideration for some subjects; Note: there are instances 
                % where a keypress event does not have a corresponding opacity update 
                % - those keypress times are removed from consideration to leave on 
                % those that have a corresponding opacity update
                if ismember(sub_ID, {'006','007','008','009','010'})
        
                    % Trial specific time point rejections
                    if isequal(sub_ID, '006')
        
                       % Trial specific corrections
                       if isequal(trial, 5)
            
                          % Remove extra keypress instance
                          trial_time_values(14) = [];
            
                       elseif isequal(trial, 6)
            
                          % Remove extra keypress instance
                          trial_time_values(14) = [];
            
                       elseif isequal(trial, 13)
            
                          % Remove extra keypress instance
                          trial_time_values(14) = [];
            
                       elseif isequal(trial, 17)
            
                          % Remove extra keypress instance
                          trial_time_values(18) = [];  
            
                       elseif isequal(trial, 18)
            
                           % Remove extra keypress instance
                          trial_time_values(14) = [];  
            
                       end
        
                    elseif isequal(sub_ID, '007')
        
                       if isequal(trial, 13)
            
                           % Remove extra keypress instance
                          trial_time_values(15) = [];  
            
                       end
        
                    elseif isequal(sub_ID, '008')
        
                       if isequal(trial, 13)
            
                           % Remove extra keypress instance
                          trial_time_values(17) = [];  
            
                       end
            
                    elseif isequal(sub_ID, '009')
        
                       if isequal(trial, 9)
            
                           % Remove extra keypress instance
                          trial_time_values(18) = []; 
        
                       elseif isequal(trial, 11)
            
                           % Remove extra keypress instance
                          trial_time_values(15) = [];  
            
                       elseif isequal(trial, 15)
            
                           % Remove extra keypress instance
                          trial_time_values(17) = [];  
        
                       elseif isequal(trial, 16)
            
                           % Remove extra keypress instance
                          trial_time_values(14) = [];    
        
                       elseif isequal(trial, 17)
            
                           % Remove extra keypress instance
                          trial_time_values(19) = [];      
        
                       end
        
                    elseif isequal(sub_ID, '010')
    
                       if isequal(trial, 9)
        
                          % Remove extra keypress instance
                          trial_time_values(12) = [];     
        
                       elseif isequal(trial, 10)
        
                          % Remove extra keypress instance
                          trial_time_values(17) = [];     
        
                       elseif isequal(trial, 13)
        
                          % Remove extra keypress instance
                          trial_time_values(14) = [];        
        
                       end
            
                    end
                    
                    % Check variables are the same size
                    if ~isequal(length(trial_time_values), length(trial_contrast_values))
                    
                       error('Time and opacity arrays are not equal!')
                    
                    end
                    
                    % Add trial contrast values to all trial array
                    if ~isempty(trial_contrast_values)
    
                        all_trial_image_matched_contrast = [all_trial_image_matched_contrast; trial_contrast_values];
                        all_trial_image_matched_time = [all_trial_image_matched_time; trial_time_values];
    
                    else
    
                        all_trial_image_matched_contrast = [all_trial_image_matched_contrast; NaN];
                        all_trial_image_matched_time = [all_trial_image_matched_time; NaN];
    
                    end
                    
                    % Reset variables
                    trial_contrast_values = [];
                    trial_time_values = [];
            
                end
            
            end
        
            % Confirm size of matched time and opacity arrays equals 18 trials
            if ~isequal(length(all_trial_image_matched_time), length(all_trial_image_matched_contrast),18)
            
                error('Image contrast and time arrays mismatch or incorrect # trials!')
            
            end
            
            % Find max contrast, duration, latency
    
            % Initialize variables
            all_trial_selected_max_opacity = [];
            all_trial_selected_max_duration = [];
            all_trial_selected_onset_latency = [];
        
            % Loop over trials
            for trial = 1:size(all_trial_image_contrast,1)
        
                % Flip data orientation
                if ~ismember(sub_ID, {'006','007','008','009','010'})
                    
                    % Trial opacity
                    trial_contrast = all_trial_image_matched_contrast{trial,1}';
            
                    % Trial time
                    trial_time = all_trial_image_matched_time{trial,1}';
    
                else
    
                    % Trial opacity
                    trial_contrast = all_trial_image_matched_contrast{trial,1};
            
                    % Trial time
                    trial_time = all_trial_image_matched_time{trial,1};
    
                end
    
                % Find non-zero contrast values
                nonzero_idx = find(trial_contrast ~= 0);
                zero_idx = find(trial_contrast == 0);
    
                % If zero is not the last value, there is at least 1 zero
                % value, and if at least one difference in the index among zero
                % values is greater than 1 (this excludes trials where there
                % are zeros at the beginning but none at the end which was a
                % particularly issue in subject 006).
                if ~isequal(max(zero_idx),length(trial_contrast)) && ~isempty(zero_idx) && any(diff(zero_idx)>1) || ...
                        ~isequal(max(zero_idx),length(trial_contrast)) && length(zero_idx)==1 && ~isequal(min(zero_idx),1)
    
                    % Set all values after the last zero to the zero index
                    nonzero_idx(nonzero_idx>=max(zero_idx)) = []; %[nonzero_idx; max(nonzero_idx)+1:length(trial_opacity)];
    
                end
    
                % Select non-zero trial times
                time_value_nonzeros = trial_time(nonzero_idx);
    
                % Special trial consideration (Note: Bad trials are removed)
                if isequal(sub_ID, '058') && isequal(trial,1)
    
                    time_value_nonzeros = [];
    
                end
        
                % Find trial max opacity and duration; Note: There must be at least 2 key
                % presses and the maximum opacity value greater than 0 for a
                % valid recording, otherwise, NaN
                if length(time_value_nonzeros)>1 && max(trial_contrast) ~= 0
    
                    % Add max contrast to array
                    all_trial_selected_max_opacity = [all_trial_selected_max_opacity; max(trial_contrast)];
    
                    % If no zeros in opacity arrary 
                    if ~any(find(trial_contrast == 0)) 
    
                        % Add max duration and latency 
                        all_trial_selected_max_duration = [all_trial_selected_max_duration; trial_time(end)-trial_time(1)];
                        all_trial_selected_onset_latency = [all_trial_selected_onset_latency; trial_time(1)];
    
                    else 
                        
                        % Find duration as the max and min non-zero contrast
                        % time points
                        all_trial_selected_max_duration = [all_trial_selected_max_duration; max(time_value_nonzeros)-min(time_value_nonzeros)];
                        
                        % Find onset latency
                        all_trial_selected_onset_latency = [all_trial_selected_onset_latency; min(time_value_nonzeros)];
    
                    end
    
                else
        
                    % Add NaN to trial
                    all_trial_selected_max_opacity = [all_trial_selected_max_opacity; NaN];
                    all_trial_selected_max_duration = [all_trial_selected_max_duration; NaN];
                    all_trial_selected_onset_latency = [all_trial_selected_onset_latency; NaN];
    
                end
    
            end
    
            % Check the number of trials
            if ~isequal(length(all_trial_selected_onset_latency), length(all_trial_selected_max_duration), length(all_trial_selected_max_opacity),18)
        
                error('Number of onset/duration/contrast trials if off!')
    
            end
    
            % Find subject mean trial time and contrast
            mean_image_stim_selected_max_contrast = nanmean(all_trial_selected_max_opacity);
            mean_image_stim_selected_max_duration = nanmean(all_trial_selected_max_duration);
            mean_image_stim_selected_onset_latency = nanmean(all_trial_selected_onset_latency);
        
            % Find difference between selected and real image stats
            diff_real_selected_max_contrast = mean_image_stim_selected_max_contrast - real_image_opacity;
            diff_real_selected_max_duration = mean_image_stim_selected_max_duration - real_image_duration;
        
            % Store all subject variable
            all_sub_mean_image_stim_max_contrast = [all_sub_mean_image_stim_max_contrast; mean_image_stim_selected_max_contrast];
            all_sub_image_stim_duration = [all_sub_image_stim_duration; mean_image_stim_selected_max_duration];
            all_sub_image_stim_onset_latency = [all_sub_image_stim_onset_latency; mean_image_stim_selected_onset_latency];
            all_sub_selected_vs_image_stim_max_contrast = [all_sub_selected_vs_image_stim_max_contrast; diff_real_selected_max_contrast];
            all_sub_selected_vs_image_stim_duration = [all_sub_selected_vs_image_stim_duration; diff_real_selected_max_duration];
        
            % *** Stats Text File ***
            
            fprintf(stat_file,'%s\n\r\n','*** Real Image Contrast Matching ***');
            
            fprintf(stat_file,'%s\n\r\n','Mean Max Real Opacity');
            fprintf(stat_file,'%f\n\r',mean_image_stim_selected_max_contrast); 
        
            fprintf(stat_file,'%s\n\r\n','Mean Real Duration');
            fprintf(stat_file,'%f\n\r',mean_image_stim_selected_max_duration); 
        
            fprintf(stat_file,'%s\n\r\n','Mean Real Onset Latency');
            fprintf(stat_file,'%f\n\r',mean_image_stim_selected_onset_latency); 
        
            fprintf(stat_file,'%s\n\r\n','Selected vs Real Mean Max Opacity');
            fprintf(stat_file,'%f\n\r',diff_real_selected_max_contrast); 
        
            fprintf(stat_file,'%s\n\r\n','Selected vs Real Mean Max Duration');
            fprintf(stat_file,'%f\n\r',diff_real_selected_max_duration); 
        
            % *** Plot Real and Matched Timecourses ***
            figure
            hold on
            
            % Figure parameters
            title(['Subject ID ',sub_ID,' - Real Opacity Matching'])
            xlabel('Time (s)')
            ylabel('Opacity [0 1]')
            xlim([0 12])
            ylim([0 0.5])
            
            % Loop over trials - real
            for trial = 1:size(all_trial_image_contrast,1)
            
                plot(all_trial_image_time(trial,:),all_trial_image_contrast(trial,:), 'b')
            
            end
            
            % Loop over trials - matched
            for trial = 1:size(all_trial_image_matched_contrast,1)
            
                plot(all_trial_image_matched_time{trial,:},all_trial_image_matched_contrast{trial,:}, 'r')
            
            end
            
            %Save figure 
            cd(save_dir)
            savefig('Real_opacity_matching.fig')
            close
        
        end
        
        %% Afterimage Contrast Matching 
        
        % Cut table rows to relevant task type
        trial_type = find(strcmp('Afterimage_Contrast',raw(:,1)));
        
        % Cut table
        afterimage_matching_data = raw(trial_type,:);
        
        % Only continue if rows are available
        if ~isempty(afterimage_matching_data)
        
            % Reconstruct Contrast vs Time Afterimage Report
        
            % Mine log file for specific string variables
            for row = 1:size(log_data,1)
            
                % Find all opacity arrays
                if any(~cellfun('isempty',strfind(log_data(row),'All physical afterimage matched opacity arrays original'))) || ...
                        any(~cellfun('isempty',strfind(log_data(row),'All mock afterimage matched opacity arrays original')))
            
                    afterimage_contrast_array = cell2mat(log_data(row,:));
                
                % Find all time arrays (unscaled)
                elseif any(~cellfun('isempty',strfind(log_data(row),'All physical afterimage matched time arrays original'))) || ...
                        any(~cellfun('isempty',strfind(log_data(row),'All mock afterimage matched time arrays original')))
            
                    afterimage_time_array = cell2mat(log_data(row,:));
                
                % Find mean onset to afterimage
                elseif any(~cellfun('isempty',strfind(log_data(row),'Afterimage mean duration')))
                    
                    % Define afterimage mean start time variable
                    afterimage_mean_duration_log = cell2mat(log_data(row,:));
                    
                    % Find index for colon
                    begin_colon = strfind(afterimage_mean_duration_log,':');
            
                    %Cut out time
                    afterimage_mean_duration_log = str2num(afterimage_mean_duration_log(begin_colon+1:end));
            
                % Find mean onset to afterimage
                elseif any(~cellfun('isempty',strfind(log_data(row),'Afterimage mean start')))
                    
                    % Define afterimage mean start time variable
                    afterimage_mean_onset_log = cell2mat(log_data(row,:));
                    
                    % Find index for colon
                    begin_colon = strfind(afterimage_mean_onset_log,':');
            
                    %Cut out time
                    afterimage_mean_onset_log = str2num(afterimage_mean_onset_log(begin_colon+1:end));
                
                % Find the normalized time array
                elseif any(~cellfun('isempty',strfind(log_data(row),'Physical afterimage matched mean duration time array'))) || ...
                    any(~cellfun('isempty',strfind(log_data(row),'Mock afterimage matched mean duration time array')))
                    
                    % Define final time array variable
                    mock_afterimage_time_array = cell2mat(log_data(row,:));
                    
                    % Find brackets to use to cut specific matrices of time
                    begin_bracket = strfind(mock_afterimage_time_array,'[');
                    end_bracket = strfind(mock_afterimage_time_array,']');
                    
                    % Cut out matrix
                    mock_afterimage_time_array = str2num(mock_afterimage_time_array(begin_bracket:end_bracket));
                
                % Find normalized, smoothed opacity array
                elseif any(~cellfun('isempty',strfind(log_data(row),'Physical afterimage matched mean opacity smoothed array'))) || ...
                        any(~cellfun('isempty',strfind(log_data(row),'Mock afterimage matched mean opacity smoothed array')))
            
                    % Define final time array variable
                    mock_afterimage_contrast_array = cell2mat(log_data(row,:)); 
        
                    % Find brackets to use to cut specific matrices of time
                    begin_bracket = strfind(mock_afterimage_contrast_array,'[');
                    end_bracket = strfind(mock_afterimage_contrast_array,']');
                    
                    % Cut out matrix
                    mock_afterimage_contrast_array = str2num(mock_afterimage_contrast_array(begin_bracket:end_bracket));
        
                end
            
            end
        
            % Check the mock afterimage arrays are the same size
            if ~isequal(length(mock_afterimage_contrast_array), length(mock_afterimage_time_array))
        
                error('Mock afterimage opacity and time array mismatch!')
        
            end
            
            % Extract number arrays - find begin/end brackets
            begin_bracket_opacity = strfind(afterimage_contrast_array,'[');
            end_bracket_opacity = strfind(afterimage_contrast_array,']');
            
            begin_bracket_time = strfind(afterimage_time_array,'[');
            end_bracket_time = strfind(afterimage_time_array,']');
            
            % Remove first and last bracket (Note: variable had double brackets [[]])
            begin_bracket_opacity(1) = [];
            end_bracket_opacity(end) = [];
            
            begin_bracket_time(1) = [];
            end_bracket_time(end) = [];
            
            % Check bracket lengths are equal across arrays
            if ~isequal(length(begin_bracket_opacity),length(end_bracket_opacity))
               
                error('Afterimage Contrast Matching: Length of opacity array is off!')
            
            elseif ~isequal(length(begin_bracket_time),length(end_bracket_time))
               
                error('Afterimage Contrast Matching: Length of time array is off!')
            
            elseif ~isequal(length(begin_bracket_time),length(begin_bracket_opacity))
            
                error('Afterimage Contrast Matching: Length of time and opacity array mistmatch!')
    
            elseif ~isequal(length(begin_bracket_time),length(begin_bracket_opacity),60)
                
                error('Number of contrast and time trials ~= 60!')
    
            end
            
            % Cut opacity and time arrays and store in cell
            
            % Initialize variables
            all_afterimage_contrast_array = {};
            all_afterimage_time_array = {};
            afterimage_max_contrast_array = [];
            afterimage_duration_array = [];
            afterimage_onset_array = [];
            
            % Loop over trials (indicated by bracket index)
            for trial = 1:length(begin_bracket_opacity)
                
                % Store contrast and time array info
                all_afterimage_contrast_array{trial,1} = afterimage_contrast_array(begin_bracket_opacity(trial):end_bracket_opacity(trial));
                all_afterimage_time_array{trial,1} = afterimage_time_array(begin_bracket_time(trial):end_bracket_time(trial));
        
                % Extract contrast and time info for trial
                trial_time = str2num(afterimage_time_array(begin_bracket_time(trial):end_bracket_time(trial)))';
                trial_contrast = str2num(afterimage_contrast_array(begin_bracket_opacity(trial):end_bracket_opacity(trial)))';
    
                % Find non-zero/zero contrast values
                nonzero_idx = find(trial_contrast ~= 0);
                zero_idx = find(trial_contrast == 0);
        
                % If zero is not the last value, there is at least 1 zero
                % value, and if at least one difference in the index among zero
                % values is greater than 1 (this excludes trials where there
                % are zeros at the beginning but none at the end which was a
                % particularly issue in subject 006).
                if ~isequal(max(zero_idx),length(trial_contrast)) && ~isempty(zero_idx) && any(diff(zero_idx)>1) || ...
                        ~isequal(max(zero_idx),length(trial_contrast)) && length(zero_idx)==1 && ~isequal(min(zero_idx),1)
    
                    % Subject specific treatment
                    if isequal(sub_ID, '036') && isequal(trial,47)
    
                        % Do not update the nonzero_idx
    
                    else
    
                        % Set all values after the last zero to the zero index
                        nonzero_idx(nonzero_idx>=max(zero_idx)) = [];
    
                    end
    
                end
    
                % Select non-zero trial times
                time_value_nonzeros = trial_time(nonzero_idx);
    
                % Special trial consideration (Note: Bad trials are removed)
                if isequal(sub_ID, '006') && ismember(trial,[12,16,31])
    
                    time_value_nonzeros = [];
    
                elseif isequal(sub_ID, '006') && isequal(trial,13)
    
                    time_value_nonzeros(16:17) = [];
    
                end
    
                % Find trial max opacity and duration; Note: There must be at least 2 key
                % presses and the maximum opacity value greater than 0 for a
                % valid recording, otherwise, NaN
                if length(time_value_nonzeros)>1 && max(trial_contrast) ~= 0
        
                    % Add max contrast to array
                    afterimage_max_contrast_array(trial,1) = max(trial_contrast);
        
                    % If no zero contrast values
                    if ~any(find(trial_contrast == 0)) 
        
                        % Add max duration and onset latency 
                        afterimage_duration_array(trial,1) = trial_time(end)-trial_time(1);
                        afterimage_onset_array(trial,1) = trial_time(1);
        
                    % If there is a zero contrast value
                    else 
                        
                        % Find duration as the max and min non-zero contrast time points
                        afterimage_duration_array(trial,1) = max(time_value_nonzeros)-min(time_value_nonzeros);
                        
                        % Find onset latency
                        afterimage_onset_array(trial,1) =  min(time_value_nonzeros);
        
                    end
        
                else
        
                    % Add NaN to trial
                    afterimage_max_contrast_array(trial,1) = NaN;
                    afterimage_duration_array(trial,1) = NaN;
                    afterimage_onset_array(trial,1) = NaN;
        
                end
    
            end
        
            % Check the real afterimage arrays are the same size
            if ~isequal(length(all_afterimage_contrast_array), length(all_afterimage_time_array),60)
        
                error('Real afterimage trial opacity and time array mismatch!')
    
            elseif ~isequal(length(afterimage_duration_array), length(afterimage_max_contrast_array), length(afterimage_onset_array), 60)
        
                error('Real afterimage duration and max opacity array mismatch!')
    
            end
        
            % Find the mean max contrast across trials
            afterimage_mean_max_contrast = nanmean(afterimage_max_contrast_array);
        
            % Find the mean duration across trials
            afterimage_mean_duration = nanmean(afterimage_duration_array);
        
            % Find the mock afterimage max opacity
            mock_afterimage_max_opacity = max(mock_afterimage_contrast_array);
        
            % Find the mock afterimage duration (Note: Should be approximately
            % equal to the afterimage_mean_duration)
            mock_afterimage_duration = max(mock_afterimage_time_array);
        
            % Find the mock afterimage area under the curve
            mock_afterimage_AUC = trapz(mock_afterimage_time_array, mock_afterimage_contrast_array);
        
            % Find mean onset delay; Note: this value should be
            % similar/identical to the afterimage_mean_duration value that the
            % task script automatically generates
            afterimage_mean_onset = nanmean(afterimage_onset_array);
    
            % Check if onset values are approximately equal; Note: afterimage_mean_onset
            % comes from the task script that saves the onset time; calculated
            % value comes from this script that analyzes these data
            if abs(afterimage_mean_onset_log - afterimage_mean_onset) > 0.5
    
                warning('Afterimage onset values mistmatch!')
                disp(['Off by: ', num2str(abs(afterimage_mean_onset_log - afterimage_mean_onset))])
    
            elseif abs(afterimage_mean_duration - afterimage_mean_duration_log) > 1
    
                warning('Afterimage duration values mistmatch!')
                disp(['Off by: ', num2str(abs(afterimage_mean_duration_log - afterimage_mean_duration))])
    
            end
    
            % Store all subjects varialbles 
            all_sub_mean_afterimage_max_contrast = [all_sub_mean_afterimage_max_contrast; afterimage_mean_max_contrast];
            all_sub_afterimage_duration = [all_sub_afterimage_duration; afterimage_mean_duration];
            all_sub_afterimage_onset_latency = [all_sub_afterimage_onset_latency; afterimage_mean_onset];
        
            % *** Stats Text File ***
            
            fprintf(stat_file,'%s\n\r\n','*** Afterimage Contrast Matching ***');
            
            fprintf(stat_file,'%s\n\r\n','Mean Max Afterimage Contrast');
            fprintf(stat_file,'%f\n\r',afterimage_mean_max_contrast); 
        
            fprintf(stat_file,'%s\n\r\n','Mean Afterimage Duration');
            fprintf(stat_file,'%f\n\r',afterimage_mean_duration); 
        
            fprintf(stat_file,'%s\n\r\n','Mean Afterimage Onset');
            fprintf(stat_file,'%f\n\r',afterimage_mean_onset); 
        
            fprintf(stat_file,'%s\n\r\n','*** Mock Afterimage Parameters ***');
            
            fprintf(stat_file,'%s\n\r\n','Mock Afterimage Max Opacity');
            fprintf(stat_file,'%f\n\r',mock_afterimage_max_opacity); 
            
            fprintf(stat_file,'%s\n\r\n','Mock Afterimage Duration');
            fprintf(stat_file,'%f\n\r',mock_afterimage_duration); 
        
            fprintf(stat_file,'%s\n\r\n','Mock Afterimage AUC');
            fprintf(stat_file,'%f\n\r',mock_afterimage_AUC); 
            
            % *** Plot Afterimage Match Timecourses ***
            figure 
            hold on 
            
            % Figure parameters
            ylim([0 0.5])
            xlim([0 12])
            yticks([0:0.1:0.5])
            xticks([0:12])
            title(['Subject ', sub_ID, ' - Afterimage Opacity vs Time'])
            ylabel('Image Opacity [0 to 1]')
            xlabel('Time (s) - from offset of inducer')
            
            % Mean start and afterimage duration lines
            plot([afterimage_mean_onset_log, afterimage_mean_onset_log],[0, 0.5],'--r')
            plot([afterimage_mean_duration_log + afterimage_mean_onset_log, afterimage_mean_duration_log + afterimage_mean_onset_log],[0, 0.5],'--r')
            
            % Loop over instances
            for trial = 1:length(all_afterimage_contrast_array)
            
                % Plot timecourses of individual afterimages
                plot(str2num(all_afterimage_time_array{trial,1}), str2num(all_afterimage_contrast_array{trial,1}),'b')
            
            end
            
            % Reconstructed model afterimage
            plot(mock_afterimage_time_array+afterimage_mean_onset_log, mock_afterimage_contrast_array, 'r', 'LineWidth',4)
            
            %Save figure 
            cd(save_dir)
            savefig('Afterimage_opacity_vs_time.fig')
            close
        
            % Save the mock afterimage information
            cd(save_dir)
            save('Mock_afterimage_parameters.mat','mock_afterimage_time_array','mock_afterimage_contrast_array','afterimage_mean_onset_log',...
                'afterimage_mean_duration_log','all_afterimage_contrast_array','afterimage_onset_array','all_afterimage_time_array',...
                'afterimage_mean_max_contrast','mock_afterimage_max_opacity', 'mock_afterimage_duration', 'mock_afterimage_AUC')
        
        end
        
        %% Afterimage Perception Rate
        
        if ~isempty(afterimage_matching_data) && ~isempty(afterimage_blur_data)
    
            % Check sample sizes 
            if length(selected_afterimage_blur_data) ~= 30 && length(afterimage_max_contrast_array) ~= 60
            
                error('Number of trials incorrect!')
            
            end 
            
            % Calculated the afterimage perceptiona across the cripsness/blur and contrast task phases
            afterimage_perception_rate = (sum(~isnan(selected_afterimage_blur_data)) + sum(~isnan(afterimage_max_contrast_array))) /...
                (length(selected_afterimage_blur_data) + length(afterimage_max_contrast_array));
            
            % Store the perception rate value
            all_sub_afterimage_perception_rate = [all_sub_afterimage_perception_rate; afterimage_perception_rate];
    
        end
        
        %% Afterimage Matching Confirmation 

        % Cut table rows to relevant task type 
        % NOTE: Earlier interation had lower case "matching"
        
        % Subject ID greater than 12 - Exception for 004 retested
        if str2num(sub_ID) > 12 || strcmp(sub_ID,'004') || strcmp(sub_ID,'003') || strcmp(sub_ID, '005') || strcmp(sub_ID,'002')
        
            trial_type = find(strcmp('Afterimage_Matching',raw(:,1))); 
        
        else
        
            trial_type = find(strcmp('Afterimage_matching',raw(:,1)));
        
        end
        
        % Cut table
        afterimage_matching_data = raw(trial_type,:);
        
        % Only continue if rows are available
        if ~isempty(afterimage_matching_data)
        
            % Cut table header
            afterimage_matching_header = raw(trial_type(1)-1,:);
            
            % Find Min Blur and Selected Blur columns
            condition_column = find(strcmp('Trial_Condition',afterimage_matching_header));
            mock_afterimage_present_column = find(strcmp('Afterimage_Present',afterimage_matching_header));
            response_column = find(strcmp('Question_Response',afterimage_matching_header));
            target_location_column = find(strcmp('Target_Location',afterimage_matching_header));
            
            % *** Afterimage Perception Rate ***
            
            % (1) Perceived Afterimage when Real Inducer Present
            
            % Total number of real inducers trials
            total_real_inducers = sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]));
            
            % Condition 1; Right Side; Response 1 or 3 + Condition 1; Left Side; Response 2 or 3
            perceived_afterimage_real_inducer =  sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ...;
                strcmp(afterimage_matching_data(:,target_location_column),'[-12, 0]') & ismember(cell2mat(afterimage_matching_data(:,response_column)),[1,3])) + ...
                sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ...
                strcmp(afterimage_matching_data(:,target_location_column),'[12, 0]') & ismember(cell2mat(afterimage_matching_data(:,response_column)),[2,3]));
            
            % Calculate Perceptoin Rate
            CP_afterimage_real_inducer_rate = perceived_afterimage_real_inducer/total_real_inducers;
            
            % (2) Perceived Afterimage when Mock Inducer Present - with Mock Afterimage
            
            % Find total number of mock inducers with mock afterimage
            total_mock_inducers_w_mock_afterimage = sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ismember(cell2mat(afterimage_matching_data(:,mock_afterimage_present_column)),1));
            
            % Condition 1; Right Side; Response 1 or 3; afterimage present 1 + Condition 1; Left Side; Response 2 or 3; afterimage present 1
            perceived_afterimage_mock_inducer_present =  sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ismember(cell2mat(afterimage_matching_data(:,mock_afterimage_present_column)),1) & ...;
                strcmp(afterimage_matching_data(:,target_location_column),'[12, 0]') & ismember(cell2mat(afterimage_matching_data(:,response_column)),[1,3])) + ... 
                sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ismember(cell2mat(afterimage_matching_data(:,mock_afterimage_present_column)),1) & ...
                strcmp(afterimage_matching_data(:,target_location_column),'[-12, 0]') & ismember(cell2mat(afterimage_matching_data(:,response_column)),[2,3]));
            
            % Perception Rate - Divided by the total number of mock inducer trials with mock afterimage
            perceived_afterimage_mock_inducer_present_rate = perceived_afterimage_mock_inducer_present / total_mock_inducers_w_mock_afterimage;
                
            % (3) Perceived Afterimage when Mock Inducer Present - without Mock Afterimage
            
            % Find total number of mock inducers without mock afterimage
            total_mock_inducers_wo_mock_afterimage = sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ismember(cell2mat(afterimage_matching_data(:,mock_afterimage_present_column)),1));
            
            % Condition 1; Right Side; Response 1 or 3; afterimage absent 0 + Condition 1; Left Side; Response 2 or 3; afterimage absent 0
            perceived_afterimage_mock_inducer_absent =  sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ismember(cell2mat(afterimage_matching_data(:,mock_afterimage_present_column)),0) & ...;
                strcmp(afterimage_matching_data(:,target_location_column),'[12, 0]') & ismember(cell2mat(afterimage_matching_data(:,response_column)),[1,3])) + ... 
                sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[1]) & ismember(cell2mat(afterimage_matching_data(:,mock_afterimage_present_column)),0) & ...
                strcmp(afterimage_matching_data(:,target_location_column),'[-12, 0]') & ismember(cell2mat(afterimage_matching_data(:,response_column)),[2,3]));
            
            % Rate - Divided by the total number of mock inducer trials without mock afterimage
            perceived_afterimage_mock_inducer_absent_rate = perceived_afterimage_mock_inducer_absent / total_mock_inducers_wo_mock_afterimage;
                
            % (4) Perceived Afterimage when No Inducer
            
            % Find total number of no inducer trials
            total_no_inducers = sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[4]));
            
            % Condition 4; Response [1,2,3]
            perceived_afterimage_no_inducer =  sum(ismember(cell2mat(afterimage_matching_data(:,condition_column)),[4]) & ismember(cell2mat(afterimage_matching_data(:,response_column)),[1,2,3]));
            
            % Perception Rate
            perceived_afterimage_no_inducer_rate = perceived_afterimage_no_inducer / total_no_inducers;
            
            % *** Plot Bar Graph ***
            figure
            hold on
            
            % Figure parameters
            ylim([0 1])
            xticks(1:4)
            ylabel('Perception Rate')
            xlabel('Task Condition')
            title(['Subject ID ', sub_ID, ' - Afterimage Perception Rate'])
            
            % Plot bar graph
            bar(1, CP_afterimage_real_inducer_rate, 'r')
            bar(2, perceived_afterimage_mock_inducer_present_rate, 'b')
            bar(3, perceived_afterimage_no_inducer_rate, 'y')
            bar(4, perceived_afterimage_mock_inducer_absent_rate, 'c')
            
            %Save figure
            cd(save_dir)
            savefig('Afterimage_perception_rate.fig')
            close
            
            % *** Stats Text File ***
            
            fprintf(stat_file,'%s\n\r\n','*** Afterimage Confirmation Matching ***');
            
            fprintf(stat_file,'%s\n\r\n','Real Inducer Perception Rate');
            fprintf(stat_file,'%f\n\r',CP_afterimage_real_inducer_rate);
            
            fprintf(stat_file,'%s\n\r\n','Mock Inducer with Mock Afterimage Perception Rate');
            fprintf(stat_file,'%f\n\r',perceived_afterimage_mock_inducer_present_rate);
            
            fprintf(stat_file,'%s\n\r\n','No Inducer Perception Rate');
            fprintf(stat_file,'%f\n\r',perceived_afterimage_no_inducer_rate);
            
            fprintf(stat_file,'%s\n\r\n','Mock Inducer without Mock Afterimage Perception Rate');
            fprintf(stat_file,'%f\n\r',perceived_afterimage_mock_inducer_absent_rate);
        
            % Store perception data
            all_sub_real_inducer_afterimage_perception_rate = [all_sub_real_inducer_afterimage_perception_rate; CP_afterimage_real_inducer_rate];
            all_sub_mock_ind_w_mock_afterimage_perception_rate = [all_sub_mock_ind_w_mock_afterimage_perception_rate; perceived_afterimage_mock_inducer_present_rate];
            all_sub_mock_ind_wo_mock_afterimage_perception_rate = [all_sub_mock_ind_wo_mock_afterimage_perception_rate; perceived_afterimage_mock_inducer_absent_rate];

        end

    end

    %% Main Experiment Analysis 
    
    % Skip main experiment analysis if OP4 session
    if ~isequal(modality_condition,'OP4')
    
        % Several analysis steps on the main experiment task phase
        
        % Main Experiment Conditions 
        % Note: Condition names are updated after task version 15. 
        % The previous task versions used a legacy condition 
        % numbering system 2 for real inducer and 3 for mock inducer; Version 15
        % and up use 1 to indicate real inducer and 2 to indicate mock inducer.
        real_inducer_condition = 1; 
        mock_inducer_condition = 2;
        
        %% Find Task Version Number
        
        % Note: The log file only reports the task version number from afterimage
        % paradigm task version 15.1 and up (i.e., version 15.0 and below do not
        % log the version number)
        
        % Set task version variable
        task_version = [];
        
        % Mine log file for specific string variables
        for row = 1:size(log_data,1)
        
            % Find "Task version" string
            if any(~cellfun('isempty',strfind(log_data(row),'Task version')))
            
                % Extract task version row
                task_version = cell2mat(log_data(row,:));
                
                % Find index for colon (:)
                begin_colon = strfind(task_version,':');
        
                %Cut out the version string
                task_version = task_version(begin_colon+2:end);
        
            end
        
        end
        
        % Default set the task version to 15.0
        if isempty(task_version)
                
            %Default task version to v15.0 for subjects run prior to the
            %addition of task code that indicates the task version in the log
            %file.
            task_version = 'v15.0';
        
        end
        
        %% Read Data File
        
        % Cut table rows to relevant task type - Main Experiment
        trial_type = find(strcmp('Main_Experiment',raw(:,1)));
        main_experiment_data = raw(trial_type,:);
        
        % Only continue with main experiment rows (there must be at least one block
        % of main experiment trials to continue with analysis; i.e., ignore if only
        % a handlful of main experiment trials were completed for training purposes
        % in OP4, for example. 
        if ~isempty(main_experiment_data) || size(main_experiment_data,1) > 27
            
            % Cut table header
            main_experiment_header = raw(trial_type(1)-1,:);
            
            % Find columns
            block_column = find(strcmp('Block_Number',main_experiment_header));
            condition_column = find(strcmp('Trial_Condition',main_experiment_header));
            mock_afterimage_present_column = find(strcmp('Afterimage_Present',main_experiment_header));
            target_location_column = find(strcmp('Target_Location',main_experiment_header));
            prestim_column = find(strcmp('Pre_Stimulus_Time',main_experiment_header));
            poststim_column = find(strcmp('Post_Stimulus_Time',main_experiment_header));
            afterimage_onset_column = find(strcmp('Afterimage_Onset',main_experiment_header));
            afterimage_offset_column = find(strcmp('Afterimage_Offset',main_experiment_header));
        
            % Trial Condition Index (1 = real inducer; 2 = mock inducer)
            trial_condition_idx = cell2mat(main_experiment_data(:,condition_column));
        
            % Correct inducer location information for task version v15.0
            % Note: Due to a coding error in the Psychopy task script the real
            % inducer stimuli locations are incorrectly coded in the text/log files
            % of the task. However, they were shown correctly on screen. All
            % subjects who completed task version v15.1 and above do not require
            % this correction. 
        
            % Check task verison as v15.0
            if strcmp(task_version, 'v15.0')
                
                % Loop over rows of main experiment
                for row = 1:size(main_experiment_data,2)
                    
                    % If a real inducer condition
                    if isequal(main_experiment_data{row, condition_column}, 1)
                        
                        % Check for logs of left sided real inducers
                        if any(strfind(main_experiment_data{row, target_location_column}, '-12'))
                            
                            % Replace value with 12 (right side)
                            main_experiment_data(row,target_location_column) = {'12'};
                        
                        % Check for logs of right sided real iducers
                        elseif any(strfind(main_experiment_data{row, target_location_column}, '12'))
                            
                            % Replace value with -12 (left side)
                            main_experiment_data(row,target_location_column) = {'-12'};
        
                        end
        
                    end
        
                end
        
            end
            
            % Mock Afterimage Present (1 = present; 0 = absent OR real afterimage, so afterimage present status is unknown) 
            afterimage_present = logical(cell2mat(main_experiment_data(:,mock_afterimage_present_column)));
            
            % Afterimage onset and offset
            afterimage_perceived_onset = main_experiment_data(:,afterimage_onset_column);
            afterimage_perceived_offset = main_experiment_data(:,afterimage_offset_column);
            
            % Replace 'None' with NaN and convert from cell to matrix vector
            afterimage_perceived_onset(strcmp(afterimage_perceived_onset,'None')) = {nan};
            afterimage_perceived_offset(strcmp(afterimage_perceived_offset,'None')) = {nan};
               
            % Special consideration for subject
            if ismember(sub_ID,{'026','028','033','037','040','052','054','059','062','065','067'}) && isequal(modality_condition,'7T_V1')
            
                % Convert number to string
                for row = 1:length(afterimage_perceived_onset)

                    afterimage_perceived_onset{row} = num2str(afterimage_perceived_onset{row});
                    afterimage_perceived_offset{row} = num2str(afterimage_perceived_offset{row});

                end

                % Convert array to mat
                afterimage_perceived_onset = str2double(afterimage_perceived_onset);
                afterimage_perceived_offset = str2double(afterimage_perceived_offset);

            else

                afterimage_perceived_onset = cell2mat(afterimage_perceived_onset);
                afterimage_perceived_offset = cell2mat(afterimage_perceived_offset);

            end
            
            % Seen Afterimage Index (if both the afterimage onset and offset times
            % column are not 'None' and the afterimage offset time is greater than the onset time i.e., onset was pressed before offset)
            reported_afterimage_index = ~strcmp(main_experiment_data(:,afterimage_onset_column),'None') & ...
                ~strcmp(main_experiment_data(:,afterimage_offset_column),'None') & ...
                afterimage_perceived_offset > afterimage_perceived_onset;
            
            % Check if afterimage vectors are the same length because they are used
            % for indexing among each other below
            if ~isequal(length(afterimage_perceived_onset), length(afterimage_perceived_offset), ...
                    length(afterimage_present), length(trial_condition_idx), length(reported_afterimage_index))
            
                error('Number of trials mismatch among trial indices!')
            
            end
        
            %% Quantify basic stats of the Main Experiment
        
            % Total number of blocks
            if ~isequal(file_num,'All')
        
                num_blocks = length(unique(cell2mat(main_experiment_data(:, block_column))));
        
            else
                
                % Divide the number of trials by the number of trials in a block
                % (28 trials)
                num_blocks = length(main_experiment_data)/28;
        
            end
        
            % Total number of trials
            num_trials = size(main_experiment_data,1);
        
            % Total number of trial conditions (1 = read inducer; 2 = mock inducer)
            num_condition_1 = length(find(cell2mat(main_experiment_data(:, condition_column)) == 1));
            num_condition_2 = length(find(cell2mat(main_experiment_data(:, condition_column)) == 2));
        
            % Total number of mock afterimages (Condition = 2 and mock afterimage
            % present = 1; Note that condition 1 should always be coded with 0 for
            % the mock afterimage present)
            num_mock_afterimages = length(find(cell2mat(main_experiment_data(:, mock_afterimage_present_column)) == 1 ...
                & cell2mat(main_experiment_data(:, condition_column)) == 2));
        
            % Total number of locations
        
            % Initialize variables
            num_left_presentation = 0;
            num_right_presentation = 0;
        
            % Loop over the main experiment data rows
            for row = 1:length(main_experiment_data)
                
                % If left-sided stimulus location
                if any(strfind(main_experiment_data{row, target_location_column}, '-12'))
                   
                   % Add to count
                   num_left_presentation = num_left_presentation + 1;
                
                % If right-sided stimulus location
                elseif any(strfind(main_experiment_data{row, target_location_column}, '12'))
        
                   % Add to count
                   num_right_presentation = num_right_presentation + 1;
        
                end
        
            end
        
            % Post-stimulus durations
            num_post_10s = length(find(cell2mat(main_experiment_data(:, poststim_column)) == 10));
            num_post_11s = length(find(cell2mat(main_experiment_data(:, poststim_column)) == 11));
            num_post_12s = length(find(cell2mat(main_experiment_data(:, poststim_column)) == 12));
        
            % Pre-stimulus durations
            num_pre_10s = length(find(cell2mat(main_experiment_data(:, prestim_column)) == 10));
            num_pre_11s = length(find(cell2mat(main_experiment_data(:, prestim_column)) == 11));
            num_pre_12s = length(find(cell2mat(main_experiment_data(:, prestim_column)) == 12));
        
            % Sample size checks
            if ~isequal(num_left_presentation, num_right_presentation) && ~isequal(num_condition_1, num_condition_2) ...
                    && ~isequal(num_post_10s+num_post_11s+num_post_12s,num_trials) && ~isequal(num_pre_10s+num_pre_11s+num_pre_12s,num_trials)
                    
                error('Number of trials/conditions is wrong! Check behavioral data.')
        
            end
        
            % *** Store the Stats File ***
            fprintf(stat_file,'%s\n\r\n','*** Main Experiment ***');
            fprintf(stat_file,'%s\n\r\n','*** General Task Statistics ***');
        
            fprintf(stat_file,'%s\n\r\n','Number of Blocks / Trials');
            fprintf(stat_file,'%f\n\r',[num_blocks num_trials]);
        
            fprintf(stat_file,'%s\n\r\n','Number of Condition 1 / 2 Trials');
            fprintf(stat_file,'%f\n\r',[num_condition_1 num_condition_2]);
        
            fprintf(stat_file,'%s\n\r\n','Number of Left / Right Presented Trials');
            fprintf(stat_file,'%f\n\r',[num_left_presentation num_right_presentation]);
        
            fprintf(stat_file,'%s\n\r\n','Number of Mock Afterimage Trials');
            fprintf(stat_file,'%f\n\r',[num_mock_afterimages]);
        
            fprintf(stat_file,'%s\n\r\n','Number of 10 / 11 / 12s Pre-Stimulus Trials');
            fprintf(stat_file,'%f\n\r',[num_pre_10s num_pre_11s num_pre_12s]);
        
            fprintf(stat_file,'%s\n\r\n','Number of 10 / 11 / 12 Post-Stimulus Trials');
            fprintf(stat_file,'%f\n\r',[num_post_10s num_post_11s num_post_12s]);
        
            %% Quantify perception stats
        
            % Categorize the afterimages into real and mock CP/FP categories (Note:
            % there can be no FP condition for the real inducer because there is
            % no objective validation)
            
            % Real inducer condition and reported an afterimage
            CP_real_afterimage_index = trial_condition_idx == real_inducer_condition & reported_afterimage_index == 1;
    
            % Real inducer condition and did not report an afterimage
            CnP_real_afterimage_index = trial_condition_idx == real_inducer_condition & reported_afterimage_index == 0;
        
            % Mock inducer condition and reported an afterimage and mock afterimage present
            CP_mock_afterimage_index = trial_condition_idx == mock_inducer_condition & afterimage_present == 1 & reported_afterimage_index == 1;
            
            % Mock inducer condition and did not report an afterimage and mock afterimage present
            FP_mock_afterimage_index = trial_condition_idx == mock_inducer_condition & afterimage_present == 0 & reported_afterimage_index == 1;
            
            % Mock inducer condition and did not report an afterimage and mock afterimage not present
            TN_mock_afterimage_index = trial_condition_idx == mock_inducer_condition & afterimage_present == 0 & reported_afterimage_index == 0;
        
            % Calculate the rates of afterimage perception
        
            % (1) Real Inducer with/without Afterimage
        
            % Total number of real inducers
            total_real_inducers = sum(trial_condition_idx == real_inducer_condition);
        
            % Afterimage rate: CP real afterimages divided by the total number of real inducer trials
            CP_afterimage_real_inducer_rate = sum(CP_real_afterimage_index) / total_real_inducers;
    
            % No afterimage rate: CnP real afterimages divide by the total number of real inducer trials
            CnP_afterimage_real_inducer_rate = sum(CnP_real_afterimage_index) / total_real_inducers;
    
            % Check the numbers are correct
            if ~isequal(sum(CP_real_afterimage_index)+sum(CnP_real_afterimage_index), total_real_inducers)
    
                error('CP and CnP real afterimage number mismatch!')
    
            end
    
            % (2) Perceived Afterimage when Mock Inducer Present - *with* Mock Afterimage
            
            % Total number of mock inducers with mock afterimage
            total_mock_inducers_w_mock_afterimage = sum(trial_condition_idx == mock_inducer_condition & afterimage_present == 1);
        
            % Afterimage rate: CP mock afterimages divided by the total number of
            % mock inducer trials with a mock afterimage
            CP_afterimage_mock_inducer_rate = sum(CP_mock_afterimage_index) / total_mock_inducers_w_mock_afterimage;
        
            % (3) Perceived Afterimage when Mock Inducer Present - *without* Mock Afterimage
        
            % Total number of mock inducers without mock afterimage
            total_mock_inducers_wo_mock_afterimage = sum(trial_condition_idx == mock_inducer_condition & afterimage_present == 0);
        
            % Afterimage rate: FP mock afterimages divided by the total number of
            % mock inducer trials without a mock afterimage
            FP_afterimage_mock_inducer_rate = sum(FP_mock_afterimage_index) / total_mock_inducers_wo_mock_afterimage;
          
            % *** Store the Stats File ***
            fprintf(stat_file,'%s\n\r\n','*** Perception Statistics ***');
            fprintf(stat_file,'%s\n\r\n','*** Perception Rates ***');
        
            fprintf(stat_file,'%s\n\r\n','Real Inducer Perception Rate');
            fprintf(stat_file,'%f\n\r',CP_afterimage_real_inducer_rate);
            
            fprintf(stat_file,'%s\n\r\n','Mock Inducer with Mock Afterimage Perception Rate');
            fprintf(stat_file,'%f\n\r',CP_afterimage_mock_inducer_rate);
            
            fprintf(stat_file,'%s\n\r\n','Mock Inducer without Mock Afterimage Perception Rate');
            fprintf(stat_file,'%f\n\r',FP_afterimage_mock_inducer_rate);
    
            fprintf(stat_file,'%s\n\r\n','Number of RIWAF');
            fprintf(stat_file,'%f\n\r',sum(CP_real_afterimage_index));
    
            fprintf(stat_file,'%s\n\r\n','Number of RIWOAF');
            fprintf(stat_file,'%f\n\r',sum(CnP_real_afterimage_index));
    
            fprintf(stat_file,'%s\n\r\n','Number of MIWAF');
            fprintf(stat_file,'%f\n\r',sum(CP_mock_afterimage_index));
                
            fprintf(stat_file,'%s\n\r\n','Number of MIWOAF');
            fprintf(stat_file,'%f\n\r',sum(TN_mock_afterimage_index));
    
            % Store subject values
            num_RIWAF = [num_RIWAF; sum(CP_real_afterimage_index)];
            num_RIWOAF = [num_RIWOAF; sum(CnP_real_afterimage_index)];
            num_MIWAF = [num_MIWAF; sum(CP_mock_afterimage_index)];
            num_MIWOAF = [num_MIWOAF; sum(TN_mock_afterimage_index)];

            all_sub_real_inducer_afterimage_perception_rate = [all_sub_real_inducer_afterimage_perception_rate; CP_afterimage_real_inducer_rate];
            all_sub_mock_ind_w_mock_afterimage_perception_rate = [all_sub_mock_ind_w_mock_afterimage_perception_rate; CP_afterimage_mock_inducer_rate];
            all_sub_mock_ind_wo_mock_afterimage_perception_rate = [all_sub_mock_ind_wo_mock_afterimage_perception_rate; FP_afterimage_mock_inducer_rate];

            %% Afterimage Duration Calculation
        
            % CP real afterimage duration
            CP_real_afterimage_durations = afterimage_perceived_offset(CP_real_afterimage_index) - afterimage_perceived_onset(CP_real_afterimage_index);
            
            % Calculate mean
            CP_real_afterimage_mean_duration = nanmean(CP_real_afterimage_durations);
        
            % Calculate variance
            CP_real_afterimage_var_duration = nanvar(CP_real_afterimage_durations);
            
            % CP mock afterimage duration
            CP_mock_afterimage_durations = afterimage_perceived_offset(CP_mock_afterimage_index) - afterimage_perceived_onset(CP_mock_afterimage_index);
        
            % Calculate mean
            CP_mock_afterimage_mean_duration = nanmean(CP_mock_afterimage_durations);
            
            % Calculate variance
            CP_mock_afterimage_var_duration = nanvar(CP_mock_afterimage_durations);
        
            % FP mock afterimage duration
            FP_mock_afterimage_durations = afterimage_perceived_offset(FP_mock_afterimage_index) - afterimage_perceived_onset(FP_mock_afterimage_index);
        
            % Calculate mean
            FP_mock_afterimage_mean_duration = nanmean(FP_mock_afterimage_durations);
        
            % Calculate variance
            FP_mock_afterimage_var_duration = nanvar(FP_mock_afterimage_durations);
        
            % *** Store the Stats File ***
            fprintf(stat_file,'%s\n\r\n','*** Afterimage Durations ***');
        
            fprintf(stat_file,'%s\n\r\n','CP Real Afterimage Mean Duration');
            fprintf(stat_file,'%f\n\r',CP_real_afterimage_mean_duration);
            
            fprintf(stat_file,'%s\n\r\n','CP Mock Afterimage Mean Duration');
            fprintf(stat_file,'%f\n\r',CP_mock_afterimage_mean_duration);
            
            fprintf(stat_file,'%s\n\r\n','FP Mock Afterimage Mean Duration');
            fprintf(stat_file,'%f\n\r',FP_mock_afterimage_mean_duration);
        
            fprintf(stat_file,'%s\n\r\n','CP Real Afterimage Duration Variance');
            fprintf(stat_file,'%f\n\r',CP_real_afterimage_var_duration);
            
            fprintf(stat_file,'%s\n\r\n','CP Mock Afterimage Duration Variance');
            fprintf(stat_file,'%f\n\r',CP_mock_afterimage_var_duration);
            
            fprintf(stat_file,'%s\n\r\n','FP Mock Afterimage Duration Variance');
            fprintf(stat_file,'%f\n\r',FP_mock_afterimage_var_duration);
        
            %% Plot afterimage duration scatter plot
            
            % Setup figure
            figure
            hold on
        
            % Figure parameters
            title(['Subject ID ', sub_ID, ' - Afterimage Duration'])    
            xlim([0.5,2.5])
            ylabel('Afterimage Duration (s)')
            xticklabels({'','CP Real Afterimage','CP Mock Afterimage', 'FP Mock Afterimage'})
        
            % CP real afterimage duration
            scatter(ones(length(CP_real_afterimage_durations)),CP_real_afterimage_durations, 'r')
            
            % CP mock afterimage duration
            scatter(ones(length(CP_mock_afterimage_durations))+0.5,CP_mock_afterimage_durations, 'b')
        
            % FP mock afterimage duration
            scatter(ones(length(FP_mock_afterimage_durations))+1,FP_mock_afterimage_durations, 'c')
        
            % Plot mean afterimage duration values
            scatter(1, CP_real_afterimage_mean_duration, "filled", 'k')
            scatter(1.5, CP_mock_afterimage_mean_duration, "filled", 'k')
            scatter(2, FP_mock_afterimage_mean_duration, "filled", 'k')
        
            %Save figure
            cd(save_dir)
            savefig('Afterimage_duration.fig')
            close
        
            %% Reconstruct the Presented Stimuli - Real and Mock Inducers
            
            % Setup matrices
            real_inducer_onset_time_array = [];
            real_inducer_offset_time_array = [];
        
            mock_inducer_onset_time_array = [];
            mock_inducer_offset_time_array = [];
        
            % Index of trail start rows
            trial_start_rows = [];
        
            % Mine log file for specific string variables
            for row = 1:size(log_data,1)
        
                % Find all opacity arrays
                if any(~cellfun('isempty',strfind(log_data(row),'AFTERIMAGE MAIN EXPERIMENT')))
            
                    task_phase_onset_row = row;
        
                elseif any(~cellfun('isempty',strfind(log_data(row),'Main Experiment Trial')))
                   
                    trial_start_rows = [trial_start_rows; row];
                
                end
        
            end
        
            % Study each trial
            for trial = 1:length(trial_start_rows)
                    
                % Setup empty matrices
                trial_time_array_tar1right = [];
                trial_opacity_array_tar1right = [];
            
                trial_time_array_tar1left = [];
                trial_opacity_array_tar1left = [];
            
                trial_time_array_tar2right = [];
                trial_opacity_array_tar2right = [];
        
                trial_time_array_tar2left = [];
                trial_opacity_array_tar2left = [];
        
                mock_afterimage_time_array = [];
                mock_afterimage_opacity_array = [];
            
                % For trials except the last
                if trial < length(trial_start_rows)
                    
                    % Find begin/end rows
                    begin_row = trial_start_rows(trial);
                    end_row = trial_start_rows(trial+1);
            
                else
                    
                    % Find begin/end rows
                    begin_row = trial_start_rows(trial);
                    end_row = length(log_data);
            
                end
            
                % Loop over trial rows
                for row = begin_row:end_row
            
                    % Target 1/Black Face - Right Side
                    if any(~cellfun('isempty',strfind(log_data(row),['Target_1_right opacity']))) || ...
                            any(~cellfun('isempty',strfind(log_data(row),['black_face_right opacity'])))
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select opacity and time values
                       opacity_value = str2num(log_row(begin_colon+1:end));
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       trial_time_array_tar1right = [trial_time_array_tar1right; time_value];
                       trial_opacity_array_tar1right = [trial_opacity_array_tar1right; opacity_value];
            
                    % Target 1/Black Face - Left Side
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Target_1_left opacity']))) || ...
                            any(~cellfun('isempty',strfind(log_data(row),['black_face_left opacity'])))
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select opacity and time values
                       opacity_value = str2num(log_row(begin_colon+1:end));
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       trial_time_array_tar1left = [trial_time_array_tar1left; time_value];
                       trial_opacity_array_tar1left = [trial_opacity_array_tar1left; opacity_value];
                    
                    % Target 2/White Face - Left Side
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Target_2_left opacity']))) || ...
                            any(~cellfun('isempty',strfind(log_data(row),['white_face_left opacity'])))
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select opacity and time values
                       opacity_value = str2num(log_row(begin_colon+1:end));
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       trial_time_array_tar2left = [trial_time_array_tar2left; time_value];
                       trial_opacity_array_tar2left = [trial_opacity_array_tar2left; opacity_value];
                    
                    % Target 2/White Face - Right Side
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Target_2_right opacity']))) || ...
                            any(~cellfun('isempty',strfind(log_data(row),['white_face_right opacity'])))
        
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select opacity and time values
                       opacity_value = str2num(log_row(begin_colon+1:end));
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       trial_time_array_tar2right = [trial_time_array_tar2right; time_value];
                       trial_opacity_array_tar2right = [trial_opacity_array_tar2right; opacity_value];
                    
                    % Mock afterimage
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Physical afterimage stimulus opacity']))) || ...
                            any(~cellfun('isempty',strfind(log_data(row),['Mock afterimage stimulus opacity'])))
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select opacity and time values
                       opacity_value = str2num(log_row(begin_colon+1:end));
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       mock_afterimage_time_array = [mock_afterimage_time_array; time_value];
                       mock_afterimage_opacity_array = [mock_afterimage_opacity_array; opacity_value];
        
                    % Real inducer onset
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Real inducer onset']))) 
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select time values
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       real_inducer_onset_time_array = [real_inducer_onset_time_array; time_value];
                       mock_inducer_onset_time_array = [mock_inducer_onset_time_array; nan];
        
                    % Real inducer offset
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Real inducer offset']))) 
        
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select time values
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       real_inducer_offset_time_array = [real_inducer_offset_time_array; time_value];
                       mock_inducer_offset_time_array = [mock_inducer_offset_time_array; nan];
        
                    % Mock inducer onset
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Mock inducer onset']))) 
                       
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select time values
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       mock_inducer_onset_time_array = [mock_inducer_onset_time_array; time_value];
                       real_inducer_onset_time_array = [real_inducer_onset_time_array; nan];
        
                    % Mock inducer offset
                    elseif any(~cellfun('isempty',strfind(log_data(row),['Mock inducer offset']))) 
        
                       % Cut out log row 
                       log_row = cell2mat(log_data(row,:));
                       begin_colon = strfind(log_row,':');
                       begin_EXP = strfind(log_row,'EXP');
                       
                       % Select time values
                       time_value = str2num(log_row(1:begin_EXP-1)); 
            
                       % Add to trial array
                       mock_inducer_offset_time_array = [mock_inducer_offset_time_array; time_value];
                       real_inducer_offset_time_array = [real_inducer_offset_time_array; nan];
        
                    end
            
                end
            
                % Add to opacity/time arrays
        
                % Target 1 - Right Side
                all_opacity_array_tar1right{trial,1} = trial_opacity_array_tar1right;
                all_time_array_tar1right{trial,1} = trial_time_array_tar1right;
            
                % Target 1 - Left Side
                all_opacity_array_tar1left{trial,1} = trial_opacity_array_tar1left;
                all_time_array_tar1left{trial,1} = trial_time_array_tar1left;
            
                % Target 2 - Left Side
                all_opacity_array_tar2left{trial,1} = trial_opacity_array_tar2left;
                all_time_array_tar2left{trial,1} = trial_time_array_tar2left;
        
                % Target 2 - Right Side
                all_opacity_array_tar2right{trial,1} = trial_opacity_array_tar2right;
                all_time_array_tar2right{trial,1} = trial_time_array_tar2right;
                
                % Mock afterimage 
                all_opacity_mock_afterimage_array{trial,1} = mock_afterimage_opacity_array;
                all_time_mock_afterimage_array{trial,1} = mock_afterimage_time_array;
            
            end
              
            %% Plot Inducer/Mock Afterimage Timecourses 
        
            % Setup Figure
            figure
            hold on
            
            % Figure parameters
            ylim([0 1.25])
            title(['Subject ID ', sub_ID, ' - Inducer Stimulus'])
            ylabel('Contrast Value')
            xlabel('Time (s)')
            
            % Loop over trials
            for trial = 1:length(trial_start_rows)
                
                % Check if trial information is empty
                if ~isempty(all_time_array_tar1right{trial})
        
                    % Target 1 - Right Side
                    trial_time = all_time_array_tar1right{trial,1};
                    trial_opacity = all_opacity_array_tar1right{trial,1};
                    
                    % Plot
                    plot(trial_time-trial_time(1), trial_opacity,'b') 
        
                end
        
                % Check if trial information is empty
                if ~isempty(all_time_array_tar1left{trial})
        
                    % Target 1 - Left Side
                    trial_time = all_time_array_tar1left{trial,1};
                    trial_opacity =  all_opacity_array_tar1left{trial,1};
                    
                    % Plot
                    plot(trial_time-trial_time(1), trial_opacity,'r')
        
                end
        
                % Check if trial information is empty
                if ~isempty(all_time_array_tar2left{trial})
        
                    % Target 2 - Left Side
                    trial_time = all_time_array_tar2left{trial,1};
                    trial_opacity = all_opacity_array_tar2left{trial,1};
        
                    % Plot
                    plot(trial_time-trial_time(1), trial_opacity,'g')
        
                end
        
                % Check if trial information is empty
                if ~isempty(all_time_array_tar2right{trial})
        
                    % Target 2 - Right Side
                    trial_time = all_time_array_tar2right{trial,1};
                    trial_opacity = all_opacity_array_tar2right{trial,1};
        
                    %Plot
                    plot(trial_time-trial_time(1), trial_opacity,'y')
                
                end
        
            end
        
            %Save figure
            cd(save_dir)
            savefig('Real_mock_inducer_stimuli.fig')
            close
        
            %% Plot Mock Afterimage Timecourses
        
            % Setup figure
            figure
            hold on
            
            %Figure parameters
            hot_map = colormap(hot);
            xlim([-0.5 10])
            ylim([0 0.25])
            title(['Subject ID ', sub_ID, ' - Mock Afterimage Stimulus'])
            ylabel('Contrast Value')
            xlabel('Time (s)')
            
            % Loop over trials
            for trial = 1:length(trial_start_rows)
                
                % Check if trial information is empty
                if ~isempty(all_time_mock_afterimage_array{trial})
            
                    % Find trial time and opacity
                    trial_time = all_time_mock_afterimage_array{trial,1};
                    trial_opacity = all_opacity_mock_afterimage_array{trial,1};            
        
                    % Plot
                    plot(trial_time-trial_time(1), trial_opacity,'Color',hot_map(trial,:))
                    
                end
            
            end
        
            %Save figure
            cd(save_dir)
            savefig('Mock_afterimage_stimuli.fig')
            close 
        
            %% Measure Afterimage Latency
        
            % Check if afterimage vectors are the same length because they are used
            % for indexing among each other below
            if ~isequal(length(real_inducer_onset_time_array), length(real_inducer_offset_time_array), ...
                    length(mock_inducer_onset_time_array), length(mock_inducer_offset_time_array), length(reported_afterimage_index))
            
                error('Number of trials mismatch among trial indices!')
            
            end
        
            % Measure the latency of the afterimage from inducer offset
            CP_real_afterimage_latency = afterimage_perceived_onset(CP_real_afterimage_index == 1);
            CP_mock_afterimage_latency = afterimage_perceived_onset(CP_mock_afterimage_index == 1);
            FP_mock_afterimage_latency = afterimage_perceived_onset(FP_mock_afterimage_index == 1);
        
            % Calculate the mean afterimage onset latency
            CP_real_afterimage_mean_latency = nanmean(CP_real_afterimage_latency);
            CP_mock_afterimage_mean_latency = nanmean(CP_mock_afterimage_latency);
            FP_mock_afterimage_mean_latency = nanmean(FP_mock_afterimage_latency);
        
            % Calculate the variance afterimage onset latency
            CP_real_afterimage_variance_latency = var(CP_real_afterimage_latency);
            CP_mock_afterimage_variance_latency = var(CP_mock_afterimage_latency);
            FP_mock_afterimage_variance_latency = var(FP_mock_afterimage_latency);

            % Store all subject variable
            all_sub_image_stim_duration = [all_sub_image_stim_duration; CP_mock_afterimage_mean_duration];
            all_sub_image_stim_onset_latency = [all_sub_image_stim_onset_latency; CP_mock_afterimage_mean_latency];
            all_sub_afterimage_duration = [all_sub_afterimage_duration; CP_real_afterimage_mean_duration];
            all_sub_afterimage_onset_latency = [all_sub_afterimage_onset_latency; CP_real_afterimage_mean_latency];
            
            % *** Store the Stats File ***
            fprintf(stat_file,'%s\n\r\n','*** Afterimage Onset Latency ***');
        
            fprintf(stat_file,'%s\n\r\n','CP Real Afterimage Mean Onset Latency');
            fprintf(stat_file,'%f\n\r',CP_real_afterimage_mean_latency);
            
            fprintf(stat_file,'%s\n\r\n','CP Mock Afterimage Mean Onset Latency');
            fprintf(stat_file,'%f\n\r',CP_mock_afterimage_mean_latency);
        
            fprintf(stat_file,'%s\n\r\n','FP Mock Afterimage Mean Onset Latency');
            fprintf(stat_file,'%f\n\r',FP_mock_afterimage_mean_latency);
        
            fprintf(stat_file,'%s\n\r\n','CP Real Afterimage Onset Latency Variance ');
            fprintf(stat_file,'%f\n\r',CP_real_afterimage_variance_latency);
            
            fprintf(stat_file,'%s\n\r\n','CP Mock Afterimage Onset Latency Variance ');
            fprintf(stat_file,'%f\n\r',CP_mock_afterimage_variance_latency);
        
            fprintf(stat_file,'%s\n\r\n','FP Mock Afterimage Onset Latency Variance ');
            fprintf(stat_file,'%f\n\r',FP_mock_afterimage_variance_latency);
    
      %{  
            %% Plot afterimage onset scatter plots - Mock vs Real Afterimage
            
            % Setup figure
            figure
            hold on
        
            % Figure parameters
            title(['Subject ID ', sub_ID, ' - Afterimage Onset Latency'])    
            xlim([0.5,2.5])
            ylim([0 10])
            ylabel('Afterimage Onset From Inducer Offset (s)')
            xticklabels({'','CP Real Afterimage','CP Mock Afterimage','FP Mock Afterimage'})
        
            % CP real afterimage duration
            scatter(ones(length(CP_real_afterimage_latency)),CP_real_afterimage_latency, 'r')
        
            % CP mock afterimage duration
            scatter(ones(length(CP_mock_afterimage_latency))+0.5,CP_mock_afterimage_latency, 'b')
        
            % FP mock afterimage duration
            scatter(ones(length(FP_mock_afterimage_latency))+1,FP_mock_afterimage_latency, 'c')
        
            % Plot mean afterimage duration values
            scatter(1, CP_real_afterimage_mean_latency, "filled", 'k')
            scatter(1.5, CP_mock_afterimage_mean_latency, "filled", 'k')
            scatter(2, FP_mock_afterimage_mean_latency, "filled", 'k')
        
            %Save figure
            cd(save_dir)
            savefig('Afterimage_onset_latency.fig')
            close
        
            %% Plot afterimage onset scatter plots - Mock vs Real Afterimage vs trial #
        
            % Setup figure
            figure
            hold on
        
            % Figure parameters
            title(['Subject ID ', sub_ID, ' - Afterimage Onset Latency vs Trial #'])    
            ylim([0 10])
            ylabel('Afterimage Onset From Inducer Offset (s)')
        
            % Loop over trials
            for trial = 1:length(CP_real_afterimage_latency)
        
                % CP real afterimage duration
                real_afterimage = scatter(trial,CP_real_afterimage_latency(trial),'r');
        
            end
        
            %%%lsline(real_afterimage)
        
            % Loop over trials
            for trial = 1:length(CP_mock_afterimage_latency)
        
                % CP mock afterimage duration
                mock_afterimage = scatter(trial,CP_mock_afterimage_latency(trial), 'b');
        
            end
        
            %Setup Legend
            legend([real_afterimage, mock_afterimage], {'Real Afterimage','Mock Afterimage'})
        
            %Save figure
            cd(save_dir)
            savefig('Afterimage_onset_latency_vs_trial.fig')
            close
        %}
        % If no main experiment trials are found
        else
        
            warning('Main Experiment session is absent or not a full run completed!')
        
        end
    
    end

    %% End Analysis 
    
    % Return to save_dir
    cd(save_dir)
    close all

end

%% Save Group Data

if save_group_data == 1

    cd(group_dir)
    if isequal(modality_condition, '7T_Whole_Brain') || isequal(modality_condition, '7T_V1')

        save(['Group_',modality_condition,'_behavioral_data.mat'], 'all_sub_image_stim_onset_latency', 'all_sub_afterimage_onset_latency', ...
            'all_sub_afterimage_duration', 'all_sub_image_stim_duration','all_sub_mock_ind_w_mock_afterimage_perception_rate',...
            'all_sub_mock_ind_wo_mock_afterimage_perception_rate','all_sub_real_inducer_afterimage_perception_rate','all_sub_IDs')

    else

        save(['Group_',modality_condition,'_behavioral_data.mat'], 'all_sub*')

    end

end
