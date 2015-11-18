% Plot a given .csv log file.
% Returns the timestamps and data.
function [time, data_AI] = plotLogFile(filename)
if nargin < 1
    [name, path] = uigetfile('*.csv');
    filename = fullfile(path, name);
end
M = csvread(filename);

time = M(:,1);
data_AI = M(:,2:end);
n_channels = size(data_AI,2);
figure, plot(time, data_AI)
xlabel('time (s)');
ylabel('voltage (V)');
