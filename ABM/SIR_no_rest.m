% Primero importamos las librerías externas y funciones propias
clc; 
close all; 
clear;

run('lib/addpath_recurse.m');
addpath_recurse('lib/');
addpath_recurse('src/');

%###########################################################

QuarantineDurations = [7 14 21 28 35];
QuarantineStarts =    [0 10 30 50];
QuarantineFractions = [0.25 0.33 0.5 0.66 0.75 0.9];

VaccineDurations =    [0 5 10 15 20 30];
VaccineStarts =       [0 1 15 30 45 60];
VaccineFractions =    [0 0.2 0.4 0.6 0.8 1.0];

%############################################################

for VacFrac=VaccineFractions
    for VacStart=VaccineStarts
        for VacDur=VaccineDurations
            for QuarFrac=QuarantineFractions
                for QuarStart=QuarantineStarts
                    for QuarDur=QuarantineDurations
                        
                        if (QuarFrac == 0.25) && (QuarStart < 11)
                            continue;
                        end
                        

                        Dir= strcat('runs/sim_',string(VacFrac),'vf_',string(VacStart),'vs_',string(VacDur),'vd_',string(QuarFrac),'qf_',string(QuarStart),'qs_',string(QuarDur),'qd/');
                        runDir = char(Dir);
                        
                        if ~isempty(runDir)  %Si estamos exportando las imagenes
                            if ~exist(runDir, 'dir')
                                mkdir(runDir);
                                disp(['Creando carpeta ',runDir]);
                            end
                        end
                        
                        nSteps=200;  %Numero de iteraciones
                        numAgents=800;  %Numero de agentes

                        recovery_rate=14; %Días que dura un agente infectado con capacidad de infectar a otros
                        speed=1;  %Velocidad de los agentes
                        susanaDistancia=5;  %Radio de interacción entre agentes
                        R0 = 2.83; %Número reproductivo básico
                        beta = 1; %Probabilidad de contagio
                        fracQuarentined=QuarFrac;  %Porcentaje de la población que no se mueve: [0,1]
                        quarantine_delay = QuarStart; %En qué día empieza la cuarentena
                        quarantine_duration = QuarDur; %Cuánto dura la cuarentena
                        quarantine_rest= 0; %Por cuántos días se relaja la cuarentena
                        quarantine_repetitions= 1; %Cuántas veces entran a cuarentena

                        fracVaccinated=VacFrac %Fraction of the population that the vaccination campaign aims to vaccine
                        daysVac=VacDur %Number of days the vaccination campaign will be working
                        day0Vac=VacStart %Day at which the vaccination campaign starts

                        % El mundo es un cuadrado de w x h
                        w=150;
                        h=150;

                        chamilpa=world(w, h, susanaDistancia, beta, fracVaccinated, daysVac);

                        for i=1:numAgents
                            this_ID=i;  %Se llama distinto
                            this_state=0; %Tambien es susceptible
                            this_xpos=randi(w);  %Esta en una posicion al azar
                            this_ypos=randi(h);
                            this_speed=speed;
                            this_direction=rand*2*pi; %Pero en una direccion distinta
                            this_quarantine=fracQuarentined;
                            this_delay=quarantine_delay;
                            this_duration=quarantine_duration;
                            this_rest=quarantine_rest;
                            this_repetition=quarantine_repetitions;

                            this_agent=agent(this_ID, this_state, this_xpos, this_ypos, this_speed, this_direction,recovery_rate, this_quarantine, this_delay, this_duration, this_rest, this_repetition);  %Creamos al agente

                            chamilpa=chamilpa.addAgent(this_agent);  %Y lo agregamos al mundo
                        end

                        %% ¡Oh no!, alguien se comio un murcielago

                        ID0=0;  %Paciente 0
                        state0=1; %Esta infectado!
                        xpos0=randi(w);  %Esta en una posicion al azar
                        ypos0=randi(h);
                        speed0=speed; %A la misma velocidad
                        direction0=rand*2*pi; %Pero en una direccion distinta
                        quarantine0=0;
                        delay0=0;
                        duration0=0;
                        rest0=0;
                        repetition0=0;

                        agent0=agent(ID0, state0, xpos0, ypos0, speed0, direction0,recovery_rate,quarantine0,delay0,duration0,rest0,repetition0);  %Creamos al individuo

                        chamilpa=chamilpa.addAgent(agent0);  %Y lo agregamos al mundo


                        chamilpa.plotWorld();
                        
                        popStructure=simulateABM(chamilpa, nSteps, runDir, VacStart, VacDur);
                        
                        %%%%%%%%%%%%%%%%%%%%%
                        %% Graficamos la curva epidemiologica

                        figure(); clf('reset'); set(gcf, 'Color', 'white')
                        plot(1:nSteps, popStructure(:,1)./numAgents, 'k-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,2)./numAgents, 'r-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,3)./numAgents, 'k--', 'LineWidth',2); hold on;
                        hospital = refline(0,0.05);
                        hospital.Color = 'c';
                        hospital.LineStyle= ':';
                        hospital.LineWidth= 3;
                        intensivo = refline(0,0.001);
                        intensivo.Color = 'm';
                        intensivo.LineStyle= ':';
                        intensivo.LineWidth= 3;
                        set(gca,'FontSize',14)
                        xlabel('Time','FontSize',16);
                        ylabel('Fraction','FontSize',16);
                        title(['Movilidad=',num2str(100-fracQuarentined*100),'%, Vacunación=' num2str(fracVaccinated*100), '%']);
                        legend('Susceptible','Infectado','Recuperado');
                        axis([0 nSteps 0 1.05]);

                        outFile=[runDir,'SIR_ABM.png'];  
                        export_fig(outFile)

                        %%%%%%%%%%%
                        %% Curva S, I, R, V, Q

                        figure(); clf('reset'); set(gcf, 'Color', 'white')
                        plot(1:nSteps, popStructure(:,1)./numAgents, 'k-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,2)./numAgents, 'r-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,3)./numAgents, 'k--', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,4)./numAgents, 'g-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,5)./numAgents, 'b-', 'LineWidth',2); hold on;
                        hospital = refline(0,0.05);
                        hospital.Color = 'c';
                        hospital.LineStyle= ':';
                        hospital.LineWidth= 3;
                        intensivo = refline(0,0.001);
                        intensivo.Color = 'm';
                        intensivo.LineStyle= ':';
                        intensivo.LineWidth= 3;
                        set(gca,'FontSize',14)
                        xlabel('Time','FontSize',16);
                        ylabel('Fraction','FontSize',16);
                        title(['Movilidad=',num2str(100-fracQuarentined*100),'%, Vacunación=' num2str(fracVaccinated*100), '%']);
                        legend('Susceptible','Infectado','Recuperado','Vacunado', 'En cuarentena');
                        axis([0 nSteps 0 1.05]);

                        outFile=[runDir,'SIRVQ_ABM.png'];  
                        export_fig(outFile)

                        %%%%%%%%%%%%%%
                        %% Curva S, I, R, V

                        figure(); clf('reset'); set(gcf, 'Color', 'white')
                        plot(1:nSteps, popStructure(:,1)./numAgents, 'k-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,2)./numAgents, 'r-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,3)./numAgents, 'k--', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,4)./numAgents, 'g-', 'LineWidth',2); hold on;
                        hospital = refline(0,0.05);
                        hospital.Color = 'c';
                        hospital.LineStyle= ':';
                        hospital.LineWidth= 3;
                        intensivo = refline(0,0.001);
                        intensivo.Color = 'm';
                        intensivo.LineStyle= ':';
                        intensivo.LineWidth= 3;
			set(gca,'FontSize',14)
                        xlabel('Time','FontSize',16);
                        ylabel('Fraction','FontSize',16);
                        title(['Movilidad=',num2str(100-fracQuarentined*100),'%, Vacunación=' num2str(fracVaccinated*100), '%']);
                        legend('Susceptible','Infectado','Recuperado','Vacunado');
                        axis([0 nSteps 0 1.05]);

                        outFile=[runDir,'SIRV_ABM.png'];  
                        export_fig(outFile)


                        %%%%%%%%%%%%%%
                        %% Curva S, I, R, Q

                        figure(); clf('reset'); set(gcf, 'Color', 'white')
                        plot(1:nSteps, popStructure(:,1)./numAgents, 'k-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,2)./numAgents, 'r-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,3)./numAgents, 'k--', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,5)./numAgents, 'b-', 'LineWidth',2); hold on;
                        hospital = refline(0,0.05);
                        hospital.Color = 'c';
                        hospital.LineStyle= ':';
                        hospital.LineWidth= 3;
                        intensivo = refline(0,0.001);
                        intensivo.Color = 'm';
                        intensivo.LineStyle= ':';
                        intensivo.LineWidth= 3;
			set(gca,'FontSize',14);                        
			xlabel('Time','FontSize',16);
                        ylabel('Fraction','FontSize',16);
                        title(['Movilidad=',num2str(100-fracQuarentined*100),'%, Vacunación=' num2str(fracVaccinated*100), '%']);
                        legend('Susceptible','Infectado','Recuperado', 'En cuarentena');
                        axis([0 nSteps 0 1.05]);

                        outFile=[runDir,'SIRQ_ABM.png'];  
                        export_fig(outFile)


                        %%%%%%%%%%%%%%
                        %% Curva S, I, R+V

                        figure(); clf('reset'); set(gcf, 'Color', 'white')
                        plot(1:nSteps, popStructure(:,1)./numAgents, 'k-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,2)./numAgents, 'r-', 'LineWidth',2); hold on;
                        plot(1:nSteps, (popStructure(:,3)+popStructure(:,4))./numAgents, 'g--', 'LineWidth',2); hold on;
                        hospital = refline(0,0.05);
                        hospital.Color = 'c';
                        hospital.LineStyle= ':';
                        hospital.LineWidth= 3;
                        intensivo = refline(0,0.001);
                        intensivo.Color = 'm';
                        intensivo.LineStyle= ':';
                        intensivo.LineWidth= 3;
			set(gca,'FontSize',14)
                        xlabel('Time','FontSize',16);
                        ylabel('Fraction','FontSize',16);
                        title(['Movilidad=',num2str(100-fracQuarentined*100),'%, Vacunación=' num2str(fracVaccinated*100), '%']);
                        legend('Susceptible','Infectado','Recuperado + Vacunado');
                        axis([0 nSteps 0 1.05]);

                        outFile=[runDir,'SIR+V_ABM.png'];  
                        export_fig(outFile)


                        %%%%%%%%%%%%%%%%
                        %% Curva S, I, R+V, Q

                        figure(); clf('reset'); set(gcf, 'Color', 'white')
                        plot(1:nSteps, popStructure(:,1)./numAgents, 'k-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,2)./numAgents, 'r-', 'LineWidth',2); hold on;
                        plot(1:nSteps, (popStructure(:,3)+popStructure(:,4))./numAgents, 'g--', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,5)./numAgents, 'b-', 'LineWidth',2); hold on;
                        hospital = refline(0,0.05);
                        hospital.Color = 'c';
                        hospital.LineStyle= ':';
                        hospital.LineWidth= 3;
                        intensivo = refline(0,0.001);
                        intensivo.Color = 'm';
                        intensivo.LineStyle= ':';
                        intensivo.LineWidth= 3;
			set(gca,'FontSize',14)
                        xlabel('Time','FontSize',16);
                        ylabel('Fraction','FontSize',16);
                        title(['Movilidad=',num2str(100-fracQuarentined*100),'%, Vacunación=' num2str(fracVaccinated*100), '%']);
                        legend('Susceptible','Infectado','Recuperado + Vacunado', 'En cuarentena');
                        axis([0 nSteps 0 1.05]);

                        outFile=[runDir,'SIR+VQ_ABM.png'];  
                        export_fig(outFile)


                        %%%%%%%%%%%%%%
                        %% Curva R+I entre Q y no Q

                        figure(); clf('reset'); set(gcf, 'Color', 'white')
                        plot(1:nSteps, popStructure(:,6)./numAgents, 'b-', 'LineWidth',2); hold on;
                        plot(1:nSteps, popStructure(:,7)./numAgents, 'r-', 'LineWidth',2); hold on;
                        set(gca,'FontSize',14)
                        xlabel('Time','FontSize',16);
                        ylabel('Fraction','FontSize',16);
                        title({'Comparación entre infecciones entre la población', 'que hizo cuarentena y la que no'});
                        legend('Infecciones en cuarentena','Infecciones no en cuarentena');
                        axis([0 nSteps 0 1.05]);

                        outFile=[runDir,'I+RQnQ_ABM.png'];  
                        export_fig(outFile)



                    end
                end
            end
        end
    end
end
