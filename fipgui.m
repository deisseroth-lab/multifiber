function varargout = fipgui(varargin)
% FIPGUI MATLAB code for fipgui.fig
%      FIPGUI, by itself, creates a new FIPGUI or raises the existing
%      singleton*.
%
%      H = FIPGUI returns the handle to a new FIPGUI or the handle to
%      the existing singleton*.
%
%      FIPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIPGUI.M with the given input arguments.
%
%      FIPGUI('Property','Value',...) creates a new fipgui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fipgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fipgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fipgui

% Last Modified by GUIDE v2.5 07-Dec-2015 14:59:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fipgui_OpeningFcn, ...
                   'gui_OutputFcn',  @fipgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before fipgui is made visible.
function fipgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fipgui (see VARARGIN)

% Parameters
handles.computer_dependent_delay = 0.00015; % seconds
handles.sample_rate_factor = 10; % how much faster DAQ samples than camera
handles.exposureGap = 0;
handles.plotLookback = 10;
handles.settingsGroup = 'FIPGUI';

% Defaults
handles.crop_roi = false;
handles.masks = false;
handles.savepath = '.';
handles.savefile = get(handles.save_txt, 'String');
handles.callback_path = false;
handles.callback = @(x,y) false;
handles.ao_waveform_path = false;
handles.ao_waveform_file = false;
handles.calibColors = 'k';
handles.calibImg.cdata = false;

% Populate dropdowns
imaqreset();
[adaptors, devices, formats, IDs] = getCameraHardware();
nDevs = length(adaptors);
if nDevs == 0
    error('MATLAB IMAQ detected no available Orca camera devices to connect to. Fix this and restart MATLAB.');
end
options = {};
for i = 1:nDevs
        options{i} = [adaptors{i} ' ' devices{i} ' ' formats{i}];
end
set(handles.cam_pop, 'String', options);

% Recover settings from last time
grp = handles.settingsGroup;
set(handles.camport_pop, 'Value', getpref(grp, 'camport_pop', 1));
set(handles.ref_pop, 'Value', getpref(grp, 'ref_pop', 2));
set(handles.sig_pop, 'Value', getpref(grp, 'sig_pop', 3));
try
    set(handles.ai_logging_check, 'Value', getpref(grp, 'ai_logging_check'));
catch e
    set(handles.ai_logging_check, 'Value',true);
end
rate_txt = getpref(grp, 'rate_txt', get(handles.rate_txt, 'String'));
if isnan(str2double(rate_txt))
    rate_txt = '10'; 
    warning(['Invalid rate text, setting to default value of ' rate_txt]);
end
set(handles.rate_txt, 'String', rate_txt);
set(handles.cam_pop, 'Value', getpref(grp, 'cam_pop', get(handles.cam_pop, 'Value')));
save_txt =  getpref(grp, 'save_txt', get(handles.save_txt, 'String'));
if numel(save_txt) > 1 && save_txt(1) == '0' 
    save_txt = ''; 
    warning(['Invalid save text, setting to default value of ' save_txt]);
end
set(handles.save_txt, 'String',save_txt);
ao_waveform_txt =  getpref(grp, 'ao_waveform_txt', get(handles.ao_waveform_txt, 'String'));
if numel(ao_waveform_txt) > 1 && ao_waveform_txt(1) == '0' 
    ao_waveform_txt = '<None>';     
    warning(['Invalid ao waveform text, setting to default value of ' ao_waveform_txt]);
end
set(handles.ao_waveform_txt, 'String',ao_waveform_txt);
set(handles.callback_txt, 'String', getpref(grp, 'callback_txt', get(handles.callback_txt, 'String')));

% Setup DAQ
rate = str2double(get(handles.rate_txt, 'String'));
fs = rate * handles.sample_rate_factor;
devices = daq.getDevices();
device = devices(1);
handles.dev = device;

