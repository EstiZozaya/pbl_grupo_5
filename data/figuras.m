close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

for i=1:n
copa = imread(['COPA', T_buenacalidad_revisadas.image{i}]);
disco = imread(['DISCO4', T_buenacalidad_revisadas.image{i}]);
roi = imread(['ROI', T_buenacalidad_revisadas.image{i}]);

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

% figure; imshow(roi); title(T_buenacalidad_revisadas.image{i});
% hold on;
% viscircles(centro_disco, radio_disco, 'EdgeColor', 'r', 'LineWidth', 2);
% viscircles(centro_copa, radio_copa, 'EdgeColor', 'b', 'LineWidth', 2);
% hold off
figure ('Position', [0 0 1400 500]);
subplot(1,4,1); imshow(roi); title('ROI')
subplot(1,4,2); imshow(roi); title('DISCO')
hold on;
[B, L] = bwboundaries(disco, 'noholes');
for k = 1:length(B)
    boundary = B{k};
    fill(boundary(:,2), boundary(:,1), 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
end
hold off;

% Capturar la imagen de la figura actual
subplot(1,4,3); imshow(roi); title('COPA')
hold on;
[B, L] = bwboundaries(copa, 'noholes');
for k = 1:length(B)
    boundary = B{k};
    fill(boundary(:,2), boundary(:,1), 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
end
hold off;

imagen_con_circulos = insertShape(roi, 'Circle', [centro_disco, radio_disco], 'Color', 'red', 'LineWidth', 4);
imagen_con_circulos = insertShape(imagen_con_circulos, 'Circle', [centro_copa, radio_copa], 'Color', 'blue', 'LineWidth', 4);
subplot(1,4,4); imshow(imagen_con_circulos); title('COPA Y DISCO')

frame_2 = getframe(gcf);
    figuraTODO = frame_2.cdata;

% Crear la carpeta 'segmentacion' si no existe
carpeta_SEGMENTACION = 'segmentacion_TODO';
mkdir(carpeta_SEGMENTACION);

% Obtener el nombre de la imagen y generar el nuevo nombre para la imagen segmentada
nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_segmentacion = ['FIGURA', nombre_imagen];
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_segmentacion);
nombre_imagen_guardada = fullfile(carpeta_SEGMENTACION, [nombre_sin_extension, extension]); 

% Guardar la imagen resultante
imwrite(figuraTODO, nombre_imagen_guardada);
close(gcf);
end