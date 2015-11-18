% Example callback function for analog input logging.
% This funcion is called once the number of acquired time points exceeds
%   src.NotifyWhenDataAvailableExceeds.
% The latest analog input data will be written to the log .csv file.
% Use plotLogFile() to view the logged data.
function logAIData(src, event, filename)    
    % Plot the latest data
    %plot(event.TimeStamps, event.Data);
    
    % Now actually write the results to the .csv log file.
    dlmwrite(filename,[ event.TimeStamps event.Data],'delimiter',',','-append');
    
    