s = daq.createSession('ni');
s.Rate = fs;
s.IsContinuous = true;
try
    camCh = s.addCounterOutputChannel(device.ID, getCurrentPopupString(handles.camport_pop), 'PulseGeneration');
    camCh.Frequency = rate;
    camCh.InitialDelay = 0;
    camCh.DutyCycle = 0.1;
    disp(['Camera should be connected to ' camCh.Terminal]);

    refCh = s.addCounterOutputChannel(device.ID, getCurrentPopupString(handles.ref_pop), 'PulseGeneration');
    refCh.Frequency = rate / 2;
    refCh.InitialDelay = 1 / rate * 0.05;
    refCh.DutyCycle = 0.45;
    disp(['Reference LED should be connected to ' refCh.Terminal]);

    sigCh = s.addCounterOutputChannel(device.ID, getCurrentPopupString(handles.sig_pop), 'PulseGeneration');
    sigCh.Frequency = rate / 2;
    sigCh.InitialDelay = 1 / rate * 1.05;
    sigCh.DutyCycle = 0.45;
    disp(['Signal LED should be connected to ' sigCh.Terminal]);
catch e
    disp(e);
    setpref('FIPGUI', 'camport_pop',1);
    setpref('FIPGUI', 'ref_pop',2);
    setpref('FIPGUI', 'sig_pop',3);
    error('Restart MATLAB');
end

% Enable analog input logging
ch = addAnalogInputChannel(s,handles.dev.ID,[0:7], 'Voltage');        
lh = addlistener(s, 'DataAvailable', @(src, event) 0); % add a dummy listener
disp(['(optional for logging) Analog inputs should be connected to ai0 - ai7']);

% Enable analog output
ao0=addAnalogOutputChannel(s,handles.dev.ID,'ao0', 'Voltage');
ao1=addAnalogOutputChannel(s,handles.dev.ID,'ao1', 'Voltage');
ao2=addAnalogOutputChannel(s,handles.dev.ID,'ao2', 'Voltage');
ao3=addAnalogOutputChannel(s,handles.dev.ID,'ao3', 'Voltage');
disp(['(optional) Analog outputs should be connected to ao0 - ao3']);
% This listener is enabled later if analog outputs are not used, and will
% continuously set the outputs to zero.
lh_ao=addlistener(s,'DataRequired', @load_zero_valued_ao_data);     

% Workaround for s.IsRunning bug. (see main acquisition for details)
% Load and send a short AO waveform.
load_zero_valued_ao_data(s,''); 
s.startBackground();
stop(s);

handles.lh_ao=lh_ao;
handles.camCh = camCh;
handles.refCh = refCh;
handles.sigCh = sigCh;
handles.s = s;

% Setup camera
camDeviceN = get(handles.cam_pop, 'Value');
vid = videoinput(adaptors{camDeviceN}, IDs(camDeviceN), formats{camDeviceN});
src = getselectedsource(vid);
vid.FramesPerTrigger = 1; 
vid.TriggerRepeat = Inf;
vid.ROIPosition = [0 0 vid.VideoResolution];

handles.vid = vid;
handles.src = src;

% Some more updates based on the defaults loaded earlier
% Update rate
rate_txt_Callback(handles.rate_txt, [], handles);
% Update save file information
[pathname, filename, ext] = fileparts(get(handles.save_txt, 'String'));
handles.savepath = pathname;
handles.savefile = [filename ext];

% Update callback file information
[pathname, filename] = fileparts(get(handles.callback_txt, 'String'));
addpath(pathname);
handles.callback_path = pathname;
[~, basename, ext] = fileparts(filename);
if strcmp(basename, '<None>')
    handles.callback = @(x,y) false;
else
    handles.callback = str2func(basename);
end
% Update analog output waveform
[pathname, filename, ext] = fileparts(get(handles.ao_waveform_txt, 'String'));
[~, basename, ext] = fileparts(filename);
if strcmp(basename,'<None>')
    handles.ao_waveform_path = false;
    handles.ao_waveform_file = false;
else
    handles.ao_waveform_path = pathname;
    handles.ao_waveform_file = [filename ext];
end

