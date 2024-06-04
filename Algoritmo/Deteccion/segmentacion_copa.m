close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

for i=1:n
roi = imread(['ROI', T_buenacalidad_revisadas.image{i}]);

red_channel = roi(:, :, 1);
green_channel = roi(:, :, 2);
blue_channel = roi(:, :, 3);
I_gray = rgb2gray(roi);

se = strel('disk', 250);
% Estimar el fondo usando la apertura morfológica para cada canal
background_red = imopen(red_channel, se);
background_green = imopen(green_channel, se);
background_blue = imopen(blue_channel, se);
background_gray = imopen(I_gray, se);

% Corregir la imagen restando el fondo y ajustando la intensidad
corrected_red = red_channel - background_red;
corrected_green = green_channel - background_green;
corrected_blue = blue_channel - background_blue;
corrected_gray = I_gray - background_gray;

% Asegurarse de que la imagen esté en el rango adecuado
corrected_red = mat2gray(corrected_red);
corrected_green = mat2gray(corrected_green);
corrected_blue = mat2gray(corrected_blue);
corrected_gray = mat2gray(corrected_gray);

red_channel = corrected_red;
green_channel= corrected_green;
blue_channel = corrected_blue;
I_gray = corrected_gray;

se = strel('disk', 15); 
canal_verde_sin_vasos = imclose(green_channel, se);
canal_rojo_sin_vasos = imclose(red_channel, se); %el canal rojo no tiene vasos
canal_azul_sin_vasos = imclose(blue_channel, se);
gray_sin_vasos = imclose (I_gray, se);

gray_sin_vasos2 = imadjust(gray_sin_vasos);
canal_azul_sin_vasos2 = imadjust(canal_azul_sin_vasos);
canal_verde_sin_vasos2 = imadjust(canal_verde_sin_vasos);
canal_rojo_sin_vasos2 = imadjust(red_channel);

se = strel('disk', 40); 
canal_verde_sin_vasos2 = imclose(canal_verde_sin_vasos2, se);
canal_rojo_sin_vasos2 = imclose(canal_rojo_sin_vasos2, se); %el canal rojo no tiene vasos
canal_azul_sin_vasos2 = imclose(canal_azul_sin_vasos2, se);
gray_sin_vasos2 = imclose (gray_sin_vasos2,se);

e_gris2 = entropy(gray_sin_vasos2);
e_rojo2 = entropy(canal_rojo_sin_vasos2);  % 5 bien
e_verde2 = entropy(canal_verde_sin_vasos2);
e_azul2 = entropy(canal_azul_sin_vasos2);

e_gris = entropy(rgb2gray(roi));
e_rojo = entropy(roi(:,:,1));  % 5 bien
e_verde = entropy(roi(:,:,2));
e_azul = entropy(roi(:,:,3));

T_gris = graythresh(gray_sin_vasos2);
cup_threshold = 0.9 * max(gray_sin_vasos2(:)); 
cup_binary = gray_sin_vasos2 > cup_threshold; 
% cup_binary = activecontour(canal_verde_sin_vasos2, cup_binary, 200);

T_verde = graythresh(canal_verde_sin_vasos2);
cup_thresholdG = 0.9 * max(canal_verde_sin_vasos2(:)); 
cup_binaryG = canal_verde_sin_vasos2 > cup_thresholdG; 
cup_binaryG = activecontour(canal_verde_sin_vasos2, cup_binaryG, 200);

if e_azul >= 5
    T_azul = graythresh(canal_azul_sin_vasos2);
    cup_thresholdB = 0.9 * max(canal_azul_sin_vasos2(:)); 
    cup_binaryB = canal_azul_sin_vasos2 > cup_thresholdB; 
    cup_binaryB = activecontour(canal_verde_sin_vasos2, cup_binaryB, 200);
else
     cup_binaryB = ones(size(gray_sin_vasos));
end
% Operación lógica de intersección para la segmentación del disco
cup_binary_comun = cup_binary & cup_binaryG  & cup_binaryB;

se = strel('disk', 5);
copa = imerode(cup_binary_comun, se);
copa = bwareafilt(copa, 1);
se = strel('disk', 10);
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

carpeta_COPA = 'segmentacion_copa2';
mkdir(carpeta_COPA);

nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_con_copa = ['COPA2', nombre_imagen];
% Guardar la imagen en la carpeta
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_con_copa);
nombre_imagen_guardada = fullfile(carpeta_COPA, [nombre_sin_extension, extension]);
imwrite(copa, nombre_imagen_guardada);
end