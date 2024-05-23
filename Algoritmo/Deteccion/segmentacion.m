close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

for i=1:n
copa = imread(['COPA', T_buenacalidad_revisadas.image{i}]);
disco = imread(['DISCO', T_buenacalidad_revisadas.image{i}]);

copa = imcomplement(copa);

segm = xor(disco, copa);

carpeta_SEGMENTACION = 'segmentacion';
mkdir(carpeta_SEGMENTACION);

nombre_imagen = T_buenacalidad_revisadas.image{i};
nombre_imagen_segmentacion = ['SEG', nombre_imagen];
% Guardar la imagen en la carpeta
[~, nombre_sin_extension, extension] = fileparts(nombre_imagen_segmentacion);
nombre_imagen_guardada = fullfile(carpeta_SEGMENTACION, [nombre_sin_extension, extension]);
imwrite(segm, nombre_imagen_guardada);
end