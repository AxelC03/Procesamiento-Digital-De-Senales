%Actividad 2 - Tratamiento de una imagen
%Procesamiento digital de señales
clc

%Solicita al usuario la cantidad de veces que dese aplicar el 
lectura=inputdlg('Introduzca la cantidad de veces que desea suavizar');
%Convierte el valor leido a un número
vecesSuavizado=str2num(lectura{1});

%En caso de que no se ejecute en mi laptop
%webcamlist

%Activa la camara y crea un objeto con la lectura de esta
camara=webcam('USB2.0 HD UVC WebCam');
%Configura la resolución al maximo
camara.Resolution = '1280x720';

%Toma una foto
foto=snapshot(camara);
%Convierte la foto anterior a escala de grises
fotogris=rgb2gray(foto);
%Se definen las matrices de filtrado
matrizsuave=[0.0625,0.125,0.0625;0.125,0.25,0.125;0.0625,0.125,0.0625]
matrizcontorno=[-1,-1,-1;-1,8,-1;-1,-1,-1]

%imagensuave=imfilter(fotogris,matrizsuave);
imagensuave=fotogris;

%Inicia el bucle de suavizado
for i=1:vecesSuavizado
    imagensuave=imfilter(imagensuave,matrizsuave);
end

%Se filtra la imagen suavizada para contorno
imagencontorno=imfilter(imagensuave,matrizcontorno);

%Se muestra al usuario el resultado
figure();
subplot(2, 1, 1)
imshow(fotogris);
title("Imagen original")
subplot(2, 1, 2)
imshow(imagencontorno)
title("Imagen filtrada")

clear all