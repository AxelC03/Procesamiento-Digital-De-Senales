% Actividad 7 - Proyecto final
% Torreta seguidora de movimiento
% Equipo 5
% Todo termino

clc
clear all
close all

cam=webcam(1);

% Para ayudar al reconocimiento se declarán las matrices de filtrado
matrizsuave=[0.0625,0.125,0.0625;0.125,0.25,0.125;0.0625,0.125,0.0625];


wb=waitbar(0, '-', 'Name', 'Espera..', 'CreateCancelBtn', 'delete(gcbf)');
i=0;
while true
    img0=snapshot(cam);
    img=rgb2gray(img0);
    imgAz=imsubtract(img0(:,:,1), img);
    bw=im2bw(imgAz, 0.007);
    %bw=medfilt2(bw);
    bw=imfilter(imgAz, matrizsuave);
    bw=imopen(bw, strel('disk', 1));
    bw=bwareaopen(bw, 3000); % Se eliminan objetos con área menos a 3000 pixeles
    bw=imfill(bw, 'holes');
    [L N]=bwlabel(bw);
    % Regionprops -----
    prop=regionprops(L);
    %------------------
    imshow(img0);
    for n=1:N
        c=round(prop(n).Centroid); %Obtener un centroide
        rectangle('Position',prop(n).BoundingBox,'EdgeColor','g', 'LineWidth',2); % Dibujar un rectangulo
        text(c(1),c(2),strcat('X',num2str(c(1)),'Y',num2str(c(2))),'Color','g'); % Agregar coordenadas
    end
    if ~ishandle(wb)
        break
    else
        waitbar(i/10, wb, ['num: ' num2str(i)]);
    end
    i=i+1;
    pause(0.001);
end
clear cam