classdef world
    
    properties  %Las propiedades de la clase world
        w = 100  %Los valores por default
        h = 100
        agents=[];
        susanaDistancia=0;
        beta = 1;
        fracVaccinated=0;
        daysVac=0;
    end
    
    methods  %Los métodos de la clase world
        
        %El constructor de la clase world
        function worldObj = world(this_w, this_h, this_susanaDistancia, this_beta, this_fracVaccinated, this_daysVac, this_agents)
            
            if nargin > 0  %Valores recibidos por el usuario
                worldObj.w = this_w;
                worldObj.h = this_h;
                worldObj.susanaDistancia = this_susanaDistancia;
                worldObj.beta = this_beta;
                worldObj.fracVaccinated = this_fracVaccinated;
                worldObj.daysVac = this_daysVac;
                
                %Si recibe a sus agents los asigna. Si no, crea un mundo vacío
                if nargin>6
                    worldObj.agents=this_agents;
                else
                    worldObj.agents=[];
                end
            end
        end
        
        %Funcion que incluye un individuo en el mundo
        function worldObj=addAgent(worldObj, this_agent)
            previous_agents=worldObj.agents;
            worldObj.agents=[previous_agents, this_agent];
        end
        
        %Funcion que incluye un individuo en el mundo
        function worldObj=setAgent(worldObj, indx, this_agent)
            worldObj.agents(indx)=this_agent;
        end
        
        %Funcion que asocia muchos individuos al mundo
        function worldObj=setAgents(worldObj, this_agents)
            worldObj.agents=this_agents;
        end
        
        %Funcion que regresa el numero de agentes infectados
        function numI=getInfected(worldObj)
            array_agents=worldObj.agents;
            numI=0;
            for i=1:length(array_agents)
                if array_agents(i).state==1
                    numI=numI+1;
                end
            end
        end
        
        %Funcion que regresa el numero de agentes recuperados
        function numR=getRecovered(worldObj)
            array_agents=worldObj.agents;
            numR=0;
            for i=1:length(array_agents)
                if array_agents(i).state==2
                    numR=numR+1;
                end
            end
        end
        
        %Función que regresa el numero de agentes vacunados
        function numV=getVaccinated(worldObj)
            array_agents=worldObj.agents;
            numV=0;
            for i=1:length(array_agents)
                if array_agents(i).state==3
                    numV=numV+1;
                end
            end
        end
        
        %Funcion que regresa el numero de agentes suceptibles
        function numS=getSusceptible(worldObj)
            array_agents=worldObj.agents;
            numS=0;
            for i=1:length(array_agents)
                if array_agents(i).state==0
                    numS=numS+1;
                end
            end
        end
        
        %Funcion que regresa el numero de agentes en cuarentena
        function numQ=getQuarantined(worldObj)
            array_agents=worldObj.agents;
            numQ=0;
            for i=1:length(array_agents)
                if (array_agents(i).quar_marker==1)
                    numQ=numQ+1;
                end
            end
        end
        
        %Funcion que regresa el numero de agentes que se enfermaron en cuarentena
        function numQI=getQuarInf(worldObj)
            array_agents=worldObj.agents;
            numQI=0;
            for i=1:length(array_agents)
                if ((array_agents(i).state==1) || (array_agents(i).state==2)) && ((array_agents(i).quar_marker==1) || (array_agents(i).quar_marker==2))
                    numQI=numQI+1;
                end
            end
        end
        
        %Funcion que regresa el numero de agentes que se enfermaron sin cuarentena
        function numNI=getNormInf(worldObj)
            array_agents=worldObj.agents;
            numNI=0;
            for i=1:length(array_agents)
                if ((array_agents(i).state==1) || (array_agents(i).state==2)) && (array_agents(i).quar_marker==0)
                    numNI=numNI+1;
                end
            end
        end
        
        %Funcion que busca objetos colisionando y les transmite el virus
        function worldObj=updateInfections(worldObj)
            array_agents=worldObj.agents;
            for i=1:length(array_agents)
                xpos1=array_agents(i).xpos;
                ypos1=array_agents(i).ypos;
                
                for j=i:length(array_agents)
                    xpos2=array_agents(j).xpos;
                    ypos2=array_agents(j).ypos;
                    
                    if i~=j
                        dist=norm([xpos1,ypos1]-[xpos2,ypos2]);  %Calcula la distancia entre dos individuos
                        
                        if dist<worldObj.susanaDistancia  %Si no mantuvieron sana distancia
                            
                            if (array_agents(i).state==1 && array_agents(j).state==0)
                            
                                %if rand(1,1) <= worldObj.beta
                                
                                disp([num2str(i),' -> ',num2str(j)]);
                                array_agents(j).state=1;  %j se contagio!
                                    
                                %end
                                
                            elseif (array_agents(i).state==0 && array_agents(j).state==1)
                            
                                %if rand(1,1) <= worldObj.beta
                                
                                disp([num2str(i),' <- ',num2str(j)]);
                                array_agents(i).state=1;  %i contagio a j!
                                
                                %end
                                
                            end
                        end
                    end
                    
                end
                worldObj=worldObj.setAgents(array_agents);  %Actualiza el mundo
                
            end
        end
        
        %Funcion que vacuna a los objetos y los vuelve resistentes
        function worldObj=updateVaccine(worldObj)
            array_agents=worldObj.agents;
            if worldObj.getVaccinated() < (length(array_agents) * worldObj.fracVaccinated)
                for i=1:length(array_agents) % Itero sobre todos los agentes
                    if array_agents(i).state==0 %Si el agente es suceptible
                        if rand <= (worldObj.fracVaccinated/(worldObj.daysVac-1)) %Si random es menor
                            array_agents(i).state=3; %Cambia el estado 
                        end
                    end
                end
                worldObj=worldObj.setAgents(array_agents);
            end
        end
        
        %Funcion que grafica el mundo
        function plotWorld(worldObj, fig, outFile)
            if nargin>1
                figure(fig);
                clf('reset');
            else
                figure();
            end
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, .75, 0.75]);
            set(gca,'color','white')
            array_agents=worldObj.agents;
            for i=1:length(array_agents)
                
                %El color depende del estado del agente
                if (array_agents(i).quar_marker==1) && (array_agents(i).state==0)
                    agent_color=[0,0,1];
                    susana_color=[0,0,.7];
                elseif ((array_agents(i).quar_marker==1)||(array_agents(i).quar_marker==2)) && (array_agents(i).state==1)
                    agent_color=[1,0,0];
                    susana_color=[0,0,.7];
                elseif ((array_agents(i).quar_marker==1)||(array_agents(i).quar_marker==2)) && (array_agents(i).state==2)
                    agent_color=[1,1,1];
                    susana_color=[0,0,.7];
                elseif ((array_agents(i).quar_marker==1)||(array_agents(i).quar_marker==2)) && (array_agents(i).state==3)
                    agent_color=[1,1,0];
                    susana_color=[0,0,.7];
                elseif (array_agents(i).quar_marker==2) && (array_agents(i).state==0)
                    agent_color=[0,0,0];
                    susana_color=[0,0,0.7];
                elseif (array_agents(i).quar_marker==0) && (array_agents(i).state==1)
                    agent_color=[1,0,0];
                    susana_color=[1,0,0];
                elseif (array_agents(i).quar_marker==0) && (array_agents(i).state==2)
                    agent_color=[1,1,1];
                    susana_color=[1,1,1];
                elseif (array_agents(i).quar_marker==0) && (array_agents(i).state==3)
                    agent_color=[1,1,0]
                    susana_color=[0,1,0]
                else
                    agent_color=[0,0,0];
                    susana_color=[.7, .7, .7];
                end
                
                %Grafica al individuo
                plot(array_agents(i).xpos,array_agents(i).ypos, 'o', 'MarkerFaceColor',agent_color,'MarkerEdgeColor','k','LineWidth',1); hold all;
                
                %Grafica el círculo de sana distancia
                xCenter = array_agents(i).xpos;
                yCenter = array_agents(i).ypos;
                theta = 0 : 0.01 : 2*pi;
                radius = worldObj.susanaDistancia;
                susanax = radius * cos(theta) + xCenter;
                susanay = radius * sin(theta) + yCenter;
                plot(susanax, susanay,'Color',susana_color);
                
                axis square
                
                
            end
            axis([0, worldObj.w 0 worldObj.h]);
            xticks([]);
            yticks([]);
            
            %Guarda la imagen
            if nargin>2
                export_fig(outFile)
            end
            
        end
        
        ...
    end
end