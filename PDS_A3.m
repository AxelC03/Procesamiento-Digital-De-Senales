% Actividad 3 - Reconocimiento de una imagen
% Procesamiento Digital de Señales
% Equipo 5

% Profe, si lee esto, tenga piedad en nuestra exposición

clc
clear all

% Se inicializa la tarjeta que servirá para activar el hardware externo
%%%%% OJO %%%%
% Es importante primero verificar en que puerto está conectada la tarjeta,
% para esto se debe usar el comando 
% arduinosetup
tarjeta=arduino("COM3", "Uno");

% Define el valor a partir del cual se considera aceptable la similitud
similitud=0.7

% Define el pin para activar el relevador
led_pin="d13";

% Para ayudar al reconocimiento se declarán las matrices de filtrado
matrizsuave=[0.0625,0.125,0.0625;0.125,0.25,0.125;0.0625,0.125,0.0625];

% Esta es opcional
%matrizcontorno=[-1,-1,-1;-1,8,-1;-1,-1,-1];

% Manda llamar la imagen patrón y se almacena en una variable
imagenoriginal=imread('fotogris.png');

% Activa la camara de la computadora y se selecciona la máxima resolución
camara=webcam(1);
camara.Resolution = '1280x720';

% Toma una foto, que es convertida a escala de grises para ser comparada
% con la imagen patrón
foto2=snapshot(camara);
fotogris2=rgb2gray(foto2);

% Filtra ambas imagenes
imgSuaveOr=imfilter(imagenoriginal, matrizsuave);
imgSuaveAc=imfilter(fotogris2, matrizsuave);

% Obtiene la correlacion 
%correlacion=corr2(imagenoriginal,fotogris2)
correlacion=corr2(imgSuaveOr,imgSuaveAc)

% Realiza la comparación entre ambas señales
if correlacion>similitud
    % Envia un pulso alto para activar el relevador si la correlación es
    % es superior al valor de similitud
    writeDigitalPin(tarjeta,led_pin,1);
else
    % De lo contrario, envia un pulso bajo
    writeDigitalPin(tarjeta,led_pin,0);
end

% Muestra ambas imagenes usadas en la comparación
figure
subplot(2,1,1)
imshow(imgSuaveOr);
title("Imagen patrón")
subplot(2,1,2)
imshow(imgSuaveAc);
title("Imagen actual")

clear camara