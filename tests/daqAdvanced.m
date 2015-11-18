% test out the nidaq by simultaneously outputting on a digital counter,
%   an analog output, and recording from analog inputs

cd 'C:\Users\user\multifiber';
devices = daq.getDevices();
device = devices(1);
rate = 10;
fs = rate * 10;

s = daq.createSession('ni');
s.Rate = fs;
s.IsContinuous = true;

camCh = s.addCounterOutputChannel(device.ID, 'ctr1', 'PulseGeneration');
camCh.Frequency = rate;
camCh.InitialDelay = 0;
camCh.DutyCycle = 0.1;
disp(['Camera should be connected to ' camCh.Terminal]);

%%
%ch = addDigitalChannel(s,device.ID, 'Port0/Line2:3', 'OutputOnly');

%% Analog output
t=addAnalogOutputChannel(s,device.ID,'ao0', 'Voltage');
%%   remove % weird bug -- must add data to queue first.
queueOutputData(s,linspace(-1, 1, 1*fs)');
removeChannel(s, 3);
s.IsContinuous = true;
%% queue analog output data
queueOutputData(s,linspace(-1, 1, 1*fs)');
disp('analog output queued');
%% Analog input
ch = addAnalogInputChannel(s,device.ID,[0 1 ], 'Voltage');
% need to store DAQ measurements from callback function
lh = addlistener(s, 'DataAvailable', @(src, event) plot(event.TimeStamps, event.Data));
s.NotifyWhenDataAvailableExceeds = fs;
disp('added analog input channel and listener');
%% Start session running in background
startBackground(s);
figure(1);
disp('running in background...');

for i = 1:10
    if(s.IsRunning)
        disp('is running');
    else
        disp('stopped');
    end
    pause(0.2);
end
%% Stop session
stop(s);
close(1);
disp('stopped');

