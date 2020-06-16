function varargout = Inicio(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Inicio_OpeningFcn, ...
                   'gui_OutputFcn',  @Inicio_OutputFcn, ...
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


% --- Executes just before Inicio is made visible.
function Inicio_OpeningFcn(hObject, eventdata, handles, varargin)
centerfig;

handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Inicio_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- BOTON ESTUDIO MELANOMA
function boton1_Callback(hObject, eventdata, handles)
close(Inicio);
GUI

% --- BOTON EVOLUCION MELANOMA
function boton2_Callback(hObject, eventdata, handles)
close(Inicio);
GUI2

% --- LOGO
function pantalla_CreateFcn(hObject, eventdata, handles)
im=imread('logo.PNG');
imshow(im);
set(gca, 'XTick', [], 'YTick', []);

