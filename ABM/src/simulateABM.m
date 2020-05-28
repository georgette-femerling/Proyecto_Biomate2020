function popStructure=simulateABM(chamilpa, nSteps, runDir, day0Vac, daysVac)

    agents=chamilpa.agents;
    popStructure=zeros(nSteps,7);
    day0Vac=day0Vac;
    daysVac=daysVac;
    
    for istep=1:nSteps

        %pause;  %Por si queremos correr las simulación un paso a la vez

        %Cuestiona al mundo respecto a su estado
        numInfected=chamilpa.getInfected();
        numRecovered=chamilpa.getRecovered();
        numSusceptible=chamilpa.getSusceptible();
        numVaccinated=chamilpa.getVaccinated();
        numQuarantined=chamilpa.getQuarantined();
        numQuarInfected=chamilpa.getQuarInf();
        numNormInf=chamilpa.getNormInf();
        popStructure(istep,:)=[numSusceptible, numInfected, numRecovered, numVaccinated, numQuarantined, numQuarInfected, numNormInf];

        fracI=(100*numInfected/length(agents));
        disp(['t=',num2str(istep),' (',num2str(fracI),'% infected)']);
        
         %Vacuna a los agentes en el tiempo establecido
        if (istep > day0Vac) && (istep <= day0Vac+daysVac)
            chamilpa=chamilpa.updateVaccine();
        end
        agents=chamilpa.agents;

        %Itera cada agente del mundo
        for iagent=1:length(agents)
            agents(iagent)=agents(iagent).iterate(world);
        end

        %Le avisa al mundo que los agentes cambiaron
        chamilpa=chamilpa.setAgents(agents);

        %Modela las interacciones entre individuos (infecciones)
        chamilpa=chamilpa.updateInfections();
        agents=chamilpa.agents;

        %Graficamos el mundo (y exportamos la imagen)
        outFile=[runDir,'world_t',num2str(istep),'.png'];  
        chamilpa.plotWorld(1, outFile);

    end