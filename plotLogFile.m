% Plot a given .csv log file.
% Returns the timestamps and data.
function [time, data_AI] = plotLogFile(filename, prompt_user)
if nargin ~= 1
    if nargin > 1 && prompt_user
        [name, path] = uigetfile([filename '/*.csv']);
    else
        [name, path] = uigetfile('*.csv');
    end
    if length(path) == 1
        return % if invalid path
    end
    filename = fullfile(path, name);
end
M = csvread(filename);

time = M(:,1);
data_AI = M(:,2:end);
n_channels = size(data_AI,2);
figure, plot(time, data_AI)
xlabel('time (s)');
ylabel('voltage (V)');
