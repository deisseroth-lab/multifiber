% Example callback function for analog input logging.
% This funcion is called once the number of acquired time points exceeds
%   src.NotifyWhenDataAvailableExceeds.
% The latest analog input data will be written to the log .csv file.
% Use plotLogFile() to view the logged data.
function logAIData(src, event)    
    % Plot the latest data
    %plot(event.TimeStamps, event.Data);
    
    % Determine log filename -- append results to latest existing log file
    % unless this is a new scan, in which case increment the counter.
    [m_path, m_name] = fileparts(mfilename('fullpath'));
    path = fullfile(m_path,'logs');
    count = 0;
    is_first_scan = src.ScansAcquired == src.NotifyWhenDataAvailableExceeds;    
    while exist(fullfile(path, ['log_' num2str(count) '.csv']), 'file') == 2
        count = count + 1;
    end
    if ~is_first_scan
        count = count -1;
    end
    filename = fullfile(path, ['log_' num2str(count) '.csv']);
    %disp(['Log file is ' filename]);
    
    % Now actually write the results to the .csv log file.
    dlmwrite(filename,[ event.TimeStamps event.Data],'delimiter',',','-append');
    
    