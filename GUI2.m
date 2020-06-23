function varargout = GUI2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI2_OutputFcn, ...
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


% --- Executes just before GUI2 is made visible.
function GUI2_OpeningFcn(hObject, ~, handles, varargin)
centerfig;

handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GUI2_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

% --- SELECCIONAR IMAGEN1
function boton1_Callback(~, ~, handles)
[filename1, pathname1] = uigetfile({'*'}, 'File Selector');
fullpathname1 = strcat(pathname1, filename1);
im1 = imread(fullpathname1);
axes(handles.imagen1);
imshow(im1);
set(handles.imagen1, 'UserData', im1);
set(gca, 'XTick', [], 'YTick', []);

%Fecha captura
data1 = imfinfo(fullpathname1);
date1 = (data1.FileModDate);
C1 = strsplit(date1,' ');
fecha1 = C1(1,1);
texto1 = 'Fecha de captura: ';
Union1 = [texto1 fecha1];
DateCapture1 = join(Union1);
set(handles.fecha1,'String',DateCapture1);

%Calculo el dpi de la imagen1
data_dpi1 = getexif(fullpathname1);
C_dpi1 = strsplit(data_dpi1,'\n');
X1 = C_dpi1(1,15);
Sx1 = split(X1,' ');
DpiX1 = Sx1(23,1);
Xdpi1 = str2double(DpiX1{1});
set(handles.boton1, 'UserData',Xdpi1);


% --- SELECCIONAR IMAGEN2
function boton2_Callback(~, ~, handles)
[filename2, pathname2] = uigetfile({'*'}, 'File Selector');
fullpathname2 = strcat(pathname2, filename2);
im2 = imread(fullpathname2);
axes(handles.imagen2);
imshow(im2);
set(handles.imagen2, 'UserData', im2);
set(gca, 'XTick', [], 'YTick', []);
set(handles.panel2,'visible','on');
set(handles.panel3,'visible','on');
set(handles.panel4,'visible','on');

%Fecha captura
data2 = imfinfo(fullpathname2);
date2 = (data2.FileModDate);
C2 = strsplit(date2,' ');
fecha2 = C2(1,1);
texto2 = 'Fecha de captura: ';
Union2 = [texto2 fecha2];
DateCapture2 = join(Union2);
set(handles.fecha2,'String',DateCapture2);

%Calculo el dpi de la imagen2
data_dpi2 = getexif(fullpathname2);
C_dpi2 = strsplit(data_dpi2,'\n');
X2 = C_dpi2(1,15);
Sx2 = split(X2,' ');
DpiX2 = Sx2(23,1);
Xdpi2 = str2double(DpiX2{1});
set(handles.boton2, 'UserData',Xdpi2);


% --- TONALIDAD
function pushbutton6_Callback(~, ~, handles)
im1 = get(handles.imagen1,'UserData');
im2 = get(handles.imagen2, 'UserData');

if isempty(im1)|| isempty(im2)
    warndlg('Inserte otra imagen para comparar tonalidades');
else

%Imagen1
%Calculo los valores R, G y B
R1 = im1(:,:,1);
G1 = im1(:,:,2);
B1 = im1(:,:,3);

%Calculo las medias de cada canal
meanR1 = mean(R1(:));
meanG1 = mean(G1(:));
meanB1 = mean(B1(:));

%Asigno a cada valor numerico su color
R1(:) = meanR1;
G1(:) = meanG1;
B1(:) = meanB1;

%Construyo el color medio
ImagenMedia1(:,:,1) = R1;
ImagenMedia1(:,:,2) = G1;
ImagenMedia1(:,:,3) = B1;
axes(handles.pantalla1);
imshow(ImagenMedia1);
set(gca, 'XTick', [], 'YTick', []);

%Imagen2
%Calculo los valores R, G y B
R2 = im2(:,:,1);
G2 = im2(:,:,2);
B2 = im2(:,:,3);

%Calculo las medias de cada canal
meanR2 = mean(R2(:));
meanG2 = mean(G2(:));
meanB2 = mean(B2(:));

%Asigno a cada valor numerico su color
R2(:) = meanR2;
G2(:) = meanG2;
B2(:) = meanB2;

%Construyo el color medio
ImagenMedia2(:,:,1) = R2;
ImagenMedia2(:,:,2) = G2;
ImagenMedia2(:,:,3) = B2;
axes(handles.pantalla2);
imshow(ImagenMedia2);
set(gca, 'XTick', [], 'YTick', []);

%Tabla
R = {meanR1, meanR2};
G = {meanG1, meanG2};
B = {meanB1, meanB2};

tonalidades = [R; G ;B];
set(handles.tabla2,'data', tonalidades);
end

% --- SUPERPONER
function boton4_Callback(~, ~, handles)
im1 = get(handles.imagen1,'UserData');
im2 = get(handles.imagen2, 'UserData');

if isempty(im1)|| isempty(im2)
    warndlg('Inserte otra imagen para poder superponerlas');
else

%Mismas dimensiones
im1 = imresize(im1, [802 919]);
im2 = imresize(im2, [802 919]);

