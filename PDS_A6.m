% Actividad 6 - Torreta guiada por voz
% Procesamiento Digital de Señales
% Equipo 5
% Ayuda, Dios nos abandono

clc
clear all

% tarjeta=arduino("COM5");

% Define los pines a utilizar
% laser_pin="d12"; % Pin para activar el laser
% rec_pin="d7"; % Pin para mostrar que está grabando
% stop_pin="d8"; % Pin de espera
% serX="d5"; % Pin del servo para eje X
% serY="d6"; % Pin del servo para eje Y

% Se declaran los objetos para los servos
% servoX=servo(tarjeta, serX);
% clear servoX;
% servoX=servo(tarjeta, serX, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);
% servoY=servo(tarjeta, serY);
% clear servoY;
% servoY=servo(tarjeta, serY, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2500e-6);

% Se inicializan dichos pines
% writeDigitalPin(tarjeta,laser_pin,0);
% writeDigitalPin(tarjeta,rec_pin,0);
% writeDigitalPin(tarjeta,stop_pin,0);

Fs=48000;
duracion=2;
bits=24;
canales=1;
grabacion=audiorecorder(Fs,bits,canales);

tiempo=tic;

while toc(tiempo)<10
    disp('Comience a hablar');
    writeDigitalPin(tarjeta,rec_pin,1);
    writeDigitalPin(tarjeta,stop_pin,0);
    recordblocking(grabacion, duracion);
    comando=getaudiodata(grabacion);
    disp('Fin de la grabacion.');
    writeDigitalPin(tarjeta,rec_pin,0);
    writeDigitalPin(tarjeta,stop_pin,1);
    pause(0.1)
    % captura=input("Elija el avance del servo (0 a 1)");
    % pause(1.5);
    % writePosition(servoX, captura);
end

% sound(comando, Fs);

% for i=0:15
%     writeDigitalPin(tarjeta,laser_pin,1);
%     pause(0.05);
%     writeDigitalPin(tarjeta,laser_pin,0);
%     pause(0.05);
% end
% writeDigitalPin(tarjeta,laser_pin,1);