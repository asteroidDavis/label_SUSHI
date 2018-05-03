function [processedFrame] = preProcessImagingFrame(frame)
%preProcessImagingFrame convert frame to double precision grayscale image
%so MODWT can be run on the image

% create greyscale double precision copy of input
processedFrame = double(frame(:,:,1));

end