%Imagen1
I = rgb2gray(im1);
umbral = graythresh(I);
imbin = imbinarize(I, umbral);
imseg = not(imbin);
imseg = bwareaopen(imseg, 150);
se = strel('square',4);
se1 = strel('square',8);
imErosion = imerode(imseg,se);
imDilatar = imdilate(imErosion,se1);
imRelleno = imfill(imDilatar,'holes');

%Calculo centro y orientacion
stats = regionprops('table', imRelleno, 'Centroid','Orientation'); 

Centroide = stats.Centroid;
Orientacion = stats.Orientation;

Centroide = Centroide(1,:);
Orientacion = Orientacion(1,:);


%Imagen2
I2 = rgb2gray(im2);
umbral2 = graythresh(I2);
imbin2 = imbinarize(I2, umbral2);
imseg2 = not(imbin2);
imseg2 = bwareaopen(imseg2, 150);
imErosion2 = imerode(imseg2,se);
imDilatar2 = imdilate(imErosion2,se1);
imRelleno2 = imfill(imDilatar2,'holes');

%Calculo centroide y orientacion
stats2 = regionprops('table', imRelleno2, 'Centroid','Orientation'); 

Centroide2 = stats2.Centroid;
Orientacion2 = stats2.Orientation;

Centroide2 = Centroide2(1,:);
Orientacion2 = Orientacion2(1,:);

%Superposicion
C = Centroide-Centroide2;
O = Orientacion-Orientacion2;

image2Desplazada = imtranslate(imRelleno2,C);

image2 = imrotate(image2Desplazada, O);
image1 = imrotate(imRelleno, O);

axes(handles.imagen3);
imshowpair(image1,image2);
set(gca, 'XTick', [], 'YTick', []);
end

% --- CALCULAR MEDIDAS
function boton3_Callback(~, ~, handles)
im1 = get(handles.imagen1,'UserData');
im2 = get(handles.imagen2, 'UserData');

if isempty(im1)|| isempty(im2)
    warndlg('Inserte otra imagen para poder comparar medidas');
else

%Calculo medidas im1
Xdpi1 = get(handles.boton1,'UserData');
I1 = rgb2gray(im1);
umbral1 = graythresh(I1);
imbin1 = imbinarize(I1, umbral1);
imseg1 = not(imbin1);
imseg1 = bwareaopen(imseg1, 150);
se = strel('square',4);
se1 = strel('square',8);
imErosion1 = imerode(imseg1,se);
imDilatar1 = imdilate(imErosion1,se1);
imRelleno1 = imfill(imDilatar1,'holes');

stats1 = regionprops(imRelleno1, 'Area', 'EquivDiameter', 'Perimeter','Circularity'); 
area1 = stats1.Area;
diam1 = stats1.EquivDiameter;
perimetro1 = stats1.Perimeter;
circular1 = stats1.Circularity;

%Conversion a cm
pulgadas = 2.54;
AreaCm1 = (area1/Xdpi1)*pulgadas;
DiametroCm1 = (diam1/Xdpi1)*pulgadas;
PerimetroCm1 = (perimetro1/Xdpi1)*pulgadas;
CircularCm1 = (circular1/Xdpi1)*pulgadas;

Radio1 = DiametroCm1/2;
Volumen1 = (4/3)*pi*(Radio1^3);
Grosor1 = Volumen1/AreaCm1;

%Calculo medidas im2
Xdpi2 = get(handles.boton2,'UserData');

I2 = rgb2gray(im2);
umbral2 = graythresh(I2);
imbin2 = imbinarize(I2, umbral2);
imseg2 = not(imbin2);
imseg2 = bwareaopen(imseg2, 150);
imErosion2 = imerode(imseg2,se);
imDilatar2 = imdilate(imErosion2,se1);
imRelleno2 = imfill(imDilatar2,'holes');

stats2 = regionprops(imRelleno2, 'Area', 'EquivDiameter', 'Perimeter','Circularity'); 
area2 = stats2.Area;
diam2 = stats2.EquivDiameter;
perimetro2 = stats2.Perimeter;
circular2 = stats2.Circularity;

%Conversion a cm
pulgadas = 2.54;
AreaCm2 = (area2/Xdpi2)*pulgadas;
DiametroCm2 = (diam2/Xdpi2)*pulgadas;
PerimetroCm2 = (perimetro2/Xdpi2)*pulgadas;
CircularCm2 = (circular2/Xdpi2)*pulgadas;

Radio2 = DiametroCm2/2;
Volumen2 = (4/3)*pi*(Radio2^3);
Grosor2 = Volumen2/AreaCm2;

Area = {AreaCm1, AreaCm2};
Diametro = {DiametroCm1, DiametroCm2};  
Perimetro = {PerimetroCm1, PerimetroCm2};
Circular = {CircularCm1, CircularCm2};
Grosor = {Grosor1, Grosor2};

datos = [Area' Diametro' Perimetro' Circular' Grosor'];
set(handles.tabla,'data', datos);
end

% --- MENUBAR
function figure1_CreateFcn(hObject, ~, ~)
set(hObject,'menubar','none');

% --- VOLVER A INICIO
function pushbutton5_Callback(~, ~, ~)
close(GUI2);
Inicio;
