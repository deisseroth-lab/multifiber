% test out the camera functionality
% cause the camera to acquire frames, process these frames trivially,
% and set the camera accept an exposure trigger

videoInputName = 'hamamatsu';

vid = videoinput(videoInputName, 1);
src = getselectedsource(vid);

vid.FramesPerTrigger = 1; 
vid.TriggerRepeat = Inf;
triggerconfig(vid, 'hardware', 'RisingEdge', 'EdgeTrigger');
vid.ROIPosition = [10 10 400 400];
src.ExposureTime = 1/25;

% Set up the daq to drive the camera in a simple way
devices = daq.getDevices;
s = daq.createSession('ni');
ch = s.addCounterOutputChannel(devices(1).ID, 'ctr1', 'PulseGeneration');
ch.Frequency = 20;
ch.InitialDelay = 0;
ch.DutyCycle = 0.1;
%ch = s.addDigitalChannel('Dev4', 'Port0/Line5', 'OutputOnly');
%s.outputSingleScan([0]);

cap = 0;
start(vid);
s.startBackground();
while cap < 10
    raw = getdata(vid, 1, 'uint16');
    image = double(raw);
    disp(max(max(image)));
    cap = cap + 1;
end

s.stop();
stop(vid);
delete(s);
delete(vid);