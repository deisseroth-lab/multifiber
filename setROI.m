function setROI( vid, pos )
%SETROI Set the ROI of the camera
%   Takes the video object and desired ROI rectangle. Unfortunately some 
% cameras return their resolution in the wrong orientation, so we rotate 
% from a common frame into camera space.

res = vid.VideoResolution;
if res(1) <= res(2)
    vid.ROIPosition = pos;
else
    vid.ROIPosition = [pos(2) pos(1) pos(4) pos(3)];
end

end

