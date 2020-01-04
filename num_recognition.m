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

    % Last Modified by GUIDE v2.5 04-Jan-2020 09:52:15

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
    global classifier;
    classifier = 0;
    global model_variance;
    global w1 w2 theta1 theta2;
    model_variance = load('model_best_120.mat');
    w1 = model_variance.w1;
    w2 = model_variance.w2;
    theta1 = model_variance.theta1;
    theta2 = model_variance.theta2;
    
    global template_num;
    global template_feature_float;
    global template_feature_int;
    maindir = './100_digit';
    subdir = dir(maindir);

    all_images = uint8([]);
    template_num = zeros(10, 1);
    template_feature_int = uint8([]);
    template_feature_float = double([]);
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
            imagedata = imresize(imagedata, [28,28]);
            thresh=graythresh(imagedata);%确定二值化阈值
            imagedata=im2bw(imagedata,thresh);%对图像二值化
            [feature,featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
            template_feature_float(total_image_num, :) = [i - 3; feature];
            [feature,featureimg] = getfeature(reshape(imagedata, [28,28]));
            template_feature_int(total_image_num, :) = [i - 3; feature];
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
    global template_feature_float;
    global template_feature_int;
    global classifier;
    global w1 w2 theta1 theta2;
    new_f_handle=figure('visible','off'); %新建一个不可见的figure
    new_axes=copyobj(handles.axes1,new_f_handle); %axes1是GUI界面内要保存图线的Tag，将其copy到不可见的figure中，不copy保存的图片总是有错误
    h = getframe(new_axes);
    %h=getframe(handles.axes1);
    if classifier == 0
        h.cdata = imresize(h.cdata, [40, 40]);
        thresh=graythresh(h.cdata);%确定二值化阈值
        h.cdata=im2bw(h.cdata,thresh);%对图像二值化
        [feature,featureimg]=getfeature(h.cdata);
    else
        h.cdata = imresize(h.cdata, [30, 30]);
        thresh=graythresh(h.cdata);%确定二值化阈值
        h.cdata=im2bw(h.cdata,thresh);%对图像二值化
        [feature,featureimg]=getfeature(h.cdata, 1);
    end
    axes(handles.axes2); 
    imshow(featureimg)
    switch classifier
        case 0
            [result,v]=BayesErzhishuju(feature, template_feature_int, template_num);
        case 1
            [result,v]=BayesLeasterror(feature, template_feature_float, template_num);
        case 2
            [result,v]=Fisher_LDA(feature, template_feature_float, template_num);
        case 3
            single_forward_1 = feature' * w1;
            single_forward_1_sigmoid = 1 ./ (1 + exp(-single_forward_1 + theta1));
            single_forward_2 = single_forward_1_sigmoid * w2;
            single_forward_2_sigmoid = 1 ./ (1 + exp(-single_forward_2 + theta2));
            [v, result] = max(single_forward_2_sigmoid);
            result = result - 1;
    end
    msgbox("手写数字识别结果:"+string(result))
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


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu2
    global classifier;
    val=get(handles.popupmenu2,'value');
    switch val
        case 1
            classifier = 0;
        case 2
            classifier = 1;
        case 3
            classifier = 2;
        case 4 
            classifier = 3;
    end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
