% Test analog input logging, using callback function @logAIData
cd 'C:\Users\user\multifiber\';
devices = daq.getDevices();
device = devices(1);
rate = 10;
fs = rate * 100;

s = daq.createSession('ni');
s.Rate = fs;
s.IsContinuous = true;

camCh = s.addCounterOutputChannel(device.ID, 'ctr1', 'PulseGeneration');
camCh.Frequency = rate;
camCh.InitialDelay = 0;
camCh.DutyCycle = 0.1;
disp(['Camera should be connected to ' camCh.Terminal]);

s.Rate = fs;
s.IsContinuous = true;
% Analog output
t=addAnalogOutputChannel(s,device.ID,'ao0', 'Voltage');


%% Analog input
% removeChannel(s,2)
ch = addAnalogInputChannel(s,device.ID,[0:7 ], 'Voltage');
figure(1)
%lh = addlistener(s, 'DataAvailable', @(src, event) plot(event.TimeStamps, event.Data));
lh = addlistener(s, 'DataAvailable', @logAIData);
s.NotifyWhenDataAvailableExceeds = fs;
disp('added analog input channel and listener');
%% Start session running in background
% queue analog output data
duration_in_seconds = 2; 
queueOutputData(s,linspace(-1, 1, duration_in_seconds*fs)');
disp('analog output queued'); 

startBackground(s);

figure(1);
disp('running in background...');
while(true)
    if(s.IsRunning)
        disp('is running');
    else
        stop(s);
        stop(s);
        disp('stopped');
        break
    end
    pause(0.1);
end
%% Stop session
stop(s);
stop(s);
%close(1);
disp('stopped');
xlabel('time (s)');
ylabel('voltage (V)');
legend('AI1','AI2');
plotLogFile();

