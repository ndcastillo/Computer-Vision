classdef NodoViajero
    properties
        xn; yn; % Nodo Viajero
        xmeta; ymeta; % Nodo Meta
        f; g; h; w; % Busqueda No Informada
        imE;
        theta; 
        ListaAbierta; 
        ListaCerrada;
        camino;
    end
    
    methods
        
        function self = init(self,xini,yini,xmeta,ymeta,imE)
            self.xn = xini; 
            self.yn = yini;
            self.xmeta = xmeta; 
            self.ymeta = ymeta;
            self.ListaCerrada = [xini; yini];
            [row col]=size(imE);
            self.camino = zeros(row,col);
            self.imE = imE;
        end
        
        function self = analisisVecinos(self)
            
            x = [self.xn-1 self.xn-1 self.xn self.xn+1  self.xn+1 self.xn+1 self.xn self.xn-1];
            y = [self.yn self.yn-1 self.yn-1 self.yn-1  self.yn self.yn+1 self.yn+1 self.yn+1];
            
            if self.yn < self.ymeta && self.xn < self.xmeta
                w = [10 32 30 32 10 14 10 14];
            elseif self.yn >= self.ymeta && self.xn < self.xmeta
                w = [32 32 30 32 10 14 10 14];
            elseif self.yn > self.ymeta && self.xn >= self.xmeta
                w = [30 14 10 14 10 32 30 32];
            else
                w = [10 14 10 14 10 14 10 14];
            end

            self.h=[]; self.g=[]; self.f=[]; self.theta=[];
            self.ListaAbierta = [];
            repositorio = [];
            director = [];
            for k = 1:8
                if x(k) < 0 || y(k) < 0
                    repositorio  = [repositorio k];
                else
                    self.g(k) = self.imE( y(k) , x(k) );
                    if self.g(k) == 1
                        % Nodos catalogados como Obstaculos
                       repositorio = [repositorio k];
                    elseif length(self.ListaCerrada)>20
                        % Nodos que ya se encuentran en la lista cerrada
                       
                       director = find(self.ListaCerrada(1,:) == x(k) & self.ListaCerrada(2,:) == y(k));
                       if ~isempty( director )
                            repositorio = [repositorio k];
                       end
                    end
                    
                end
            end
            
 
            x(repositorio) = [];
            y(repositorio) = [];
            w(repositorio) = []  ;
            
            
            self.ListaAbierta = [x(:) , y(:) , w(:)]';
            
            [m1 n1] = size(self.ListaAbierta);
            
            for p = 1:n1
                self = self.detectorObstaculos(p,self.ListaAbierta(1,p),self.ListaAbierta(2,p),self.ListaAbierta(3,p));
            end
            lowcost = find(self.f == min(self.f(:)));
            self.xn = self.ListaAbierta(1,lowcost); self.yn = self.ListaAbierta(2,lowcost);
            self = self.append(self.ListaAbierta(1,lowcost),self.ListaAbierta(2,lowcost));
            
        end
        
        function self = append(self,x,y)
            self.ListaCerrada = [self.ListaCerrada(1,:) self.xn; self.ListaCerrada(2,:) self.yn];
            self.imE(y,x) = 1;
        end
        
        function self = detectorObstaculos(self,i,x,y,w)
           self = self.heuristica(x,y,i);
           self.f(i) = w + self.h(i);
        end
        
        function self = heuristica(self,xi,yi,i)
            y = norm(self.ymeta-yi);
            x = norm(self.xmeta-xi);
            if x == 0
               % disp('Es un x');
                self.h(i) = sqrt(y^2+x^2)*10;
                self.theta(i) = pi/2;
            elseif y == 0
                %disp('Es un y');
                self.h(i) = sqrt(y^2+x^2)*10;
                self.theta(i) = 0;
            else
                self.h(i) = sqrt(y^2+x^2)*10;
                self.theta(i) = atan(y/x);
            end
        end
    end
end