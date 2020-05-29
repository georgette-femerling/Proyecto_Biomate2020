clc, clear

% Parametros
% Numero basico de reproduccion
Ro    = 2.8;

% Periodo de exposicion
gamma = 1/14;

% Transmision
beta  = Ro*gamma;
alfa  = 0;           

% Poblacion
N     = 7e6;

% Condiciones Inciales
I0    = 1 / N;
S0    = 1 - I0;
R0    = 0;
y0    = [S0 I0 R0];

%Tiempo de integracion
tspan = [0:1:200];

%Dias de simulación
psimulation = 200;

%Simulacion
[ t, SIR ] = ode45( @(t,SIR) odefun(t,SIR, ...
             alfa,beta,gamma), tspan, y0 ); 

%figure("Visible",false)
QuarantineDurations = [7 14 21 28 35 42 63 70 77 84 91];
QuarantineStarts = [0 10 30 50 60 70];

nSim = length(QuarantineDurations) * length(QuarantineStarts);
n = 1;
for start=QuarantineStarts
	for period=QuarantineDurations
        fig = figure;
    	[ mSat dSat ] = quarantine(start, period, psimulation, ...
                        false, false, y0, beta, gamma);
        legend( 'I sin aislamiento', 'I aislamento', ...
                'demanda', 'capacidad')
		M(n,1) = start;
		M(n,2) = period;
		M(n,3) = mSat;
		M(n,4) = dSat;
		n = n+1;
        fig.PaperPositionMode = 'manual';
        orient(fig,'landscape');
        title = strcat('figureGrid_',num2str(n),'.pdf');
        print(fig,title,'-dpdf');
	end	
end

T =  table(M);
writetable(T, 'GridExploration.txt');
fig = figure;
imagesc(M), colorbar;
colormap(hot);
print(fig,'GridColorResultMatrix','-dpdf');

close all
return