% CODIGO CON TODAS LAS FUNCIONES DE CALIDAD

close all; clc; clearvars;

T_caracteristicas_CALIDAD = extraccion_caracteristicas_calidad('image_0125.jpg'); % extracción de caracteristicas para el modelo
load modelo_calidad_final_SVM.mat % cargar el modelo 
calidad_im = modelo_calidad(T_caracteristicas_CALIDAD, mdl_final_TODO_SVM); % predicción de la calidad

function T_caracteristicas_CALIDAD = extraccion_caracteristicas_calidad(imagen)
    I = imread(imagen);
    entropia = entropy(I);

    I = double(rgb2gray(I)); 
    rango_dinamico = max(I(:))-min(I(:));
    var_intensidad = var(I(:));

    I_filtrada=medfilt2(I);
    mse=immse(I_filtrada, I);
    snr=psnr(I_filtrada, I); 

    T_caracteristicas_CALIDAD = table(entropia, rango_dinamico, var_intensidad, mse, snr, 'VariableNames', {'entropia', 'rango_dinamico', 'var_intensidad', 'mse', 'snr'});
end

function calidad_im = modelo_calidad(T_caracteristicas_CALIDAD, mdl_final_TODO_SVM)
    T_caracteristicas_CALIDAD = table2array(T_caracteristicas_CALIDAD);
    calidad_im = predict(mdl_final_TODO_SVM, T_caracteristicas_CALIDAD);
end
