close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

entropia = zeros(n,1);
entropiaR = zeros(n,1);
entropiaG = zeros(n,1);
entropiaB = zeros(n,1);
rango_dinamico= zeros(n, 1);
rango_dinamicoG= zeros(n, 1);
rango_dinamicoR= zeros(n, 1);
rango_dinamicoB= zeros(n, 1);
std_intensidad= zeros(n, 1);
var_intensidad= zeros(n, 1);
var_intensidadR= zeros(n, 1);
var_intensidadG= zeros(n, 1);
var_intensidadB= zeros(n, 1);
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
media = zeros(n, 1);
media_r = zeros(n, 1);
media_g = zeros(n, 1);
media_b = zeros(n, 1);
nitidez_borde = zeros(n, 1);
nitidez_bordeR = zeros(n, 1);
nitidez_bordeG = zeros(n, 1);
nitidez_bordeB = zeros(n, 1);
energy_cA = zeros(n, 1);
energy_cH = zeros(n, 1);
energy_cV = zeros(n, 1);
energy_cD = zeros(n, 1);
contrast_red = zeros(n, 1);
homogeneity_red = zeros(n, 1);
correlation_red = zeros(n, 1);
entropy_red = zeros(n, 1);
energy_red = zeros(n, 1);
contrast_green = zeros(n, 1);
homogeneity_green = zeros(n, 1);
correlation_green = zeros(n, 1);
entropy_green = zeros(n, 1);
energy_green = zeros(n, 1);
contrast_blue = zeros(n, 1);
homogeneity_blue = zeros(n, 1);
correlation_blue = zeros(n, 1);
entropy_blue = zeros(n, 1);
energy_blue = zeros(n, 1);
contrast_gray = zeros(n, 1);
homogeneity_gray = zeros(n, 1);
correlation_gray = zeros(n, 1);
entropy_gray = zeros(n, 1);
energy_gray = zeros(n, 1);
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

entropiaNRR = zeros(n, 1);
varianzaNRR = zeros(n, 1);
stdNRR = zeros(n, 1);
energyNRR = zeros(n, 1);
mediaNRR = zeros(n, 1);
entropiaNRR_HSV = zeros(n, 1);
varianzaNRR_HSV = zeros(n, 1);
stdNRR_HSV = zeros(n, 1);
energyNRR_HSV = zeros(n, 1);
mediaNRR_HSV = zeros(n, 1);

filtro_laplace=[1, 1, 1; 1, -8, 1; 1, 1, 1];

for i=1:n
copa = imread(['COPA2', T_buenacalidad_revisadas.image{i}]);
disco = imread(['DISCO5', T_buenacalidad_revisadas.image{i}]);
roi = imread(['ROI', T_buenacalidad_revisadas.image{i}]);

copa = imresize(copa, [300 300]);
disco = imresize(disco, [300 300]);
roi = imresize(roi, [300 300]);

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

entropiaNRR(i) = entropy(roi_NRR);
roi_NRR = double(roi_NRR);
varianzaNRR(i) = var(roi_NRR(:));
stdNRR(i) = std2(roi_NRR);
energyNRR(i) = sum(roi_NRR(:).^2);
mediaNRR(i) = mean(roi_NRR(:));

roi_NRR = rgb2hsv(roi_NRR);
entropiaNRR_HSV(i) = entropy(roi_NRR);
roi_NRR = double(roi_NRR);
varianzaNRR_HSV(i) = var(roi_NRR(:));
stdNRR_HSV(i) = std2(roi_NRR);
energyNRR_HSV(i) = sum(roi_NRR(:).^2);
mediaNRR_HSV(i) = mean(roi_NRR(:));

entropia(i) = entropy(roi);
entropiaR(i) = entropy(red_channel);
entropiaG(i) = entropy(green_channel);
entropiaB(i) = entropy(blue_channel);

I_gray = rgb2gray(roi);

