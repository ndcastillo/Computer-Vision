% Proyecto 3 - Redes Neuronales


function main()
    clc; clear; close all
    im = rgb2gray(imread('layout4.jpg'));   % Read original image file
    
    % Segmentacion
    th= 200; imbw = im;          % Upper & lower bounds for bw
    imbw(imbw <= th) = 0; 
    imbw(imbw >= th) = 1;        % Binarizing the image
    imbw = ~imbw;
    
    % Deteccion de Orillas
    imE = edge(imbw, 'canny', [0.0, 0.95]); % Detect edges on the image

    
    % Deteccion de Circulos por la Transformada de Hough
    % Centros, radios de los circulos
    [centros, radios] = imfindcircles(imE, [15 40]);
    num_centros = length(centros);
    
    % Verificacion de Circulos
    if num_centros ==  0
        disp('No existe ningun punto de partida')
    else
        %viscircles(centros, radios, 'EdgeColor', 'b')
        disp('# ciculos : '); disp(length(centros))
        disp('Centros: '); disp(centros)
        disp('radioss: '); disp(radios)
        
         %Inicio=imcrop(im);
         Inicio=imread('Inicio.jpeg');
         %imshow(Inicio)
         %imwrite(Inicio,'Inicio.jpeg')
 
          %Final
          %Final=imcrop(im);
          Final=imread('Final.jpeg');
        

        %Se procede a realizar la correlación cruzada en busqueda de las palabras
        %Inicio y Final
        ind2=findTemplate(im, Final);
        ind=findTemplate(im,Inicio);
        
        %Encontramos las distancias minimas de las palabras con los circulos para
        %saber que punto es el inicio y cual es el final
        XYmeta=round(CalcularDistancia(centros, ind2));
        xmeta=XYmeta(1);
        ymeta=XYmeta(2);
        XYini=round(CalcularDistancia(centros, ind));
        xini=XYini(1);
        yini=XYini(2);

        %Pintamos la imagen de negro:

        imE=PintarBolitas(imE,XYini,18);
        imE=PintarBolitas(imE,XYmeta,18);

        disp('Inicio: ')
        disp(XYini)
        disp('Final')
        disp(XYmeta)
        
        
        SE = strel('square', 13);               % Structuring element
        imE = imclose(imE, SE);                 % Morphologic image closing
        imE = imfill(imE, 4, 'holes');          % Fill holes
        %[lima dn] = bwlabel(imE,8);
        %meas = regionprops(lima);
        SE2 = strel('rectangle',[ 15 15 ]);
        imE = imdilate(imE,SE2);
        figure; imshow(imE)
        
        
        % Objetos
        n = NodoViajero();
        n = init(n,xini,yini,xmeta,ymeta,imE);
        
        % Algoritmo Estrella
        n = estrella(n,imE);
        
        %Graficamos:
        centers=[XYini;XYmeta];
        if(length(centers)~=0)
         radii=radios(1:2,1);
        end
       
        figure; imshow(im); hold on;   
        viscircles(centers, radii, 'EdgeColor', 'y');
        plot(n.ListaCerrada(1,:),n.ListaCerrada(2,:),'m');
        figure; imshow(n.camino);
        hold off
        
    end
end

function ind=findTemplate(im,t)
res=normxcorr2(t,im);
[rt, ct]=size(t);
[rawRow rawCol]=find(res==max(res(:)));
col=rawCol-floor(ct/2);
row=rawRow-floor(rt/2);
surf(res); shading flat
ind=[row col];
end

function Circulo = CalcularDistancia(centro, posicion)
distancias = [];
for i=1: length(centro)
    distancia=sqrt((centro(i,1)-posicion(2))^2+(centro(i,2)-posicion(1))^2);
    distancias=[distancias distancia];
end
M=min(distancias);
indice=find(distancias==M);
Circulo=centro(indice,1:end);
end


function n = estrella(n,imE)

    try
        while true
            
            n = analisisVecinos(n);
            if (n.xn>=n.xmeta-1 & n.xn <= n.xmeta+1) & (n.yn>=n.xmeta-1 & n.yn <= n.ymeta+1) 
                disp('Felicitaciones Llego!')
                break;
            elseif n.xn == 0 | n.yn == 0
                disp('Salimos bro')
                break
            end
            
            %imshow(imE); hold on;      
            %plot(n.ListaCerrada(1,:),n.ListaCerrada(2,:),'m');    
            %drawnow;
            %pause(0.01);
            
        end
    catch
        figure; imshow(imE); hold on;      
        plot(n.ListaCerrada(1,:),n.ListaCerrada(2,:),'m');
        
    end
end


function imF2 = PintarBolitas(imagen,ind,radio)
for i=-radio: radio
    for  j=-radio:radio
        imagen(ind(2)+i,ind(1)+j)=0;       
    end
end
imF2=imagen;

end