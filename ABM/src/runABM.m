%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% El modelo SIR de agentes individuales mas simple del mundo
% RPM [03/04/20]
%
% Disclaimer: Este modelo es informativo y no se debe usar 
% para definir políticas de salud pública.
%
% Inspirado en un artículo de Harry Stevens para el Washington Post
% https://www.washingtonpost.com/graphics/2020/world/corona-simulator/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Primero importamos las librerías externas y funciones propias
clc; 
close all; 
clear;

run('lib/addpath_recurse.m');
addpath_recurse('lib/');
addpath_recurse('src/');

%% Preparamos la estructura de carpetas

% Cada simulación se guarda en su propia carpeta
runDir=['runs/_sim_',datestr(now,'yyyymmdd_HHMMSS'),'/'];

%runDir=[]; %Descomentar si no queremos guardar las imagenes

if ~isempty(runDir)  %Si estamos exportando las imagenes
    if ~exist(runDir, 'dir')
        mkdir(runDir);
        disp(['Creando carpeta ',runDir]);
    end
end

%% Parametros del modelo

nSteps=500;  %Numero de iteraciones
numAgents=200;  %Numero de agentes

recovery_rate=0.01; %Probabilidad de que, estando infectado, un agente se recupere
fracQuarentined=0.2;  %Porcentaje de la población que no se mueve: [0,1]
speed=1;  %Velocidad de los agentes
susanaDistancia=2.5;  %Radio de interacción entre agentes

w=100;  % El mundo es un cuadrado de w x h
h=100;

%% Lo primero, es crear el mundo

chamilpa=world(w, h, susanaDistancia);

%% Ahora un objeto que lo habite

ID1=1;
state1=0; %Vamos a suponer que es susceptible
xpos1=w/2;
ypos1=h/2;
speed1=speed;
direction1=2*pi*rand;

agent1=agent(ID1, state1, xpos1, ypos1, speed1, direction1, recovery_rate);

%%  Ahora asocia ese agente al mundo

chamilpa=chamilpa.addAgent(agent1);

% Le decimos al mundo que se grafique a si mismo
chamilpa.plotWorld(1);

%% El agente se siente solo, asi que le hacemos un amigo

ID2=2;  %Se llama distinto
state2=0; %Tambien es susceptible
xpos2=randi(w);  %Esta en una posicion al azar
ypos2=randi(h);
speed2=speed; %A la misma velocidad
direction2=rand*2*pi; %Pero en una direccion distinta

agent2=agent(ID2, state2, xpos2, ypos2, speed2, direction2,recovery_rate);  %Creamos al agente

chamilpa=chamilpa.addAgent(agent2);  %Y lo agregamos al mundo

%chamilpa.plotWorld(1);  %Los podemos graficar juntos

%% Muchos amigos!

for i=1:numAgents
    this_ID=i;  %Se llama distinto
    this_state=0; %Tambien es susceptible
    this_xpos=randi(w);  %Esta en una posicion al azar
    this_ypos=randi(h);
    this_speed=speed;
    
    this_direction=rand*2*pi; %Pero en una direccion distinta
    
    this_agent=agent(this_ID, this_state, this_xpos, this_ypos, this_speed, this_direction,recovery_rate);  %Creamos al agente
    
    chamilpa=chamilpa.addAgent(this_agent);  %Y lo agregamos al mundo
end

%% ¡Oh no!, alguien se comio un murcielago

ID0=0;  %Paciente 0
state0=1; %Esta infectado!
xpos0=randi(w);  %Esta en una posicion al azar
ypos0=randi(h);
speed0=speed; %A la misma velocidad
direction0=rand*2*pi; %Pero en una direccion distinta

agent0=agent(ID0, state0, xpos0, ypos0, speed0, direction0,recovery_rate);  %Creamos al individuo

chamilpa=chamilpa.addAgent(agent0);  %Y lo agregamos al mundo

chamilpa.plotWorld();

%% Algunos individuos responsables se quedan en su casa

agents=chamilpa.agents;
numAgents=length(agents);
for i=1:length(chamilpa.agents)
    if rand<fracQuarentined
        if chamilpa.agents(i).state==0  %si no esta infectado
            this_speed=0;  %Una fraccion no se mueve (#QuedateEnTuCasa)
            disp([num2str(i),' está en cuarentena']);
        end
    else
        this_speed=chamilpa.agents(i).speed; %Algunos tienen igual tienen que salir y iteraterse
    end
    agents(i).speed=this_speed;
end
chamilpa=chamilpa.setAgents(agents);

%% Ahora hacemos que todos salgan al mundo (salvo a los que estan en cuarentena) y simulamos la epidemia

popStructure=simulateABM(chamilpa, nSteps, runDir);

%% Finalmente, graficamos la curva epidemiologica

figure(); clf('reset'); set(gcf, 'Color', 'white')
plot(1:nSteps, popStructure(:,1)./numAgents, 'k-', 'LineWidth',2); hold on;
plot(1:nSteps, popStructure(:,2)./numAgents, 'r-', 'LineWidth',2); hold on;
plot(1:nSteps, popStructure(:,3)./numAgents, 'k--', 'LineWidth',2); hold on;
set(gca,'FontSize',14)
xlabel('Time','FontSize',16);
ylabel('Fraction','FontSize',16);
title(['Movilidad=',num2str(100-fracQuarentined*100),'%']);
legend('Susceptible','Infected','Recovered','FontSize',16);
axis([0 nSteps 0 1.05]);

outFile=[runDir,'SIR_ABM_frac',num2str(round(fracQuarentined*100)),'e-2.png'];  
export_fig(outFile)
