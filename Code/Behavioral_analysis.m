%% Afterimage Paradigm - Behavioral Analysis

% Kronemer et al., Neuroscience of Consciousness, 2024

% This script will read subject task log and text files and process them.
% Text and log files are created by the afterimage paradigm behavioral task.

% INPUT:
% Subject log file(s)
% Subject xls file(s)

% OUTPUT:
% Text file with subject behavioral results
% Mat file with all subject behavioral results 
% Behavioral result figures

% Written By: Sharif I. Kronemer
% Last Modified: 7/12/2024

clear all

%% Parameters

% Save group data? (1 = Yes; 0 = No)
% Note: If you are analyzing only one subject/subset set to 0
save_group_data = 1;

% Real/image stimulus stats
% Note: See Kronemer et al., 2024 for method details
image_duration = 4; % Seconds
image_contrast = 0.25;
max_sharpness_value = 25;

%% Group Directories

% Root directory
root_dir = pwd;

% Subject folder directories
subject_list = dir(fullfile(root_dir, 'Data'));

% Remove non-subject names
subject_list(1:3) = [];

% Group folder directory
if save_group_data == 1

    group_dir = fullfile(root_dir,'Analysis','Group_Analysis','Behavior');

    % Make save directory if it does not exist
    if ~isfolder(group_dir)
    
        mkdir(group_dir)
    
    end

end


%% Behavioral Analysis

% Initialize group variables
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

