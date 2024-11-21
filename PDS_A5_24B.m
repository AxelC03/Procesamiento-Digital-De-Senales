% Actividad 5 - Torreta de seguridad
% Equipo 3

clc
clear all

%% Inicializa la tarjeta

% tarjeta=arduino("COM5", "Uno", "Libraries", "Servo");
tarjeta=arduino("COM3", "Mega2560", "Libraries", "Servo");

% Define los pines a utilizar
micPin="d13"; % Pin para mostrar al usuario que esta grabando
laser_pin="d12"; % Pin para activar el laser
serX="d5"; % Pin del servo para eje X
serY="d9"; % Pin del servo para eje Y

%% Inicializa la grabacion
% Frecuencia de sampleo
Fs = 48000;

%Duracion de la grabacion
tr = 2;

% Parametros de la grabacion
grabacion=audiorecorder(Fs, 16, 1);

%Valores para filtrado
a = [0.1 - 0.95];
b = [1 - 0.99];

% Acondicionamiento de señales
cmdStop = audioread("detente.wav");
cmdStop = filter(a, b, cmdStop);
maxStop = max(abs(cmdStop));
n = length(cmdStop);
for i=1:n
    normStop(i) = cmdStop(i)/maxStop;
end
fftStop=abs(fft(normStop));
% Pasabajas
fs=1;
T=1/fs; %periodo de muestreo
fc=3000; %frecuencia de corte
fnyq=Fs/2; %frecuencia de Nyquist
fnorm=fc/fnyq; %frecuencia normalizada
tau=1/(2*pi*fnorm); %tau del filtro
nums=[1]; %numerador de la función de transferencia del filtro
dens=[tau,1]; %denominador de la funciÓn de transferencia del fitro
nums2=conv(nums,nums);
dens2=conv(dens,dens);
nums3=conv(nums2,nums);
dens3=conv(dens2,dens);
nums4=conv(nums3, nums);
dens4=conv(dens3, dens);
nums5=conv(nums4, nums);
dens5=conv(dens4, dens);
nums6=conv(nums5, nums);
dens6=conv(dens5, dens);
nums7=conv(nums6, nums);
dens7=conv(dens6, dens);
nums8=conv(nums7, nums);
dens8=conv(dens7, dens);
nums9=conv(nums8, nums);
dens9=conv(dens8, dens);
nums10=conv(nums9, nums);
dens10=conv(dens9, dens);
% Función de transferencia del filtro
[numz, denz] = bilinear(nums10, dens10, T);

%% Configura los servos
% Se declaran los objetos para los servos
% Configuren de acuerdo a los servos que utlicen
servoX=servo(tarjeta, serX);
clear servoX;
servoX=servo(tarjeta, serX, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);

servoY=servo(tarjeta, serY);
clear servoY;
servoY=servo(tarjeta, serY, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);

% Sonido de deteccion
% Aqui, pongan el sonido que quieran que suene al detectar un intruso
% si quieren cambiarle el nombre, vayan al menú de find y den en replace
spy=audioread("enemySpoted.mp3");
% sound(spy, 48000);

% Se colocan los servos en posición de reposo
writePosition(servoX, 0.5);
writePosition(servoY, 0.5);

%% Configura la camara y la imagen patron
% Inicializa la camara
camara=webcam(1);
camara.Resolution = '1280x720';

% Se toma la imagen que servirá como patrón
imagenPatron=snapshot(camara);
patronGris=rgb2gray(imagenPatron);
imwrite(patronGris, "patronA7_Gris.png");

% Para ayudar al reconocimiento se declarán las matrices de filtrado
matrizsuave=[0.0625,0.125,0.0625;0.125,0.25,0.125;0.0625,0.125,0.0625];

% Se realiza el filtrado de la imagen patron
patronSuave=imfilter(patronGris, matrizsuave);

% Se declaran las zonas de monitoreo 
seccPat1=imcrop(patronSuave, [0 0 255 720]);
seccPat2=imcrop(patronSuave, [256 0 256 720]);
seccPat3=imcrop(patronSuave, [512 0 256 720]);
seccPat4=imcrop(patronSuave, [769 0 256 720]);
seccPat5=imcrop(patronSuave, [1024 0 1280 720]);


% Se crea una barra de espera para detener el bucle
wb=waitbar(0, 'Presiona cancel para detener', 'Name', 'Detener el bucle', 'CreateCancelBtn', 'delete(gcbf)');
% i=0;

% Define un umbral de correlación a partir del cual se considera un intruso
umbCorr=0.6;

