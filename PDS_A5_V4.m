% % Actividad 5 - Filtros mejorados
% Procesamiento Digital de Señales
% Equipo 5
% Estoy cansado, jefe

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

% Guarda la información en un vector y en un archivo
mensaje=getaudiodata(grabacion);
audiowrite('mensaje.wav',mensaje,Fs);

%% LECTURA DEL ARCHIVO DE AUDIO
[mensaje,Fs] = audioread('mensaje.wav');    % Cargar el archivo de audio

mensaje = mensaje/max(abs(mensaje));        % Normalizar el audio
%sound(mensaje, Fs)                         % Reproducir el audio cargado
n = length(mensaje);                        % Longitud del vector de audio
t = n/Fs;                                   % Tiempo total que dura el audio
Ts = 1/Fs;                                  % Periodo de muestreo
tiempo=[0:Ts:(t-Ts)];                       % Vector de tiempo

%% ESPECTRO DE LA SEÑAL ORIGINAL
transformada=abs(fft(mensaje));
L=length(transformada);
espectro=transformada(1:L/2);
maximo=max(espectro);
espectro=espectro/maximo;
frecuencias=Fs*(1:L/2)/L;

%% ETAPA DE FILTRADO
fs = 1;
T = 1/fs;               % Periodo de muestreo
fc = 1000;              % Frecuencia de corte
fnyq = Fs/2;            % Frecuencia de Nyquist
fnorm = fc/fnyq;        % Frecuencia normalizada
tau = 1/(2*pi*fnorm);   % Tau del filtro

if tipoFiltro == 1
    % FILTRO PASA-BAJAS
    nums = [1];       % Numerador TF del filtro pasa-bajas
    dens = [tau,1];   % Denominador TF del fitro pasa-bajas
    funcion=abs(1./(i*(frecuencias/fc)+1));
    Y = 1;
elseif tipoFiltro == 2
    % FILTRO PASA-ALTAS
    nums = [tau,0];   % Numerador TF del filtro pasa-altas
    dens = [tau,1];   % Denominador TF del fitro pasa-altas
    funcion=abs((i*(frecuencias/fc))./(i*(frecuencias/fc)+1));
    Y = 1;
else 
    disp('Tipo no valido')
    Y = 0;
end

% DEFINICION DE LA FUNCION DE TRANSFERENCIA
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

askTimes=inputdlg('¿Cuántas veces desea filtrar? (Máximo 10)');
vecesFiltrado=str2num(askTimes{1});

switch vecesFiltrado
    case 1
        numsfinal=nums;
        densfinal=dens;
        funcionfinal = funcion;
    case 2
        numsfinal=nums2;
        densfinal=dens2;
        funcionfinal = funcion.*funcion;
    case 3
        numsfinal=nums3;
        densfinal=dens3;
        funcionaux = funcion;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcionaux;
    case 4
        numsfinal=nums4;
        densfinal=dens4;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcion;
    case 5
        numsfinal=nums5;
        densfinal=dens5;
        funcionaux = funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcionaux;
    case 6
        numsfinal=nums6;
        densfinal=dens6;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcion;
    case 7
        numsfinal=nums7;
        densfinal=dens7;
        funcionaux = funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcionaux;
    case 8
        numsfinal=nums8;
        densfinal=dens8;
        funcionaux = funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcionaux;
    case 9
        numsfinal=nums9;
        densfinal=dens9;
        funcionaux = funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcionaux;
    case 10
        numsfinal=nums10;
        densfinal=dens10;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcion = funcion.*funcion;
        funcionfinal = funcion.*funcion;
    otherwise
        numsfinal=nums;
        densfinal=dens;
end

[numz, denz] = bilinear(nums, dens, T); % Transformada z del filtro
filtrado = filter(numz,denz,mensaje);   % Filtrar el audio
sound(filtrado,Fs)                      % Reproducir el audio filtrado

%% ESPECTRO DE LA SEÑAL FILTRADA
transformada_filt=abs(fft(filtrado)); %transformadaformada de Fourier del audio filtrado
espectro_filt=transformada_filt(1:L/2); %tomar sólo la mitad del espectro
espectro_filt=espectro_filt/maximo; %normalizar el espectro filtrado respecto al original

%% GRÁFICAS DE RESULTADOS
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
xlim([0 5000]) %limitar el rango en "x" al valor que deseemos
legend('Espectro original','Espectro filtrado','Respuesta del filtro') %etiquetas para las señales