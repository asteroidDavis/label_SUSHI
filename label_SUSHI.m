addpath('Brain Wavelet Toolbox\BWT_v2.0_fMRI_Linux_Windows\BWT_v2.0_fMRI_Linux_Windows\BrainWavelet\BWT');
addpath('Brain Wavelet Toolbox\BWT_v2.0_fMRI_Linux_Windows\BWT_v2.0_fMRI_Linux_Windows\BrainWavelet\third_party\cprintf');
addpath('Brain Wavelet Toolbox\BWT_v2.0_fMRI_Linux_Windows\BWT_v2.0_fMRI_Linux_Windows\BrainWavelet\third_party\wmtsa\dwt');
addpath('Brain Wavelet Toolbox\BWT_v2.0_fMRI_Linux_Windows\BWT_v2.0_fMRI_Linux_Windows\BrainWavelet\third_party\wmtsa\utils\');
addpath('timing');

% run python script collecting videso of 
% 10s of nanometer resolution videos
filename = 'mmc1.mp4';%...
% open file containing the downloaded videos
video_id = VideoReader(filename);   
% setup timing object representing the video
timing = Timing(floor(video_id.Duration/(1/video_id.get('FrameRate'))),...
    video_id.get('FrameRate'));

IMAGING_DEPTH = 50; %um
MAX_SCALE = 1;     % max scale passed as parameter to wavelet transform
i_BLOCK_PERIOD = ceil(timing.SPS/10); % period to take window over for wavelet transform blocks
CLEAN_DEST = [filename '_clean'];
NLE_DEST = [filename '_nle'];


% open file for denoised writeback
writer = VideoWriter(CLEAN_DEST, 'Grayscale AVI');
% open file for nonlinear motion writeback
nle_writer = VideoWriter(NLE_DEST, 'Grayscale AVI');
% set videos frame rate
writer.FrameRate = ceil(timing.SPS);
nle_writer.FrameRate = ceil(timing.SPS);
open(writer);
open(nle_writer);

% open file for sp writeback
sp_fid = fopen([filename '.sp'], 'w');

% select feature locations one frame at a time
start_time = tic;

% memory for video blocks being processed 
voxels = zeros(video_id.Height, video_id.Width, i_BLOCK_PERIOD);
i = 1;

% read frames
while video_id.hasFrame
    voxels(:, :, i) =  preProcessImagingFrame(video_id.readFrame());
    i = i + 1;

    % until there's window_period seconds stored
    if  i <= ceil(timing.SPS)
        
        % perform wavelet denoising on the window_period block
        [clean, noise , sp, edof, mmc] = wdscore(voxels(:, :, :), 'nscale', MAX_SCALE);

        % convert denoised videos to grayscale
        clean = uint8(clean(:,:,1));
        noise = uint8(noise(:,:,1));
        % remove any zeroed rows or columns added in wdscore
        clean(all(~clean,2),:)= [];
        clean(:, all(~clean,1))= [];
        noise(all(~noise,2),:)= [];
        noise(:, all(~noise,1))= [];
        % writeback videos
        writeVideo(writer, clean);
        writeVideo(nle_writer, noise);

        % write sp for a set of variance based emissions
        fwrite(sp_fid, sp, 'uint8');
        
        % reset i 
        i = 1;
        
    end
end

% close video writer
close(writer);
close(nle_writer);

% close sp_writer
fclose(sp_fid);

% take end time
elapsed_time = toc(start_time);

% print T(2*MODWT) 
disp(['Elapsed time in MODWT: ' num2str(elapsed_time) ' seconds']);
% free memory
clear clean CLEAN_DEST DEST edof elapsed_time filename frame i i_BLOCK_PERIOD IMAGING_DEPTH MAX_SCALE mmc new_name NLE_DEST nle_writer
clear noise sp sp_fid start_time timing video_id voxels writer
disp(['Finished wavelet denoising and writeback' SysText.newLine()]);




