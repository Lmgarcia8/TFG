function varargout = GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, ~, handles, varargin)
centerfig;

handles.output = hObject;
guidata(hObject, handles);

function varargout = GUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;



% --- BOTÓN SELECCIONE UNA IMAGEN
function select_Callback(~, ~, handles)
global im;
[filename, pathname] = uigetfile({'*'}, 'File Selector');
fullpathname = strcat(pathname, filename);
im = imread(fullpathname);
imshow(im);
set(handles.restablece, 'UserData', im);
set(gca, 'XTick', [], 'YTick', []);

%Calculo el dpi
data_dpi = getexif(fullpathname);
C = strsplit(data_dpi,'\n');
X = C(1,15);
Sx = split(X,' ');
DpiX = Sx(23,1);
Xdpi = str2double(DpiX{1});
set(handles.select, 'UserData',Xdpi);

set(handles.panel1,'visible','on');

% --- BOTON RECORTA
function recorta_Callback(~, ~, handles)
global im;

if isempty(im)
    warndlg('Inserte una imagen para poder recortar');
else

im = imcrop(im);
set(gca, 'XTick', [], 'YTick', []);
imshow(im);
set(handles.recorta, 'UserData', im);
set(gca, 'XTick', [], 'YTick', []);
end

% --- BOTON PELO
function botonPelo_Callback(~, ~, handles)
global im;

if isempty(im)
    warndlg('Inserte una imagen para eliminar el vello');
else

Image=im;
%Si pulsamos el boton lo añadimos a la lista de procesamientos realizados
str_part = 'Eliminar vello';
old_str = get(handles.listbox2, 'String');
new_str = char(old_str, str_part);
set(handles.listbox2,'String',new_str);
%

Imgray= rgb2gray(Image);

%Filtro sobel
sobelFilter = fspecial ('sobel'); 
sobelFiltersigno = - (sobelFilter);

tras= sobelFilter';%bordes verticales
tras_signo = -tras;

%Bordes horizontales
im_sobel = imfilter(Imgray,sobelFilter);
im_sobel_signo = imfilter(Imgray,sobelFiltersigno);

%Bordes verticales
im_trans = imfilter(Imgray,tras);
im_trans_signo = imfilter(Imgray,tras_signo);

%Bordes total
imbordes_horizontales = imadd(im_sobel,im_sobel_signo);
imbordes_verticales = imadd(im_trans,im_trans_signo);
imbordes = imadd(imbordes_horizontales, imbordes_verticales);

%Binarizamos el resultado
imBin = imbinarize(imbordes);
imBin = bwareaopen(imBin,50);

%Dilato y erosiono 
se = strel('square',4);
se1 = strel('square',2);
se.Neighborhood;
imErosion = imerode(imBin,se);
imDilatar = imdilate(imErosion,se1);

%Creamos la mascara
W = graydiffweight(Imgray, imDilatar, 'GrayDifferenceCutoff', 35);
thresh = 0.01; 
[BW] = imsegfmm(W, imDilatar, thresh);
Mask = imcomplement(BW);%imagen complementaria

