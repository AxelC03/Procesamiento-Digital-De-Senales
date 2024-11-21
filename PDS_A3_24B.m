% Actividad 3 - Correlacion de imagenes
% Equipo 3 - Ahora en Matlab

clc;
clear all;

% Antes de cualquier cosa, ejecuten el comando
% arduinosetup
% para saber si Matlab reconoce la tarjeta y en que puerto com esta
% conectada.
% Tambien, ejecuten el codigo capturaImagen_A3 para que tengan ya las
% imagenes patron en su carpeta, muevan tanto ese código como este
% a la carpeta Documentos\Matlab para que todo funcione

% Activa la camara y la configura en resolucion HD
camara=webcam(1);
camara.Resolution='1280x720';

% Inicializa la tarjeta de desarrollo
% tarjeta=arduino("COM5", "Uno", "Libraries", "Servo"); % Cambien el puerto segun sea el caso

% Se define el valor de correlacion minimo aceptable
similitud=0.7;

% Declara el pin a utilizar en Arduino
serv_pin="d6"; 

% Define el objeto para el servo
% indicador=servo(tarjeta, serv_pin);
% clear indicador;
%%%% IMPORTANTE %%%%
% La duracion de los pulsos dependen de cada servo, es VITAL que sepan
% cuales son para que funcione y gire adecuadamente, revisen en la hoja de
% datos estos valores y ponganlos segun corresponda, suelen venir en milis
% o microsegundos, "e" es el operador "elevado a la "
% indicador=servo(tarjeta, serv_pin, 'MinPulseDuration', 100e-6, 'MaxPulseDuration', 2000e-6);

% Matriz de filtro suave para ayudar con la comparacion
matrizsuave=[0.0625,0.125,0.0625;0.125,0.25,0.125;0.0625,0.125,0.0625];

% Se mandan llamar las imagenes patrón y se almacenan varias variables
original1=imread('Patron1.png');
original2=imread('Patron2.png');
original3=imread('Patron3.png');

% Define las posiciones donde se encuentra cada imagen en funcion del servo
% 0 => maximo a la izquierda del servo
% 1 => maximo a la derecha del servo
posIm1=0.20;
posIm2=0.40;
posIm3=0.60;
posNeu=0.80;

% Se crea una barra de espera para detener el bucle
wb=waitbar(0, 'Presiona cancel para detener', 'Name', 'Detener el bucle', 'CreateCancelBtn', 'delete(gcbf)');
disp("Comenzando captura continua...");
pause(3);

while true
    clc;

    % Captura la imagen actual y la convierte a escala de grises
    imgActual=snapshot(camara);
    imgActual=rgb2gray(imgActual);

    % Muestra la imagen capturada
    imshow(imgActual);
    title("Imagen actual");
    
    % Filtra todas las imagenes
    patSua1=imfilter(original1, matrizsuave);
    patSua2=imfilter(original2, matrizsuave);
    patSua3=imfilter(original3, matrizsuave);
    actSua=imfilter(imgActual, matrizsuave);
    
    % Calcula las correlaciones de la imagen actual con cada imagen patron
    corrPat1=corr2(actSua, patSua1);
    corrPat2=corr2(actSua, patSua2);
    corrPat3=corr2(actSua, patSua3);
    
    % Comparacion de correlaciones
    if(corrPat1>similitud && corrPat1>corrPat2 && corrPat1>corrPat3)
        secc=1;
    elseif(corrPat2>similitud && corrPat2>corrPat1 && corrPat2>corrPat3)
        secc=2;
    elseif(corrPat3>similitud && corrPat3>corrPat1 && corrPat3>corrPat2)
        secc=3;
    else
        secc=4;
    end
    
    % switch secc
    %     case 1:
    %         writePosition(indicador, posIm1);
    %     case 2:
    %         writePosition(indicador, posIm2);
    %     case 3:
    %         writePosition(indicador, posIm3);
    %     otherwise
    %         writePosition(indicador, posNeu);
    % end

    % Detener la grabación si se ha presionado el boton de cancel
    if ~ishandle(wb)
        break
    end

    disp("Pausando para la siguiente captura...");
    pause(5);
    ishandle();
end

clear camara;