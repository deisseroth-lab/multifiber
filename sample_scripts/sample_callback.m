% Sample callback function for real-time processing of signal data.
%   data - double. new single data point
%   channel - string. channel corresponding to the data point. a value of
%     "test" is used to ensure the callback works.
function sample_callback(data, channel)
figure(5);
if strcmp(channel,'signal')
    subplot(2,1,1), plot(cputime,data), hold on, xlabel('time (s)'), ylabel('signal');
elseif strcmp(channel,'reference')
    subplot(2,1,2), plot(cputime,data), hold on, xlabel('time (s)'), ylabel('reference');
elseif strcmp(channel,'test')
    disp('Pre-acquisition callback test check succeeded');
else
    disp('unrecognized channel for callback');
end
