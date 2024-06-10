% CODIGO EMPLEADO PARA SEGMENTAR LOS DISCOS DE TODAS LAS IMAGENES DEL CONJUNTO DE DATOS
% QUE LUEGO SE USAN PARA ELABORAR EL MODELO DE DETECCIÓN 

close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

for i=1:n
roi = imread(['ROI', T_buenacalidad_revisadas.image{i}]);

entropia = entropy(roi);

red_channel = roi(:, :, 1);
green_channel = roi(:, :, 2);
blue_channel = roi(:, :, 3);
I_gray = rgb2gray(roi);
I_GRIS = rgb2gray(roi);

se = strel('disk', 15); 
canal_verde_sin_vasos = imclose(green_channel, se);
canal_rojo_sin_vasos = imclose(red_channel, se); %el canal rojo no tiene vasos
canal_azul_sin_vasos = imclose(blue_channel, se);
gray_sin_vasos = imclose (I_gray, se);

canal_verde_sin_vasos = imgaussfilt(canal_verde_sin_vasos, 10);
canal_rojo_sin_vasos = imgaussfilt(canal_rojo_sin_vasos, 10);
canal_azul_sin_vasos = imgaussfilt(canal_azul_sin_vasos, 10);
gray_sin_vasos = imgaussfilt(gray_sin_vasos, 10);

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

e_gris = ceil(e_gris2);
e_rojo = ceil(e_rojo2);  % 5 bien
e_verde = ceil(e_verde2);
e_azul = ceil(e_azul2);

if e_rojo >= e_verde && e_rojo2 > 4.5 && e_rojo < e_azul
    if e_rojo >= 6
        disc_thresholdR = 0.9 * max(canal_rojo_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
        disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
    else
        disc_thresholdR = 0.7 * max(canal_rojo_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
        disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
        disc_binaryR = activecontour(canal_rojo_sin_vasos2, disc_binaryR, 200);
    end
% elseif e_rojo >= e_gris && e_rojo2 > 4.5 && e_rojo <= e_verde
%     disc_thresholdR = 0.95 * max(canal_rojo_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
%     disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
% %     disc_binaryR = activecontour(canal_rojo_sin_vasos2, disc_binaryR, 200);
elseif e_rojo2 > 5 
    disc_thresholdR = 0.95 * max(canal_rojo_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
    disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
    if e_rojo > e_gris && e_rojo > e_verde %PARA QUE LAS IMAGENES ROJAS FUNCIONEN
        disc_binaryR = activecontour(canal_rojo_sin_vasos2, disc_binaryR, 200);
    end
else 
    disc_binaryR = ones(size(gray_sin_vasos));
    disc_thresholdR = 0;
end

if e_gris > e_verde && disc_thresholdR == 0 
    %1555 mal
    disc_threshold = 0.6 * max(gray_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
    disc_binary = gray_sin_vasos2 > disc_threshold; % Segmentación del disco completo
    disc_binary = activecontour(gray_sin_vasos2, disc_binary, 200);
else 
    disc_binary = ones(size(gray_sin_vasos)); %imagen blanca pq luego se juntan los canales
    disc_threshold = 0; 
end

if e_verde > e_rojo && e_gris > e_rojo && e_azul <= 6 || e_rojo2 < 3
    disc_thresholdG = 0.4 * max(canal_verde_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
    if e_verde >= 7
        disc_thresholdG = 0.5 * max(canal_verde_sin_vasos2(:)); 
    elseif e_rojo >= 6
        disc_thresholdG = 0.4 * max(canal_verde_sin_vasos2(:)); 
    end
    if e_rojo2 < 4.5 && e_verde2 <  e_azul2
        disc_thresholdG = 0.8 * max(canal_azul_sin_vasos2(:));
    end
    disc_binaryG = canal_verde_sin_vasos2 > disc_thresholdG; % Segmentación del disco completo
%     if e_rojo2 < 4.5
%         disc_binaryG = activecontour(canal_verde_sin_vasos2, disc_binaryG, 200);
%     end
else 
    disc_binaryG = ones(size(gray_sin_vasos));
    disc_thresholdG = 0; 
end

if e_azul > e_verde && disc_thresholdR == 0 || e_azul >= 5 && disc_threshold == 0 && e_rojo2 < 5.5 %% && disc_thresholdR ~= 0 
    disc_thresholdB = 0.4 * max(canal_azul_sin_vasos2(:));
    if e_azul >= 6
        disc_thresholdB = 0.7 * max(canal_azul_sin_vasos2(:));
    elseif e_azul2 <= 4.5 && e_azul <= e_verde && e_azul >= 5 || e_rojo2 < 4.5 && e_azul > 5 ||  entropia < 6.5 && e_azul >= 5
        disc_thresholdB = 0.85 * max(canal_azul_sin_vasos2(:));
    end
    disc_binaryB = canal_azul_sin_vasos2 > disc_thresholdB; % Segmentación del disco completo
    if e_rojo2 < 4 
        disc_binaryB = activecontour(canal_verde_sin_vasos2, disc_binaryB, 200);
    end
    
% %      disc_binaryB = activecontour(canal_verde_sin_vasos2, disc_binaryB, 200);
else 
    disc_binaryB = ones(size(gray_sin_vasos));
end

% Operación lógica de intersección para la segmentación del disco 
disc_binary_comun = disc_binary & disc_binaryR & disc_binaryG  & disc_binaryB; %juntar los canales

% si la imagen se queda blanca (por si los otros if ninguno sirve)
if disc_binary_comun(:) == 1
    if e_rojo >= 5
        if e_rojo >= 6
            disc_thresholdR = 0.9 * max(canal_rojo_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
        else
            disc_thresholdR = 0.8 * max(canal_rojo_sin_vasos2(:)); % Umbral para el disco completo (menos brillo)
        end
        disc_binary_comun = canal_rojo_sin_vasos2 > disc_thresholdR; 
%         if e_rojo2 < 4.75
            disc_binary_comun = activecontour(canal_rojo_sin_vasos2, disc_binary_comun, 200);
%         end
    else
        disc_threshold = 0.6 * max(gray_sin_vasos2(:));
        disc_binary = gray_sin_vasos2 > disc_threshold;
        disc_binary = activecontour(canal_verde_sin_vasos2, disc_binary, 200);

        disc_thresholdG = 0.6 * max(canal_verde_sin_vasos2(:)); 
        disc_binaryG = canal_verde_sin_vasos2 > disc_thresholdG;
%         disc_binaryG = activecontour(canal_verde_sin_vasos2, disc_binaryG, 200);

        disc_thresholdB = 0.7 * max(canal_azul_sin_vasos2(:)); 
        disc_binaryB = canal_azul_sin_vasos2 > disc_thresholdB;
        disc_binaryB = activecontour(canal_verde_sin_vasos2, disc_binaryB, 200);
    
        disc_binary_comun = disc_binary & disc_binaryG & disc_binaryB;
    end
end

se = strel('disk', 30);
disco = imerode(disc_binary_comun, se);
disco = bwareafilt(disco, 1);
% se = strel('disk', 30);
disco = imdilate(disco, se);
disco = imfill(disco, "holes");


carpeta_DISCO = 'segmentacion_disco6';
mkdir(carpeta_DISCO);

nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_con_disco = ['DISCO6', nombre_imagen];
% Guardar la imagen en la carpeta
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_con_disco);
nombre_imagen_guardada = fullfile(carpeta_DISCO, [nombre_sin_extension, extension]);
imwrite(disco, nombre_imagen_guardada);
end