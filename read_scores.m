% Here we need to:
% 1. read in EVAI output file
% 2. unrandomize the rows
% 3. read in data_sheet.xls
% 4. fill in the expert score + view 

input_folder = 'for_scoring/31-05-2018/';

%% Read in EVAI csv
[~,~,data] = xlsread([input_folder 'evai_output.xlsx'],1);
data{1,end+1} = 'Trial num';
data{1,end+1} = 'Timestamp';

%% Unrandomize rows
% get rev'd timestamp
for i = 2:size(data,1)
    revd_addr = data{i,1};
    m = regexp(revd_addr,'(\d{9})(\d{2})','tokens');
    trial_str = ['trial_' m{1}{2}(2) m{1}{2}(1)];
    timestamp = [m{1}{1}(9) m{1}{1}(8) '-' m{1}{1}(7) ...
                 m{1}{1}(6) '-' m{1}{1}(5) m{1}{1}(4) ...
                 '.' m{1}{1}(3) m{1}{1}(2) m{1}{1}(1)];
	data{i,end-1} = trial_str;
    data{i,end} = timestamp;
end

% Sort data by timestamp
data(1,:) = [];
data_sorted = sortrows(data,[5 6]);

%% Read in data_sheet.xls
[~,~,data] = xlsread([input_folder 'data_sheet.xls'],1);

% Fill in quality
data(2:end,5) = data_sorted(:,4);

% Fill in corrected view
view_strs = {'AP2';'AP3';'AP4';'AP5';'PLAX';...
             'RVIF';'SUBC4';'SUBC5';'SUBIVC';'PSAXAo';...
             'PSAXM';'PSAXPM';'PSAXAp';'SUPRA';'Other';'Garbage'};

data{1,end+1} = 'Corrected View';
data(2:end,end) = view_strs(cell2mat(data_sorted(:,3))+1);

%% Write to new data_sheet
output_addr = [input_folder 'data_sheet_scored.xlsx'];
xlswrite(output_addr, data);
