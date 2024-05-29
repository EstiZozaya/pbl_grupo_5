close all; clc; clearvars;

T_buenacalidad_revisadas = readtable('metadataCALIDADCORRECTA.csv');
[n, m] = size(T_buenacalidad_revisadas);

entropia = zeros(n,1);
entropiaR = zeros(n,1);
entropiaG = zeros(n,1);
entropiaB = zeros(n,1);
rango_dinamico= zeros(n, 1);
rango_dinamicoG= zeros(n, 1);
rango_dinamicoR= zeros(n, 1);
rango_dinamicoB= zeros(n, 1);
std_intensidad= zeros(n, 1);
var_intensidad= zeros(n, 1);
var_intensidadR= zeros(n, 1);
var_intensidadG= zeros(n, 1);
var_intensidadB= zeros(n, 1);
CDR = zeros(n, 1);
DDLS = zeros(n, 1);
dist1 = zeros(n, 1);
dist2 = zeros(n, 1);
dist3 = zeros(n, 1);
dist4 = zeros(n, 1);
radioC = zeros(n, 1);
radioD = zeros(n, 1);
centro1 = zeros(n, 1);
centro2 = zeros(n, 1);
NRR_area_ratio = zeros(n, 1);
media = zeros(n, 1);
media_r = zeros(n, 1);
media_g = zeros(n, 1);
media_b = zeros(n, 1);
nitidez_borde = zeros(n, 1);
nitidez_bordeR = zeros(n, 1);
nitidez_bordeG = zeros(n, 1);
nitidez_bordeB = zeros(n, 1);

filtro_laplace=[1, 1, 1; 1, -8, 1; 1, 1, 1];

for i=1:n
copa = imread(['COPA', T_buenacalidad_revisadas.image{i}]);
disco = imread(['DISCO2', T_buenacalidad_revisadas.image{i}]);
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

red_channel = roi(:, :, 1);
green_channel = roi(:, :, 2);
blue_channel = roi(:, :, 3);
red_channel = double(red_channel);
green_channel = double(green_channel);
blue_channel = double(blue_channel);

entropia(i) = entropy(roi);
entropiaR(i) = entropy(red_channel);
entropiaG(i) = entropy(green_channel);
entropiaB(i) = entropy(blue_channel);

I = double(rgb2gray(roi)); % damos por hecho que la imagen es de color (igual hacer un for para diferenciar)
media (i) =mean(roi(:));
media_g (i) =mean(green_channel(:));
media_b (i) =mean(blue_channel(:));
media_r (i) =mean(red_channel(:));

rango_dinamico(i)=max(I(:))-min(I(:));
rango_dinamicoR(i)=max(red_channel(:))-min(red_channel(:));
rango_dinamicoG(i)=max(green_channel(:))-min(green_channel(:));
rango_dinamicoB(i)=max(blue_channel(:))-min(blue_channel(:));
std_intensidad(i) = std2(I(:)); % desviación estandar
var_intensidad(i) =var(I(:)); % varianza
var_intensidadR(i) =var(red_channel(:)); % varianza
var_intensidadG(i) =var(green_channel(:)); % varianza
var_intensidadB(i) =var(blue_channel(:)); % varianza
I2=imfilter(roi, filtro_laplace);
nitidez_borde(i) = sum(abs(I2(:)));
I3=imfilter(red_channel, filtro_laplace);
nitidez_bordeR(i) = sum(abs(I3(:)));
I4=imfilter(green_channel, filtro_laplace);
nitidez_bordeG(i) = sum(abs(I4(:)));
I5=imfilter(blue_channel, filtro_laplace);
nitidez_bordeB(i) = sum(abs(I5(:)));

CDR(i)=radio_disco/radio_copa;

RIM = radio_disco-radio_copa;
DDLS(i) = RIM/radio_disco;

dist1(i) = (centro_disco(1)-radio_disco)-(centro_copa(1)-radio_copa);
dist2(i) = (centro_disco(1)+radio_disco)-(centro_copa(1)+radio_copa);
dist3(i) = (centro_disco(2)-radio_disco)-(centro_copa(2)-radio_copa);
dist4(i) = (centro_disco(2)+radio_disco)-(centro_copa(2)+radio_copa);

radioC(i) = radio_copa;
radioD(i) = radio_disco;

centro1(i) = centro_disco(1) - centro_copa(1);
centro2(i) = centro_disco(2) - centro_copa(2);

% Create a meshgrid for the coordinates
[x, y] = meshgrid(1:size(disco, 2), 1:size(disco, 1));

% Calculate distances from the center
distX = x - centro_disco(1);
distY = y - centro_disco(2);

% Determine the quadrants
inferior = distY > 0; % Inferior quadrants (y > center_y)
superior = distY <= 0; % Superior quadrants (y <= center_y)
nasal = distX <= 0;    % Nasal quadrants (x <= center_x)
temporal = distX > 0;  % Temporal quadrants (x > center_x)

% Calculate areas in each quadrant for the disc
area_inferior_disc = sum(disco(inferior), 'all');
area_superior_disc = sum(disco(superior), 'all');
area_nasal_disc = sum(disco(nasal), 'all');
area_temporal_disc = sum(disco(temporal), 'all');

% Calculate areas in each quadrant for the cup
area_inferior_cup = sum(copa(inferior), 'all');
area_superior_cup = sum(copa(superior), 'all');
area_nasal_cup = sum(copa(nasal), 'all');
area_temporal_cup = sum(copa(temporal), 'all');

% Total areas in each region (disc - cup)
total_inferior = area_inferior_disc - area_inferior_cup;
total_superior = area_superior_disc - area_superior_cup;
total_nasal = area_nasal_disc - area_nasal_cup;
total_temporal = area_temporal_disc - area_temporal_cup;

% Calculate the NRR area ratio
NRR_area_ratio (i) = (total_inferior + total_superior) / (total_nasal + total_temporal);
end

T_caracteristicas_DETECCION = table(entropia, entropiaR, entropiaG, entropiaB, rango_dinamico, rango_dinamicoR, rango_dinamicoG,rango_dinamicoB, std_intensidad, var_intensidad, var_intensidadR, var_intensidadG, var_intensidadB, CDR, DDLS, dist1, dist2, dist3, dist4, radioD, radioC, centro1, centro2, NRR_area_ratio, media, media_r, media_g, media_b, nitidez_borde, nitidez_bordeR, nitidez_bordeG, nitidez_bordeB, 'VariableNames', {'entropia', 'entropiaR', 'entropiaG', 'entropiaB', 'rango_dinamico', 'rango_dinamicoR', 'rango_dinamicoG', 'rango_dinamicoB', 'std_intensidad', 'var_intensidad', 'var_intensidadR', 'var_intensidadG', 'var_intensidadB', 'CDR', 'DDLS', 'dist1', 'dist2', 'dist3', 'dist4', 'radioC', 'radioD', 'centro1', 'centro2','NRR_area_ratio', 'media', 'media_r', 'media_g', 'media_b', 'nitidez_borde', 'nitidez_bordeR', 'nitidez_bordeG', 'nitidez_bordeB'}); 

T_caracteristicas_DETECCION.imagen = T_buenacalidad_revisadas.image;
T_caracteristicas_DETECCION.glaucoma = T_buenacalidad_revisadas.glaucoma;
writetable(T_caracteristicas_DETECCION, 'CaracteristicasDETECCION.csv');
