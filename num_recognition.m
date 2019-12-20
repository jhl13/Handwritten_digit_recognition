function varargout = num_recognition(varargin)
% NUM_RECOGNITION MATLAB code for num_recognition.fig
%      NUM_RECOGNITION, by itself, creates a new NUM_RECOGNITION or raises the existing
%      singleton*.
%
%      H = NUM_RECOGNITION returns the handle to a new NUM_RECOGNITION or the handle to
%      the existing singleton*.
%
%      NUM_RECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUM_RECOGNITION.M with the given input arguments.
%
%      NUM_RECOGNITION('Property','Value',...) creates a new NUM_RECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before num_recognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to num_recognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help num_recognition

% Last Modified by GUIDE v2.5 01-Nov-2019 19:26:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @num_recognition_OpeningFcn, ...
                   'gui_OutputFcn',  @num_recognition_OutputFcn, ...
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


% --- Executes just before num_recognition is made visible.
function num_recognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to num_recognition (see VARARGIN)

% Choose default command line output for num_recognition
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes num_recognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%axes(handles.axes1); 
set(handles.axes1,'ButtonDownFcn',{@axes1_ButtonDownFcn,handles})
global template_num;
global template_feature;
maindir = './100_digit';
subdir = dir(maindir);

all_images = uint8([]);
template_num = zeros(10, 1);
%template_feature = uint8([]);
template_feature = double([]);
total_image_num = 0;

for i = 1 : length(subdir)
    if (isequal(subdir(i).name, '.') || ...
        isequal(subdir(i).name, '..') || ...
        ~subdir(i).isdir) % 跳过不是目录的子文件夹
        continue;
    end
%     sprintf(subdir(i).name)
    subdirpath = fullfile(maindir, subdir(i).name, '*.jpg');
    images = dir(subdirpath);
    template_num(i-2) = length(images);
    
    for j = 1 : length(images)
        total_image_num = total_image_num + 1;
        imagepath = fullfile(maindir, subdir(i).name, images(j).name);
        imagedata = imread(imagepath);
        [feature,featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
        template_feature(total_image_num, :) = [i - 3; feature];
        % all_images(i-2, j, :, :) = imagedata;
    end
end


% --- Outputs from this function are returned to the command line.
function varargout = num_recognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mouseflg x0 y0 x y;
if mouseflg
    x0=x;y0=y;
    currPt=get(gca, 'CurrentPoint'); % 获取当前的坐标点
    x=currPt(1,1);
    y=currPt(1,2);
    %axes(handles.axes1);
    line([x0 x], [y0,y],'LineWidth',5,'color',[0,0,0]);
    set(gca,'ButtonDownFcn',{@axes1_ButtonDownFcn,handles})
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_f_handle=figure('visible','off'); %新建一个不可见的figure
new_axes=copyobj(handles.axes1,new_f_handle); %axes1是GUI界面内要保存图线的Tag，将其copy到不可见的figure中，不copy保存的图片总是有错误
image = getframe(new_axes);
[filename pathname fileindex]=uiputfile({'*.bmp';'*.png';'*.jpg';'*.eps';},'图片保存为');
if filename ~= 0
    file=strcat(pathname,filename);
    image.cdata = imresize(image.cdata, [240, 240]);
    imwrite(im2bw(image.cdata,0.5)*255, file);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
axes(handles.axes2);
cla;
sign = ones(10,10);
imshow(sign)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global feature;
global template_num;
global template_feature;
new_f_handle=figure('visible','off'); %新建一个不可见的figure
new_axes=copyobj(handles.axes1,new_f_handle); %axes1是GUI界面内要保存图线的Tag，将其copy到不可见的figure中，不copy保存的图片总是有错误
h = getframe(new_axes);
%h=getframe(handles.axes1);
h.cdata = imresize(h.cdata, [240, 240]);
[feature,featureimg]=getfeature(im2bw(h.cdata,0.5)*255, 1);
axes(handles.axes2); 
imshow(featureimg)
[result,v]=BayesLeasterror(feature, template_feature, template_num)
msgbox("result:"+string(result))
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mouseflg
mouseflg = 0;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global mouseflg
mouseflg = 0;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton2.
function pushbutton2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mouseflg;
global x;
global y;
mouseflg = 1;
p = get(gca, 'currentpoint'); % 按下鼠标时，记录鼠标当前的坐标点
x = p(1);
y = p(3);

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