% Disable acquisition until calibration is run
set(handles.acquire_tgl, 'Enable', 'off');

% Choose default command line output for fipgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
update_camera_exposure_time(handles);

% UIWAIT makes fipgui wait for user response (see UIRESUME)
% uiwait(handles.fipgui);


% --- Outputs from this function are returned to the command line.
function varargout = fipgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in snap_btn.
function snap_btn_Callback(hObject, eventdata, handles)
% hObject    handle to snap_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
snapframe = getsnapshot(handles.vid);

% Display the frame
figure();
imagesc(snapframe);
colorbar();

% --- Executes on button press in calibframe_btn.
function calibframe_btn_Callback(hObject, eventdata, handles)
% hObject    handle to calibframe_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Run the camera and LED commands briefly to get illuminated frames
nFrames = 4;
i = 0;
res = get(handles.vid, 'VideoResolution');
frames = zeros(res(1), res(2), nFrames);
set(handles.vid, 'ROIPosition', [0 0 res]);

load_analog_output_data(handles, true);
triggerconfig(handles.vid, 'hardware', 'RisingEdge', 'EdgeTrigger');
start(handles.vid);
startBackground(handles.s);

while i < nFrames
    i = i + 1;
    frames(:,:,i) = getdata(handles.vid, 1, 'uint16');
end

stop(handles.vid);
stop(handles.s);

calibframe = max(frames, [], 3);

% Fiber ROI GUI
calibOut = calibrationgui(calibframe);
masks = calibOut.masks;
handles.calibColors = calibOut.colors;
handles.calibImg = calibOut.figImg;
handles.labels = calibOut.labels;

% Use masks to determine how much we can crop
all_masks = any(masks, 3);
[rows, cols] = ind2sub(size(all_masks), find(all_masks));
crop_roi = [min(cols), min(rows), max(cols) - min(cols) + 1, max(rows) - min(rows) + 1];
masks = masks(min(rows):max(rows), min(cols):max(cols), :);
handles.crop_roi = crop_roi;
handles.masks = logical(masks);
handles.vid.ROIPosition = crop_roi;
% This also sets the exposureGap. This assumes bidirectional center-out
% rolling shutter
r_min = min(rows);
r_max = max(rows);
res = handles.vid.VideoResolution;
r_center = res(1)/2; % center row for orca
row_range = min(r_max-r_min, ceil(max(abs(r_center - r_min), abs(r_center -r_max))));
disp(row_range);
full_frame_readout_time = 0.010; % camera and mode dependent, assumes Orca FAST mode
handles.exposureGap = handles.computer_dependent_delay + full_frame_readout_time/(res(1)/2)*row_range;
guidata(hObject, handles);
update_camera_exposure_time(handles)

set(handles.acquire_tgl, 'Enable', 'on');
set(handles.calibframe_lbl, 'Visible', 'off');

% Update handles structure
guidata(hObject, handles);

% Get file paths for saving out put (auto-increment the file counter).
function [saveFile, calibFile, logAIFile] = get_save_paths(handles)
[~, basename, ext] = fileparts(handles.savefile);
n = 0;
while exist(fullfile(handles.savepath, [basename sprintf('_%03d', n) ext]), 'file') == 2
    n = n + 1;
end
saveFile = fullfile(handles.savepath, [basename sprintf('_%03d', n) ext]);
calibFile = fullfile(handles.savepath, [basename sprintf('_%03d_calibration', n) '.jpg']);
logAIFile = fullfile(handles.savepath, [basename sprintf('_%03d_logAI', n) '.csv']);
if exist(logAIFile,'file')==2
    delete(logAIFile);
end

% Validate settings
function valid = settings_are_valid(handles)
valid = true;
ports = [get(handles.camport_pop, 'Value'), get(handles.ref_pop, 'Value'), get(handles.sig_pop, 'Value')];
if length(unique(ports)) < length(ports)
    valid = false;
    errordlg('Two or more devices (e.g. reference LED and camera) are set to the same DAQ port. Please correct this to proceed.', 'Config error');
