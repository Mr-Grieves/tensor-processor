% V2
% contains a natural sorting algorithm which will correctly sort files with
% mixed numbers+characters in their filenames
function csv_lines = convert_bin2dicom(inputFolder, outputFolder, enhance)

if (exist([inputFolder '/'], 'dir') == 0)
    warning(['input folder does not exist: ' inputFolder]);
    return;
end

files = dir(inputFolder);
if(length(files) < 3)
    warning(['input folder is empty: ' inputFolder]);
    return;
end

m = regexp(inputFolder,'trial_(\d+)','tokens');
trial_num_str = m{1}{1};

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

csv_lines = {};

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
        s = timestamp;
        t = trial_num_str;
        outputFileName = [s(12) s(11) s(10) s(8) s(7) s(5) s(4) s(2) s(1) t(2) t(1) '_' last_view '.mat'];
        outputFilePath = [outputFolder '/' outputFileName];
        if exist(outputFilePath,'file')
            %warning(['Video already exists (check that L5 =? BO): ' outputFileName]); 
        else
            disp(['    Writing ' num2str(size(T_all,3)) ' frames to: ' outputFilePath]);
            I_3D = reshape(T_all,[size(T_all,1),size(T_all,2),size(T_all,3)]); 
            if(enhance)
                I_3D = (I_3D - en_min)/(en_max-en_min);
                I_3D(I_3D < 0) = 0;
                I_3D(I_3D > 1) = 1;
            end
            
            % Write tensor to file
            
            % Clear buffer
            Patient = [];
            
            % Data
            Patient.DicomImage = I_3D;
            
            % Info
            Patient.DicomInfo.PatientID = '001';
            Patient.DicomInfo.StudyDate = '20180531';
            Patient.DicomInfo.SeriesData = '001';
            Patient.DicomInfo.AcquisitionDateTime = ['20180531_' filename(1:8)];
            Patient.DicomInfo.StudyInstanceUID = '001';
            Patient.DicomInfo.SOPInstanceUID = '000';
            Patient.DicomInfo.SOPClassUID = '000';
            Patient.DicomInfo.Manufacturer = 'General Electric';
            Patient.DicomInfo.ManufacturerModelName = 'iU33';
            Patient.DicomInfo.TransducerData = 'S3';
            load 'region.mat'
            Patient.DicomInfo.SequenceOfUltrasoundRegions = region;
            Patient.DicomInfo.Width = W;
            Patient.DicomInfo.Height = H;
            Patient.DicomInfo.BitDepth = 8;
            Patient.DicomInfo.FrameTime = 33.33; %~10 fps
            Patient.DicomInfo.HeartRate = -1;
            Patient.DicomInfo.NumberOfFrames = size(I_3D,3);

            % Filename
            Patient.OriginalFileName = [trial_num_str '_' timestamp '_' last_view '.avi'];

            % Save it
            save(outputFilePath,'Patient');
            
            % Add this line to the csv file
            csv_lines{end+1,1} = outputFilePath;
            csv_lines{end,2} = get_view_index(last_view);

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
s = timestamp;
t = trial_num_str;
outputFileName = [s(12) s(11) s(10) s(8) s(7) s(5) s(4) s(2) s(1) t(2) t(1) '_' last_view '.mat'];
outputFilePath = [outputFolder '/' outputFileName];
if exist(outputFilePath,'file')
    %warning(['Video already exists (check that L5 =? BO): ' outputFileName]); 
else
    disp(['    Writing ' num2str(size(T_all,3)) ' frames to: ' outputFilePath]);
    I_3D = reshape(T_all,[size(T_all,1),size(T_all,2),size(T_all,3)]); 
    if(enhance)
        I_3D = (I_3D - en_min)/(en_max-en_min);
        I_3D(I_3D < 0) = 0;
        I_3D(I_3D > 1) = 1;
    end

    % Write tensor to file      
    % Data
    Patient.DicomImage = I_3D;

    % Info
    Patient.DicomInfo.PatientID = '001';
    Patient.DicomInfo.StudyDate = '20180531';
    Patient.DicomInfo.SeriesData = '001';
    Patient.DicomInfo.AcquisitionDateTime = ['20180531_' filename(1:8)];
    Patient.DicomInfo.StudyInstanceUID = '001';
    Patient.DicomInfo.SOPInstanceUID = '000';
    Patient.DicomInfo.SOPClassUID = '000';
    Patient.DicomInfo.Manufacturer = 'General Electric';
    Patient.DicomInfo.ManufacturerModelName = 'iU33';
    Patient.DicomInfo.TransducerData = 'S3';
    load 'region.mat'
    Patient.DicomInfo.SequenceOfUltrasoundRegions = region;
    Patient.DicomInfo.Width = W;
    Patient.DicomInfo.Height = H;
    Patient.DicomInfo.BitDepth = 8;
    Patient.DicomInfo.FrameTime = 33.33; %~10 fps
    Patient.DicomInfo.HeartRate = -1;
    Patient.DicomInfo.NumberOfFrames = size(I_3D,3);

    % Filename
    Patient.OriginalFileName = [trial_num_str '_' timestamp '_' last_view '.avi'];

    % Save it
    save(outputFilePath,'Patient');
    
    % Add this line to the csv file
    csv_lines{end+1,1} = outputFilePath;
    csv_lines{end,2} = get_view_index(last_view);
end

