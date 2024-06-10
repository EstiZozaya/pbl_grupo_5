close all; clc; clearvars;
T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

for i=1:n
I = imread(T_buenacalidad_revisadas.image{i});
I_gray = rgb2gray(I);
I_borde = imbinarize(I_gray, 0.1);

% OSCURECER BORDES + quitar los puntos blancos que aparecen fuera del ciruclo
se = strel('disk', 100); 
bordes = imerode(I_borde, se); 
I_gray_oscura = I_gray * 0;
I_gray_oscura(bordes) = I_gray(bordes);

I_gray_oscura = adapthisteq(I_gray_oscura);
I_gray_oscura = imgaussfilt(I_gray_oscura, 2);

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

carpeta_ROI = 'imagenes_ROI';
mkdir(carpeta_ROI);

nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_con_roi = ['ROI', nombre_imagen];
% Guardar la imagen en la carpeta
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_con_roi);
nombre_imagen_guardada = fullfile(carpeta_ROI, [nombre_sin_extension, extension]);
imwrite(roi, nombre_imagen_guardada);
end
