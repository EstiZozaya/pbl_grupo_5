% EXTRACCIÓN CARACTERISTICAS
function T_caracteristicas_DETECCION = funcion_caracteristicas_deteccion(copa, disco, roi)
copa = imresize(copa, [300 300]);
disco = imresize(disco, [300 300]);
roi = imresize(roi, [300 300]);
roiHSV = rgb2hsv(roi);

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
roi_gris = rgb2gray(roi);

copaR = imcomplement(copa);
if radio_copa < radio_disco
    segm = xor(disco, copaR);
    segm = imcomplement(segm);
else
   segm = disco;
end 

red_channel_NRR = red_channel * 0;
red_channel_NRR(segm) = red_channel(segm);
green_channel_NRR = green_channel * 0;
green_channel_NRR(segm) = green_channel(segm);
blue_channel_NRR = blue_channel * 0;
blue_channel_NRR(segm) = blue_channel(segm);

roi_NRR(:, :, 1)= red_channel_NRR;
roi_NRR(:, :, 2)=green_channel_NRR;
roi_NRR(:, :, 3) =blue_channel_NRR;

entropiaRGB = entropy(roi);
entropiaHSV = entropy(roiHSV);
entropiaR = entropy(red_channel);
entropiaG = entropy(green_channel);
entropiaB = entropy(blue_channel);
entropiaNRR = entropy(roi_NRR);

roi = double(roi);
roiHSV = double(roiHSV);
roi_gris = double(roi_gris);
red_channel = double(red_channel);
green_channel = double(green_channel);
blue_channel = double(blue_channel);
roi_NRR = double(roi_NRR);

rango_dinamicoRGB= max(roi(:))-min(roi(:));
rango_dinamicoHSV = max(roiHSV(:))-min(roiHSV(:));
rango_dinamicoR = max(red_channel(:))-min(red_channel(:));
rango_dinamicoNRR = max(roi_NRR(:))-min(roi_NRR(:));

varianzaGris = var(roi_gris(:));
varianzaG = var(red_channel(:));
varianzaR = var(green_channel(:));
varianzaB = var(blue_channel(:));
varianzaNRR = var(roi_NRR(:));

mediaRGB = mean(roi(:));
mediaHSV = mean(roiHSV(:));
mediaG = mean(red_channel(:));
mediaR= mean(green_channel(:));
mediaB = mean(blue_channel(:));

roi_NRR=rgb2gray(roi_NRR);
glcm_NRR = graycomatrix(roi_NRR, 'NumLevels', 256, 'Offset', [0 1], 'Symmetric', true);
props_NRR = graycoprops(glcm_NRR);
correlation_NRR = props_NRR.Correlation;

CDR=radio_disco/radio_copa;

Inorm_img = im2double(roi_gris);

filters = {'bior3.3'};
filters_names = {'bior33'};

averageDh = struct();
averageDv = struct();
energy = struct();

% Aplicar DWT y calcular las características para cada filtro
for j = 1:length(filters)
    filter = filters{j};
    filter_name = filters_names{j};
    % Aplicar la DWT
    [cA, cH, cV, cD] = dwt2(Inorm_img, filter);
    
    % Calcular el promedio de los coeficientes de detalle horizontal (Dh)
    averageDh.(filter_name) = mean(cH(:));
    
    % Calcular el promedio de los coeficientes de detalle vertical (Dv)
    averageDv.(filter_name) = mean(cV(:));
    
    % Calcular la energía de los coeficientes
    [p, q] = size(cV);
    energy.(filter_name) = sum(cV(:).^2) / (p^2 + q^2);
end

average_dh_bior33 = averageDh.bior33;
average_dv_bior33= averageDv.bior33;
energy_bior33 = energy.bior33;


T_caracteristicas_DETECCION = table(entropiaRGB, entropiaHSV, entropiaR, entropiaG, entropiaB, entropiaNRR, ...
    rango_dinamicoRGB, rango_dinamicoHSV, rango_dinamicoR, rango_dinamicoNRR, ...
    varianzaGris, varianzaR, varianzaG, varianzaB, varianzaNRR, ...
    mediaRGB, mediaHSV, mediaR, mediaG, mediaB,  ...
    correlation_NRR, CDR,...
    energy_bior33, average_dh_bior33, average_dv_bior33,...
    'VariableNames', {'entropiaRGB', 'entropiaHSV', 'entropiaR', 'entropiaG', 'entropiaB', 'entropiaNRR', ...
    'rango_dinamicoRGB', 'rango_dinamicoHSV', 'rango_dinamicoR', 'rango_dinamicoNRR', ...
    'varianzaGris', 'varianzaR', 'varianzaG', 'varianzaB', 'varianzaNRR', ...
    'mediaRGB', 'mediaHSV', 'mediaR', 'mediaG', 'mediaB', ...
    'correlation_NRR', 'CDR', ...
    'energy_bior33', 'average_dh_bior33', 'average_dv_bior33'});

% T_caracteristicas_DETECCION.imagen = T_buenacalidad_revisadas.image;
% T_caracteristicas_DETECCION.glaucoma = T_buenacalidad_revisadas.glaucoma;
writetable(T_caracteristicas_DETECCION, 'CaracteristicasDETECCIONGLAUCOMA_APP.csv');
end