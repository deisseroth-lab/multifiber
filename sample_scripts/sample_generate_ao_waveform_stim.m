% This produces an analog output waveform .mat for generating a single
%   stimulation pulse train with a particular duty cycle.p on all channels.
% An analog output waveform .mat file must contain two variables:
%   rate - int. samples per second, must match handles.s.Rate
%   waveform - (N x 4) vector of voltage values
function sample_generate_ao_waveform_stim()
    % Stimulation parameters
    num_channels = 4; % number of AO channels in fipgui.m
    rate = 10*10; % samples per second in fipgui.m
    duration = 4.0; % in seconds    
    stim_rate = 5; % Hz
    stim_duty_cycle = 0.5; % fraction, between 0 and 1.0
    stim_start = 1.0 - 0.025; % time in seconds; adjust the precise start 
                              % time to align this pulse train with the 
                              % digital counter output pulse trains by 
                              % using analog input recording to measure
                              % the synchrony.
    stim_duration = 1.0; % seconds
    high_voltage = 5; % Volts
    
    % Compute the waveform
    if stim_start + stim_duration > duration
        error('stim period exceeds total duration');
    end  
    stim_cycles = round(stim_duration * stim_rate);          
    stim_cycle_start_times = stim_start + linspace(0,stim_cycles-1, stim_cycles)/stim_rate;
    stim_cycle_end_times = stim_cycle_start_times + stim_duty_cycle/stim_rate;
    waveform_single = zeros(duration*rate,1);
    for i=1:stim_cycles
       waveform_single(round(rate*stim_cycle_start_times(i)):round(rate*stim_cycle_end_times(i))) = high_voltage;
    end
    
    % Replicate waveform for all analog output channels
    waveform = repmat( waveform_single,[1 num_channels]);
    %%figure(1), plot(waveform_single);
    
    % Save waveform
    [file, path] = uiputfile('*.mat');
    save(fullfile(path, file), 'rate','waveform');