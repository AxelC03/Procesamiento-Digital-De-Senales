% Actividad 4 - Filtros digitales de voz
% Equipo 3

clc
clear all

% Declaracion de los parametros de la grabacion
Fs = 48000;
duracion = 3;
bits = 24;
canales = 1;
grabacion = audiorecorder(Fs, bits, canales);

% Señala al usuario el principio y final de la grabacion
disp("Comenzando a grabar...");
recordblocking(grabacion, duracion);
clc
disp("Grabacion finalizada");

% Solicita al usuario el tipo de filtro a realizar
tipoFiltro=input("Elija el tipo de filtro: 1) Pasabajas 2) Pasaaltas \n");
% tipoFiltro=str2num(lectura);

% Solicita al usuario la cantidad de veces que desea filtrar (Maximo 10)
vecesFiltrado=input("¿Cuántas veces desea filtrar? \n");
% vecesFiltrado=str2num(askTimes);

% Guarda la información en un vector y en un archivo
mensaje=getaudiodata(grabacion);
audiowrite('mensaje.wav',mensaje,Fs);

% Carga el audio desde el archivo y se normaliza
[mensaje,Fs] = audioread('mensaje.wav');
mensaje = mensaje/max(abs(mensaje));

% Se obtienen los parámetros del archivo
n=length(mensaje); %longitud del vector de audio
t=n/Fs; %tiempo total que dura el audio
Ts=1/Fs; %periodo de muestreo
tiempo=[0:Ts:(t-Ts)]; %vector de tiempo

% Diseño de filtros
fs=1;
T=1/fs; %periodo de muestreo

fc=1300; %frecuencia de corte
fnyq=Fs/2; %frecuencia de Nyquist
fnorm=fc/fnyq; %frecuencia normalizada
tau=1/(2*pi*fnorm); %tau del filtro

% Espectro de la señal original
transformada=abs(fft(mensaje));
L=length(transformada);
espectro=transformada(1:L/2);
maximo=max(espectro);
espectro=espectro/maximo;
frecuencias=Fs*(1:L/2)/L;

% Asignacion de la funcion de transferencia segun corresponda
if tipoFiltro==1
    num = [1];
    den = [tau, 1];
    funcion=abs(1./(i*(frecuencias/fc)+1));
elseif tipoFiltro==2
    num = [tau, 0];
    den = [tau, 1];
    funcion=abs((i*(frecuencias/fc))./(i*(frecuencias/fc)+1));
else
    disp("Opcion invalida! Aplicando filtro pasabajas");
    num = [1];
    den = [tau, 1];
    funcion=abs(1./(i*(frecuencias/fc)+1));
end

% Variable para la grafica de la respuesta en frecuencia del filtro
funcionAux = funcion;

% Se declara variable auxiliar para el calculo de la TF del filtro
auxN=num;
auxD=den;

% Bucle para obtener la TF de acuerdo al grado del filtro
for i=1:(vecesFiltrado-1)
    auxN=conv(auxN, num);
    auxD=conv(auxD, den);
    funcionAux=funcionAux.*funcion;
    % funcionAux=funcionAux.^vecesFiltrado;
end

funcion=funcionAux;

% Forma la TF para la grafica de polos y ceros
funTran = tf(auxN, auxD);

% Se convierte la TF en el dominio de s al dominio Z
[numz, denz] = bilinear(auxN, auxD, T);

% Convolucion y filtrado
filtrado=filter(numz,denz,mensaje); %filtrar el audio
sound(filtrado,Fs) %reproducir el audio filtrado

% ESPECTRO DE LA SEÑAL FILTRADA
transformada_filt=abs(fft(filtrado)); %transformadaformada de Fourier del audio filtrado
espectro_filt=transformada_filt(1:L/2); %tomar sólo la mitad del espectro
espectro_filt=espectro_filt/maximo; %normalizar el espectro filtrado respecto al original

% GRÁFICAS DE RESULTADOS
figure %invocar una ventana de figura nueva
grafica1=subplot(2,1,1) %subfigura de dos filas y una columna, grafica 1
plot(tiempo,mensaje,'b') %graficar el mensaje original en azul (b)
hold on %mantener la gráfica en primer plano para graficar sobre ella
plot(tiempo,filtrado,'r') %graficar el mensaje filtrado en rojo (r)
title(['Señal de audio capturada, en el dominio del tiempo']); %titulo de la grafica
xlabel('Tiempo (s)') %etiqueta para el eje X
ylabel('Amplitud') %etiqueta para el eje Y
legend('Audio original','Audio filtrado') %etiquetas para las señales

grafica2=subplot(2 ,1 ,2)
plot(frecuencias,espectro,'b') %graficar el espectro de la señal
hold on %mantener la gráfica en primer plano para graficar sobre ella
plot(frecuencias,espectro_filt,'r') %graficar el espectro de la señal filtrada
hold on
plot(frecuencias,funcion,'g')
title(['Espectro de la señal capturada']); %titulo de la grafica
xlabel('Frecuencia (Hz)') %etiqueta para el eje X
ylabel('Amplitud') %etiqueta para el eje Y
grid(grafica2,'on') %activar la cuadrícula en la gráfica 2
set(gca,'YTick',[0.1]) %graficar una linea de la cuadricula de y en 0.1
%set(gca,'XTick',[fc]) %graficar una linea de la cuadricula de x en la frecuencia máxima de mi voz
ylim([0 max(espectro)]) %limitar el rango en "y" al valor máximo de la señal
xlim([0 5000]) %limitar el rango en "x" al valor que deseemos
legend('Espectro original','Espectro filtrado','Respuesta del filtro') %etiquetas para las señales

figure()
zplane(numz, denz);