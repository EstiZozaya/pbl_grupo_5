close all; clc; clearvars;

roi = RecortarROI('image_0125.jpg');
[canal_verde_sin_vasos2,canal_rojo_sin_vasos2,canal_azul_sin_vasos2,gray_sin_vasos2] = Preprocesado_Segme(roi);
disco = segmentacion_disco(canal_verde_sin_vasos2,canal_rojo_sin_vasos2,canal_azul_sin_vasos2,gray_sin_vasos2);
copa = segmentacion_copa(canal_verde_sin_vasos2,canal_rojo_sin_vasos2,canal_azul_sin_vasos2,gray_sin_vasos2);
error = errores(disco, copa);
figura(roi, disco, copa);
T_caracteristicas_DETECCION = extraccion_caracteristicas(roi, disco, copa);
load modelo_final_deteccion_SVM.mat
glaucoma = modelo(T_caracteristicas_DETECCION, mdl_final_SVM);

function roi = RecortarROI(imagen)
    % Lee la imagen
    I = imread(imagen);
  
    % Convierte la imagen a escala de grises
    I_gray = rgb2gray(I);
    
    % Binariza la imagen
    I_borde = imbinarize(I_gray, 0.1);

    % Oscurece los bordes y elimina los puntos blancos que aparecen fuera del círculo
    se = strel('disk', 100); 
    bordes = imerode(I_borde, se); 
    I_gray_oscura = I_gray * 0;
    I_gray_oscura(bordes) = I_gray(bordes);

    % Mejora el contraste adaptativo de la imagen
    I_gray_oscura = adapthisteq(I_gray_oscura);
    
    % Aplica un filtro gaussiano
    I_gray_oscura = imgaussfilt(I_gray_oscura, 2);

    % Encuentra los puntos más brillantes en la imagen
    [max_fila, max_columna] = find(I_gray_oscura == max(I_gray_oscura(:)));
    centroide_x = mean(max_fila);
    centroide_y = mean(max_columna);

    % Determina el tamaño de la región de interés (ROI)
    s = size(I_gray_oscura);
    tamano_roi = min(s)/2;

    % Calcula las coordenadas del ROI
    inicio_x = max(1, round(centroide_x - tamano_roi/2));
    fin_x = min(size(I_gray, 1), round(centroide_x + tamano_roi/2));
    inicio_y = max(1, round(centroide_y - tamano_roi/2));
    fin_y = min(size(I_gray, 2), round(centroide_y + tamano_roi/2));

    % Extrae la región de interés (ROI) de la imagen original
    roi = I(inicio_x:fin_x, inicio_y:fin_y, :);
end

function [canal_verde_sin_vasos2,canal_rojo_sin_vasos2,canal_azul_sin_vasos2,gray_sin_vasos2]  = Preprocesado_Segme(roi)
    entropia = entropy(roi);
    
    % Separar canales y convertir imagen a blanco y negro
    red_channel = roi(:, :, 1);
    green_channel = roi(:, :, 2);
    blue_channel = roi(:, :, 3);
    I_gray = rgb2gray(roi);
    
    % Correción del fondo
    se = strel('disk', 250);
    % Estimar el fondo usando la apertura morfológica para cada canal
    background_red = imopen(red_channel, se);
    background_green = imopen(green_channel, se);
    background_blue = imopen(blue_channel, se);
    background_gray = imopen(I_gray, se);
    % Corregir la imagen restando el fondo 
    corrected_red = red_channel - background_red;
    corrected_green = green_channel - background_green;
    corrected_blue = blue_channel - background_blue;
    corrected_gray = I_gray - background_gray;
    % Asegurarse de que la imagen esté en el rango adecuado
    corrected_red = mat2gray(corrected_red);
    corrected_green = mat2gray(corrected_green);
    corrected_blue = mat2gray(corrected_blue);
    corrected_gray = mat2gray(corrected_gray);
    
    % Quitar las venas
    se = strel('disk', 15); 
    canal_verde_sin_vasos = imclose(corrected_green, se);
    canal_rojo_sin_vasos = imclose(corrected_red, se); %el canal rojo no tiene vasos
    canal_azul_sin_vasos = imclose(corrected_blue, se);
    gray_sin_vasos = imclose (corrected_gray, se);
    
    % Ajustar la intensidad
    gray_sin_vasos2 = imadjust(gray_sin_vasos);
    canal_azul_sin_vasos2 = imadjust(canal_azul_sin_vasos);
    canal_verde_sin_vasos2 = imadjust(canal_verde_sin_vasos);
    canal_rojo_sin_vasos2 = imadjust(canal_rojo_sin_vasos);
    
    % Volver a quitar las venas
    se = strel('disk', 40); 
    canal_verde_sin_vasos2 = imclose(canal_verde_sin_vasos2, se);
    canal_rojo_sin_vasos2 = imclose(canal_rojo_sin_vasos2, se); %el canal rojo no tiene vasos
    canal_azul_sin_vasos2 = imclose(canal_azul_sin_vasos2, se);
    gray_sin_vasos2 = imclose (gray_sin_vasos2,se);
    
