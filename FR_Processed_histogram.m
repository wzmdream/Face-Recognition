function varargout = FR_Processed_histogram(varargin)
%The algorithm implements the Approach of histogram based processing (apperance based approach) 
%The histogram of image is calculated and then bin formation is done on the
%basis of mean of successive graylevels frequencies. The training is done on odd images of 40 subjects (200 images out of 400 images) 

%The results of the implemented algorithm is 99.75 (recognition fails on image number 4 of subject 17)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FR_Processed_histogram_OpeningFcn, ...
                   'gui_OutputFcn',  @FR_Processed_histogram_OutputFcn, ...
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

%--------------------------------------------------------------------------
% --- Executes just before FR_Processed_histogram is made visible.
function FR_Processed_histogram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FR_Processed_histogram (see VARARGIN)

% Choose default command line output for FR_Processed_histogram
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FR_Processed_histogram wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global total_sub train_img sub_img max_hist_level bin_num form_bin_num;

total_sub = 40;
train_img = 200;
sub_img = 10;
max_hist_level = 256;
bin_num = 9;
form_bin_num = 29;
%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = FR_Processed_histogram_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
% --- Executes on button press in train_button.  
function train_button_Callback(hObject, eventdata, handles)
% hObject    handle to train_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global train_processed_bin;
global total_sub train_img sub_img max_hist_level bin_num form_bin_num;

train_processed_bin(form_bin_num,train_img) = 0;
K = 1;
train_hist_img = zeros(max_hist_level, train_img);

for Z=1:1:total_sub 
  for X=1:2:sub_img    %%%train on odd number of images of each subject
    
    I = imread( strcat('Images\S',int2str(Z),'\',int2str(X),'.bmp') ); 
	
    [rows cols] = size(I);
    
    for i=1:1:rows
       for j=1:1:cols
           if( I(i,j) == 0 )
               train_hist_img(max_hist_level, K) =  train_hist_img(max_hist_level, K) + 1;                            
           else
               train_hist_img(I(i,j), K) = train_hist_img(I(i,j), K) + 1;                         
           end
       end   
    end   
     K = K + 1;        
  end  
 end  

[r c] = size(train_hist_img);
sum = 0;
for i=1:1:c
    K = 1;
   for j=1:1:r        
        if( (mod(j,bin_num)) == 0 )
            sum = sum + train_hist_img(j,i);            
            train_processed_bin(K,i) = sum/bin_num;
            K = K + 1;
            sum = 0;
        else
            sum = sum + train_hist_img(j,i);            
        end
    end
    train_processed_bin(K,i) = sum/bin_num;
end

display ('Training Done')
save 'train'  train_processed_bin;

%--------------------------------------------------------------------------
% --- Executes on button press in Testing_button.    
function Testing_button_Callback(hObject, eventdata, handles)
% hObject    handle to Testing_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global train_img max_hist_level bin_num form_bin_num;
global train_processed_bin;
global filename pathname I

load 'train'
test_hist_img(max_hist_level) = 0;
test_processed_bin(form_bin_num) = 0;


 [rows cols] = size(I);
  
    for i=1:1:rows
       for j=1:1:cols
           if( I(i,j) == 0 )
               test_hist_img(max_hist_level) =  test_hist_img(max_hist_level) + 1;                            
           else
               test_hist_img(I(i,j)) = test_hist_img(I(i,j)) + 1;                         
           end
       end   
    end   
    
  [r c] = size(test_hist_img);
  sum = 0;

    K = 1;
    for j=1:1:c        
        if( (mod(j,bin_num)) == 0 )
            sum = sum + test_hist_img(j);            
            test_processed_bin(K) = sum/bin_num;
            K = K + 1;
            sum = 0;
        else
            sum = sum + test_hist_img(j);            
        end
    end
  
 test_processed_bin(K) = sum/bin_num;
    
sum = 0;
K = 1;

    for y=1:1:train_img
        for z=1:1:form_bin_num        
          sum = sum + abs( test_processed_bin(z) - train_processed_bin(z,y) );  
        end         
        img_bin_hist_sum(K,1) = sum;
        sum = 0;
        K = K + 1;
    end

    [temp M] = min(img_bin_hist_sum);
    M = ceil(M/5);
    getString_start=strfind(pathname,'S');
    getString_start=getString_start(end)+1;
    getString_end=strfind(pathname,'\');
    getString_end=getString_end(end)-1;
    subjectindex=str2num(pathname(getString_start:getString_end));
    axes (handles.axes3)
	%msgbox(STRCAT('Images\S',num2str(M),'\5.bmp'))
    %imshow(imread(STRCAT('Images\S',num2str(M),'\5.bmp')))    
    %msgbox ( ' Recognized finish ');   %end
	display('looking for the face.....');
	display (['Testing Image of Subject >>' num2str(subjectindex) '  matches with the image of subject >> '  num2str(M)])
	I=imread(STRCAT('Images\S',num2str(M),'\5.bmp'));
		if (size(I,3)>1)%if RGB image make gray scale
			try
			   x=rgb2gray(I);%image toolbox dependent
			catch
				x=sum(double(I),3)/3;%if no image toolbox do simple sum
			end
		end
	x=double(x);%make sure the input is double format
	[output,count,m,svec]=facefind(x);
	imshow(I);
	plotbox(output,[0,0,1],1);
	msgbox ( ' Recognized finish ');
 
display('Testing Done')
%--------------------------------------------------------------------------
function box_Callback(hObject, eventdata, handles)
% hObject    handle to box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box as text
%        str2double(get(hObject,'String')) returns contents of box as a double

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
% --- Executes on button press in Input_Image_button.
function Input_Image_button_Callback(hObject, eventdata, handles)
% hObject    handle to Input_Image_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename pathname I
[filename, pathname] = uigetfile('*.*', 'Test Image');
%[file_name file_path] = uigetfile ('*.*','Test Image');
display('looking for the face.....');
axes(handles.axes1)
I=imread([[pathname,filename]]);
	if (size(I,3)>1)%if RGB image make gray scale
		try
		   x=rgb2gray(I);%image toolbox dependent
		catch
			x=sum(double(I),3)/3;%if no image toolbox do simple sum
		end
	end
x=double(x);%make sure the input is double format
[output,count,m,svec]=facefind(x);

imshow(I);
plotbox(output,[0,0,1],1);
  
%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3

 
%Programmed by Usman Qayyum



