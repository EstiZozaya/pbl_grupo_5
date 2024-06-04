close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

entropiaRGB = zeros(n,1);
entropiaHSV = zeros(n,1);
entropiaGris = zeros(n,1);
entropiaR = zeros(n,1);
entropiaG = zeros(n,1);
entropiaB = zeros(n,1);
entropiaNRR = zeros(n, 1);
entropiaNRR_HSV = zeros(n, 1);

rango_dinamicoRGB = zeros(n, 1);
rango_dinamicoHSV = zeros(n, 1);
rango_dinamicoGris = zeros(n, 1);
rango_dinamicoG= zeros(n, 1);
rango_dinamicoR= zeros(n, 1);
rango_dinamicoB= zeros(n, 1);
rango_dinamicoNRR= zeros(n, 1);
rango_dinamicoNRR_HSV= zeros(n, 1);

std_intensidadRGB = zeros(n, 1);
std_intensidadHSV = zeros(n, 1);
std_intensidadGris = zeros(n, 1);
std_intensidadG = zeros(n, 1);
std_intensidadR = zeros(n, 1);
std_intensidadB = zeros(n, 1);
std_intensidadNRR = zeros(n, 1);
std_intensidadNRR_HSV = zeros(n, 1);

varianzaRGB = zeros(n, 1);
varianzaHSV = zeros(n, 1);
varianzaGris = zeros(n, 1);
varianzaG = zeros(n, 1);
varianzaR = zeros(n, 1);
varianzaB = zeros(n, 1);
varianzaNRR = zeros(n, 1);
varianzaNRR_HSV = zeros(n, 1);

mediaRGB = zeros(n, 1);
mediaHSV = zeros(n, 1);
mediaGris = zeros(n, 1);
mediaG = zeros(n, 1);
mediaR = zeros(n, 1);
mediaB = zeros(n, 1);
mediaNRR = zeros(n, 1);
mediaNRR_HSV = zeros(n, 1);

energiaRGB = zeros(n, 1);
energiaHSV = zeros(n, 1);
energiaGris = zeros(n, 1);
energiaG = zeros(n, 1);
energiaR = zeros(n, 1);
energiaB = zeros(n, 1);
energiaNRR = zeros(n, 1);
energiaNRR_HSV = zeros(n, 1);

CDR = zeros(n, 1);
DDLS = zeros(n, 1);
dist1 = zeros(n, 1);
dist2 = zeros(n, 1);
dist3 = zeros(n, 1);
dist4 = zeros(n, 1);
radioC = zeros(n, 1);
radioD = zeros(n, 1);
centro1 = zeros(n, 1);
centro2 = zeros(n, 1);
NRR = zeros(n, 1);

contrast_red = zeros(n, 1);
homogeneity_red = zeros(n, 1);
correlation_red = zeros(n, 1);
contrast_green = zeros(n, 1);
homogeneity_green = zeros(n, 1);
correlation_green = zeros(n, 1);
contrast_blue = zeros(n, 1);
homogeneity_blue = zeros(n, 1);
correlation_blue = zeros(n, 1);
contrast_gray = zeros(n, 1);
homogeneity_gray = zeros(n, 1);
correlation_gray = zeros(n, 1);
contrast_NRR = zeros(n, 1);
homogeneity_NRR = zeros(n, 1);
correlation_NRR = zeros(n, 1);

average_dh_db3 = zeros(n, 1);
average_dv_db3 = zeros(n, 1);
energy_db3 = zeros(n, 1);
average_dh_sym3 = zeros(n, 1);
average_dv_sym3 = zeros(n, 1);
energy_sym3 = zeros(n, 1);
average_dh_bior33 = zeros(n, 1);
average_dv_bior33 = zeros(n, 1);
energy_bior33 = zeros(n, 1);
average_dh_bior35 = zeros(n, 1);
average_dv_bior35 = zeros(n, 1);
energy_bior35 = zeros(n, 1);
average_dh_bior37 = zeros(n, 1);
average_dv_bior37 = zeros(n, 1);
energy_bior37 = zeros(n, 1);

for i=1:n
copa = imread(['COPA2', T_buenacalidad_revisadas.image{i}]);
disco = imread(['DISCO5', T_buenacalidad_revisadas.image{i}]);
roi = imread(['ROI', T_buenacalidad_revisadas.image{i}]);

copa = imresize(copa, [300 300]);
disco = imresize(disco, [300 300]);
roi = imresize(roi, [300 300]);
roiHSV = rgb2hsv(roi);

copa = imbinarize(copa);
disco = imbinarize(disco);