end

% Analog output data must be loaded before a session is started
function load_analog_output_data(handles, disable_ao_out)    
    if disable_ao_out
        analog_output_waveform_enabled = false;
    else
        analog_output_waveform_enabled = handles.ao_waveform_path; 
    end
    if analog_output_waveform_enabled
        disp('Loading user defined AO output');        
        user_waveform = load_user_ao_waveform(handles);        
        disp(['AO waveform duration: ' num2str(size(user_waveform,1)/handles.s.Rate) ' seconds']);
        handles.lh_ao.Enabled = false;        
        queueOutputData(handles.s,user_waveform);        
    else
        handles.lh_ao.Enabled = true;
        disp('Setting all analog output values to 0 V');
        load_zero_valued_ao_data(handles.s,'');        
    end
 
% Verify user waveform is valid
function verify_user_ao_waveform(handles)
    disp('Verifying AO waveform.');
    load_user_ao_waveform(handles);
    
% Load a user specified AO waveform
% A valid analog output waveform .mat file must contain two variables:
%   rate - int. samples per second, must match handles.s.Rate
%   waveform - (N x 4) vector of voltage values
function user_waveform = load_user_ao_waveform(handles)
    t = load(fullfile(handles.ao_waveform_path, handles.ao_waveform_file));    
    user_waveform = 0;
    if t.rate ~= handles.s.Rate
        error(['Waveform rate ' num2str(t.rate) ' does not match daq rate ' num2str(handles.s.Rate)]);
    else
        if size(t.waveform,2) == 4
            user_waveform = t.waveform;
        else
            error(['Waveform has ' num2str(size(t.waveform,2)) ' channels instead of 4.']);
        end        
    end    
    if max(abs(user_waveform(:))) > 10
        error('AO output waveform must be between +/- 10 V');
    end
    
% Call back function to load zero valued AO data 
function load_zero_valued_ao_data(src, event)
    % minimum output is 0.5s of samples, for 4 channels
    src.queueOutputData(zeros(5000,4));

