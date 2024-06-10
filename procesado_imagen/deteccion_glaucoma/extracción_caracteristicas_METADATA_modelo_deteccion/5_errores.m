% CODIGO EMPLEADO PARA DESCARTAR AUTOMATICAMENTE LAS IMAGENES SEGMENTADAS CON ALGUN ERROR
% Y DE ESTA MANERA NO USARLAS PARA LA ELABORACIÓN DEL MODELO

close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv'); % leer todas las imagenes clasificadas como buena calidad
[n, m] = size(T_buenacalidad_revisadas);
error_disco = zeros (n, 1);
error = zeros (n, 1);
error_copa = zeros (n, 1);
error_disco2 = zeros (n, 1);
error_disco3 = zeros (n, 1);

for i=1:n
copa = imread(['COPA2', T_buenacalidad_revisadas.image{i}]); % cargar las imagenes segmentadas de la copa
disco = imread(['DISCO5', T_buenacalidad_revisadas.image{i}]); % cargar las imagenes segmentadas del disco

[filaD, columnaD] = find(disco == max(disco(:)));
% Calcula el centroide disco
centroide_x = mean(columnaD);
centroide_y = mean(filaD);
centro_disco = [centroide_x, centroide_y]; 
% Calcula el radio disco
ancho_maximoD = max(filaD) - min(filaD);
alto_maximoD = max(columnaD) - min(columnaD);
radio_disco = max(ancho_maximoD, alto_maximoD) / 2; 

[filaC, columnaC] = find(copa == max(copa(:)));
% Calcula el centroide copa
centroide_x = mean(columnaC);
centroide_y = mean(filaC);
centro_copa = [centroide_x, centroide_y]; 
% Calcula el radio copa
ancho_maximoC = max(filaC) - min(filaC);
alto_maximoC = max(columnaC) - min(columnaC);
radio_copa = max(ancho_maximoC, alto_maximoC) / 2;

% si esta toda la imagen negra/blanca es que no ha segmentado bien
if max(disco(:)) == min(disco(:)) 
    error_disco(i) = 1;
elseif ancho_maximoD > alto_maximoD*1.5
    error_disco(i) = 1;
elseif ancho_maximoD*1.5 < alto_maximoD
    error_disco(i) = 1;
else 
    error_disco(i) = 0;
end

[alto, ancho] = size(disco);

% el disco tiene que tener más o menos forma circular
% comparar las dimensiones de disco con ancho_maximoD y alto_maximoD
if ancho_maximoD > ancho - 50 || alto_maximoD > alto - 50
    error_disco2(i)= 1;
else
    error_disco2(i)= 0;
end

% el disco tiene que ser más grande que la copa
if radio_copa > radio_disco
    error_copa(i) = 1;
else
   error_copa(i) = 0;
end 

% el centro de la copa tiene que estar dentro del disco
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

% el radio del disco no puede ser 3 veces mayor que el de la copa
if radio_disco > radio_copa  * 3
     error_disco3(i) = 1;
else
    error_disco3(i)=0;
end 

end

% guardar los errores en el metadata
T_buenacalidad_revisadas.error_disco = error_disco;
T_buenacalidad_revisadas.error_disco2 = error_disco2;
T_buenacalidad_revisadas.error_disco3 = error_disco3;
T_buenacalidad_revisadas.error_copa = error_copa;
T_buenacalidad_revisadas.error_segmentacion = error;

writetable(T_buenacalidad_revisadas, 'T_buenacalidad_revisadas_ERRORES2.csv');