[filaD, columnaD] = find(disco == max(disco(:)));
% Calcula el centroide
centroide_x = mean(columnaD);
centroide_y = mean(filaD);
centro_disco = [centroide_x, centroide_y]; 
% Calcula el radio
ancho_maximo = max(filaD) - min(filaD);
alto_maximo = max(columnaD) - min(columnaD);
radio_disco = max(ancho_maximo, alto_maximo) / 2; 

[filaC, columnaC] = find(copa == max(copa(:)));
% Calcula el centroide
centroide_x = mean(columnaC);
centroide_y = mean(filaC);
centro_copa = [centroide_x, centroide_y]; 
% Calcula el radio
ancho_maximo = max(filaC) - min(filaC);
alto_maximo = max(columnaC) - min(columnaC);
radio_copa = max(ancho_maximo, alto_maximo) / 2;

red_channel = roi(:, :, 1);
green_channel = roi(:, :, 2);
blue_channel = roi(:, :, 3);
roi_gris = rgb2gray(roi);

copaR = imcomplement(copa);
if radio_copa < radio_disco
    segm = xor(disco, copaR);
    segm = imcomplement(segm);
else
   segm = disco;
end 

red_channel_NRR = red_channel * 0;
red_channel_NRR(segm) = red_channel(segm);
green_channel_NRR = green_channel * 0;
green_channel_NRR(segm) = green_channel(segm);
blue_channel_NRR = blue_channel * 0;
blue_channel_NRR(segm) = blue_channel(segm);

roi_NRR(:, :, 1)= red_channel_NRR;
roi_NRR(:, :, 2)=green_channel_NRR;
roi_NRR(:, :, 3) =blue_channel_NRR;

roi_NRR_HSV = rgb2hsv(roi_NRR);

% COLOR

entropiaRGB(i) = entropy(roi);
entropiaHSV(i) = entropy(roiHSV);
entropiaGris(i) = entropy(roi_gris);
entropiaR(i) = entropy(red_channel);
entropiaG(i) = entropy(green_channel);
entropiaB(i) = entropy(blue_channel);
entropiaNRR(i) = entropy(roi_NRR);
entropiaNRR_HSV(i) = entropy(roi_NRR_HSV);

roi = double(roi);
roiHSV = double(roiHSV);
roi_gris = double(roi_gris);
red_channel = double(red_channel);
green_channel = double(green_channel);
blue_channel = double(blue_channel);
roi_NRR = double(roi_NRR);
roi_NRR_HSV = double(roi_NRR_HSV);

rango_dinamicoRGB(i) = max(roi(:))-min(roi(:));
rango_dinamicoHSV(i) = max(roiHSV(:))-min(roiHSV(:));
rango_dinamicoGris(i) = max(roi_gris(:))-min(roi_gris(:));
rango_dinamicoR(i) = max(red_channel(:))-min(red_channel(:));
rango_dinamicoG(i) = max(green_channel(:))-min(green_channel(:));
rango_dinamicoB(i) = max(blue_channel(:))-min(blue_channel(:));
rango_dinamicoNRR(i) = max(roi_NRR(:))-min(roi_NRR(:));
rango_dinamicoNRR_HSV(i) = max(roi_NRR_HSV(:))-min(roi_NRR_HSV(:));

std_intensidadRGB(i) = std2(roi(:));
std_intensidadHSV(i) = std2(roiHSV(:));
std_intensidadGris(i) = std2(roi_gris(:));
std_intensidadG(i) = std2(red_channel(:));
std_intensidadR(i) = std2(green_channel(:));
std_intensidadB(i) = std2(blue_channel(:));
std_intensidadNRR(i) = std2(roi_NRR(:));
std_intensidadNRR_HSV(i) = std2(roi_NRR_HSV(:));

varianzaRGB(i) = var(roi(:));
varianzaHSV(i) = var(roiHSV(:));
varianzaGris(i) = var(roi_gris(:));
varianzaG(i) = var(red_channel(:));
varianzaR(i) = var(green_channel(:));
varianzaB(i) = var(blue_channel(:));
varianzaNRR(i) = var(roi_NRR(:));
varianzaNRR_HSV(i) = var(roi_NRR_HSV(:));

mediaRGB(i) = mean(roi(:));
mediaHSV(i) = mean(roiHSV(:));
mediaGris(i) = mean(roi_gris(:));
mediaG(i) = mean(red_channel(:));
mediaR(i) = mean(green_channel(:));
mediaB(i) = mean(blue_channel(:));
mediaNRR(i) = mean(roi_NRR(:));
mediaNRR_HSV(i) = mean(roi_NRR_HSV(:));

