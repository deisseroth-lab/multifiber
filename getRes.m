function [ res ] = getRes( vid )
%GETRES Get the resolution of a camera
%   Takes the video object. Unfortunately some cameras return their
% resolution in the wrong orientation, so we rotate into a common frame.

res = vid.VideoResolution;
if res(1) > res(2)
    res = res(end:-1:1);
end

end