% Loop over subjects
for sub = 1:length(subject_list)
    
    % Current subject
    sub_ID = subject_list(sub).name;

    %% Subject Directories 
    
    % Subject directory
    sub_dir = fullfile(root_dir,'Data',sub_ID);
    
    % Check if subject directory exists
    if exist(sub_dir)

        disp(['Running subject ', num2str(sub_ID)])

        % Store subject IDs
        all_sub_IDs = [all_sub_IDs; num2str(sub_ID)];
    
        % Subject save directory
        save_dir = fullfile(root_dir,'/Analysis/Subject_Analysis',sub_ID);
        
        % Make save directory if it does not exist
        if ~isfolder(save_dir)
        
            mkdir(save_dir)
        
        end
    
    else
    
        disp('Subject directory does not exist - moving on!')
        continue
    
    end
    
    %% Load xls/txt Data
    
    % Find directories with xls extension
    data_file = dir(fullfile(sub_dir,'*.xls'));
    
    % If more than one file in directory
    if size(data_file,1) > 1
    
        % Prompt in command line which file to select among those found
        file_num = 'All';
        
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
    
            % Add to raw variable
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

    %% Real/Image Perceptual Blur/Sharpness Analysis

    % Note: Kronemer et al., 2024 uses sharpness, while some of the task
    % outputs used blur or blurriness to describe the same
    % perceptual feature; blur and sharpness are used interchangeably
        
    % Cut table rows to relevant task type
    trial_type = find(strcmp('Real_Blur',raw(:,1)));
    
    % Cut raw data
    real_blur_data = raw(trial_type,:);
    
    % Only continue if rows are available
    if ~isempty(real_blur_data)
    
        % Cut table header
        real_blur_header = raw(trial_type(1)-1,:);
        
        % Find min sharpness and selected sharpness columns; Note: The min blur
        % refers to the minimum blur value (or maximum crispness/sharpness
        % value) of the on screen image stimulus. 
        min_blur_column = find(strcmp('Trial_Min_Blur_Value',real_blur_header));
        selected_sharpness_column = find(strcmp('Selected_Blur_Value',real_blur_header));
        
        % Pull out sharpness data
        min_sharpness_data = cell2mat(real_blur_data(:,min_blur_column));
        selected_image_sharpness_data = real_blur_data(:,selected_sharpness_column);
        
        % Replace none with NaNs
        selected_sharpness_data_char = cellfun(@num2str,selected_image_sharpness_data,'un',0);
        selected_image_sharpness_data(ismember(selected_sharpness_data_char,'None'))= {nan}; 
        selected_image_sharpness_data = cell2mat(selected_image_sharpness_data);
    
        % Check that the arrays are the same length and equal 20 trials
        if ~isequal(length(min_sharpness_data),length(selected_image_sharpness_data),20)
    
            error('Blur data vectors are not the same length/wrong number!')
    
        end
        
        % Real minus selected sharpness value
        % Note: This calculates the error in the participant selected blur 
        % values relative to the true blur values of the image stimulus
        diff_sharpness_data = selected_image_sharpness_data-min_sharpness_data;
        diff_sharpness_data_flipped = abs(selected_image_sharpness_data-max_sharpness_value)-abs(min_sharpness_data-max_sharpness_value);

        % Mean real minus selected blur value
        mean_diff_sharpness = nanmean(diff_sharpness_data);
        mean_diff_sharpness_flipped = nanmean(diff_sharpness_data_flipped);

        % Find the mean selected sharpness value
        mean_selected_sharpness = nanmean(selected_image_sharpness_data);

        % Flip data
        % Note: In the current scale as the numbers
        % get larger the image is reported as less crisp. This is the
        % opposite of the contrast/brightness data set where as the numbers
        % get large the image is reported as brighter. To guide intuition
        % of the results, the sign of the data is flipped so that large
        % values correspond with sharper. The values are baselined to 25
        % because that is the maximum bluriness value that participants
        % coudl select. See Kronemer et al., 2024 for method details.
        mean_selected_sharpness_flipped = abs(mean_selected_sharpness-max_sharpness_value);

        % Add blur data to all subject data varaible
        all_sub_mean_image_stim_sharpness = [all_sub_mean_image_stim_sharpness; mean_selected_sharpness];
        all_sub_mean_image_stim_sharpness_flipped = [all_sub_mean_image_stim_sharpness_flipped; mean_selected_sharpness_flipped];
        all_sub_selected_vs_image_stim_sharpness = [all_sub_selected_vs_image_stim_sharpness; mean_diff_sharpness];
        all_sub_selected_vs_image_stim_sharpness_flipped = [all_sub_selected_vs_image_stim_sharpness_flipped; mean_diff_sharpness_flipped];
        
        % *** Plot sharpness values ***
        figure 
        hold on
        
        % Figure parameters
        yticks([1:8])
        title(['Subject ', sub_ID, ' - Image Sharpness'])
        xlabel('Image Sharpness Value - Selected Sharpness Value (Pixels)')
        ylabel('Count')
        
        % Histogram
        histogram(diff_sharpness_data)
        
        % Mean Line
        plot([mean_diff_sharpness, mean_diff_sharpness],[0 8],'--r')
        
        % Save figure
        cd(save_dir)
        savefig('Image_sharpness.fig')
        close
        
        % Update text file
        fprintf(stat_file,'%s\n\r\n','*** Image Sharpness Matching ***');
        fprintf(stat_file,'%s\n\r\n','Mean Image Sharpness vs Selected Sharpness Value');
        fprintf(stat_file,'%f\n\r',mean_diff_sharpness);
    
    end
       
    %% Afterimage Sharpness Analysis
    
    % Cut table rows to relevant task type
    trial_type = find(strcmp('Afterimage_Blur',raw(:,1)));
    
    % Cut table
    afterimage_sharpness_data = raw(trial_type,:);
    
    % Only continue if rows are available
    if ~isempty(afterimage_sharpness_data)
    
        % Cut table header
        afterimage_sharpness_header = raw(trial_type(1)-1,:);
        
        % Find min blur and selected blur columns
        selected_sharpness_column = find(strcmp('Selected_Blur_Value',afterimage_sharpness_header));
        
        % Pull out blur data
        selected_afterimage_sharpness_data = afterimage_sharpness_data(:,selected_sharpness_column);
        
        % Replace none with NaNs
        selected_sharpness_data_char = cellfun(@num2str,selected_afterimage_sharpness_data,'un',0);
        selected_afterimage_sharpness_data(ismember(selected_sharpness_data_char,'[]'))= {nan}; 
        selected_afterimage_sharpness_data = cell2mat(selected_afterimage_sharpness_data);
    
        % Check if all trials are accounted for
        if ~length(selected_afterimage_sharpness_data) == 30
    
            error('All afterimage sharpness trials not accounted for!')
    
        end
        
        % Mean blur data
        mean_afterimage_sharpness = nanmean(selected_afterimage_sharpness_data);

        % Flip data
        % Note: In the current scale as the numbers
        % get larger the image is reported as less crisp. This is the
        % opposite of the contrast/brightness data set where as the numbers
        % get large the image is reported as brighter. To guide intuition
        % of the results, the sign of the data is flipped so that large
        % values correspond with sharper. The values are baselined to 25
        % because that is the maximum bluriness value that participants
        % coudl select.
        mean_afterimage_sharpness_flipped = abs(mean_afterimage_sharpness-max_sharpness_value);

        % Store all subject mean afterimage blur
        all_sub_mean_afterimage_sharpness = [all_sub_mean_afterimage_sharpness; mean_afterimage_sharpness];
        all_sub_mean_afterimage_sharpness_flipped = [all_sub_mean_afterimage_sharpness_flipped; mean_afterimage_sharpness_flipped];

        % *** Plot blur data ***
        figure 
        hold on
        
        % Figure Parameters
        yticks([1:10])
        xlim([0 25])
        title(['Subject ', sub_ID, ' - Afterimage Sharpness'])
        xlabel('Blur Value')
        ylabel('Count')
        
        % Mean line
        plot([mean_afterimage_sharpness,mean_afterimage_sharpness],[0,10], '--r')
        
        % Histogram
        histogram(selected_afterimage_sharpness_data)
        
        %Save figure
        cd(save_dir)
        savefig('Afterimage_sharpness.fig')
        close
        
        % Update text file
        fprintf(stat_file,'%s\n\r\n','*** Afterimage Sharpness Matching ***');
        fprintf(stat_file,'%s\n\r\n','Mean Afterimage Selected Sharpness Value');
        fprintf(stat_file,'%f\n\r',mean_afterimage_sharpness);
    
    end
    
    %% Real/Image Stimulus Contrast Matching
    
    % Cut table rows to relevant task type
    trial_type = find(strcmp('Real_Contrast',raw(:,1)));
    
    % Cut table
    image_contrast_data = raw(trial_type,:);
    
    % Only continue if rows are available
    if ~isempty(image_contrast_data)
    
        % Index of trail start rows
        trial_start_rows = [];
        all_trial_image_time = [];
        all_trial_image_contrast = [];
        all_trial_image_matched_time = {};
        all_trial_image_matched_contrast = {};
        
        % Reset variable
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
            trial_image_time = [];
            trial_image_contrast = [];
       
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
                
                % Extract image stimulus time array
                if any(~cellfun('isempty',strfind(log_data(row),['Real time array'])))
                   
                   % Cut out log row 
                   log_row = cell2mat(log_data(row,:));
                   begin_EXP = strfind(log_row,':');
                   
                   % Select contrast and time values
                   trial_time_values = str2num(log_row(begin_EXP+1:end)); 
                   
                   % Store time array
                   all_trial_image_time = [all_trial_image_time; trial_time_values];
    
                % Extract image contrast array
                elseif any(~cellfun('isempty',strfind(log_data(row),['Real contrast array'])))
        
                   % Cut out log row 
                   log_row = cell2mat(log_data(row,:));
                   begin_EXP = strfind(log_row,':');
                   
                   % Select contrast and time values
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
                   
                   % Select contrast and time values
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
    
                   % Alternative contrast value check
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
            
            % Special consideration for some subjects
            % Note: These subjects completed a slightly different task 
            % version that did not save the array of the matched 
            % contrast/opacity values, so this script goes through each 
            % row of the log file and extracts that opacity/contrast info
            % and corresponding timing
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
    
                    % Find contrast values
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
        
                       % Store contrast values one-by-one
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

            % Special consideration for some subjects
            % Note: There are instances where a keypress event does not 
            % have a corresponding contrast update - those keypress times 
            % are removed from consideration to leave only 
            % those that have a corresponding contrast update
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
                
                   error('Time and contrast arrays are not equal!')
                
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
    
        % Confirm size of matched time and contrast arrays equals 18 trials
        if ~isequal(length(all_trial_image_matched_time), length(all_trial_image_matched_contrast),18)
        
            error('Image contrast and time arrays mismatch or incorrect # trials!')
        
        end
        
        % Find max contrast, duration, latency

        % Initialize variables
        all_trial_selected_max_contrast = [];
        all_trial_selected_max_duration = [];
        all_trial_selected_onset_latency = [];
    
        % Loop over trials
        for trial = 1:size(all_trial_image_contrast,1)
    
            % Flip data orientation
            if ~ismember(sub_ID, {'006','007','008','009','010'})
                
                % Trial contrast
                trial_contrast = all_trial_image_matched_contrast{trial,1}';
        
                % Trial time
                trial_time = all_trial_image_matched_time{trial,1}';

            else

                % Trial contrast
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
                nonzero_idx(nonzero_idx>=max(zero_idx)) = [];

            end

            % Select non-zero trial times
            time_value_nonzeros = trial_time(nonzero_idx);

            % Special trial consideration (Note: Bad trials are removed)
            if isequal(sub_ID, '058') && isequal(trial,1)

                time_value_nonzeros = [];

            end
    
            % Find trial max contrast and duration; Note: There must be at least 2 key
            % presses and the maximum contrast value greater than 0 for a
            % valid recording, otherwise, NaN
            if length(time_value_nonzeros)>1 && max(trial_contrast) ~= 0

                % Add max contrast to array
                all_trial_selected_max_contrast = [all_trial_selected_max_contrast; max(trial_contrast)];

                % If no zeros in contrast arrary 
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
                all_trial_selected_max_contrast = [all_trial_selected_max_contrast; NaN];
                all_trial_selected_max_duration = [all_trial_selected_max_duration; NaN];
                all_trial_selected_onset_latency = [all_trial_selected_onset_latency; NaN];

            end

        end

        % Check the number of trials
        if ~isequal(length(all_trial_selected_onset_latency), length(all_trial_selected_max_duration), length(all_trial_selected_max_contrast),18)
    
            error('Number of onset/duration/contrast trials if off!')

        end

        % Find subject mean trial time and contrast
        mean_image_stim_selected_max_contrast = nanmean(all_trial_selected_max_contrast);
        mean_image_stim_selected_max_duration = nanmean(all_trial_selected_max_duration);
        mean_image_stim_selected_onset_latency = nanmean(all_trial_selected_onset_latency);
    
        % Find difference between selected and image stats
        diff_image_selected_max_contrast = mean_image_stim_selected_max_contrast - image_contrast;
        diff_image_selected_max_duration = mean_image_stim_selected_max_duration - image_duration;
    
        % Store all subject variable
        all_sub_mean_image_stim_max_contrast = [all_sub_mean_image_stim_max_contrast; mean_image_stim_selected_max_contrast];
        all_sub_image_stim_duration = [all_sub_image_stim_duration; mean_image_stim_selected_max_duration];
        all_sub_image_stim_onset_latency = [all_sub_image_stim_onset_latency; mean_image_stim_selected_onset_latency];
        all_sub_selected_vs_image_stim_max_contrast = [all_sub_selected_vs_image_stim_max_contrast; diff_image_selected_max_contrast];
        all_sub_selected_vs_image_stim_duration = [all_sub_selected_vs_image_stim_duration; diff_image_selected_max_duration];
    
        % Update text file
        
        fprintf(stat_file,'%s\n\r\n','*** Image Contrast Matching ***');
        
        fprintf(stat_file,'%s\n\r\n','Mean Max Image Contrast');
        fprintf(stat_file,'%f\n\r',mean_image_stim_selected_max_contrast); 
    
        fprintf(stat_file,'%s\n\r\n','Mean Image Duration');
        fprintf(stat_file,'%f\n\r',mean_image_stim_selected_max_duration); 
    
        fprintf(stat_file,'%s\n\r\n','Mean Image Onset Latency');
        fprintf(stat_file,'%f\n\r',mean_image_stim_selected_onset_latency); 
    
        fprintf(stat_file,'%s\n\r\n','Selected vs Image Mean Max Contrast');
        fprintf(stat_file,'%f\n\r',diff_image_selected_max_contrast); 
    
        fprintf(stat_file,'%s\n\r\n','Selected vs Image Mean Max Duration');
        fprintf(stat_file,'%f\n\r',diff_image_selected_max_duration); 
    
        % *** Plot Image and Matched Timecourses ***
        figure
        hold on
        
        % Figure parameters
        title(['Subject ID ',sub_ID,' - Image Contrast Matching'])
        xlabel('Time (s)')
        ylabel('Contrast [0 1]')
        xlim([0 12])
        ylim([0 0.5])
        
        % Loop over trials - image
        for trial = 1:size(all_trial_image_contrast,1)
        
            plot(all_trial_image_time(trial,:),all_trial_image_contrast(trial,:), 'b')
        
        end
        
        % Loop over trials - matched
        for trial = 1:size(all_trial_image_matched_contrast,1)
        
            plot(all_trial_image_matched_time{trial,:},all_trial_image_matched_contrast{trial,:}, 'r')
        
        end
        
        % Save figure 
        cd(save_dir)
        savefig('Real_contrast_matching.fig')
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
        
            % Find all contrast arrays
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
            
            % Find normalized, smoothed contrast array
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
    
            error('Mock afterimage contrast and time array mismatch!')
    
        end
        
        % Extract number arrays - find begin/end brackets
        begin_bracket_contrast = strfind(afterimage_contrast_array,'[');
        end_bracket_contrast = strfind(afterimage_contrast_array,']');
        
        begin_bracket_time = strfind(afterimage_time_array,'[');
        end_bracket_time = strfind(afterimage_time_array,']');
        
        % Remove first and last bracket (Note: variable had double brackets [[]])
        begin_bracket_contrast(1) = [];
        end_bracket_contrast(end) = [];
        
        begin_bracket_time(1) = [];
        end_bracket_time(end) = [];
        
        % Check bracket lengths are equal across arrays
        if ~isequal(length(begin_bracket_contrast),length(end_bracket_contrast))
           
            error('Afterimage Contrast Matching: Length of contrast array is off!')
        
        elseif ~isequal(length(begin_bracket_time),length(end_bracket_time))
           
            error('Afterimage Contrast Matching: Length of time array is off!')
        
        elseif ~isequal(length(begin_bracket_time),length(begin_bracket_contrast))
        
            error('Afterimage Contrast Matching: Length of time and contrast array mistmatch!')

        elseif ~isequal(length(begin_bracket_time),length(begin_bracket_contrast),60)
            
            error('Number of contrast and time trials ~= 60!')

        end
        
        % Cut contrast and time arrays and store in cell
        
        % Initialize variables
        all_afterimage_contrast_array = {};
        all_afterimage_time_array = {};
        afterimage_max_contrast_array = [];
        afterimage_duration_array = [];
        afterimage_onset_array = [];
        
        % Loop over trials (indicated by bracket index)
        for trial = 1:length(begin_bracket_contrast)
            
            % Store contrast and time array info
            all_afterimage_contrast_array{trial,1} = afterimage_contrast_array(begin_bracket_contrast(trial):end_bracket_contrast(trial));
            all_afterimage_time_array{trial,1} = afterimage_time_array(begin_bracket_time(trial):end_bracket_time(trial));
    
            % Extract contrast and time info for trial
            trial_time = str2num(afterimage_time_array(begin_bracket_time(trial):end_bracket_time(trial)))';
            trial_contrast = str2num(afterimage_contrast_array(begin_bracket_contrast(trial):end_bracket_contrast(trial)))';

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

            % Special trial consideration 
            % Note: Bad trials are removed
            if isequal(sub_ID, '006') && ismember(trial,[12,16,31])

                time_value_nonzeros = [];

            elseif isequal(sub_ID, '006') && isequal(trial,13)

                time_value_nonzeros(16:17) = [];

            end

            % Find trial max contrast and duration
            % Note: There must be at least 2 key
            % presses and the maximum contrast value greater than 0 for a
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
    
        % Check the afterimage arrays are the same size
        if ~isequal(length(all_afterimage_contrast_array), length(all_afterimage_time_array),60)
    
            error('Afterimage trial contrast and time array mismatch!')

        elseif ~isequal(length(afterimage_duration_array), length(afterimage_max_contrast_array), length(afterimage_onset_array), 60)
    
            error('Afterimage duration and max contrast array mismatch!')

        end
    
        % Find the mean max contrast across trials
        afterimage_mean_max_contrast = nanmean(afterimage_max_contrast_array);
    
        % Find the mean duration across trials
        afterimage_mean_duration = nanmean(afterimage_duration_array);
    
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
    
        % Update text file
        
        fprintf(stat_file,'%s\n\r\n','*** Afterimage Contrast/Duration Matching ***');
        
        fprintf(stat_file,'%s\n\r\n','Mean Max Afterimage Contrast');
        fprintf(stat_file,'%f\n\r',afterimage_mean_max_contrast); 
    
        fprintf(stat_file,'%s\n\r\n','Mean Afterimage Duration');
        fprintf(stat_file,'%f\n\r',afterimage_mean_duration); 
    
        fprintf(stat_file,'%s\n\r\n','Mean Afterimage Onset');
        fprintf(stat_file,'%f\n\r',afterimage_mean_onset); 
        
        % *** Plot Afterimage Match Timecourses ***
        figure 
        hold on 
        
        % Figure parameters
        ylim([0 0.5])
        xlim([0 12])
        yticks([0:0.1:0.5])
        xticks([0:12])
        title(['Subject ', sub_ID, ' - Afterimage Contrast vs Time'])
        ylabel('Image Contrast [0 to 1]')
        xlabel('Time (s) - from offset of inducer')
        
        % Mean start and afterimage duration lines
        plot([afterimage_mean_onset_log, afterimage_mean_onset_log],[0, 0.5],'--r')
        plot([afterimage_mean_duration_log + afterimage_mean_onset_log, afterimage_mean_duration_log + afterimage_mean_onset_log],[0, 0.5],'--r')
        
        % Loop over instances
        for trial = 1:length(all_afterimage_contrast_array)
        
            % Plot timecourses of individual afterimages
            plot(str2num(all_afterimage_time_array{trial,1}), str2num(all_afterimage_contrast_array{trial,1}),'b')
        
        end
        
        % Save figure 
        cd(save_dir)
        savefig('Afterimage_contrast_vs_time.fig')
        close
    
        % Save afterimage information
        cd(save_dir)
        save('Afterimage_parameters.mat','afterimage_mean_onset_log','afterimage_mean_duration_log','all_afterimage_contrast_array',...
            'afterimage_onset_array','all_afterimage_time_array','afterimage_mean_max_contrast')
    
    end
    
    %% Afterimage Perception Rate
    
    if ~isempty(afterimage_matching_data) && ~isempty(afterimage_sharpness_data)

        % Check sample sizes 
        if length(selected_afterimage_sharpness_data) ~= 30 && length(afterimage_max_contrast_array) ~= 60
        
            error('Number of trials incorrect!')
        
        end 
        
        % Calculated the afterimage perceptiona across the cripsness/blur and contrast task phases
        afterimage_perception_rate = (sum(~isnan(selected_afterimage_sharpness_data)) + sum(~isnan(afterimage_max_contrast_array))) /...
            (length(selected_afterimage_sharpness_data) + length(afterimage_max_contrast_array));
        
        % Store the perception rate value
        all_sub_afterimage_perception_rate = [all_sub_afterimage_perception_rate; afterimage_perception_rate];

    end
     
    %% End Analysis 
    
    % Return to save folder
    cd(save_dir)
    close all

end

%% Save Group Data

% If specified to save group data
if save_group_data == 1

    cd(group_dir)
    save('Group_behavioral_data.mat', 'all_sub*')

end
