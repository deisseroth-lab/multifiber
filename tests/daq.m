% test out the nidaq by driving TTL pulses on a digital clock

fs = 2000;
framerate = 20;

devices = daq.getDevices();
dev = devices(1);

s = daq.createSession('ni');
s.Rate = fs;
s.IsContinuous = true;

camCh = s.addCounterOutputChannel(dev.ID, 1, 'PulseGeneration');
disp(camCh.Terminal);
camCh.Frequency = framerate;
camCh.InitialDelay = 0;
camCh.DutyCycle = 0.1;

refCh = s.addCounterOutputChannel(dev.ID, 2, 'PulseGeneration');
disp(refCh.Terminal);
refCh.Frequency = framerate / 2;
refCh.InitialDelay = 1 / framerate * 0.05;
refCh.DutyCycle = 0.45;

sigCh = s.addCounterOutputChannel(dev.ID, 3, 'PulseGeneration');
disp(sigCh.Terminal);
sigCh.Frequency = framerate / 2;
sigCh.InitialDelay = 1 / framerate * 1.05;
sigCh.DutyCycle = 0.45;

s.startBackground();
pause(15);
s.stop();