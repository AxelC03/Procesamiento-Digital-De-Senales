clc
clear all

%% Inicializa la tarjeta
tarjeta = arduino("COM11", "Uno", "Libraries", "Servo");

% Define los pines a utilizar
micPin = "d13"; % Pin para mostrar al usuario que está grabando
laser_pin = "d12"; % Pin para activar el láser
serX = "d5"; % Pin del servo para eje X
serY = "d9"; % Pin del servo para eje Y
writeDigitalPin(tarjeta, 'd8', 1);

%% Inicializa la grabación
% Frecuencia de muestreo
Fs = 48000;
% Duración de la grabación
tr = 2;
% Parámetros de la grabación
grabacion = audiorecorder(Fs, 16, 1);

% Valores para filtrado
a = [0.1 -0.95];
b = [1 -0.99];

% Acondicionamiento de señales
cmdStop = audioread("detente.wav");
cmdStop = filter(a, b, cmdStop);
maxStop = max(abs(cmdStop));
cmdStop = cmdStop / maxStop;
fftStop = abs(fft(cmdStop));

%% Configura los servos
servoX = servo(tarjeta, serX);
servoY = servo(tarjeta, serY);

% Sonido de detección
% Cambien el audio por el que quieran que suene al detectar un intruso, de
% la misma manera, si gustan cambiarle el nombre a la variable, vayan al
% menu de find y seleccionen replace
spy = audioread("enemySpoted.mp3");

% Se colocan los servos en posición de reposo
writePosition(servoX, 0.5);
writePosition(servoY, 0.5);

%% Configura la cámara y la imagen patrón
camara = webcam(1);
camara.Resolution = '1280x720';
imagenPatron = snapshot(camara);
patronGris = rgb2gray(imagenPatron);
imwrite(patronGris, "patronA7_Gris.png");

% Aplica un filtrado suave a la imagen patron
matrizsuave = [0.0625, 0.125, 0.0625; 0.125, 0.25, 0.125; 0.0625, 0.125, 0.0625];
patronSuave = imfilter(patronGris, matrizsuave);

% Dividide la imagen patron filtrada en cinco segmentos horizontales
seccPat1 = imcrop(patronSuave, [0 0 255 720]);
seccPat2 = imcrop(patronSuave, [256 0 256 720]);
seccPat3 = imcrop(patronSuave, [512 0 256 720]);
seccPat4 = imcrop(patronSuave, [769 0 256 720]);
seccPat5 = imcrop(patronSuave, [1024 0 1280 720]);

% Barra de opciones para detener el bucle manualmente
wb = waitbar(0, 'Presiona cancel para detener', 'Name', 'Detener el bucle', 'CreateCancelBtn', 'delete(gcbf)');

% Umbrales minimos de correlacion para imagen y audio respectivamente
umbCorr = 0.6;
corrAudio = 0.7;

%% Inicia el bucle de detección
detener = false;

while true
    % Captura de imagen
    img = snapshot(camara);
    act = rgb2gray(img);
    actSuave = imfilter(act, matrizsuave);
    imshow(actSuave);

    % Division de la imagen actual
    seccAct1 = imcrop(actSuave, [0 0 255 720]);
    seccAct2 = imcrop(actSuave, [256 0 256 720]);
    seccAct3 = imcrop(actSuave, [512 0 256 720]);
    seccAct4 = imcrop(actSuave, [769 0 256 720]);
    seccAct5 = imcrop(actSuave, [1024 0 1280 720]);

    % Calculo de la correlacion entre las secciones
    corrSec1 = corr2(seccPat1, seccAct1);
    corrSec2 = corr2(seccPat2, seccAct2);
    corrSec3 = corr2(seccPat3, seccAct3);
    corrSec4 = corr2(seccPat4, seccAct4);
    corrSec5 = corr2(seccPat5, seccAct5);

    % Detección de palabra clave
    writeDigitalPin(tarjeta, micPin, 1);
    recordblocking(grabacion, tr);
    audiograbado = getaudiodata(grabacion);
    audiograbado = filter(a, b, audiograbado);
    maxin = max(abs(audiograbado));
    audiograbado = audiograbado / maxin;
    transff = abs(fft(audiograbado));
    
    % Calculo de la correlacion de la palabra clave con la grabada
    corrPal = corr2(transff, fftStop);
    if corrPal >= corrAudio
        disp("Bienvenido master!");
        detener = true;
    end
    writeDigitalPin(tarjeta, micPin, 0);
    
    % Detiene el bucle si se dice la palabra clave
    if detener
        writeDigitalPin(tarjeta, laser_pin, 0); % Apaga el láser al detener el sistema
        break
    end
    
    % Encuentra la correlación mínima y mueve el servo
    [minCorr, movTorr] = min([corrSec1, corrSec2, corrSec3, corrSec4, corrSec5]);
    if minCorr < umbCorr
        switch movTorr
            case 1
                writePosition(servoX, 0.7);
                writePosition(servoY, 0.6);
                writeDigitalPin(tarjeta, laser_pin, 1);
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
            case 4
                writePosition(servoX, 0.4);
                writePosition(servoY, 0.6);
                writeDigitalPin(tarjeta, laser_pin, 1);
                sound(spy, Fs);
            case 5
                writePosition(servoX, 0.3);
                writePosition(servoY, 0.6);
                writeDigitalPin(tarjeta, laser_pin, 1);
                sound(spy, Fs);
        end
    else
        writePosition(servoX, 0.5);
        writePosition(servoY, 0.6);
        writeDigitalPin(tarjeta, laser_pin, 0);
    end

    pause(0.001);

    % Detiene el bucle manualmente si se selecciona la opcion en la barra
    % de opcines
    if ~ishandle(wb)
        writeDigitalPin(tarjeta, laser_pin, 0); % Apaga el láser si el bucle se detiene
        break
    end
end

close all

% Muestra al usuario la imagen patron y la ultima imagen tomada
figure("Name", "Actual")
subplot(1, 5, 1), imshow(seccAct1);
subplot(1, 5, 2), imshow(seccAct2);
subplot(1, 5, 3), imshow(seccAct3);
subplot(1, 5, 4), imshow(seccAct4);
subplot(1, 5, 5), imshow(seccAct5);

figure("Name", "Patron")
subplot(1, 5, 1), imshow(seccPat1);
subplot(1, 5, 2), imshow(seccPat2);
subplot(1, 5, 3), imshow(seccPat3);
subplot(1, 5, 4), imshow(seccPat4);
subplot(1, 5, 5), imshow(seccPat5);

clear camara;