% --- Executes on button press in acquire_tgl.
function acquire_tgl_Callback(hObject, eventdata, handles)
% hObject    handle to acquire_tgl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acquire_tgl
state = get(hObject,'Value');
if state
    % Pre-check for valid analog output waveform
    if handles.ao_waveform_path
        verify_user_ao_waveform(handles);
    end    
    verify_callback_function(handles);    
    
    % Disable all settings
    confControls = [
        handles.camport_pop
        handles.ref_pop
        handles.sig_pop
        handles.rate_txt
        handles.cam_pop
        handles.snap_btn
        handles.calibframe_btn
        handles.save_txt
        handles.callback_txt
        handles.ai_logging_check
        handles.ao_waveform_btn
        handles.ao_waveform_clear_btn
        handles.ao_waveform_txt
        handles.callback_clear_btn
        handles.callback_btn
        handles.save_btn];
    for control = confControls
        set(control, 'Enable', 'off');
    end
    
    % Re-label button
    set(hObject, 'String', 'Stop acquisition');
    
    if settings_are_valid(handles)
        % Get save paths
        [saveFile, calibFile, logAIFile] = get_save_paths(handles);
        
        if(ai_logging_is_enabled(handles))
            % Add listener for analog input logging        
            lh = addlistener(handles.s, 'DataAvailable', @(src, event) logAIData(src, event, logAIFile));
            handles.s.NotifyWhenDataAvailableExceeds = round(handles.s.Rate*1);
            disp('Added analog input channels and listener');
        end
        
        % Snap a quick dark frame
        darkframe = getsnapshot(handles.vid);

        if ~any(handles.masks(:))
            handles.masks = ones(handles.vid.VideoResolution);
            darkOffset = mean(darkframe(:));
        else
            darkOffset = applyMasks(handles.masks, darkframe);
        end
        
        nMasks = size(handles.masks, 3);
        ref = zeros(1, nMasks); sig = zeros(1, nMasks);
        i = 0;
        j = 0;
        rate = str2double(get(handles.rate_txt, 'String'));
        lookback = handles.plotLookback;
        framesback = lookback * rate / 2;
        vid = handles.vid;
        s = handles.s;

        % Set up plotting
        plot_fig = figure('CloseRequestFcn', @uncloseable);
        ha = tightSubplot(nMasks, 1, 0.1, 0.05, 0.10, plot_fig);
        yyaxes = zeros(nMasks, 2);
        lyy = zeros(nMasks, 2);
        t = -lookback:(2/rate):0;
        ymax = 4;
        ybuf = 1.1;
        for k = 1:nMasks
            [yyax, l1, l2] = plotyy(ha(k), 0, 0, 0, 0);
            xlim(yyax(1), [-lookback 0]);
            xlim(yyax(2), [-lookback 0]);
            ylim(yyax(1), [0 ymax]);
            ylim(yyax(2), [0 ymax]);
            linkprop(yyax,{'Xlim'});
            set(l1, 'Color', handles.calibColors(k,:));
            set(l2, 'Color', handles.calibColors(k,:));
            set(l1, 'LineWidth', 2);
            set(l2, 'LineStyle', '--');
            if verLessThan('matlab', '8.4')
                set(l1, 'LineSmoothing', 'on');
                set(l2, 'LineSmoothing', 'on');
            end
            set(yyax, {'ycolor'},{'k';'k'});
            ylabel(yyax(1), 'Signal');
            ylabel(yyax(2), 'Reference');
            setappdata(gca, 'LegendColorbarManualSpace' ,1);
            setappdata(gca, 'LegendColorbarReclaimSpace', 1);
            yyaxes(k,:) = yyax;
            lyy(k,:) = [l1 l2];
        end

        triggerconfig(vid, 'hardware', 'RisingEdge', 'EdgeTrigger');
        load_analog_output_data(handles, false);
        start(vid);
        
        s.startBackground();
        
        handles.startTime = now();

        % Stop if value is set to false, or if the user-specified AO
        % finishes running
        if handles.ao_waveform_path
            disp('Waiting for user to end acquisition or AO waveform to finish...');
        else
            disp('Waiting for user to end acquisition...');
        end
        while get(hObject,'Value') 
            
            if ~ s.IsRunning                
                disp('AO waveform output finished.');
                set(hObject,'Value', false); % Exit loop if AO output just finished                
                break            
            end 
                        
            try
                img = getdata(vid, 1, 'uint16');
            catch e
                % Most likely cause for getting here is the s.IsRunning bug: 
                %   without the workaround implemented above in init, the very
                %   first acquisition, if AO is enabled, will fail to stop 
                %   (s.IsRunning is True indefinitely despite the waveform
                %   having stopped). As a side effect, the synchronization
                %   of the AO waveform and digital counter channels appears
                %   to be consistently different.
                if j > 0
                    disp('ERROR: AO and counters may not be synced. See s.IsRunning bug comments');
                    warning('See s.IsRunning bug comments'); beep;
                end
                set(hObject,'Value', false); % Exit loop if AO output just finished
                break
            end
            
            i = i + 1;      % frame number
            j = ceil(i/2);  % sig/ref pair number                        
            
            avgs = applyMasks(handles.masks, img);
            avgs = avgs - darkOffset;

            % Exponentially expanding matrix as per std::vector
            if j > size(ref, 1) || j > size(sig, 1)
                szr = size(ref); szs = size(sig);
                ref = [ref; zeros(szr)]; sig = [sig; zeros(szs)];
            end

            if mod(i, 2) == 1   % reference channel
                ref(j,:) = avgs;
                handles.callback(avgs, 'reference');
            else                % signal channel
                sig(j,:) = avgs;
                handles.callback(avgs, 'signal');
            end
            % Plotting
            jboth = 2 * floor(j / 2);
            if jboth > 0 && mod(i, 2) == 0
                tlen = jboth - max(1, j-framesback);
                tnow = t(end-tlen:end);
                for k = 1:nMasks
                    sigmin = min(sig(max(1, j-framesback):jboth,k));
                    sigmax = max(sig(max(1, j-framesback):jboth,k));
                    
                    refmin = min(ref(max(1, j-framesback):jboth,k));
                    refmax = max(ref(max(1, j-framesback):jboth,k));
                    
                    if sigmax > sigmin
                        ylim(yyaxes(k,1), [sigmin sigmax]);
                    end
                    if refmax > refmin
                        ylim(yyaxes(k,2), [refmin refmax]);
                    end

                    set(lyy(k,1), 'XData', tnow, 'YData', sig(max(1, j-framesback):jboth,k));
                    set(lyy(k,2), 'XData', tnow, 'YData', ref(max(1, j-framesback):jboth,k));
                end
            end
                       
            % Check to make sure camera acquisition is keeping up.
            elapsed_time = (now() - handles.startTime());
            rate = str2double(get(handles.rate_txt,'String'));            
            if abs(elapsed_time*24*3600 - (i)/rate) > 1 % if camera acquisition falls behind more than 1 s...
                fraction_frames_acquired = i/(elapsed_time*24*3600*rate);                
                if j > 0
                    disp(['fraction of frames acquired: ' num2str(fraction_frames_acquired)]);
                    if abs(fraction_frames_acquired - 0.5) < 0.04
                        warning('ERROR: Only got half as many frames as expected. Most likely check trigger connections; less likely: select a smaller ROI or lower speed and try again. Last resort: increase handles.computer_dependent_delay');
                    else
                        warning('ERROR: Camera acquisition fell behind! Select a smaller ROI or lower speed and try again. Last resort: increase handles.computer_dependent_delay'); beep;
                    end
                end
                set(hObject,'Value', false);
                break
            end
            set(handles.elapsed_txt, 'String', datestr(elapsed_time, 'HH:MM:SS'));
        end
        disp('...acquisition complete.');
         
        % Stop acquisition
        stop(vid);
        s.stop();
        if(ai_logging_is_enabled(handles))
            delete(lh); % delete analog input listener
        end
        set(handles.elapsed_txt, 'String', datestr(0, 'HH:MM:SS'));

        % Save data
        if j > 0
            save_data(sig(1:j,:), ref(1:j,:), handles.labels, handles.calibImg.cdata, saveFile, calibFile);
        else            
            warning(['No frames captured or saved! Check camera trigger connection is ' handles.camCh.Terminal '. Then restart MATLAB.']); beep;
        end
        
    end % end settings are valid check
    
    % Make the old plots closeable
    set(plot_fig, 'CloseRequestFcn', @closeable);
    
    % Re-enable all controls
    for control = confControls
        set(control, 'Enable', 'on');
    end
    
    % Re-label button
    set(hObject, 'String', 'Acquire data');