glcm_red = graycomatrix(red_channel, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
    glcm_green = graycomatrix(green_channel, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
    glcm_blue = graycomatrix(blue_channel, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
    glcm_gray = graycomatrix(I_gray, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);

% Para el canal rojo
props_red = graycoprops(glcm_red);
contrast_red(i) = props_red.Contrast;
homogeneity_red(i) = props_red.Homogeneity;
correlation_red(i) = props_red.Correlation;
entropy_red(i) = entropy(red_channel);
energy_red(i) = sum(red_channel(:).^2);

% Para el canal verde
props_green = graycoprops(glcm_green);
contrast_green(i) = props_green.Contrast;
homogeneity_green(i) = props_green.Homogeneity;
correlation_green(i) = props_green.Correlation;
entropy_green(i) = entropy(green_channel);
energy_green(i) = sum(green_channel(:).^2);

% Para el canal azul
props_blue = graycoprops(glcm_blue);
contrast_blue(i) = props_blue.Contrast;
homogeneity_blue(i) = props_blue.Homogeneity;
correlation_blue(i) = props_blue.Correlation;
entropy_blue(i) = entropy(blue_channel);
energy_blue(i) = sum(blue_channel(:).^2);

% Para la imagen en escala de grises
props_gray = graycoprops(glcm_gray);
contrast_gray(i) = props_gray.Contrast;
homogeneity_gray(i) = props_gray.Homogeneity;
correlation_gray(i) = props_gray.Correlation;
entropy_gray(i) = entropy(I_gray);
energy_gray(i) = sum(I_gray(:).^2);

red_channel = double(red_channel);
green_channel = double(green_channel);
blue_channel = double(blue_channel);

I = double(rgb2gray(roi)); % damos por hecho que la imagen es de color (igual hacer un for para diferenciar)
media (i) = mean(roi(:));
media_g (i) = mean(green_channel(:));
media_b (i) = mean(blue_channel(:));
media_r (i) = mean(red_channel(:));

rango_dinamico(i)=max(I(:))-min(I(:));
rango_dinamicoR(i)=max(red_channel(:))-min(red_channel(:));
rango_dinamicoG(i)=max(green_channel(:))-min(green_channel(:));
rango_dinamicoB(i)=max(blue_channel(:))-min(blue_channel(:));
std_intensidad(i) = std2(I(:)); % desviación estandar
var_intensidad(i) =var(I(:)); % varianza
var_intensidadR(i) =var(red_channel(:)); % varianza
var_intensidadG(i) =var(green_channel(:)); % varianza
var_intensidadB(i) =var(blue_channel(:)); % varianza
I2=imfilter(roi, filtro_laplace);
nitidez_borde(i) = sum(abs(I2(:)));
I3=imfilter(red_channel, filtro_laplace);
nitidez_bordeR(i) = sum(abs(I3(:)));
I4=imfilter(green_channel, filtro_laplace);
nitidez_bordeG(i) = sum(abs(I4(:)));
I5=imfilter(blue_channel, filtro_laplace);
nitidez_bordeB(i) = sum(abs(I5(:)));

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
Inorm_img = im2double(I_gray);

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

T_caracteristicas_DETECCION = table(entropia, entropiaR, entropiaG, entropiaB, ...
    rango_dinamico, rango_dinamicoR, rango_dinamicoG, rango_dinamicoB, ...
    std_intensidad, var_intensidad, var_intensidadR, var_intensidadG, var_intensidadB, ...
    CDR, DDLS,NRR, dist1, dist2, dist3, dist4, radioD, radioC, centro1, centro2, ...
    media, media_r, media_g, media_b, nitidez_borde, nitidez_bordeR, nitidez_bordeG, nitidez_bordeB, ...
    contrast_red, homogeneity_red, correlation_red, entropy_red, energy_red, ...
    contrast_green, homogeneity_green, correlation_green, entropy_green, energy_green, ...
    contrast_blue, homogeneity_blue, correlation_blue, entropy_blue, energy_blue, ...
    contrast_gray, homogeneity_gray, correlation_gray, entropy_gray, energy_gray, ...
     energy_db3, average_dh_db3, average_dv_db3,...
    energy_sym3, average_dh_sym3, average_dv_sym3, ...
    energy_bior33, average_dh_bior33, average_dv_bior33,...
    energy_bior35, average_dh_bior35, average_dv_bior35,...
    energy_bior37, average_dh_bior37, average_dv_bior37,...
    entropiaNRR, varianzaNRR, stdNRR, energyNRR ,mediaNRR,...
      entropiaNRR_HSV, varianzaNRR_HSV, stdNRR_HSV, energyNRR_HSV ,mediaNRR_HSV,...
    'VariableNames', {'entropia', 'entropiaR', 'entropiaG', 'entropiaB', ...
    'rango_dinamico', 'rango_dinamicoR', 'rango_dinamicoG', 'rango_dinamicoB', ...
    'std_intensidad', 'var_intensidad', 'var_intensidadR', 'var_intensidadG', 'var_intensidadB', ...
    'CDR', 'DDLS', 'NRR','dist1', 'dist2', 'dist3', 'dist4', 'radioD', 'radioC', 'centro1', 'centro2', ...
    'media', 'media_r', 'media_g', 'media_b', 'nitidez_borde', 'nitidez_bordeR', 'nitidez_bordeG', 'nitidez_bordeB', ...
    'contrast_red', 'homogeneity_red', 'correlation_red', 'entropy_red', 'energy_red', ...
    'contrast_green', 'homogeneity_green', 'correlation_green', 'entropy_green', 'energy_green', ...
    'contrast_blue', 'homogeneity_blue', 'correlation_blue', 'entropy_blue', 'energy_blue', ...
    'contrast_gray', 'homogeneity_gray', 'correlation_gray', 'entropy_gray', 'energy_gray' ...
    'energy_db3', 'average_dh_db3', 'average_dv_db3',...
    'energy_sym3', 'average_dh_sym3', 'average_dv_sym3', ...
    'energy_bior33', 'average_dh_bior33', 'average_dv_bior33',...
    'energy_bior35', 'average_dh_bior35', 'average_dv_bior35',...
    'energy_bior37', 'average_dh_bior37', 'average_dv_bior37', ...
    'entropiaNRR', 'varianzaNRR', 'stdNRR', 'energyNRR','mediaNRR',...
     'entropiaNRR_HSV', 'varianzaNRR_HSV', 'stdNRR_HSV', 'energyNRR_HSV','mediaNRR_HSV'});

T_caracteristicas_DETECCION.imagen = T_buenacalidad_revisadas.image;
T_caracteristicas_DETECCION.glaucoma = T_buenacalidad_revisadas.glaucoma;
writetable(T_caracteristicas_DETECCION, 'CaracteristicasDETECCION5.csv');

