%% ------------------------------- Main -----------------------------------
% This script should provide a 1-click way to process an entire days' worth
% of trial data and produce all the required outputs.
% 
% Inputs: the datestamped folder containing all the trial folders
%
% Outputs: 
%       - 'for_scoring/cine_videos': 
%               folder containing all the recorded cines as mp4 videos
%
%       - 'for_scoring/trial_data_sheet.xls': 
%               .xls sheet containing as little info as possible.  
%               Basically just the video filename, and a column for the 
%               GoldStandard (to be filled out by expert)
%
%       - 'master_data_sheet.xls': .xls sheet all recorded data to date.
%                                  This scipt will append to it, populating
%                                  every column except for the GoldStandard

% Trial #1 Notes:
% - trials 04 and 06 started with trying PLAX instead of AP4
% - the "scroll down for more options" should be a button that scrolls down for you
% - trial_11 and trial_12 are both from sean so need to amalgomate
% - timer appear after 1 min?
% - subc5's are classified as c4

% Trial #2 Notes:
% - Started with ID=12 -> trial_11 (+9)
% - Ended with   ID=22 -> trial_21 (+9)
% - NASA Slider!
% - Look at the effect of 1st vs. 2nd attempt at a view
% - Something funky happened with trial 14's PLAX_OFF/PSAX_OFF
% - And again on Trial 20 :( no bo AP4 or PSAXPM?
%     - lost subc4
%     - Assert failed becuase the bestOf PLAX_OFF == lastN PLAX_OFF
% - Dont proceed until youve recorded 100 Frames!

%% Here we go
clc;
clear all;
datestamp = '21-06-2018';
append = 0;
enhance = 1;

input_folder = ['saved_QUS_trials/' datestamp];
if (exist([input_folder '/'], 'dir') == 0)
    error(['input folder does not exist: ' input_folder]);
    return
end
output_folder = ['for_scoring/' datestamp];
if (exist([output_folder '/'], 'dir') == 0)
    mkdir([output_folder '/']);
end
random_folder = ['for_scoring/' datestamp '/randomized_mats'];
if (exist([random_folder '/'], 'dir') == 0)
    mkdir([random_folder '/']);
end
trial_nums = dir(input_folder);

demo_lines = { 'Date' 'Trial #' 'Participant ID' 'Position-Year' ...
               'Regular Practice' 'Experience' 'Confidence' 'MD' 'PD' ...
               'TP' 'P' 'E' 'F' 'MT' 'PD' 'TD' 'P' 'E' 'F' };
           
all_cells = {'Date' 'Trial #' 'Participant ID' 'Timestamp' 'Requested View' 'Expert Score' ...
             'AI Score' 'Time Taken' 'Feedback' 'BestOf' 'Position Error' 'Orientation Error'};

evai_input_cells = {};%'file_address','correct_indx'};


