close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);
error_disco = zeros (n, 1);
error = zeros (n, 1);
error_copa = zeros (n, 1);

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

if max(disco(:)) == min(disco(:)) 
    error_disco(i) = 1;
% SI Imin == Imax entoces es que la imagen es toda blanca o toda negra ->
% NO SIRVE
elseif ancho_maximo > alto_maximo*2 
    error_disco(i) = 1;
elseif ancho_maximo*2 < alto_maximo
    error_disco(i) = 1;
else 
    error_disco(i) = 0;
end

if radio_copa > radio_disco
    error_copa(i) = 1;
else
   error_copa(i) = 0;
end 


if centro_copa(1) < (centro_disco(1) - radio_disco)  
     error(i) = 1;
elseif centro_copa(1) > (centro_disco(1) + radio_disco)
    error(i) = 1;
elseif centro_copa(2) < (centro_disco(2) - radio_disco)
      error(i) = 1;
elseif centro_copa(2) > (centro_disco(2) + radio_disco)
     error(i) = 1;
else
    error(i)=0;
end 

end

T_buenacalidad_revisadas.error_disco = error_disco;
T_buenacalidad_revisadas.error_copa = error_copa;
T_buenacalidad_revisadas.error_segmentacion = error;

writetable(T_buenacalidad_revisadas, 'T_buenacalidad_revisadas_ERRORES.csv');