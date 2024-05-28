close all; clc; clearvars;
T_metadata = readtable('metadata.csv');
T_buenacalidad_revisadas = T_metadata(T_metadata.quality == 4, :);

[n, m] = size(T_buenacalidad_revisadas);
entropia = zeros(n,1);
rango_dinamico= zeros(n, 1);
std_intensidad= zeros(n, 1);
var_intensidad= zeros(n, 1);
CDR = zeros(n, 1);
DDLS = zeros(n, 1);

for i=1:149
I = imread(T_buenacalidad_revisadas.image{i+60});
I_gray = rgb2gray(I);

I_borde = imbinarize(I_gray, 0.15);

% quitar los puntos blancos que aparecen fuera del ciruclo
se = strel('disk', 15);
I_borde = imerode(I_borde, se);

I = im2double(I);
I(:, :, 1) = I(:, :, 1) .* I_borde;
I(:, :, 2) = I(:, :, 2) .* I_borde;
I(:, :, 3) = I(:, :, 3) .* I_borde;

I = im2uint8(I);

% OSCURECER BORDES 
se = strel('disk', 100); 
bordes = imerode(I_borde, se); 
I_gray_oscura = I_gray * 0;
I_gray_oscura(bordes) = I_gray(bordes);

I_gray_oscura = adapthisteq(I_gray_oscura);

[max_fila, max_columna] = find(I_gray_oscura == max(I_gray_oscura(:)));
centroide_x = mean(max_fila);
centroide_y = mean(max_columna);

s = size(I_gray_oscura);
tamano_roi = min(s)/2;

inicio_x = max(1, round(centroide_x - tamano_roi/2));
fin_x = min(size(I_gray, 1), round(centroide_x + tamano_roi/2));
inicio_y = max(1, round(centroide_y - tamano_roi/2));
fin_y = min(size(I_gray, 2), round(centroide_y + tamano_roi/2));

roi = I(inicio_x:fin_x, inicio_y:fin_y, :);

red_channel = roi(:, :, 1);
green_channel = roi(:, :, 2);
blue_channel = roi(:, :, 3);
I_gray = rgb2gray(roi);

se = strel('disk', 30); 

canal_verde_sin_vasos = imclose(green_channel, se);
% canal_rojo_sin_vasos = imclose(red_channel, se); el canal rojo no tiene vasos
canal_azul_sin_vasos = imclose(blue_channel, se);
gray_sin_vasos = imclose (I_gray, se);

gray_sin_vasos1 = adapthisteq(gray_sin_vasos);
canal_azul_sin_vasos1 = adapthisteq(canal_azul_sin_vasos);
canal_verde_sin_vasos1 = adapthisteq(canal_verde_sin_vasos);
red_channel1 = adapthisteq(red_channel);

gray_sin_vasos2 = histeq(gray_sin_vasos);
canal_azul_sin_vasos2 = histeq(canal_azul_sin_vasos);
canal_verde_sin_vasos2 = histeq(canal_verde_sin_vasos);
red_channel2 = histeq(red_channel);

gray_sin_vasos3 = imadjust(gray_sin_vasos);
canal_azul_sin_vasos3 = imadjust(canal_azul_sin_vasos);
canal_verde_sin_vasos3 = imadjust(canal_verde_sin_vasos);
red_channel3 = imadjust(red_channel);

e_gris = entropy(I_gray);
e_rojo = entropy(red_channel); % si es mas de 6 bien
e_verde = entropy(green_channel);
e_azul = entropy(blue_channel); % si es menos de 4 -> no usar

if e_gris > 5 && e_gris < 6 
    cup_threshold = 0.85 * max(gray_sin_vasos1(:)); % Umbral para la copa (brillo)
    disc_threshold = 0.95 * max(gray_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)

    cup_binary = gray_sin_vasos1 > cup_threshold; % Segmentación de la copa
    disc_binary = gray_sin_vasos2 > disc_threshold; % Segmentación del disco completo
else 
    cup_binary = ones(size(gray_sin_vasos));
    disc_binary = ones(size(gray_sin_vasos));
end