end

function disco = segmentacion_disco(canal_verde_sin_vasos2,canal_rojo_sin_vasos2,canal_azul_sin_vasos2,gray_sin_vasos2);
    % Calcular entropia
    e_gris2 = entropy(gray_sin_vasos2);
    e_rojo2 = entropy(canal_rojo_sin_vasos2); 
    e_verde2 = entropy(canal_verde_sin_vasos2);
    e_azul2 = entropy(canal_azul_sin_vasos2);
    
    e_gris = ceil(e_gris2);
    e_rojo = ceil(e_rojo2);  
    e_verde = ceil(e_verde2);
    e_azul = ceil(e_azul2);
    
    % Segmentar disco dependiendo de la entropia
    if e_rojo >= e_verde && e_rojo2 > 4.5 && e_rojo < e_azul
        if e_rojo >= 6
            disc_thresholdR = 0.9 * max(canal_rojo_sin_vasos2(:)); 
            disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
        else
            disc_thresholdR = 0.7 * max(canal_rojo_sin_vasos2(:)); 
            disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
            disc_binaryR = activecontour(canal_rojo_sin_vasos2, disc_binaryR, 200);
        end
    elseif e_rojo >= e_gris && e_rojo2 > 4.5 && e_rojo <= e_verde
        disc_thresholdR = 0.95 * max(canal_rojo_sin_vasos2(:)); 
        disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
        disc_binaryR = activecontour(canal_rojo_sin_vasos2, disc_binaryR, 200);
    elseif e_rojo2 > 5 && entropia > 7
        disc_thresholdR = 0.9 * max(canal_rojo_sin_vasos2(:)); 
        disc_binaryR = canal_rojo_sin_vasos2 > disc_thresholdR;
        disc_binaryR = activecontour(canal_rojo_sin_vasos2, disc_binaryR, 200);
    else 
        disc_binaryR = ones(size(gray_sin_vasos));
        disc_thresholdR = 0;
    end
    
    if e_gris >= e_verde && disc_thresholdR == 0
        disc_threshold = 0.6 * max(gray_sin_vasos2(:)); 
        disc_binary = gray_sin_vasos2 > disc_threshold; 
        disc_binary = activecontour(gray_sin_vasos2, disc_binary, 200);
        se = strel('disk', 10);
        disc_binary = imdilate(disc_binary, se);
    else 
        disc_binary = ones(size(gray_sin_vasos)); 
    end
    
    if e_verde > e_rojo && e_gris > e_rojo 
        disc_thresholdG = 0.5 * max(canal_verde_sin_vasos2(:));
        if e_verde >= 7
            disc_thresholdG = 0.6 * max(canal_verde_sin_vasos2(:)); 
        end
        disc_binaryG = canal_verde_sin_vasos2 > disc_thresholdG; 
        if entropia > 7
            disc_binaryG = activecontour(canal_verde_sin_vasos2, disc_binaryG, 200);
        end
    else 
        disc_binaryG = ones(size(gray_sin_vasos));
    end
    
    if e_azul > e_verde && disc_thresholdR == 0 || e_azul >= 5
        disc_thresholdB = 0.6 * max(canal_azul_sin_vasos2(:));
        if e_azul2 <= 4.5 && e_azul <= e_verde 
            disc_thresholdB = 0.8 * max(canal_azul_sin_vasos2(:));
        elseif e_azul2 <= 5 && e_azul <= e_verde 
            disc_thresholdB = 0.7 * max(canal_azul_sin_vasos2(:));
        end
        disc_binaryB = canal_azul_sin_vasos2 > disc_thresholdB; 
         disc_binaryB = activecontour(canal_verde_sin_vasos2, disc_binaryB, 200);
    else 
        disc_binaryB = ones(size(gray_sin_vasos));
    end
    
    % Operación lógica de intersección para la segmentación del disco 
    disc_binary_comun = disc_binary & disc_binaryR & disc_binaryG  & disc_binaryB; %juntar los canales
    
    if disc_binary_comun(:) == 1  % si la imagen se queda blanca (por si los otros if ninguno sirve)
        if e_rojo >= 5
            if e_rojo >= 6
                disc_thresholdR = 0.9 * max(canal_rojo_sin_vasos2(:)); 
            else
                disc_thresholdR = 0.8 * max(canal_rojo_sin_vasos2(:)); 
            end
            disc_binary_comun = canal_rojo_sin_vasos2 > disc_thresholdR; 
            disc_binary_comun = activecontour(canal_rojo_sin_vasos2, disc_binary_comun, 200);
        else
            disc_threshold = 0.6 * max(gray_sin_vasos2(:));
            disc_binary = gray_sin_vasos2 > disc_threshold;
            disc_binary = activecontour(canal_verde_sin_vasos2, disc_binary, 200);
    
            disc_thresholdG = 0.6 * max(canal_verde_sin_vasos2(:)); 
            disc_binaryG = canal_verde_sin_vasos2 > disc_thresholdG;
            disc_thresholdB = 0.7 * max(canal_azul_sin_vasos2(:)); 
            disc_binaryB = canal_azul_sin_vasos2 > disc_thresholdB;
            disc_binaryB = activecontour(canal_verde_sin_vasos2, disc_binaryB, 200);
        
            disc_binary_comun = disc_binary & disc_binaryG & disc_binaryB;
        end
    end
    
    se = strel('disk', 30);
    disco = imerode(disc_binary_comun, se);
    disco = bwareafilt(disco, 1);
    disco = imdilate(disco, se);
    disco = imfill(disco, "holes");
