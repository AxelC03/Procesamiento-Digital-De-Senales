% Actividad 7 - Proyecto final
% Torreta seguidora de intrusos
% Equipo 5
% Y así, en un parpadeo, todo termino...

clc 
clear all

%% Se inicializa la tarjeta
tarjeta=arduino("COM5", "Uno", "Libraries", "Servo");
%tarjeta=arduino("COM7","Mega2560","Libraries","Servo");

% Define los pines a utilizar
laser_pin="d12"; % Pin para activar el laser
serX="d5"; % Pin del servo para eje X
serY="d9"; % Pin del servo para eje Y

% Se declaran los objetos para los servos
servoX=servo(tarjeta, serX);
clear servoX;
servoX=servo(tarjeta, serX, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);

servoY=servo(tarjeta, serY);
clear servoY;
servoY=servo(tarjeta, serY, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);

% Se colocan los servos en posición de reposo
gradosX=90;
valorX=gradosX/180;
writePosition(servoX, valorX);

gradosY=165;
valorY=gradosY/180;
writePosition(servoY, valorY);

%% Inicializa la camara
camara=webcam(1);
camara.Resolution = '1280x720';
pause(0.5);

% Se toma la imagen que servirá como patrón
img=snapshot(camara);
img=rgb2gray(img);
imwrite(img, "patronA7_Gris.png");

% Se obtienen las dimensiones de la foto
[dimX, dimY]=size(img);

% Divide la imagen en una cantidad de partes horizontales
num_div=10;
size_div=floor(dimX/num_div);

% Crea una celda que permita contener las divisiones
celdaDiv=cell(num_div);

% Dividir la imagen
for i=1:num_div
    primerFila=(i-1)*size_div+1;
    ultimaFila=min(i*size_div, dimX);
    celdaDiv{i}=img(:,primerFila:ultimaFila,:);
end

% Mostrar las celdas divididas
figure("Name","Celdas divididas");
for i=1:num_div
    subplot(1, num_div, i);
    imshow(celdaDiv{i});
    title(["Sector ", num2str(i)]);
end

% Se definen las posiciones que puede tomar la torreta
angMin=30;
angMax=160;
pasos=(angMax-angMin)/(num_div-1);

posTorr=angMin:pasos:angMax;
posTorr=round(posTorr);

tempMax=10;
umbCorr=0.8;
pause(2);

% Se crea una pequeña interfaz que permita cerrar el bucle
wb=waitbar(0, 'Apachurrale a cancel para detener', 'Name', 'GUI para detener el bucle', 'CreateCancelBtn', 'delete(gcbf)');

%% Inicia el bucle de deteccion de intrusos
while true
    % Captura la foto actual
    imgAct=snapshot(camara);
    imgAct=rgb2gray(imgAct);
    
    [tamX, tamY, ~]=size(imgAct);
    size_div=floor(tamX/num_div);

    % Crea otra celda para las divisiones de la imagen actual
    sentryUp=cell(num_div, 1);

    % Se divide la imagen actual
    for i=1:num_div
        filaInicial=(i-1)*size_div+1;
        filaFinal=min(i*size_div, tamX);
        sentryUp{i}=imgAct(:,filaInicial:filaFinal,:);
    end

    % Se compara la imagen actual con la imagen patron
    for i=1:num_div
        corrImgs=max(max(normxcorr2(sentryUp{i}, celdaDiv{i})));
    end

    % Obtener la menor correlacion
    [minCorr, indice]=min(corrImgs);

    % Mueve la torreta en esa direccion
    if minCorr>umbCorr
        tempMax=10;
        writeDigitalPin(tarjeta, laser_pin, 0);
        writePosition(servoX, 0.5);
        writePosition(servoY, 0.5); % Aqui con cuidado, editar valor %
    else
        writeDigitalPin(tarjeta, laser_pin, 1);
        posX=posTorr(indice)/180;
        writePosition(servoX, posX);
        tempMax=tempMax-0.5;
        if tempMax<=0
            for i=2:10
                writeDigitalPin(tarjeta, laser_pin, mod(i, 2));
                pause(0.25);
                disp("FUEGO!");
            end
            tempMax=10;
        end
    end

    if ~ishandle(wb)
        break
    end
end

clear camara;