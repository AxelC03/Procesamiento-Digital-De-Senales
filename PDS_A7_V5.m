% Actividad 7 - Proyecto final
% Torreta seguidora de intrusos
% Equipo 5
% Si profe, me lo piratie el código

clear all;
clc;
close all;
% Configurando arduino 
ardu=arduino("COM5", "Uno", "Libraries", "Servo");
motorx=servo(ardu, 'D5', 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);
motory=servo(ardu, 'D9', 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);

% Encendiendo el laser
writeDigitalPin(ardu, 'D12', 0);

% Centrando torreta
gradosx=90;
valorx=gradosx/180;
writePosition(motorx, valorx);

gradosy=165;
valory=gradosy/180;
writePosition(motory, valory);

% Inicializar la camara web
cam=webcam;
pause(0.05);
% Tomar foto
img=snapshot(cam);

img=rgb2gray(img);

% Obtener el tamaño de la imagen
[tamy, tamx, ~]=size(img);

% Dividir la imagen en x partes horizontales
num_divisiones=10;
tamano_division=floor(tamx/num_divisiones);

% Inicializar la celda para almacenar las divisiones
fondo=cell(num_divisiones, 1);

% Dividir la imagen
for i=1:num_divisiones
    inicio_fila=(i-1)*tamano_division+1;
    fin_fila=min(i*tamano_division, tamx);
    fondo{i}=img(:, fin_fila: fin_fila, :);
end

% Mostrar las divisiones
figure("Name","Patron");
for i=1:num_divisiones
    subplot(1, num_divisiones, i);
    imshow(fondo{i});
    title(['Sector', num2str(i)]);
end

% Definimos las posiciones de la torreta para cada cuadrante
angulo_minimo=65;
angulo_maximo=110;
pasos=(angulo_maximo-angulo_minimo)/(num_divisiones-1);

posicionLaser=angulo_minimo:pasos:angulo_maximo;
posicionLaser=round(posicionLaser);

contador=10;
pause(2);

while true
    % Tomar la foto
    img=snapshot(cam);

    img=rgb2gray(img);

    % Obtener el tamaño de la imagen
    [tamx, tamy, ~]=size(img);

    % Dividir la imagen en x partes horizontales
    tamano_division=floor(tamx/num_divisiones);

    % Inicializar la celda para almacenar las divisiones
    vigilancia=cell(num_divisiones, 1);

    % Dividir la imagen
    for i=1:num_divisiones

        inicio_fila=(i-1)*tamano_division+1;
        fin_fila=min(i*tamano_division, tamx);
        vigilancia{i}=img(:, inicio_fila: fin_fila, :);

    end

    % Compara las divisiones de vigilancia con la del fondo
    for i=1:num_divisiones
        correlacion(i)=max(max(normxcorr2(vigilancia{i}, fondo{i})));
    end

    % Determinar cual de las correlaciones es la más alta
    [correlacion_minima, indice_maximo]=min(correlacion);

    % Apunta el laser
    if correlacion_minima>0.88
        clc;
        fprintf('No se detecta intruso\n');
        contador=10;
        % Apagando laser
        writeDigitalPin(ardu, 'D2', 0);

        % Centrando torreta
        gradosx=90;
        valorx=gradosx/180;
        writePosition(motorx, valorx);

        gradosy=165;
        valory=gradosy/180;
        writePosition(motory, valory);
    else
        clc;
        fprintf('Intruso detectado \n %d', contador);
        writeDigitalPin(ardu, 'D2', 1);
        valorx=posicionLaser(indice_maximo)/180;
        writePosition(motorx, valorx);
        contador=contador-0.5;
        if contador==0
            for i=2:10
                writeDigitalPin(ardu, 'D2', mod(i,2));
                pause(0.25);
            end
            contador=10;
        end
    end
    pause(0.5);
end