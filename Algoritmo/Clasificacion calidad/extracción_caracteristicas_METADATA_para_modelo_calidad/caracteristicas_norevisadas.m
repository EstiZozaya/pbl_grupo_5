close all; clc; clearvars;
T_metadata = readtable('metadata.csv');

T_norevisada = T_metadata;
T_norevisada = T_norevisada(T_norevisada.quality == 0, :);

[n, m] = size(T_norevisada);

entropia = zeros(n,1);
min_intensidad= zeros(n, 1);
max_intensidad= zeros(n, 1);
rango_dinamico= zeros(n, 1);
std_intensidad= zeros(n, 1);
var_intensidad= zeros(n, 1);
nitidez_borde = zeros(n, 1);
mse_mediana = zeros(n, 1);
snr_mediana = zeros(n,1);
mse_gauss = zeros(n, 1);
snr_gauss = zeros(n,1);
energia = zeros(n,1);
filtro_laplace=[1, 1, 1; 1, -8, 1; 1, 1, 1];


for i = 1:n
    I = imread(T_norevisada.image{i});
    entropia(i) = entropy(I);

    I = double(rgb2gray(I)); % damos por hecho que la imagen es de color (igual hacer un for para diferenciar)

    min_intensidad(i)=min(I(:));
    max_intensidad(i)=max(I(:));
    rango_dinamico(i)=max(I(:))-min(I(:));
    std_intensidad(i) = std2(I(:)); % desviación estandar
    var_intensidad(i) =var(I(:)); % varianza

    I2=imfilter(I, filtro_laplace);
    nitidez_borde(i) = sum(abs(I2(:)));

    I_filtrada=medfilt2(I);
    mse_mediana(i)=immse(I_filtrada, I);
    snr_mediana(i)=psnr(I_filtrada, I);

    I_filtrada=imgaussfilt(I);
    mse_gauss(i)=immse(I_filtrada, I);
    snr_gauss(i)=psnr(I_filtrada, I);

    energia(i) = sum(I(:).^2);
end

T_caracteristicas = table(T_norevisada.quality, entropia, min_intensidad, max_intensidad, rango_dinamico, std_intensidad, var_intensidad, nitidez_borde, mse_mediana, snr_mediana, mse_gauss, snr_gauss, energia, 'VariableNames', {'quality', 'entropia', 'min_intensidad', 'max_intensidad', 'rango_dinamico', 'std_intensidad', 'var_intensidad', 'nitidez_borde', 'mse_mediana', 'snr_mediana', 'mse_gauss', 'snr_gauss', 'energia'});

T_caracteristicas.imagen = T_norevisada.image;
writetable(T_caracteristicas, 'CaracteristicasCalidadNOREVISADAS.csv');