for t = 0:length(trial_nums)-3
    % Loop through all trial folders saved here
    trial_num = trial_nums(t+3).name;
    trial_folder = [input_folder '/' trial_num];
    if ~exist([trial_folder '/recorded_tensors'], 'dir')
        disp(['No recorded data in folder: ' trial_folder ': Skipping it.']);
        continue;
    else
        disp(' ');disp(['Processing folder: ' trial_folder]);
    end

    %% Read stuff from setup_info.txt
    fid = fopen([trial_folder '/setup_info.txt']);
    nextLine = fgetl(fid); % get first line
    while 1
        if ~ischar(nextLine), break, end
        if strfind(nextLine,'Participant ID: ')
            id = nextLine(17:end);
        elseif strfind(nextLine,'Position/Year: ')
            pgy = nextLine(16:end);
        elseif strfind(nextLine,'Regular Practice: ')
            reg_prac = nextLine(19:end);
        elseif strfind(nextLine,'Experience Level: ')
            exp = str2num(nextLine(19:end));
        elseif strfind(nextLine,'Confidence Level: ')
            conf = str2num(nextLine(19:end));
        end
        nextLine = fgetl(fid);
    end
    fclose(fid);

    %% Read stuff from NASA_survey.txt
    nasa = -1*ones(6,2);
    nasa_filenames = {'NASA_survey_ultrasound.txt','NASA_survey_guidance.txt'};
    for i = 1:2
        fid = fopen([trial_folder '/' nasa_filenames{i}]);
        if(fid == -1)
            warning(['No NASA file found at: ' trial_folder '/' nasa_filenames{i}]);
            continue;
        end
        nextLine = fgetl(fid); % get first line
        while 1
            if ~ischar(nextLine), break, end
            if strfind(nextLine,'Mental Demand: ')
                nasa(1,i) = str2num(nextLine(16:end));
            elseif strfind(nextLine,'Physical Demand: ')
                nasa(2,i) = str2num(nextLine(18:end));
            elseif strfind(nextLine,'Temporal Demand: ')
                nasa(3,i) = str2num(nextLine(18:end));
            elseif strfind(nextLine,'Performance: ')
                nasa(4,i) = str2num(nextLine(13:end));
            elseif strfind(nextLine,'Effort: ')
                nasa(5,i) = str2num(nextLine(9:end));
            elseif strfind(nextLine,'Frustration: ')
                nasa(6,i) = str2num(nextLine(14:end));
            end
            nextLine = fgetl(fid);
        end
        fclose(fid);
    end
        
    %% Write demographics
    demo_lines(end+1,:) = {datestamp, trial_num, id, pgy, reg_prac, exp, conf, ...
         nasa(1,1), nasa(2,1), nasa(3,1), nasa(4,1), nasa(5,1), nasa(6,1),...
         nasa(1,2), nasa(2,2), nasa(3,2), nasa(4,2), nasa(5,2), nasa(6,2)};

    %% Write the .mp4's 
    timestamps_last = convert_bin2mp4([trial_folder '/recorded_tensors/raw_pixels'],[output_folder '/' trial_num],enhance);
    timestamps_best = convert_bin2mp4([trial_folder '/recorded_tensors/raw_pixels_bo'],[output_folder '/' trial_num],enhance);
    cells_last = convert_bin2dicom([trial_folder '/recorded_tensors/raw_pixels'],random_folder,enhance);
    cells_best = convert_bin2dicom([trial_folder '/recorded_tensors/raw_pixels_bo'],random_folder,enhance);
    
    %% Add cells to evai csv
    for j = 1:length(cells_last)
       evai_input_cells{end+1,1} = cells_last{j,1};
       evai_input_cells{end,2}   = cells_last{j,2};
    end
    for j = 1:length(cells_best)
       evai_input_cells{end+1,1} = cells_best{j,1};
       evai_input_cells{end,2}   = cells_best{j,2};
    end
    
    %% Add this trial to the datasheet's cells
    % First read and store all relevant data from results.txt
    results = []; % the goal is to build this array such that each line 
                  % will match the .avi's created by convert_bin2mp4
    if (exist([trial_folder '/results.txt'], 'file') == 0)
        warning(['results.txt does not exist: ' trial_folder '/results.txt']);
    else
        fid = fopen([trial_folder '/results.txt']);
        nextLine = fgetl(fid); % get first line
        while 1
            if ~ischar(nextLine), break, end  
            m = regexp(nextLine,'Quality: (\d+.\d+)%\s+Time: (\d+)ms\s+BestOf: (\d+.\d+)%\s+Time-BO: (\d+)ms','tokens');
            view = get_view(nextLine,0); % dont actually need this but good sanity check
            feedback = isempty(strfind(nextLine,'OFF'));    
            score_last = str2num(m{1}{1});
            time_last = str2num(m{1}{2});
            score_best = str2num(m{1}{3});
            time_best = str2num(m{1}{4});
            if strfind(nextLine,'PositionError'), pos_err = 'PositionError'; else pos_err = ''; end
            if strfind(nextLine,'OrientationError'), ori_err = 'OrientationError'; else ori_err = ''; end

            % This should only be true if the lastN scores had 10 tensors!
            %assert(score_best >= score_last); % if this fails, something is wrong in the java code

            % Add bestof score 
            if score_best ~= 0
                results{end+1,1} = view;
                results{end,2} = score_best;
                results{end,3} = time_best;
                results{end,4} = feedback;
                if time_last == time_best
                    results{end,5} = 'BOTH';
                    nextLine = fgetl(fid);
                    continue; % Use this line as both lastN and bestOf
                else
                    results{end,5} = 'TRUE';
                end
                results{end,6} = pos_err;
                results{end,7} = ori_err;
            end

            % Add last5 score
            results{end+1,1} = view;
            results{end,2} = score_last;
            results{end,3} = time_last;
            results{end,4} = feedback;
            results{end,5} = 'FALSE';
            results{end,6} = pos_err;
            results{end,7} = ori_err;

            nextLine = fgetl(fid);
        end
        fclose(fid);
    
        % Second populate and add a new row for each .avi
        files = dir([output_folder '/' trial_num]);
        assert(length(files)-2 == size(results,1));
        for i = 3:length(files)
            filename = files(i).name;
            [~,~,ext] = fileparts(filename);

            % sanity checks        
            if (~strcmp(ext,'.avi'))
                warning(['Non .avi file detected in trial folder: ' filename])
            end
            assert(strcmp(get_view(filename,0),results{i-2,1})); 
            if strcmp(results{i-2,5},'TRUE') || strcmp(results{i-2,5},'BOTH')
                assert(is_member_of(filename(1:12),timestamps_best) == 1);
            end
            if strcmp(results{i-2,5},'FALSE') || strcmp(results{i-2,5},'BOTH')
                assert(is_member_of(filename(1:12),timestamps_last) == 1);
            end

            all_cells{end+1,1} = datestamp;
            all_cells{end,2} = trial_num;
            all_cells{end,3} = id;
            all_cells{end,4} = filename(1:12);
            all_cells{end,5} = get_view(filename,0);
            all_cells{end,7} = results{i-2,2};
            all_cells{end,8} = results{i-2,3};
            all_cells{end,9} = results{i-2,4};
            all_cells{end,10} = results{i-2,5};
            all_cells{end,11} = results{i-2,6};
            all_cells{end,12} = results{i-2,7};
        end
    end
