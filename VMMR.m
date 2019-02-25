function varargout = VMMR(varargin)
% VMMR MATLAB code for VMMR.fig
%      VMMR, by itself, creates a new VMMR or raises the existing
%      singleton*.
%
%      H = VMMR returns the handle to a new VMMR or the handle to
%      the existing singleton*.
%
%      VMMR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VMMR.M with the given in arguments.
%
%      VMMR('Property','Value',...) creates a new VMMR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VMMR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VMMR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VMMR

% Last Modified by GUIDE v2.5 06-Jan-2019 15:22:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VMMR_OpeningFcn, ...
                   'gui_OutputFcn',  @VMMR_OutputFcn, ...
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


% --- Executes just before VMMR is made visible.
function VMMR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no out args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VMMR (see VARARGIN)

% Choose default command line out for VMMR
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = VMMR_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning out args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line out from handles structure
varargout{1} = handles.output;



% --- Executes on button press in select_pushbtn.
function select_pushbtn_Callback(hObject, eventdata, handles)
% hObject    handle to select_pushbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global path; 
[FileName,FilePath ]= uigetfile('*','Select the image'); %Browse function
path = fullfile(FilePath, FileName);               % Test Image as input
imshow(path,'Parent',handles.in);                  % Display it guide Axis

 
% --- Executes on button press in match_pushbtn.
function match_pushbtn_Callback(hObject, eventdata, handles)
% hObject    handle to match_pushbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global path;
test_img=imread(path);
temp=0;
% Read images from database
training_img=dir(strcat('Training_Database','/*.jpg')); 

% Check in image is color image if yes then convert into grayscale
if(size(test_img,3)==3)
    test_img=rgb2gray(test_img);
end

% compare image with current image from training database
for i=1:size(training_img)
   
   % read Training image data path
   matchpath=fullfile('Training_Database',training_img(i).name);
   match_img=imread(matchpath);
     
   % Check if image is color image if yes then convert into grayscale    
    if(size(match_img,3)==3)
       match_img=rgb2gray(match_img);
    end
        
   % Get the SURF features
   pts_1 = detectSURFFeatures(test_img);
   pts_2 = detectSURFFeatures(match_img);

   % Extract features 
   [fe_1, pts_1] = extractFeatures(test_img, pts_1);
   [fe_2, pts_2] = extractFeatures(match_img, pts_2);

   % Match features
   index_pairs = matchFeatures(fe_1, fe_2);
   matched_points1 = pts_1(index_pairs(:, 1), :);
   matched_points2 = pts_2(index_pairs(:, 2), :);

   % count of matched features 
   store=size(index_pairs);
   s=store(1:1);

   % Store current image if it has higher number of matching feature  
   % points than last image
   if(s>temp)
      temp=s;
      mat_pt1 = matched_points1;
      mat_pt2 = matched_points2;
      out_img = match_img;
      result  = matchpath;
    end
end


% Display the Final Result
figure;
% Place test and result image next to each other in the same image
% and show arrows to Coordinates of points in image
showMatchedFeatures(test_img, out_img, mat_pt1,mat_pt2,'montage');
imshow(result,'Parent',handles.out);
title('Output: Matched Points');
legend('Test','Result');
set(handles.carname,'String',result); 