end

function  save_data(sig, ref, labels, cdata, saveFile, calibFile)
save(saveFile, 'sig', 'ref', 'labels', '-v7.3');
if any(cdata(:))
    imwrite(cdata, calibFile, 'JPEG');
end

% --- Executes during object creation, after setting all properties.
function camport_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camport_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ref_pop.
function ref_pop_Callback(hObject, eventdata, handles)
% hObject    handle to ref_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ref_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ref_pop
f = handles.refCh.Frequency;
i = handles.refCh.InitialDelay;
d = handles.refCh.DutyCycle;
handles.s.removeChannel(chIdx(handles.s, handles.refCh));

handles.refCh = handles.s.addCounterOutputChannel(handles.dev.ID, getCurrentPopupString(hObject), 'PulseGeneration');
handles.refCh.Frequency = f;
handles.refCh.InitialDelay = i;
handles.refCh.DutyCycle = d;
disp(['Signal LED should be connected to ' handles.refCh.Terminal]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ref_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sig_pop.
function sig_pop_Callback(hObject, eventdata, handles)
% hObject    handle to sig_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sig_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sig_pop
f = handles.sigCh.Frequency;
i = handles.sigCh.InitialDelay;
d = handles.sigCh.DutyCycle;
handles.s.removeChannel(chIdx(handles.s, handles.sigCh));

handles.sigCh = handles.s.addCounterOutputChannel(handles.dev.ID, getCurrentPopupString(hObject), 'PulseGeneration');
handles.sigCh.Frequency = f;
handles.sigCh.InitialDelay = i;
handles.sigCh.DutyCycle = d;
disp(['Signal LED should be connected to ' handles.sigCh.Terminal]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sig_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sig_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rate_txt_Callback(hObject, eventdata, handles)
% hObject    handle to rate_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rate_txt as text
%        str2double(get(hObject,'String')) returns contents of rate_txt as a double
rate = str2double(get(handles.rate_txt,'String'));
fs = rate * handles.sample_rate_factor;
set(handles.s, 'Rate', fs);
set(handles.camCh, 'Frequency', rate);
set(handles.refCh, 'Frequency', rate / 2);
set(handles.refCh, 'InitialDelay', 1 / rate * 0.05);
set(handles.sigCh, 'Frequency', rate / 2);
set(handles.sigCh, 'InitialDelay', 1 / rate * 1.05);

% Update handles structure
guidata(hObject, handles);
update_camera_exposure_time(handles);


% --- Executes during object creation, after setting all properties.
function rate_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rate_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in camport_pop.
function camport_pop_Callback(hObject, eventdata, handles)
% hObject    handle to camport_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns camport_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from camport_pop
f = handles.camCh.Frequency;
i = handles.camCh.InitialDelay;
d = handles.camCh.DutyCycle;
handles.s.removeChannel(chIdx(handles.s, handles.camCh));

handles.camCh = handles.s.addCounterOutputChannel(handles.dev.ID, getCurrentPopupString(hObject), 'PulseGeneration');
handles.camCh.Frequency = f;
handles.camCh.InitialDelay = i;
handles.camCh.DutyCycle = d;
disp(['Camera should be connected to ' handles.camCh.Terminal]);

% Update handles structure
guidata(hObject, handles);

function update_camera_exposure_time(handles)
   rate = str2double(get(handles.rate_txt, 'String'));
   handles.src.ExposureTime = 1 / rate - handles.exposureGap;
function cam_pop_Callback(hObject, eventdata, handles)
% hObject    handle to cam_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam_pop as text
%        str2double(get(hObject,'String')) returns contents of cam_pop as a double
% Setup camera
rate = str2double(get(handles.rate_txt, 'String'));
[adaptors, devices, formats, IDs] = getCameraHardware();
camDeviceN = get(hObject, 'Value');
vid = videoinput(adaptors{camDeviceN}, IDs(camDeviceN), formats{camDeviceN});
src = getselectedsource(vid);
vid.FramesPerTrigger = 1; 
vid.TriggerRepeat = Inf;

handles.vid = vid;
handles.src = src;

% Choose default command line output for fipgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
update_camera_exposure_time(handles);

% Disable acquisition until calibration is run
set(handles.acquire_tgl, 'Enable', 'off');
set(handles.calibframe_lbl, 'Visible', 'on');


% --- Executes during object creation, after setting all properties.
function cam_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function save_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function callback_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to callback_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile('experiment.mat', 'Save experiment .mat file');
handles.savepath = pathname;
handles.savefile = filename;
set(handles.save_txt, 'String', fullfile([pathname filename]));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in callback_btn.
function callback_btn_Callback(hObject, eventdata, handles)
% hObject    handle to callback_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('', 'Select a .m function file');
if handles.callback_path
    rmpath(handles.callback_path);
end
addpath(pathname);
handles.callback_path = pathname;
[~, basename, ext] = fileparts(filename);
handles.callback = str2func(basename);
set(handles.callback_txt, 'String', fullfile([pathname filename]));

% Update handles structure
guidata(hObject, handles);
verify_callback_function(handles);

function save_txt_Callback(hObject, eventdata, handles)
% hObject    handle to save_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_txt as text
%        str2double(get(hObject,'String')) returns contents of save_txt as a double
[path, file, ext] = fileparts(get(hObject,'String'));
handles.savepath = path;
handles.savefile = [file ext];

% Update handles structure
guidata(hObject, handles);

function callback_txt_Callback(hObject, eventdata, handles)
% hObject    handle to callback_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of callback_txt as text
%        str2double(get(hObject,'String')) returns contents of callback_txt as a double
[path, file, ext] = fileparts(get(hObject, 'String'));
if handles.callback_path
    rmpath(handles.callback_path);
end
addpath(path);
handles.callback_path = path;
handles.callback = str2func(file);

% Update handles structure
guidata(hObject, handles);

function verify_callback_function(handles)
    if handles.callback_path
        handles.callback(0,'test');
    end
% --- Executes on button press in callback_clear_btn.
function callback_clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to callback_clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.callback_path = false;
handles.callback = @(x,y) false;
set(handles.callback_txt, 'String', '<None>');

% Update handles structure
guidata(hObject, handles);


% --- Executes when user attempts to close fipgui.
function fipgui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fipgui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save settings for next time
grp = handles.settingsGroup;
setpref(grp, 'camport_pop', get(handles.camport_pop, 'Value'));
setpref(grp, 'ref_pop', get(handles.ref_pop, 'Value'));
setpref(grp, 'sig_pop', get(handles.sig_pop, 'Value'));
setpref(grp, 'rate_txt', get(handles.rate_txt, 'String'));
setpref(grp, 'cam_pop', get(handles.cam_pop, 'Value'));
setpref(grp, 'save_txt', get(handles.save_txt, 'String'));
setpref(grp, 'callback_txt', get(handles.callback_txt, 'String'));
setpref(grp, 'ao_waveform_txt', get(handles.ao_waveform_txt, 'String'));
setpref(grp, 'ai_logging_check', get(handles.ai_logging_check, 'Value'));

% Hint: delete(hObject) closes the figure
delete(hObject);

function uncloseable(src, callbackdata)
% A dummy function that makes it impossible to close if used as the
% CloseRequestFcn
return

function closeable(src, callbackdata)
% Does the right thing (closes the figure) if used as the CloseRequestFcn
delete(src);


% --- Executes during object creation, after setting all properties.
function ao_waveform_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ao_waveform_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ao_waveform_txt_Callback(hObject, eventdata, handles)
% hObject    handle to ao_waveform_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ao_waveform_txt as text
%        str2double(get(hObject,'String')) returns contents of ao_waveform_txt as a double
[path, file, ext] = fileparts(get(hObject,'String'));
handles.ao_waveform_path = path;
handles.ao_waveform_file = [file ext];

% Update handles structure
guidata(hObject, handles);
verify_user_ao_waveform(handles);


% --- Executes on button press in ao_waveform_btn.
function ao_waveform_btn_Callback(hObject, eventdata, handles)
% hObject    handle to ao_waveform_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('ao_waveform.mat', 'Save AO waveform .mat file');
handles.ao_waveform_path = pathname;
handles.ao_waveform_file = filename;
set(handles.ao_waveform_txt, 'String', fullfile([pathname filename]));
% Update handles structure
guidata(hObject, handles);
verify_user_ao_waveform(handles);


% --- Executes on button press in ao_waveform_clear_btn.
function ao_waveform_clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to ao_waveform_clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ao_waveform_path = false;
handles.ao_waveform_file = false;
set(handles.ao_waveform_txt, 'String', '<None>');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in viewlog_btn.
function viewlog_btn_Callback(hObject, eventdata, handles)
% hObject    handle to viewlog_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotLogFile(handles.savepath, true);


% --- Executes on button press in ai_logging_check.
function ai_logging_check_Callback(hObject, eventdata, handles)
% hObject    handle to ai_logging_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai_logging_check
function is_enabled = ai_logging_is_enabled(handles)
    is_enabled = get(handles.ai_logging_check,'Value');
