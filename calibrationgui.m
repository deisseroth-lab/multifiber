function varargout = calibrationgui(varargin)
% CALIBRATIONGUI MATLAB code for calibrationgui.fig
%      CALIBRATIONGUI, by itself, creates a new CALIBRATIONGUI or raises the existing
%      singleton*.
%
%      H = CALIBRATIONGUI returns the handle to a new CALIBRATIONGUI or the handle to
%      the existing singleton*.
%
%      CALIBRATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATIONGUI.M with the given input arguments.
%
%      CALIBRATIONGUI('Property','Value',...) creates a new CALIBRATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibrationgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibrationgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibrationgui

% Last Modified by GUIDE v2.5 09-Nov-2016 17:19:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibrationgui_OpeningFcn, ...
                   'gui_OutputFcn',  @calibrationgui_OutputFcn, ...
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


% --- Executes just before calibrationgui is made visible.
function calibrationgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calibrationgui (see VARARGIN)

% Choose default command line output for calibrationgui
handles.output.hObject = hObject;

% Parameters
radius_range = [20 50];
handles.defaultRadius = 75;
handles.maxFibers = 7;

% Initialization
handles.ellipses = {};
handles.cmap = hsv(handles.maxFibers);
handles.cmap = handles.cmap(randperm(handles.maxFibers),:);

% Process the input image
handles.image = varargin{1};
max_value = max(handles.image(:));
if max_value >= 65535
    warning('WARNING: Calibration image has saturated pixels');
end
disp(['Calibration image uses ' num2str(max_value*100/65535) '% of camera dynamic range.']);
if max_value*100/65535 < 10
    warning('Consider increasing the light power or reducing the acquisition rate for better signal to noise.');
end
imagesc(handles.image, 'Parent', handles.img_ax);
handles.frameSize = size(handles.image);

% Find initial circles
[centers, radii, metric] = imfindcircles(handles.image, radius_range);
if centers
    % Initialize ellipses
    for i = 1:length(radii)
        r = radii(i) * 0.9;
        handles = placeEllipse([centers(i,1:2) - r, 2*r, 2*r], i, handles);
    end
else
    % No ellipses found. Place one in the middle.
    r = handles.defaultRadius;
    handles = placeEllipse([handles.frameSize(1)/2 - r/2, handles.frameSize(2)/2 - r/2, r, r], 1, handles);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calibrationgui wait for user response (see UIRESUME)
uiwait(handles.calibrationgui);

function handles = placeEllipse(pos, num, handles)
center = [pos(1) + pos(3) / 2, pos(2) + pos(4) / 2];
axes(handles.img_ax);
numh = text(center(1) - 12, center(2) - 12, num2str(num), 'FontSize', 24);
h = imellipse(handles.img_ax, pos);
handles.ellipses{num} = h;

color = handles.cmap(num,:);
h.setColor(color);
numh.Color = color;
h.addNewPositionCallback(@(pos) updateNumber(pos, numh));

function updateNumber(pos, h)
center = [pos(1) + pos(3) / 2, pos(2) + pos(4) / 2];
h.Position = [center(1) - 12, center(2) - 12];

% --- Outputs from this function are returned to the command line.
function varargout = calibrationgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.calibrationgui);

% --- Executes on button press in add_btn.
function add_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nfibers = length(handles.ellipses);

r = handles.defaultRadius;
handles = placeEllipse([handles.frameSize(1)/2 - r/2, handles.frameSize(2)/2 - r/2, r, r], nfibers + 1, handles);

% Update handles structure
guidata(hObject, handles);

function labels_txt_Callback(hObject, eventdata, handles)
% hObject    handle to labels_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labels_txt as text
%        str2double(get(hObject,'String')) returns contents of labels_txt as a double


% --- Executes during object creation, after setting all properties.
function labels_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labels_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in done_btn.
function done_btn_Callback(hObject, eventdata, handles)
% hObject    handle to done_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Pre-check for number of valid ellipses
nfibers = 0;
for i = 1:length(handles.ellipses)
    if isvalid(handles.ellipses{i})
        nfibers = nfibers + 1;
    end
end

% Get the number of labels and warn if there's a different number of
% labels and fibers
raw_labels = get(handles.labels_txt, 'String');
[rows, cols] = size(raw_labels);
labels = cell(rows, 1);
for row = 1:rows
    str = deblank(raw_labels(row,:));
    if length(str) == 0
        errordlg('List of labels cannot include blank lines');
        return;
    end
    labels{row} = str;
end

if length(labels) ~= nfibers
    errordlg('Number of labels must be equal to the number of fibers');
    return;
end

frsz = handles.frameSize;
colors = zeros(nfibers, 3);
masks = zeros([frsz nfibers]);

% Store this labeled image for saving later
figImg = getframe(gcf);

i = 0;
for j = 1:nfibers
    e = handles.ellipses{j};
    if isvalid(e)
        i = i +1;
        pos = e.getVertices();
        x = pos(:,1); y = pos(:,2);
        mask = poly2mask(x, y, frsz(1), frsz(2));
        masks(:,:,i) = mask;
        colors(i,:) = e.getColor();
    end
end

handles.output.figImg = figImg;
handles.output.colors = colors;
handles.output.masks = masks;
handles.output.labels = labels;

% Update handles structure
guidata(hObject, handles);

close(handles.calibrationgui);

% --- Executes when user attempts to close calibrationgui.
function calibrationgui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to calibrationgui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
