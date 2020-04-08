function varargout = changeDetectGUI(varargin)
% CHANGEDETECTGUI MATLAB code for changeDetectGUI.fig
%      CHANGEDETECTGUI, by itself, creates a new CHANGEDETECTGUI or raises the existing
%      singleton*.
%
%      H = CHANGEDETECTGUI returns the handle to a new CHANGEDETECTGUI or the handle to
%      the existing singleton*.
%
%      CHANGEDETECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANGEDETECTGUI.M with the given input arguments.
%
%      CHANGEDETECTGUI('Property','Value',...) creates a new CHANGEDETECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before changeDetectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to changeDetectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help changeDetectGUI

% Last Modified by GUIDE v2.5 25-Feb-2018 23:42:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @changeDetectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @changeDetectGUI_OutputFcn, ...
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


% --- Executes just before changeDetectGUI is made visible.
function changeDetectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to changeDetectGUI (see VARARGIN)
[fileName,pathName] = uigetfile('*.avi','Choose your video file...');
handles.videoFile = VideoReader([pathName fileName]);
set(gcf,'CurrentAxes',handles.imAxes2); imshow([]);
set(gcf,'CurrentAxes',handles.imAxes1); imshow([]);

% Choose default command line output for changeDetectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes changeDetectGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = changeDetectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectionOK = 0;
set(gcf,'CurrentAxes',handles.imAxes1);
while selectionOK == 0
    selMode = menu('Choose Frame Selection Type','Enter Frame Number','Choose from Video','Auto Generate');
    switch selMode
        case 1
            answer = str2double(inputdlg('Enter Bacground Frame No'));
            if isnan(answer)
                warndlg('Not a number!');
            elseif 0 < answer && answer <= handles.videoFile.NumberOfFrames
                frmStr = get(handles.frameNoTxt,'string');
                set(handles.frameNoTxt,'string',[frmStr(1:13) ' ' num2str(answer)]);
                currFrame = rgb2gray(read(handles.videoFile,answer));
                imshow(currFrame);
                permission = menu('Is it correct?','Yes','No');
                if permission == 1
                    backGrdFrameNo = uint16(answer);
                    selectionOK = 1;
                    imshow([]);
                else
                    msgbox('Select Again!');
                end
            else
                warndlg(['Enter a number up to ' num2str(handles.videoFile.NumberOfFrames) ' for this video!']);
            end
        otherwise
            frameNo = uint16(1);
            changeType = 0;
            while changeType == 0
                frmStr = get(handles.frameNoTxt,'string');
                set(handles.frameNoTxt,'string',[frmStr(1:13) ' ' num2str(frameNo)]);
                currFrame = rgb2gray(read(handles.videoFile,frameNo));
                imshow(currFrame);
                option = menu('Frame Options','Previous','Next','Select','Enter Number');
                switch option
                    case 1
                        if frameNo ~= 1
                            frameNo = frameNo - 1;
                        else
                            frameNo = handles.videoFile.NumberOfFrames;
                        end
                    case 2
                        if frameNo ~= handles.videoFile.NumberOfFrames
                            frameNo = frameNo + 1;
                        else
                            frameNo = 1;
                        end
                    case 3
                        backGrdFrameNo = frameNo;
                        selectionOK = 1;
                        changeType = 1;
                        frmStr = get(handles.frameNoTxt,'string');
                        set(handles.frameNoTxt,'string',frmStr(1:13));
                        imshow([]);
                    otherwise
                        changeType = 1;
                end
            end
    end
end
baseFrame = rgb2gray(read(handles.videoFile,backGrdFrameNo));
frameCounter = 1;
newFrame = rgb2gray(read(handles.videoFile,frameCounter));
diffFrame = uint8(abs(int16(newFrame) - int16(baseFrame)));
indx = histCV(diffFrame);
T = otsuThreshold(indx);
BW_Frame = (diffFrame > T);
imshow(newFrame);
set(gcf,'CurrentAxes',handles.imAxes2);
imshow(BW_Frame);
bwAreaNum = numel(find(BW_Frame == 1));
alpha = 0.01;
min_t = 20;
tSaturate = 100;
% erKer = logical([0 1 0;1 1 1;0 1 0]);
dlKer = logical([0 1 1 1 0;1 1 1 1 1;1 1 1 1 1;1 1 1 1 1;0 1 1 1 0]);
% % Rmap = rand(1,100);
% % Gmap = rand(1,100);
% % Bmap = rand(1,100);
rgbMap = [0.3 0.8 0.9];
lbFrameRGB = uint8(zeros(240,320,3));
frmStr = get(handles.frameNoTxt,'string');
set(handles.frameNoTxt,'string',[frmStr(1:13) ' ' num2str(frameCounter)]);
while frameCounter < handles.videoFile.NumberOfFrames
    baseFrame(BW_Frame==0) = alpha * newFrame(BW_Frame==0)...
        + (1 - alpha) * baseFrame(BW_Frame==0);
    frameCounter = frameCounter + 1;
    newFrame = rgb2gray(read(handles.videoFile,frameCounter));
    diffFrame = uint8(abs(int16(newFrame) - int16(baseFrame)));
    indx = histCV(saturateVector(diffFrame,tSaturate));
    T = otsuThreshold(indx);
    if T < min_t
        T = min_t;
    end
    BW_Frame = (diffFrame > T);
    BW_Frame = bwareaopen(BW_Frame,25);
%    BW_Frame = erosionOp(BW_Frame,erKer);
    BW_Frame = imcomplement(bwareaopen(imcomplement(BW_Frame),500));
%    BW_Frame = dilationOp(BW_Frame,dlKer);
    BW_Frame = imclose(BW_Frame,dlKer);
    BW_Frame = imcomplement(bwareaopen(imcomplement(BW_Frame),500));
    lbFrame = labelFrame(BW_Frame);
% TO DO stationary label colors
    labeledFrame = single(lbFrame);
    labeledFrame(labeledFrame ~= 0) = labeledFrame(labeledFrame ~= 0) + 50;
    labeledFrame = labeledFrame / max(labeledFrame(:));
    lbFrameRGB(:,:,1) = uint8(rgbMap(1)*labeledFrame*256);
    lbFrameRGB(:,:,2) = uint8(rgbMap(3)*labeledFrame*256);
    lbFrameRGB(:,:,3) = uint8(rgbMap(3)*labeledFrame*256);
    set(gcf,'CurrentAxes',handles.imAxes1); imshow(newFrame);
    set(gcf,'CurrentAxes',handles.imAxes2); imshow(lbFrameRGB);
    frmStr = get(handles.frameNoTxt,'string');
    set(handles.frameNoTxt,'string',[frmStr(1:13) ' ' num2str(frameCounter)]);
                
%     totArea = sum(BW_Frame(:));
%     tempLabels = unique(lbFrame);
%     tempLabels(tempLabels == 0) = [];
%     Labels = (1:length(tempLabels))';
%     Areas = uint16(zeros(length(Labels),1));
%     for lbCnt = Labels'
%         lbFrame(lbFrame == tempLabels(lbCnt)) = Labels(lbCnt);
%         Areas(lbCnt) = numel(find(lbFrame == Labels(lbCnt)));
%     end
%     tbl = table(Labels,Areas)
    pause(1/handles.videoFile.FrameRate);
end
