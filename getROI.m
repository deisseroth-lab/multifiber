function [ roi ] = getROI( vid )
%GETROI Get the ROI of the camera
%   Takes the video object. Unfortunately some cameras return their 
% resolution in the wrong orientation, so we rotate to a common frame 
% from camera space.

res = vid.VideoResolution;
if res(1) <= res(2)
    roi = vid.ROIPosition;
else
    pos = vid.ROIPosition;
    roi = [pos(2) pos(1) pos(4) pos(3)];
end

end

