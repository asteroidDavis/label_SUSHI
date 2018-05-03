function label_frames(image_name)
    TRANS = [   0.5 0.125 0.25 0.125;
                0.125 0.5 0.25 0.125;
                0.25 0.25 0.25 0.25;
                0.125 0.125 0.25 0.5];
    % intensity based emission probabilities
    EMISS_I = [ 0.001 0.875 0.125 0.125]';
    % variance based emisssion probabilities
    EMISS_V = [ 0.001 0.5 0.875 0.875]';
    EMISS = horzcat(EMISS_I, EMISS_V);
    
    vid_reader = VideoReader(image_name);
    
    % emission from first 2 frames
    emiss_i = zeros(vid_reader.Height, vid_reader.Width);
    emiss_v = zeros(vid_reader.Height, vid_reader.Width);
    
    first_frame = vid_reader.readFrame();
    
    
    % find intensity based emissions from the video
    emiss_i = (first_frame >= 2350);
    % find variance based emissions from the video
    for i = 2:vid_reader.Height-1
        for j = 2:vid_reader.Width-1
            roi = zeros(9,1);
            k = 1;
            for x_offset = [-1 0 1]
                for y_offset = [-1 0 1]
                    roi(k) = first_frame(i+y_offset, j + x_offset);
                    k = k + 1;
                end
            end
            emiss_v(i,j) = var(roi) >= 30;
        end
    end
    emiss = emiss_i | emiss_v; 
    
    ecf_label = uint8(zeros(size(first_frame)));
    neuron_label = uint8(zeros(size(first_frame)));
    glial_label = uint8(zeros(size(first_frame)));
    other_label = uint8(zeros(size(first_frame)));
    
    % decode and label the frame of the image
    for i = 1:vid_reader.Height
        for j = 1:vid_reader.Width
            probs = hmmdecode(uint8(emiss(i,j)), TRANS, EMISS, 'Symbols', [0 1]);
            P_ecf =  probs(1);
            P_soma = probs(2);
            P_glial = probs(3);
            P_other = probs(4);
            ecf_label(i,j) = P_ecf*255;
            neuron_label(i,j) = P_soma*255;
            glial_label(i,j) = P_glial*255;
            other_label(i,j) = P_other*255;
        end
    end
    
    % show results
    figure;
    imshow(ecf_label(:,:));
    figure;
    imshow(neuron_label(:,:));
    figure;    
    imshow(glial_label(:,:));
    figure;
    imshow(other_label(:,:));

end