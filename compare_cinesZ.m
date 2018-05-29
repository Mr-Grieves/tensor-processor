% Display the results from a saved tensor
%function display_tensor(filepath)

folder = 'saved_QUS_trials/27-04-2018/trial_4/recorded_tensors/';
folderN = [folder 'net_input/'];
folderC = [folder 'raw_pixels/'];
filesN = dir(folderN);
filesC = dir(folderC);
frame_rate = 30;
Wn = 120;
Hn = 120;
Wc = 350;
Hc = 350;
N = 10;
last_time = get_time(filesN(3).name)
colormap('gray')

for i = 3:size(filesN,1)
    
    filenameN = filesN(i).name;
    filepathN = [folderN filenameN];
    
    filenameC = filesC(i).name;
    filepathC = [folderC filenameC];

    if(get_time(filenameN) - last_time > 1)
        disp('Start of next cine... press any key to continue');
        pause;
        %return;
    end
    
    % same cine: add to T_all and continue
    disp(['Reading from: ' filenameN ' --- Same cine...']);

    fid = fopen(filepathN);
    T = fread(fid,Wn*Hn*N,'uint8');
    Tn = reshape(T,[Wn Hn N]);
    fclose(fid);
    
    fid = fopen(filepathC);
    T = fread(fid,Wc*Hc*N,'uint8');
    Tc = reshape(T,[Wc Hc N]);
    fclose(fid);
    
    %[min(min(min(Tn))) max(max(max(Tn))); min(min(min(Tc))) max(max(max(Tc)))]
    
    for j = 1:N
        subplot(211)
        imagesc(Tn(:,:,j)');
        title('net input');

        subplot(212)
        imagesc(Tc(:,:,j)');
        title('raw pixels');
        pause(1/frame_rate)
    end
        
    last_time = get_time(filenameN);
end

