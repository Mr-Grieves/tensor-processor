% V2
% contains a natural sorting algorithm which will correctly sort files with
% mixed numbers+characters in their filenames
function timestamps = convert_bin2mp4(inputFolder, outputFolder, enhance)

timestamps = [];
if (exist([inputFolder '/'], 'dir') == 0)
    warning(['input folder does not exist: ' inputFolder]);
    return;
end

files = dir(inputFolder);
if(length(files) < 3)
    warning(['input folder is empty: ' inputFolder]);
    return;
end

en_min = 20;
en_max = 200;
N = 10;

T_all = [];
last_time = get_time(files(3).name);
last_view = get_view(files(3).name,1);
timestamp = files(3).name(1:12);

m = regexp(files(3).name,'(\d+)x(\d+)','tokens');
W = str2num(m{1}{1});
H = str2num(m{1}{2});

if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

for i = 3:length(files)
    filename = files(i).name;
    filepath = [inputFolder '/' filename];
    [~,~,ext] = fileparts(filepath);
    if (~strcmp(ext,'.bin'))
        error('Non .bin file detected in input folder, exiting')
    end
    
    fid = fopen(filepath);
    T = fread(fid,W*H*N,'uint8');
    fclose(fid);
    
    if(get_time(filename) - last_time < 1.5 && strcmp(get_view(filename,1),last_view))
        % same cine: add to T_all and continue
        %disp(['        Reading from: ' filename ' --- Same cine...']); 
        T_all = cat(3,T_all,permute(reshape(T,[W H N]),[2 1 3]));
        last_time = get_time(filename);
        last_view = get_view(filename,1);
        continue;
    else        
        T_all = T_all();
        outputFileName = [outputFolder '/' timestamp '_' last_view '.avi'];
        timestamps = [timestamps;timestamp];
        if exist(outputFileName,'file')
            %warning(['Video already exists (check that L5 =? BO): ' outputFileName]); 
        else
            disp(['    Writing ' num2str(size(T_all,3)) ' frames to: ' outputFileName]);
            I_4D = reshape(T_all,[size(T_all,1),size(T_all,2),1,size(T_all,3)]); 
            if(enhance)
                I_4D = (I_4D - en_min)/(en_max-en_min);
                I_4D(I_4D < 0) = 0;
                I_4D(I_4D > 1) = 1;
            end
            % Write tensor to file
            v = VideoWriter(outputFileName,'Grayscale AVI');
            %v.Quality = 100;
            open(v);
            writeVideo(v,I_4D);
            close(v);
        end

        % new cine
        %disp(['Reading from: ' filename ' --- Next cine...']);
        timestamp = filename(1:12);
        T_all = permute(reshape(T,[W H N]),[2 1 3]);
        last_time = get_time(filename);
        last_view = get_view(filename,1);
    end
end

T_all = T_all();
outputFileName = [outputFolder '/' timestamp '_' last_view '.avi'];
timestamps = [timestamps;timestamp];
if exist(outputFileName,'file')
    %warning(['Video already exists (check that L5 =? BO): ' outputFileName]); 
else
    disp(['    Writing ' num2str(size(T_all,3)) ' frames to: ' outputFileName]);
    I_4D = reshape(T_all,[size(T_all,1),size(T_all,2),1,size(T_all,3)]); 
    if(enhance)
        I_4D = (I_4D - en_min)/(en_max-en_min);
        I_4D(I_4D < 0) = 0;
        I_4D(I_4D > 1) = 1;
    end
    % Write tensor to file
    v = VideoWriter(outputFileName,'Grayscale AVI');
    %v.Quality = 100;
    open(v);
    writeVideo(v,I_4D);
    close(v)
end

