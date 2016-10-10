function varargout = pidgui(varargin)
% PIDGUI MATLAB code for pidgui.fig
%      PIDGUI, by itself, creates a new PIDGUI or raises the existing
%      singleton*.
%
%      H = PIDGUI returns the handle to a new PIDGUI or the handle to
%      the existing singleton*.
%
%      PIDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIDGUI.M with the given input arguments.
%
%      PIDGUI('Property','Value',...) creates a new PIDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pidgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pidgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pidgui

% Last Modified by GUIDE v2.5 09-Oct-2016 23:43:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pidgui_OpeningFcn, ...
                   'gui_OutputFcn',  @pidgui_OutputFcn, ...
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


% --- Executes just before pidgui is made visible.
function pidgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pidgui (see VARARGIN)

handler = varargin{1};

addlistener(handler.pid, 'Pterm', 'PostSet', @(s, e) set(handles.pterm_txt, 'String', num2str(e.AffectedObject.Pterm)));
addlistener(handler.pid, 'Iterm', 'PostSet', @(s, e) set(handles.iterm_txt, 'String', num2str(e.AffectedObject.Iterm)));
addlistener(handler.pid, 'Dterm', 'PostSet', @(s, e) set(handles.dterm_txt, 'String', num2str(e.AffectedObject.Dterm)));

addlistener(handler, 'current_ctrl_signal', 'PostSet', @(s, e) set(handles.ctrlsig_txt, 'String', num2str(e.AffectedObject.current_ctrl_signal)));
addlistener(handler.pid, 'setpt', 'PostSet', @(s, e) set(handles.setpt_txt, 'String', num2str(e.AffectedObject.setpt)));



handles.handler = handler;

% Choose default command line output for pidgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pidgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pidgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function p_txt_Callback(hObject, eventdata, handles)
% hObject    handle to p_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p_txt as text
%        str2double(get(hObject,'String')) returns contents of p_txt as a double

handles.handler.pid.P = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function p_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function i_txt_Callback(hObject, eventdata, handles)
% hObject    handle to i_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of i_txt as text
%        str2double(get(hObject,'String')) returns contents of i_txt as a double

handles.handler.pid.I = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function i_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to i_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function d_txt_Callback(hObject, eventdata, handles)
% hObject    handle to d_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d_txt as text
%        str2double(get(hObject,'String')) returns contents of d_txt as a double

% --- Executes during object creation, after setting all properties.

handles.handler.pid.D = str2double(get(hObject,'String'));

function d_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function pterm_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pterm_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function iterm_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iterm_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function dterm_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dterm_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ctrlsig_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ctrlsig_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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
handles.handler.rate = str2double(get(hObject,'String'));

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

function width_txt_Callback(hObject, eventdata, handles)
% hObject    handle to width_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width_txt as text
%        str2double(get(hObject,'String')) returns contents of width_txt as a double
handles.handler.width = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function width_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function setpt_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setpt_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in acquire_setpt_btn.
function acquire_setpt_btn_Callback(hObject, eventdata, handles)
% hObject    handle to acquire_setpt_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acquire_setpt_btn

if get(hObject,'Value')
    handles.handler.reset_baseline();
else
    handles.handler.establish_baseline();
end