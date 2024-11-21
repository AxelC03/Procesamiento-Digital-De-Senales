% Actividad 7 - Proyecto final
% Torreta seguidora de movimiento
% Equipo 5
% Todo termino

clc
clear all
close all
pause(1);

%% Se inicializa la tarjeta
tarjeta=arduino("COM5", "Uno", "Libraries", "Servo");

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
writePosition(servoX, 0.5);
writePosition(servoY, 0.5);

%% Inicializa la camara
camara=webcam(1);
camara.Resolution = '1280x720';
tiempo=tic;

% Se toma la imagen que servirá como patrón
imagenPatron=snapshot(camara);
patronGris=rgb2gray(imagenPatron);
imwrite(patronGris, "patronA7_Gris.png");

% Para ayudar al reconocimiento se declarán las matrices de filtrado
matrizsuave=[0.0625,0.125,0.0625;0.125,0.25,0.125;0.0625,0.125,0.0625];

% Se realiza el filtrado de la imagen patron
patronSuave=imfilter(patronGris, matrizsuave);

% Se declaran las zonas de monitoreo 
seccPat1=imcrop(patronSuave, [0 0 426 359]);
seccPat2=imcrop(patronSuave, [427 0 426 359]);
seccPat3=imcrop(patronSuave, [854 0 1280 359]);
seccPat4=imcrop(patronSuave, [0 360 426 359]);
seccPat5=imcrop(patronSuave, [427 360 426 359]);
seccPat6=imcrop(patronSuave, [854 360 1280 359]);


%% Se crea una barra de espera para detener el bucle
wb=waitbar(0, 'Presiona cancel para detener', 'Name', 'Detener el bucle', 'CreateCancelBtn', 'delete(gcbf)');
% i=0;

% Define un umbral de correlación a partir del cual se considera un intruso
umbCorr=0.6;
dispIntr=true;

%% Inicia el bucle que permita la detección continua de objetos

auxT=1;

while true
    % Se toma la imagen actual y se convierte a escala de grises
    img=snapshot(camara);
    act=rgb2gray(img);

    % writeDigitalPin(tarjeta, laser_pin, 1);

    % Se filtra la imagen actual
    actSuave=imfilter(act, matrizsuave);
     
    % Muestra al usuario la imagen actual
    imshow(actSuave);

    % Define las zonas de monitoreo de la imagen actaul
    seccAct1=imcrop(actSuave, [0 0 426 359]);
    seccAct2=imcrop(actSuave, [427 0 426 359]);
    seccAct3=imcrop(actSuave, [854 0 1280 359]);
    seccAct4=imcrop(actSuave, [0 360 426 359]);
    seccAct5=imcrop(actSuave, [427 360 426 359]);
    seccAct6=imcrop(actSuave, [854 360 1280 359]);

    % Se calculan las correlaciones de las secciones de ambas imagenes
    corrSec1=corr2(seccPat1, seccAct1);
    corrSec2=corr2(seccPat2, seccAct2);
    corrSec3=corr2(seccPat3, seccAct3);
    corrSec4=corr2(seccPat4, seccAct4);
    corrSec5=corr2(seccPat5, seccAct5);
    corrSec6=corr2(seccPat6, seccAct6);

    % Obtiene el promedio de correlación para determinar a donde mover 
    % la torreta
    promCorr=(corrSec1+corrSec2+corrSec3+corrSec4+corrSec5+corrSec6)/6;

    if corrSec1<promCorr
        movTorr=1;
    elseif corrSec2<promCorr
        movTorr=2;
    elseif corrSec3<promCorr
        movTorr=3;
    elseif corrSec4<promCorr
        movTorr=4;
    elseif corrSec5<promCorr
        movTorr=5;
    elseif corrSec6<promCorr
        movTorr=6;
    else
        movTorr=2;
    end

    switch movTorr
        case 1
            writePosition(servoX, 0.7);
            writePosition(servoY, 0.6);
            writeDigitalPin(laser_pin, 1);
            if corrSec1>umbCorr
                % timePassed=toc(tiempo);
                auxT=auxT+1
            end
            % pause(0.5);
        case 2
            writePosition(servoX, 0.5);
            writePosition(servoY, 0.6);
            writeDigitalPin(laser_pin, 1);
            if corrSec2>umbCorr
                % timePassed=toc(tiempo);
                auxT=auxT+1
            end
            % pause(0.5);
        case 3
            writePosition(servoX, 0.3);
            writePosition(servoY, 0.6);
            writeDigitalPin(laser_pin, 1);
            if corrSec3>umbCorr
                % timePassed=toc(tiempo);
                auxT=auxT+1
            end
            % pause(0.5);
        case 4
            writePosition(servoX, 0.7);
            writePosition(servoY, 0.6);
            writeDigitalPin(laser_pin, 1);
            if corrSec4>umbCorr
                % timePassed=toc(tiempo);
                auxT=auxT+1
            end
            % pause(0.5);
        case 5
            writePosition(servoX, 0.5);
            writePosition(servoY, 0.6);
            writeDigitalPin(laser_pin, 1);
            if corrSec5>umbCorr
                % timePassed=toc(tiempo);
                auxT=auxT+1
            end
            % pause(0.5);
        case 6
            writePosition(servoX, 0.3);
            writePosition(servoY, 0.6);
            writeDigitalPin(laser_pin, 1);
            if corrSec5>umbCorr
                % timePassed=toc(tiempo);
                auxT=auxT+1
            end
            % pause(0.5);
        otherwise
            writePosition(servoX, 0.5);
            writePosition(servoY, 0.6);
            writeDigitalPin(laser_pin, 0);
            timePassed=0;
            % pause(0.5);
    end

    if auxT>100
        dispIntr=false;
    end

    pause(0.001);

    % Detener la grabación si se ha presionado el boton de cancel
    if ~ishandle(wb)
        break
    end

    % auxT=auxT+1 % Verificar el número de iteraciones

    if dispIntr==false
        for i=0:10
            writeDigitalPin(tarjeta, laser_pin, 1);
            pause(0.1);
            writeDigitalPin(tarjeta, laser_pin, 0);
        end
        timePassed=0;
        auxT=0;
        dispIntr=true;
    end
    
end

close all

figure("Name","Actual")
subplot(2, 3, 1)
imshow(seccAct1);
subplot(2, 3, 2)
imshow(seccAct2);
subplot(2, 3, 3)
imshow(seccAct3);
subplot(2, 3, 4)
imshow(seccAct4);
subplot(2, 3, 5)
imshow(seccAct5);
subplot(2, 3, 6)
imshow(seccAct6);

figure("Name","Patron")
subplot(2, 3, 1)
imshow(seccPat1);
subplot(2, 3, 2)
imshow(seccPat2);
subplot(2, 3, 3)
imshow(seccPat3);
subplot(2, 3, 4)
imshow(seccPat4);
subplot(2, 3, 5)
imshow(seccPat5);
subplot(2, 3, 6)
imshow(seccPat6);

clear camara;