end

function copa = segmentacion_copa(canal_verde_sin_vasos2,canal_rojo_sin_vasos2,canal_azul_sin_vasos2,gray_sin_vasos2)
    e_gris2 = entropy(gray_sin_vasos2);
    e_rojo2 = entropy(canal_rojo_sin_vasos2); 
    e_verde2 = entropy(canal_verde_sin_vasos2);
    e_azul2 = entropy(canal_azul_sin_vasos2);
    
    e_gris = ceil(e_gris2);
    e_rojo = ceil(e_rojo2);  
    e_verde = ceil(e_verde2);
    e_azul = ceil(e_azul2);
    cup_threshold = 0.9 * max(gray_sin_vasos2(:)); 
    cup_binary = gray_sin_vasos2 > cup_threshold; 
    
    cup_thresholdG = 0.9 * max(canal_verde_sin_vasos2(:)); 
    cup_binaryG = canal_verde_sin_vasos2 > cup_thresholdG; 
    cup_binaryG = activecontour(canal_verde_sin_vasos2, cup_binaryG, 200);
    
    if e_azul >= 5
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
end

function error = errores(disco, copa)
    [filaD, columnaD] = find(disco == max(disco(:)));
    % Calcula el centroide
    centroide_x = mean(columnaD);
    centroide_y = mean(filaD);
    centro_disco = [centroide_x, centroide_y]; 
    % Calcula el radio
    ancho_maximoD = max(filaD) - min(filaD);
    alto_maximoD = max(columnaD) - min(columnaD);
    radio_disco = max(ancho_maximoD, alto_maximoD) / 2; 
    
    [filaC, columnaC] = find(copa == max(copa(:)));
    % Calcula el centroide
    centroide_x = mean(columnaC);
    centroide_y = mean(filaC);
    centro_copa = [centroide_x, centroide_y]; 
    % Calcula el radio
    ancho_maximoC = max(filaC) - min(filaC);
    alto_maximoC = max(columnaC) - min(columnaC);
    radio_copa = max(ancho_maximoC, alto_maximoC) / 2;
    
    if max(disco(:)) == min(disco(:)) 
        error_disco = 1;
    elseif ancho_maximoD > alto_maximoD*1.5
        error_disco = 1;
    elseif ancho_maximoD*1.5 < alto_maximoD
        error_disco = 1;
    else 
        error_disco= 0;
    end
    
    [alto, ancho] = size(disco);
    
    % Comparar las dimensiones de disco con ancho_maximoD y alto_maximoD
    if ancho_maximoD > ancho - 50 || alto_maximoD > alto - 50
        error_disco2= 1;
    else
        error_disco2= 0;
    end
    
    if radio_copa > radio_disco
        error_copa = 1;
    else
       error_copa = 0;
    end 
    
    
    if centro_copa(1) < (centro_disco(1) - radio_disco)  
         error_segm = 1;
    elseif centro_copa(1) > (centro_disco(1) + radio_disco)
        error_segm = 1;
    elseif centro_copa(2) < (centro_disco(2) - radio_disco)
          error_segm = 1;
    elseif centro_copa(2) > (centro_disco(2) + radio_disco)
         error_segm = 1;
    else
        error_segm = 0;
    end 
    
    if radio_disco > radio_copa  * 3
         error_disco3 = 1;
    else
        error_disco3=0;
    end 

    error = error_segm || error_disco3 || error_disco2 || error_disco || error_copa;
end

function figura(roi, disco, copa)
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
end

function T_caracteristicas_DETECCION = extraccion_caracteristicas(roi, disco, copa)
    copa = imresize(copa, [300 300]);
    disco = imresize(disco, [300 300]);
    roi = imresize(roi, [300 300]);
    roiHSV = rgb2hsv(roi);

%     copa = imbinarize(copa);
%     disco = imbinarize(disco);
    
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
    
    roi_NRR = rgb2gray(roi_NRR);
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
end

function glaucoma = modelo(T_caracteristicas_DETECCION, mdl_final_SVM)
    glaucoma = predict(mdl_final_SVM, T_caracteristicas_DETECCION);
end