energiaRGB(i) = sum(roi(:).^2);
energiaHSV(i) = sum(roiHSV(:).^2);
energiaGris(i) = sum(roi_gris(:).^2);
energiaG(i) = sum(red_channel(:).^2);
energiaR(i) = sum(green_channel(:).^2);
energiaB(i) = sum(blue_channel(:).^2);
energiaNRR(i) = sum(roi_NRR(:).^2);
energiaNRR_HSV(i) = sum(roi_NRR_HSV(:).^2);

% TEXTURA
roi_NRR = rgb2gray(roi_NRR);
glcm_red = graycomatrix(red_channel, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
glcm_green = graycomatrix(green_channel, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
glcm_blue = graycomatrix(blue_channel, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
glcm_gray = graycomatrix(roi_gris, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
glcm_NRR = graycomatrix(roi_NRR, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);

% Para el canal rojo
props_red = graycoprops(glcm_red);
props_green = graycoprops(glcm_green);
props_blue = graycoprops(glcm_blue);
props_gray = graycoprops(glcm_gray);
props_NRR = graycoprops(glcm_NRR);

contrast_red(i) = props_red.Contrast;
contrast_green(i) = props_green.Contrast;
contrast_blue(i) = props_blue.Contrast;
contrast_gray(i) = props_gray.Contrast;
contrast_NRR(i) = props_NRR.Contrast;

homogeneity_red(i) = props_red.Homogeneity;
homogeneity_green(i) = props_green.Homogeneity;
homogeneity_blue(i) = props_blue.Homogeneity;
homogeneity_gray(i) = props_gray.Homogeneity;
homogeneity_NRR(i) = props_NRR.Homogeneity;

correlation_red(i) = props_red.Correlation;
correlation_green(i) = props_green.Correlation;
correlation_blue(i) = props_blue.Correlation;
correlation_gray(i) = props_gray.Correlation;
correlation_NRR(i) = props_NRR.Correlation;

% COPA Y DISCO

CDR(i)=radio_disco/radio_copa;

RIM = radio_disco-radio_copa;
DDLS(i) = RIM/radio_disco;

dist1(i) = (centro_disco(1)-radio_disco)-(centro_copa(1)-radio_copa);
dist2(i) = (centro_disco(1)+radio_disco)-(centro_copa(1)+radio_copa);
dist3(i) = (centro_disco(2)-radio_disco)-(centro_copa(2)-radio_copa);
dist4(i) = (centro_disco(2)+radio_disco)-(centro_copa(2)+radio_copa);

radioC(i) = radio_copa;
radioD(i) = radio_disco;

centro1(i) = centro_disco(1) - centro_copa(1);
centro2(i) = centro_disco(2) - centro_copa(2);

NRR(i) = sum(sum(segm));

%WAVELET

Inorm_img = im2double(roi_gris);

% Lista de filtros wavelet
filters = {'db3', 'sym3', 'bior3.3', 'bior3.5', 'bior3.7'};
filters_names = {'db3', 'sym3', 'bior33', 'bior35', 'bior37'};

% Inicializar estructuras para almacenar las características
averageDh = struct();
averageDv = struct();
energy = struct();

% Aplicar DWT y calcular las características para cada filtro
for j = 1:length(filters)
    filter = filters{j};
    filter_name = filters_names{j};
    % Aplicar la DWT
    [cA, cH, cV, cD] = dwt2(Inorm_img, filter);
    
    % Calcular el promedio de los coeficientes de detalle horizontal (Dh)
    averageDh.(filter_name) = mean(cH(:));
    
    % Calcular el promedio de los coeficientes de detalle vertical (Dv)
    averageDv.(filter_name) = mean(cV(:));
    
    % Calcular la energía de los coeficientes
    [p, q] = size(cV);
    energy.(filter_name) = sum(cV(:).^2) / (p^2 + q^2);
end

% Acceso a las características individuales
average_dh_db3(i) = averageDh.db3;
average_dv_db3(i) = averageDv.db3;
energy_db3(i) = energy.db3;

average_dh_sym3(i) = averageDh.sym3;
average_dv_sym3(i) = averageDv.sym3;
energy_sym3(i) = energy.sym3;

average_dh_bior33(i) = averageDh.bior33;
average_dv_bior33(i) = averageDv.bior33;
energy_bior33(i) = energy.bior33;

average_dh_bior35(i) = averageDh.bior35;
average_dv_bior35(i) = averageDv.bior35;
energy_bior35(i) = energy.bior35;

average_dh_bior37(i) = averageDh.bior37;
average_dv_bior37(i) = averageDv.bior37;
energy_bior37(i) = energy.bior37;
end

T_caracteristicas_DETECCION = table(entropiaRGB, entropiaHSV, entropiaGris, entropiaR, entropiaG, entropiaB, entropiaNRR, entropiaNRR_HSV, ...
    rango_dinamicoRGB, rango_dinamicoHSV, rango_dinamicoGris, rango_dinamicoR, rango_dinamicoG, rango_dinamicoB, rango_dinamicoNRR, rango_dinamicoNRR_HSV, ...
    std_intensidadRGB, std_intensidadHSV, std_intensidadGris, std_intensidadR, std_intensidadG,std_intensidadB, std_intensidadNRR, std_intensidadNRR_HSV, ...
    varianzaRGB, varianzaHSV, varianzaGris, varianzaR, varianzaG, varianzaB, varianzaNRR, varianzaNRR_HSV, ...
    mediaRGB, mediaHSV, mediaGris, mediaR, mediaG, mediaB, mediaNRR, mediaNRR_HSV, ...
    energiaRGB, energiaHSV, energiaGris, energiaR, energiaG, energiaB, energiaNRR, energiaNRR_HSV, ...
    contrast_red, homogeneity_red, correlation_red,...
    contrast_green, homogeneity_green, correlation_green, ...
    contrast_blue, homogeneity_blue, correlation_blue,  ...
    contrast_gray, homogeneity_gray, correlation_gray, ...
    contrast_NRR, homogeneity_NRR, correlation_NRR, ...
    CDR, DDLS,NRR, dist1, dist2, dist3, dist4, radioD, radioC, centro1, centro2, ...
     energy_db3, average_dh_db3, average_dv_db3,...
    energy_sym3, average_dh_sym3, average_dv_sym3, ...
    energy_bior33, average_dh_bior33, average_dv_bior33,...
    energy_bior35, average_dh_bior35, average_dv_bior35,...
    energy_bior37, average_dh_bior37, average_dv_bior37,...
    'VariableNames', {'entropiaRGB', 'entropiaHSV', 'entropiaGris', 'entropiaR', 'entropiaG', 'entropiaB', 'entropiaNRR', 'entropiaNRR_HSV', ...
    'rango_dinamicoRGB', 'rango_dinamicoHSV', 'rango_dinamicoGris', 'rango_dinamicoR', 'rango_dinamicoG', 'rango_dinamicoB', 'rango_dinamicoNRR', 'rango_dinamicoNRR_HSV', ...
    'std_intensidadRGB', 'std_intensidadHSV', 'std_intensidadGris', 'std_intensidadR', 'std_intensidadG','std_intensidadB', 'std_intensidadNRR', 'std_intensidadNRR_HSV', ...
   'varianzaRGB', 'varianzaHSV', 'varianzaGris', 'varianzaR', 'varianzaG', 'varianzaB', 'varianzaNRR', 'varianzaNRR_HSV', ...
    'mediaRGB', 'mediaHSV', 'mediaGris', 'mediaR', 'mediaG', 'mediaB', 'mediaNRR','mediaNRR_HSV', ...
    'energiaRGB', 'energiaHSV', 'energiaGris', 'energiaR', 'energiaG', 'energiaB', 'energiaNRR', 'energiaNRR_HSV', ...
    'contrast_red', 'homogeneity_red', 'correlation_red',...
    'contrast_green', 'homogeneity_green', 'correlation_green', ...
    'contrast_blue', 'homogeneity_blue', 'correlation_blue',  ...
    'contrast_gray', 'homogeneity_gray', 'correlation_gray', ...
    'contrast_NRR', 'homogeneity_NRR', 'correlation_NRR', ...
    'CDR', 'DDLS', 'NRR','dist1', 'dist2', 'dist3', 'dist4', 'radioD', 'radioC', 'centro1', 'centro2', ...
    'energy_db3', 'average_dh_db3', 'average_dv_db3',...
    'energy_sym3', 'average_dh_sym3', 'average_dv_sym3', ...
    'energy_bior33', 'average_dh_bior33', 'average_dv_bior33',...
    'energy_bior35', 'average_dh_bior35', 'average_dv_bior35',...
    'energy_bior37', 'average_dh_bior37', 'average_dv_bior37'});

T_caracteristicas_DETECCION.imagen = T_buenacalidad_revisadas.image;
T_caracteristicas_DETECCION.glaucoma = T_buenacalidad_revisadas.glaucoma;
writetable(T_caracteristicas_DETECCION, 'CaracteristicasDETECCIONGLAUCOMA.csv');