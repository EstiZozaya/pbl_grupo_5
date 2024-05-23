close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

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

gray_sin_vasos1 = adapthisteq(gray_sin_vasos);
canal_azul_sin_vasos1 = adapthisteq(canal_azul_sin_vasos);
canal_verde_sin_vasos1 = adapthisteq(canal_verde_sin_vasos);
canal_rojo_sin_vasos1 = adapthisteq(canal_rojo_sin_vasos);

e_gris1 = entropy(gray_sin_vasos1);
e_rojo1 = entropy(canal_rojo_sin_vasos1); 
e_verde1 = entropy(canal_verde_sin_vasos1);
e_azul1 = entropy(canal_azul_sin_vasos1);

if e_gris1 > 5 
    cup_threshold = 0.85 * max(gray_sin_vasos1(:)); % Umbral para la copa (brillo)
    
    cup_binary = gray_sin_vasos1 > cup_threshold; % Segmentación de la copa
else 
    cup_binary = ones(size(gray_sin_vasos));
end

if e_verde1 > 4.5 
    cup_thresholdG = 0.95 * max(canal_verde_sin_vasos1(:)); % Umbral para la copa (brillo)
  
    cup_binaryG = canal_verde_sin_vasos1 > cup_thresholdG; % Segmentación de la copa
else 
    cup_binaryG = ones(size(gray_sin_vasos));
end

if e_azul1 > 5.5 
    cup_thresholdB = 0.8 * max(canal_azul_sin_vasos1(:)); % Umbral para la copa (brillo)

    cup_binaryB = canal_azul_sin_vasos1 > cup_thresholdB; % Segmentación de la copa
else 
    cup_binaryB = ones(size(gray_sin_vasos));
end

% Operación lógica de intersección para la segmentación de la copa
cup_binary_comun = cup_binary & cup_binaryG & cup_binaryB;

copa = bwareafilt(cup_binary_comun, 1);
copa = imdilate(copa, se);

% [filaC, columnaC] = find(copa == max(copa(:)));
% % Calcula el centroide
% centroide_x = mean(columnaC);
% centroide_y = mean(filaC);
% centro_copa = [centroide_x, centroide_y]; 
% % Calcula el radio
% ancho_maximo = max(filaC) - min(filaC);
% alto_maximo = max(columnaC) - min(columnaC);
% radio_copa = max(ancho_maximo, alto_maximo) / 2;

carpeta_COPA = 'segmentacion_copa';
mkdir(carpeta_COPA);

nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_con_copa = ['COPA', nombre_imagen];
% Guardar la imagen en la carpeta
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_con_copa);
nombre_imagen_guardada = fullfile(carpeta_COPA, [nombre_sin_extension, extension]);
imwrite(copa, nombre_imagen_guardada);
end