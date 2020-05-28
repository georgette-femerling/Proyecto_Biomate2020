clc, clear

run('lib/addpath_recurse.m');
addpath_recurse('lib/');
addpath_recurse('src/');

%% Preparamos la estructura de carpetas

% Cada simulación se guarda en su propia carpeta
runDir=['_sim_',datestr(now,'yyyymmdd_HHMMSS'),'/'];

%runDir=[]; %Descomentar si no queremos guardar las imagenes

if ~isempty(runDir)  %Si estamos exportando las imagenes
    if ~exist(runDir, 'dir')
        mkdir(runDir);
        disp(['Creando carpeta ',runDir]);
    end
end
%% Parametros y Condiciones iniciales
% Parametros
% Numero basico de reproduccion
Ro    = 2.83;
% periodo de exposicion
gamma = 1/14;
% Transmicion
beta  = Ro*gamma;
alfa  = 0;           
% Campana de Vacunacion
% V     = .5 ; %Percentage of poulation to be vaccinated
% TVi   = 80; %First day of vaccine
% TVd   = 1; %Duration of the vaccination campaign
% TVf   = TVi + TVd; %Last day of vaccination
% epsilon = double(V / TVd); %Rate at which a susceptible individual gets vaccinated

% Poblacion
N     = 7e6;

% Condiciones Inciales
I0    = 1 / N;
S0    = 1 - I0;
R0    = 0;
y0    = [S0 I0 R0];

%Tiempo de integracion
dur = 300;
tspan = [1:1:dur];

% Simulacion
[ t, SIR ] = ode45( @(t,SIR) odefun(t,SIR, ...
             alfa,beta,gamma), tspan, y0 ); 

% Pandemia sin intervenciones
figure(1)
%subtitle('Simulacion')
plot(   t,SIR( :, 1 ), '.', ...
        t,SIR( :, 2 ), '.', ...
        t,SIR( :, 3 ), '.', ...
        'markersize'   , 15 ), hold on
title('pandemia sin intervencion')
xlabel('dias'), ylabel('proporcion')
legend('S', 'I', 'R')
hold off 

%% Variables to try
VaccineDurations =    [1 5 10 15 20 30];
VaccineStarts =       [1 30 60 80 100];
VaccineFractions =    [0.2 0.4 0.6 0.8 1.0];
%VaccineFractions =    [0.4];
%% Conduct simulations

for j=1:length(VaccineDurations)
    figure(j)
    for i=1:length(VaccineFractions)
        subplot(2,3,i)
        titleplot = strcat('Vacuna al ', {' '}, num2str(VaccineFractions(i)*100), '% durante ', {' '}, num2str(VaccineDurations(j)), ' dias');
        for k = 1:length(VaccineStarts)
            epsilon = double(VaccineFractions(i) / VaccineDurations(j));
            vacuna(VaccineStarts(k), VaccineDurations(j), dur, y0, beta, gamma, epsilon, VaccineFractions(i));
            Legend{k}=num2str(VaccineStarts(k));
        end
        plot(   t,SIR( :, 2 ), '.-','markersize', 8,'color', 'blue'), hold on
        Legend{k+1}='no Vac';
        legend(Legend);
        title( titleplot )
        hold off
        %outFile=[runDir,'SIR_ODE_Vac_frac',num2str(round(VaccineFractions(i)*100)),'.png'];                                                                                                                                                                                                                                                                
        %export_fig(outFile) 
    end
end

