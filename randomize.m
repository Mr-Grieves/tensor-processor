clear all;
input_folder = 'for_scoring/31-05-2018';
output_folder = [input_folder '/randomized'];
trial_folders = dir(input_folder);
ordered_files = {};
randomized_files = {};

% add all the filenames to ordered_files
for i = 3:length(trial_folders)
    if(isempty(strfind(trial_folders(i).name,'trial_')))
       warning([trial_folders(i).name ' is not a trial folder']);
       continue;
    end
    avis = dir([input_folder '/' trial_folders(i).name]);
    for j = 3:length(avis)
        ordered_files{end+1,1} = [input_folder '/' trial_folders(i).name '/' avis(j).name];

        % reverse timestamps of the filename
        s = avis(j).name;
        t = trial_folders(i).name;
        revd = [s(12) s(11) s(10) s(8) s(7) s(5) s(4) s(2) s(1) t(8) t(7) s(13:end)];
        ordered_files{end,2} = [output_folder '/' revd];
    end
end

% sort by new names 
randomized_files = sortrows(ordered_files,2);

% copy files in their new order to destroy timestamps
if (exist([output_folder '/'], 'dir') == 0)
    mkdir([output_folder '/']);
end
for i = 1:length(randomized_files)
    src = randomized_files{i,1};
    dest = randomized_files{i,2};
    disp(['Copying ' src ' to ' dest '...']);
    copyfile(src, dest);
end

% get the randomized expert scores


% fill in the excel sheet with the scores