if e_rojo > 5.5
    cup_thresholdR = 0 * max(red_channel1(:)); % Umbral para la copa (brillo)
    disc_thresholdR = 0.95 * max(red_channel2(:)); % Umbral para el disco completo (menos brillo)

    cup_binaryR = red_channel1 > cup_thresholdR; % Segmentación de la copa
    disc_binaryR = red_channel2 > disc_thresholdR; % Segmentación del disco completo
else 
    cup_binaryR = ones(size(gray_sin_vasos));
    disc_binaryR = ones(size(gray_sin_vasos));
end

if e_verde > 4.5
    cup_thresholdG = 0.85 * max(canal_verde_sin_vasos1(:)); % Umbral para la copa (brillo)
    disc_thresholdG = 0.9 * max(canal_verde_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
    
    cup_binaryG = canal_verde_sin_vasos1 > cup_thresholdG; % Segmentación de la copa
    disc_binaryG = canal_verde_sin_vasos2 > disc_thresholdG; % Segmentación del disco completo
else 
    cup_binaryG = ones(size(gray_sin_vasos));
    disc_binaryG = ones(size(gray_sin_vasos));
end

if e_azul > 4.5 && e_azul < 6
    cup_thresholdB = 0.8 * max(canal_azul_sin_vasos1(:)); % Umbral para la copa (brillo)
    disc_thresholdB = 0.9 * max(canal_azul_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
    
    cup_binaryB = canal_azul_sin_vasos1 > cup_thresholdB; % Segmentación de la copa
    disc_binaryB = canal_azul_sin_vasos2 > disc_thresholdB; % Segmentación del disco completo
else 
    cup_binaryB = ones(size(gray_sin_vasos));
    disc_binaryB = ones(size(gray_sin_vasos));
end

% Operación lógica de intersección para la segmentación de la copa
cup_binary_comun = cup_binary & cup_binaryR & cup_binaryG & cup_binaryB;

se = strel('disk', 10);
disc_binaryR = imdilate(disc_binaryR, se);
% Operación lógica de intersección para la segmentación del disco
disc_binary_comun = disc_binary & disc_binaryR & disc_binaryG  & disc_binaryB;

se = strel('disk', 15);
disco = imerode(disc_binary_comun, se);
disco = bwareafilt(disco, 1);
disco = imdilate(disco, se);
copa = bwareafilt(cup_binary_comun, 1);
copa = imdilate(copa, se);

[fila, columna] = find(disco == max(disco(:)));
% Calcula el centroide
centroide_x = mean(columna);
centroide_y = mean(fila);
centro_disco = [centroide_x, centroide_y]; 
% Calcula el radio
ancho_maximo = max(fila) - min(fila);
alto_maximo = max(columna) - min(columna);
radio_disco = max(ancho_maximo, alto_maximo) / 2;

[fila, columna] = find(copa == max(copa(:)));
% Calcula el centroide
centroide_x = mean(columna);
centroide_y = mean(fila);
centro_copa = [centroide_x, centroide_y]; 
% Calcula el radio
ancho_maximo = max(fila) - min(fila);
alto_maximo = max(columna) - min(columna);
radio_copa = max(ancho_maximo, alto_maximo) / 2;

entropia(i) = entropy(roi);

I = double(rgb2gray(roi)); % damos por hecho que la imagen es de color (igual hacer un for para diferenciar)

rango_dinamico(i)=max(I(:))-min(I(:));
std_intensidad(i) = std2(I(:)); % desviación estandar
var_intensidad(i) =var(I(:)); % varianza

CDR(i)=radio_disco/radio_copa;

RIM = radio_disco-radio_copa;
DDLS(i) = RIM/radio_disco;
end

T_caracteristicas_DETECCION = table(entropia, rango_dinamico, std_intensidad, var_intensidad, CDR, DDLS, 'VariableNames', {'entropia', 'rango_dinamico', 'std_intensidad', 'var_intensidad', 'CDR', 'DDLS'});
variables=T_caracteristicas.Properties.VariableNames;

T_caracteristicas_DETECCION.imagen = T_buenacalidad_revisadas.image;
writetable(T_caracteristicas_DETECCION, 'CaracteristicasDETECCION.csv');