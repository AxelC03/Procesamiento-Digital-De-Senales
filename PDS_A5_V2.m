% Actividad 5 - Filtros mejorados
% Procesamiento Digital de Señales
% Equipo 5

clc
clear all

Fs=48000;
duracion=3;
bits=24;
canales=1;
grabacion=audiorecorder(Fs,bits,canales);

% Solicita al usuario el mensaje a grabar
disp('Comienza a hablar.')
recordblocking(grabacion, duracion);
disp('Fin de la grabacion.');

% Solicita al usuario el tipo de filtro a realizar
lectura=inputdlg('Elija el tipo de filtro: 1) Pasabajas 2) Pasaaltas');
tipoFiltro=str2num(lectura{1});

% Solicita al usuario la cantidad de veces que desea filtrar (Maximo 10)
askTimes=inputdlg('¿Cuántas veces desea filtrar? (Máximo 10)');
vecesFiltrado=str2num(askTimes{1});

% Guarda la información en un vector y en un archivo
mensaje=getaudiodata(grabacion);
audiowrite('mensaje.wav',mensaje,Fs);

%%LEER ARCHIVO DE AUDIO%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[mensaje,Fs] = audioread('mensaje.wav');
%%NORMALIZAR AUDIO%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mensaje = mensaje/max(abs(mensaje));
%sound(mensaje, Fs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%ESPECTRO DE LA SEÑAL ORIGINAL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
transformada=abs(fft(mensaje));
L=length(transformada);
espectro=transformada(1:L/2);
maximo=max(espectro);
espectro=espectro/maximo;
frecuencias=Fs*(1:L/2)/L;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%ETAPA DE FILTRADO%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T=1; %periodo de muestreo
%%FILTRO PASA-BAJAS%%
f3db=1600; %frecuencia de corte

% % Hagan una prueba con este if, y despues comentenlo
% if tipoFiltro==1
%     fc=f3db;
% else
%     fc=f3db/(sqrt((2^(1/vecesFiltrado))-1))
% end

% Comentado lo otro, descomenten este, para ver los cambios
fc=f3db/(sqrt((2^(1/vecesFiltrado))-1))

fnyq=Fs/2; %frecuencia de Nyquist
fnorm=fc/(fnyq); %frecuencia normalizada
tau=1/(2*pi*fnorm); %tau del filtro

if tipoFiltro==1
    funcion=abs(1./(i*(frecuencias/fc)+1));
elseif tipoFiltro==2
    funcion=abs((i*(frecuencias/fc)./(i*(frecuencias/fc)+1)));
else
    disp('Tipo no valido');
    return
end

% Pasabajas
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

% Pasaaltas
numsa=[tau, 0];
densa=[tau, 1];
numsa2=conv(numsa, numsa);
densa2=conv(densa, densa);
numsa3=conv(numsa2, numsa);
densa3=conv(densa2, densa);
numsa4=conv(numsa3, numsa);
densa4=conv(densa3, densa);
numsa5=conv(numsa4, numsa);
densa5=conv(densa4, densa);
numsa6=conv(numsa5, numsa);
densa6=conv(densa5, densa);
numsa7=conv(numsa6, numsa);
densa7=conv(densa6, densa);
numsa8=conv(numsa7, numsa);
densa8=conv(densa7, densa);
numsa9=conv(numsa8, numsa);
densa9=conv(densa8, densa);
numsa10=conv(numsa9, numsa);
densa10=conv(densa9, densa);

% Función de transferencia del filtro
if tipoFiltro==1
    switch vecesFiltrado
        case 1
            [numz, denz] = bilinear(nums, dens, T);
        case 2
            [numz, denz] = bilinear(nums2, dens2, T);
        case 3
            [numz, denz] = bilinear(nums3, dens3, T);
        case 4
            [numz, denz] = bilinear(nums4, dens4, T);
        case 5
            [numz, denz] = bilinear(nums5, dens5, T);
        case 6
            [numz, denz] = bilinear(nums6, dens6, T);
        case 7
            [numz, denz] = bilinear(nums7, dens7, T);
        case 8
            [numz, denz] = bilinear(nums8, dens8, T);
        case 9
            [numz, denz] = bilinear(nums9, dens9, T);
        case 10
            [numz, denz] = bilinear(nums10, dens10, T);
        otherwise
            disp('Orden no válido');
            return
    end
elseif tipoFiltro==2
    switch vecesFiltrado
        case 1
            [numz, denz] = bilinear(numsa, densa, T);
        case 2
            [numz, denz] = bilinear(numsa2, densa2, T);
        case 3
            [numz, denz] = bilinear(numsa3, densa3, T);
        case 4
            [numz, denz] = bilinear(numsa4, densa4, T);
        case 5
            [numz, denz] = bilinear(numsa5, densa5, T);
        case 6
            [numz, denz] = bilinear(numsa6, densa6, T);
        case 7
            [numz, denz] = bilinear(numsa7, densa7, T);
        case 8
            [numz, denz] = bilinear(numsa8, densa8, T);
        case 9
            [numz, denz] = bilinear(numsa9, densa9, T);
        case 10
            [numz, denz] = bilinear(numsa10, densa10, T);
        otherwise
            disp('Orden no válido');
            return
    end
else
    disp('Tipo no válido');
    return
end

%[numz, denz] = bilinear(nums, dens, T); %transformadaformada z del filtro
filtrado=filter(numz,denz,mensaje); %filtrar el audio
sound(filtrado,Fs)

%%%ESPECTRO DE LA SEÑAL FILTRADA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
transformada_filt=abs(fft(filtrado)); %transformadaformada de Fourier del audio filtrado
espectro_filt=transformada_filt(1:L/2); %tomar sólo la mitad del espectro
espectro_filt=espectro_filt/maximo; %normalizar el espectro filtrado respecto al original
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%GRÁFICAS DE RESULTADOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=length(mensaje); %longitud del vector de audio
t=n/Fs; %tiempo total que dura el audio
Ts=1/Fs; %periodo de muestreo
tiempo=[0:Ts:(t-Ts)]; %vector de tiempo

figure %invocar una ventana de figura nueva
grafica1=subplot(2,1,1) %subfigura de dos filas y una columna, grafica 1
plot(tiempo,mensaje,'b') %graficar el mensaje original en azul (b)
hold on %mantener la gráfica en primer plano para graficar sobre ella
plot(tiempo,filtrado,'r') %graficar el mensaje filtrado en rojo (r)
title(['Señal de audio capturada, en el dominio del tiempo']); %titulo de la grafica
xlabel('Tiempo (s)') %etiqueta para el eje X
ylabel('Amplitud') %etiqueta para el eje Y
legend('Audio original','Audio filtrado') %etiquetas para las señales

grafica2=subplot(2,1,2) %subfigura de dos filas y una columna, grafica 2
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
xlim([0 3000]) %limitar el rango en "x" al valor que deseemos
legend('Espectro original','Espectro filtrado','Respuesta del filtro') %etiquetas para las señales
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
