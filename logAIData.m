function logAIData(src, event)    
    plot(event.TimeStamps, event.Data);
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
    dlmwrite(filename,[ event.TimeStamps event.Data],'delimiter',',','-append');
    
    