close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);
error = zeros (n, 1);
for i=1:n
copa = imread(['COPA', T_buenacalidad_revisadas.image{i}]);
disco = imread(['DISCO', T_buenacalidad_revisadas.image{i}]);

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

copa = imcomplement(copa);

if radio_copa < radio_disco
    segm = xor(disco, copa);
    segm = imcomplement(segm);
else
   segm = disco;
end 

se = strel('disk', 5);
segm = imdilate(segm, se);

carpeta_SEGMENTACION = 'segmentacion';
mkdir(carpeta_SEGMENTACION);

nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_segmentacion = ['SEG', nombre_imagen];
% Guardar la imagen en la carpeta
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_segmentacion);
nombre_imagen_guardada = fullfile(carpeta_SEGMENTACION, [nombre_sin_extension, extension]);
imwrite(segm, nombre_imagen_guardada);
end