end

%% Create trial_data_sheet.xls and write cells to it
datasheet_filename = [output_folder '/data_sheet.xls'];
disp(' ');disp(['Writing template xls to: ' datasheet_filename]);
xlswrite(datasheet_filename, all_cells(:,2:6)); % only copy 5 columns

% format the columns all nice
ExcelApp=actxserver('excel.application');
ExcelApp.Visible=0;
NewWorkbook=ExcelApp.Workbooks.Open([pwd '\' datasheet_filename]);   
NewSheet=NewWorkbook.Sheets.Item(1);
NewRange=NewSheet.Range('A1'); NewRange.ColumnWidth=10;
NewRange=NewSheet.Range('B1'); NewRange.ColumnWidth=15;
NewRange=NewSheet.Range('C1'); NewRange.ColumnWidth=15;
NewRange=NewSheet.Range('D1'); NewRange.ColumnWidth=15;
NewRange=NewSheet.Range('E1'); NewRange.ColumnWidth=12;
%ExcelApp.Cells.Select;
%ExcelApp.Cells.EntireColumn.AutoFit;
NewWorkbook.Save
NewWorkbook.Close

%% Append to master_data_sheet.xls
if append
    % Append results
    mastersheet_filename = ['master_sheetALL.xls'];
    disp(['Appending results to master: ' mastersheet_filename]);
    [~,~, data] = xlsread(mastersheet_filename, 1);
    data = [data; all_cells(2:end,:)]; % remove 1st row
    xlswrite(mastersheet_filename, data);
    
    % Append demographics
    disp(['Appending demographics to master: ' mastersheet_filename]);
    [~,~, data] = xlsread(mastersheet_filename, 2);
    data = [data; demo_lines(2:end,:)]; % remove 1st row
    xlswrite(mastersheet_filename, data, 2);
else
    % Create a new master 
    mastersheet_filename = [output_folder '/master_sheet.xls'];
    disp(['Writing results to master: ' mastersheet_filename]);
    xlswrite(mastersheet_filename, all_cells, 1);
    disp(['Writing demographics to master: ' mastersheet_filename]);
    xlswrite(mastersheet_filename, demo_lines, 2);
    
    NewWorkbook=ExcelApp.Workbooks.Open([pwd '\' mastersheet_filename]);   
    NewSheet=NewWorkbook.Sheets.Item(1);
    NewRange=NewSheet.Range('A1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('B1'); NewRange.ColumnWidth=10;
    NewRange=NewSheet.Range('C1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('D1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('E1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('F1'); NewRange.ColumnWidth=13;
    NewRange=NewSheet.Range('G1'); NewRange.ColumnWidth=10;
    NewRange=NewSheet.Range('H1'); NewRange.ColumnWidth=10;
    NewRange=NewSheet.Range('J1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('K1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('L1'); NewRange.ColumnWidth=15;
    
    NewSheet=NewWorkbook.Sheets.Item(2);
    NewRange=NewSheet.Range('A1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('B1'); NewRange.ColumnWidth=10;
    NewRange=NewSheet.Range('C1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('D1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('E1'); NewRange.ColumnWidth=15;
    NewRange=NewSheet.Range('F1'); NewRange.ColumnWidth=10;
    NewRange=NewSheet.Range('G1'); NewRange.ColumnWidth=10;
    NewRange=NewSheet.Range('H1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('I1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('J1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('K1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('L1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('M1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('N1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('O1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('P1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('Q1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('R1'); NewRange.ColumnWidth=4;
    NewRange=NewSheet.Range('S1'); NewRange.ColumnWidth=4;
    %ExcelApp.Cells.Select;
    %ExcelApp.Cells.EntireColumn.AutoFit;
    NewWorkbook.Save
    NewWorkbook.Close
end
ExcelApp.Quit

%% Create the evai csv
evai_input_cells = sortrows(evai_input_cells,1);
evai_input_cells = [ {'file_address' 'correct_indx'}; evai_input_cells];
datasheet_filename = [output_folder '/evai_input.csv'];
disp(['Writing EVAI csv to: ' datasheet_filename]);
fid = fopen(datasheet_filename, 'w');
fprintf(fid, '%s,', evai_input_cells{1,1:end-1}) ;
fprintf(fid, '%s\n', evai_input_cells{1,end}) ;
for i = 2:length(evai_input_cells)
    fprintf(fid, '%s,', evai_input_cells{i,1}) ;
    fprintf(fid, '%d\n', evai_input_cells{i,2}) ;
end
fclose(fid);

disp(['Success! Finished processing data from: ' input_folder]);