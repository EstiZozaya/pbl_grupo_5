close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

error = zeros (n, 1);
for i=1:n
roi = imread(['ROI', T_buenacalidad_revisadas.image{i}]);

red_channel = roi(:, :, 1);
green_channel = roi(:, :, 2);
blue_channel = roi(:, :, 3);
I_gray = rgb2gray(roi);

se = strel('disk', 30); 

canal_verde_sin_vasos = imclose(green_channel, se);
canal_rojo_sin_vasos = imclose(red_channel, se); %el canal rojo no tiene vasos
canal_azul_sin_vasos = imclose(blue_channel, se);
gray_sin_vasos = imclose (I_gray, se);

gray_sin_vasos2 = histeq(gray_sin_vasos);
canal_azul_sin_vasos2 = histeq(canal_azul_sin_vasos);
canal_verde_sin_vasos2 = histeq(canal_verde_sin_vasos);
canal_rojo_sin_vasos2 = histeq(canal_rojo_sin_vasos);

e_gris2 = entropy(gray_sin_vasos2);
e_rojo2 = entropy(canal_rojo_sin_vasos2); 
e_verde2 = entropy(canal_verde_sin_vasos2);
e_azul2 = entropy(canal_azul_sin_vasos2);

if e_gris2 > 5 
    disc_threshold = 0.8 * max(gray_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)

    disc_binary = gray_sin_vasos2 > disc_threshold; % Segmentación del disco completo
else 
    disc_binary = ones(size(gray_sin_vasos));
end

if e_rojo2 > 6
    disc_thresholdR = 0.95 * max(canal_rojo_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)

    disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR; % Segmentación del disco completo
else 
    disc_binaryR = ones(size(gray_sin_vasos));
end

if e_verde2 > 5
    disc_thresholdG = 0.8 * max(canal_verde_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
    
    disc_binaryG = canal_verde_sin_vasos2 > disc_thresholdG; % Segmentación del disco completo
else 
    disc_binaryG = ones(size(gray_sin_vasos));
end

if e_azul2 > 4 
    disc_thresholdB = 0.9 * max(canal_azul_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
    
    disc_binaryB = canal_azul_sin_vasos2 > disc_thresholdB; % Segmentación del disco completo
else 
    disc_binaryB = ones(size(gray_sin_vasos));
end

% Operación lógica de intersección para la segmentación del disco
disc_binary_comun = disc_binary & disc_binaryR & disc_binaryG  & disc_binaryB;

se = strel('disk', 20);
disco = imerode(disc_binary_comun, se);
disco = bwareafilt(disco, 1);
se = strel('disk', 30);
disco = imdilate(disco, se);
disco = imfill(disco, "holes");

[filaD, columnaD] = find(disco == max(disco(:)));
% Calcula el centroide
centroide_x = mean(columnaD);
centroide_y = mean(filaD);
centro_disco = [centroide_x, centroide_y]; 
% Calcula el radio
ancho_maximo = max(filaD) - min(filaD);
alto_maximo = max(columnaD) - min(columnaD);
radio_disco = max(ancho_maximo, alto_maximo) / 2;

carpeta_DISCO = 'segmentacion_disco';
mkdir(carpeta_DISCO);

nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_con_disco = ['DISCO', nombre_imagen];
% Guardar la imagen en la carpeta
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_con_disco);
nombre_imagen_guardada = fullfile(carpeta_DISCO, [nombre_sin_extension, extension]);
imwrite(disco, nombre_imagen_guardada);


if max(disco(:)) == min(disco(:)) 
    error = 1;
% SI Imin == Imax entoces es que la imagen es toda blanca o toda negra ->
% NO SIRVE
elseif ancho_maximo > alto_maximo*2 
    error = 1;
elseif ancho_maximo*2 < alto_maximo
    error = 1;
else 
    error = 0;
end
end

T_buenacalidad_revisadas.error_disco = error;