%Aplicamos la mascara para eliminar pelos (suponemos que todo el pelo vale
%0
imBorrosa = medfilt3(Image,[25 25 3]);

imPelos = Image.*uint8(Mask);

imPelos2 = imBorrosa.* uint8(BW);

im = imPelos + imPelos2;
axes(handles.pantalla);
imshow(im);
set(handles.botonPelo, 'UserData', im);
set(gca, 'XTick', [], 'YTick', []);
set(handles.guardar,'visible','on');
end

% --- BOTONES RADIO BUTTON
function group_SelectionChangedFcn(hObject, ~, handles)
global modo;
if hObject == handles.boton1
    modo = 1;
end
if hObject == handles.boton2
    modo = 2;
end
if hObject == handles.boton3
    modo = 3;
end
if hObject == handles.boton4
    modo = 4;
end

% --- BOTON EXAMINA (RADIO BUTTON)
function examina_Callback(~, ~, handles)
global modo;
global im;
global contrast;
global brillo1;
global brillo2;
set(handles.guardar,'visible','on');

if isempty(im)
    warndlg('Inserte una imagen para poder procesar la imagen');
else

if modo == 1 %contraste
    str_part = 'Contraste';
    im = imadjust(im,[.2 .3 0; .6 .7 1],[]);
    imshow(im);
    set(gca, 'XTick', [], 'YTick', []);
    contrast = true;
end

if modo == 2 %brillo
    str_part = 'Ajuste de brillo';
    if contrast == true
        AInv = imcomplement(im);
        BInv = imreducehaze(AInv, 'ContrastEnhancement', 'none');
        im = imcomplement(BInv);
        imshow(im)
        set(gca, 'XTick', [], 'YTick', []);
        brillo1 = true;
    else
        AInv = imcomplement(im);
        BInv = imreducehaze(AInv, 'ContrastEnhancement', 'none');
        im = imcomplement(BInv);
        imshow(im)
        set(gca, 'XTick', [], 'YTick', []);
        brillo2 = true;
    end
end


if modo == 3 %Segmentacion
    str_part = 'Segmentación';
    set(handles.boton4,'visible','on');
    set(handles.panel3,'visible','on');
    
    if contrast == true
        I = rgb2gray(im);
        umbral = graythresh(I);
        imbin = imbinarize(I, umbral);
        imseg = not(imbin);
        imseg = bwareaopen(imseg, 150);
        se = strel('square',4);
        se1 = strel('square',8);
        imErosion = imerode(imseg,se);
        imDilatar = imdilate(imErosion,se1);
        im = imfill(imDilatar,'holes');
        imshow(im);
        set(gca, 'XTick', [], 'YTick', []);
        set(handles.boton3, 'UserData', im);
    else
        if brillo1 == true
            I = rgb2gray(im);
            umbral = graythresh(I);
            imbin = imbinarize(I, umbral);
            imseg = not(imbin);
            imseg = bwareaopen(imseg, 150);
            se = strel('square',4);
            se1 = strel('square',8);
            imErosion = imerode(imseg,se);
            imDilatar = imdilate(imErosion,se1);
            im = imfill(imDilatar,'holes');
            imshow(im);
            set(gca, 'XTick', [], 'YTick', []);
            set(handles.boton3, 'UserData', im);
        else
            if brillo2 == true
                I = rgb2gray(im);
                umbral = graythresh(I);
                imbin = imbinarize(I, umbral);
                imseg = not(imbin);
                imseg = bwareaopen(imseg, 150);
                se = strel('square',4);
                se1 = strel('square',8);
                imErosion = imerode(imseg,se);
                imDilatar = imdilate(imErosion,se1);
                im = imfill(imDilatar,'holes');
                imshow(im);
                set(gca, 'XTick', [], 'YTick', []);
                set(handles.boton3, 'UserData', im);
            else
                I = rgb2gray(im);
                umbral = graythresh(I);
                imbin = imbinarize(I, umbral);
                imseg = not(imbin);
                imseg = bwareaopen(imseg, 150);
                se = strel('square',4);
                se1 = strel('square',8);
                imErosion = imerode(imseg,se);
                imDilatar = imdilate(imErosion,se1);
                im = imfill(imDilatar,'holes');
                imshow(im);
                set(gca, 'XTick', [], 'YTick', []);
                set(handles.boton3, 'UserData', im);
                
            end
        end
    end 
end


if modo == 4 %Contorno
    str_part = 'Contorno';
    imshow(im);
    hold on;
    boundaries = bwboundaries(im);
    numberOfBoundaries = size(boundaries, 1);
    for k = 1 : numberOfBoundaries
      thisBoundary = boundaries{k};
      plot(thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 2);
    end
    hold off;
    set(gca, 'XTick', [], 'YTick', []);
end

old_str = get(handles.listbox2, 'String');
new_str = char(old_str, str_part);
set(handles.listbox2,'String',new_str);
end

% --- LISTBOX
function listbox2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- RESTABLECER IMAGEN
function restablece_Callback(hObject, eventdata, handles)
global im;

if isempty(im)
    warndlg('Inserte una imagen');
else
    im = get(handles.restablece, 'UserData');
    imshow(im);
    set(gca, 'XTick', [], 'YTick', []);
    set(handles.listbox2, 'String', []);
    set(handles.boton4,'visible','off');
    set(handles.panel3,'visible','off');
    set(handles.guardar,'visible','off'); 
    set(handles.tabla, 'Data', []);
end

% --- BOTON CALCULAR MEDIDAS
function medidas_Callback(~, ~, handles)
im = get(handles.restablece, 'UserData');

if isempty(im)
    warndlg('Inserte una imagen para calcular medidas');
else

Xdpi = get(handles.select,'UserData');

im = get(handles.boton3, 'UserData');

%Obtengo los atributos que necesito
stats = regionprops(im, 'Area', 'EquivDiameter', 'Perimeter','Circularity'); 
area = stats.Area;
diam = stats.EquivDiameter;
perimetro = stats.Perimeter;
circular = stats.Circularity;

%Cambio las unidades a cm
pulgadas = 2.54;
AreaCm = (area/Xdpi)*pulgadas;
DiametroCm = (diam/Xdpi)*pulgadas;
PerimetroCm = (perimetro/Xdpi)*pulgadas;
CircularCm = (circular/Xdpi)*pulgadas;

Radio = DiametroCm/2;
Volumen = (4/3)*pi*(Radio^3);
Grosor = Volumen/AreaCm;

datos = [AreaCm DiametroCm PerimetroCm CircularCm Grosor];
set(handles.tabla,'data', datos);
end

% --- MENU BAR
function figure1_CreateFcn(hObject, ~, ~)
set(hObject,'toolbar','none');


% --- BOTON VOLVER AL INICIO
function pushbutton9_Callback(~, ~, ~)
close(GUI);
Inicio;


% --- GUARDAR IMAGEN
function guardar_Callback(hObject, eventdata, handles)
imagen = getimage(handles.pantalla);
formatos = {'*.jpg'};
[nomb,ruta] = uiputfile(formatos,'GUARDAR IMAGEN');
if nomb == 0, return, end
fName = fullfile(ruta,nomb);
imwrite(imagen,fName);