%% Inicia el bucle que permita la detección continua de objetos
while true
    %% Captura de la imagen actual y su acondicionamiento
    % Se toma la imagen actual y se convierte a escala de grises
    img=snapshot(camara);
    act=rgb2gray(img);

    % writeDigitalPin(tarjeta, laser_pin, 1);

    % Se filtra la imagen actual
    actSuave=imfilter(act, matrizsuave);

    % Muestra al usuario la imagen actual
    imshow(actSuave);

    % Define las zonas de monitoreo de la imagen actaul
    seccAct1=imcrop(actSuave, [0 0 255 720]);
    seccAct2=imcrop(actSuave, [256 0 256 720]);
    seccAct3=imcrop(actSuave, [512 0 256 720]);
    seccAct4=imcrop(actSuave, [769 0 256 720]);
    seccAct5=imcrop(actSuave, [1024 0 1280 720]);

    % Se calculan las correlaciones de las secciones de ambas imagenes
    corrSec1=corr2(seccPat1, seccAct1);
    corrSec2=corr2(seccPat2, seccAct2);
    corrSec3=corr2(seccPat3, seccAct3);
    corrSec4=corr2(seccPat4, seccAct4);
    corrSec5=corr2(seccPat5, seccAct5);

    %% Grabacion y acondicionamiento para detener el bucle
    % Inicia la grabacion para detener el bucle
    writeDigitalPin(tarjeta, micPin, 1);
    recordblocking(grabacion, tr);
    audiograbado=getaudiodata(grabacion);
    % Guarda la información en un vector y en un archivo
    mensaje = audiograbado;
    mensaje = mensaje/max(abs(mensaje));
    % Se obtienen los parámetros del archivo
    n=length(mensaje); %longitud del vector de audio
    t=n/Fs; %tiempo total que dura el audio
    Ts=1/Fs; %periodo de muestreo
    tiempo=[0:Ts:(t-Ts)]; %vector de tiempo
    % Convolucion y filtrado
    audiograbado=filter(numz,denz,mensaje); %filtrar el audio

    %Normalizacion del audio grabado
    audiograbado = filter(a,b,audiograbado);
    maxin = max(abs(audiograbado));
    n = length(audiograbado);
    for i= 1:n
        x(i) = audiograbado(i)/maxin;
    end
    transff = abs(fft(x)); %FFT en una dimension

    corrPal = corr2(transff, fftStop);

    if corrPal<umbCorr
        disp("Bienvenido master! ");
        break
    end

    writeDigitalPin(tarjeta, micPin, 0);

    %% Mueve la torreta
    % Obtiene el promedio de correlación para determinar a donde mover 
    % la torreta
    promCorr=(corrSec1+corrSec2+corrSec3+corrSec4+corrSec5)/5;

    if corrSec1<promCorr && umbCorr<corrSec1
        movTorr=1;
    elseif corrSec2<promCorr && umbCorr<corrSec1
        movTorr=2;
    elseif corrSec3<promCorr && umbCorr<corrSec1
        movTorr=3;
    elseif corrSec4<promCorr && umbCorr<corrSec1
        movTorr=4;
    elseif corrSec5<promCorr && umbCorr<corrSec1
        movTorr=5;
    else
        movTorr=6;
    end

    switch movTorr
        case 1
            writePosition(servoX, 0.7);
            writePosition(servoY, 0.6);
            writeDigitalPin(tarjeta, laser_pin, 1)
            sound(spy, Fs);
        case 2
            writePosition(servoX, 0.6);
            writePosition(servoY, 0.6);
            writeDigitalPin(tarjeta, laser_pin, 1);
            sound(spy, Fs);
        case 3
            writePosition(servoX, 0.5);
            writePosition(servoY, 0.6);
            writeDigitalPin(tarjeta, laser_pin, 1);
            sound(spy, Fs);
            % pause(0.5);
        case 4
            writePosition(servoX, 0.4);
            writePosition(servoY, 0.6);
            writeDigitalPin(tarjeta, laser_pin, 1);
            sound(spy, Fs);
            % pause(0.5);
        case 5
            writePosition(servoX, 0.3);
            writePosition(servoY, 0.6);
            writeDigitalPin(tarjeta, laser_pin, 1);
            sound(spy, Fs);
            % pause(0.5);
        otherwise
            writePosition(servoX, 0.5);
            writePosition(servoY, 0.6);
            writeDigitalPin(tarjeta, laser_pin, 0);
            % pause(0.5);
    end
    pause(0.001);

    % Detener la grabación si se ha presionado el boton de cancel
    if ~ishandle(wb)
        break
    end

    % auxT=auxT+1 % Verificar el número de iteraciones
end

close all

figure("Name","Actual")
subplot(1, 5, 1)
imshow(seccAct1);
subplot(1, 5, 2)
imshow(seccAct2);
subplot(1, 5, 3)
imshow(seccAct3);
subplot(1, 5, 4)
imshow(seccAct4);
subplot(1, 5, 5)
imshow(seccAct5);

figure("Name","Patron")
subplot(1, 5, 1)
imshow(seccPat1);
subplot(1, 5, 2)
imshow(seccPat2);
subplot(1, 5, 3)
imshow(seccPat3);
subplot(1, 5, 4)
imshow(seccPat4);
subplot(1, 5, 5)
imshow(seccPat5);

clear camara;

