% Test the delay between an analog output and a digital counter session.

% Set to true to use two separate sessions instead of one
use_separate_sessions = true;

cd 'C:\Users\user\multifiber\tests';
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

if use_separate_sessions
    s2 = daq.createSession('ni');
else
    s2 = s;
end
s2.Rate = fs;
s2.IsContinuous = true;
% Analog output
t=addAnalogOutputChannel(s2,device.ID,'ao0', 'Voltage');


%% Analog input
% removeChannel(s,2)
ch = addAnalogInputChannel(s,device.ID,[0 1 ], 'Voltage');
figure(1)
lh = addlistener(s, 'DataAvailable', @(src, event) plot(event.TimeStamps, event.Data));
s.NotifyWhenDataAvailableExceeds = fs;
disp('added analog input channel and listener');
%% Start sessions running in background

% queue analog output data
queueOutputData(s2,linspace(-1, 1, 1*fs)');
disp('analog output queued');

startBackground(s); % there is a slight delay between these two starts
if use_separate_sessions
    startBackground(s2);
end

figure(1);
disp('running in background...');

for i = 1:10
    if(s2.IsRunning)
        disp('is running');
    else
        stop(s);
        stop(s2);
        disp('stopped');
    end
    pause(0.1);
end
%% Stop session
stop(s);
stop(s2);
%close(1);
disp('stopped');
xlabel('time (s)');
ylabel('voltage (V)');
legend('AI1','AI2');

