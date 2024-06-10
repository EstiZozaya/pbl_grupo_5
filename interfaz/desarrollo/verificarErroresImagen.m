function errorFlag = verificarErroresImagen(copa, disco)
    errorFlag = 0;

    % Encontrar las coordenadas máximas en disco
    [filaD, columnaD] = find(disco == max(disco(:)));
    % Calcular el centroide del disco
    centroide_x = mean(columnaD);
    centroide_y = mean(filaD);
    centro_disco = [centroide_x, centroide_y];
    % Calcular el radio del disco
    ancho_maximoD = max(filaD) - min(filaD);
    alto_maximoD = max(columnaD) - min(columnaD);
    radio_disco = max(ancho_maximoD, alto_maximoD) / 2;

    % Encontrar las coordenadas máximas en copa
    [filaC, columnaC] = find(copa == max(copa(:)));
    % Calcular el centroide de la copa
    centroide_x = mean(columnaC);
    centroide_y = mean(filaC);
    centro_copa = [centroide_x, centroide_y];
    % Calcular el radio de la copa
    ancho_maximoC = max(filaC) - min(filaC);
    alto_maximoC = max(columnaC) - min(columnaC);
    radio_copa = max(ancho_maximoC, alto_maximoC) / 2;

    % Verificar errores en el disco
    if max(disco(:)) == min(disco(:)) || ...
       ancho_maximoD > alto_maximoD * 1.5 || ...
       ancho_maximoD * 1.5 < alto_maximoD
        errorFlag = 1;
        return;
    end

    % Verificar las dimensiones del disco
    [alto, ancho] = size(disco);
    if ancho_maximoD > ancho - 50 || alto_maximoD > alto - 50
        errorFlag = 1;
        return;
    end

    % Verificar errores en la copa
    if radio_copa > radio_disco
        errorFlag = 1;
        return;
    end

    % Verificar la posición relativa de la copa respecto al disco
    if centro_copa(1) < (centro_disco(1) - radio_disco) || ...
       centro_copa(1) > (centro_disco(1) + radio_disco) || ...
       centro_copa(2) < (centro_disco(2) - radio_disco) || ...
       centro_copa(2) > (centro_disco(2) + radio_disco)
        errorFlag = 1;
        return;
    end

    % Verificar la relación entre los radios de la copa y el disco
    if radio_disco > radio_copa * 3
        errorFlag = 1;
        return;
    end
end