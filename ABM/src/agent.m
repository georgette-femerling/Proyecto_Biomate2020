classdef agent

    
    properties
        ID=0;
        state=0; %S, I, R
        xpos=0;
        ypos=0;
        speed=0;
        direction=0;
        recoverytime=0;
        quarantinefraction=0;
        quarantinedelay=0;
        quarantineduration=0;
        quarantinerest=0;
        quarantinerepetition=1;
        
        recoverycounter=0;
        quarantinecounter=0;
        repetitioncounter=1;
        %quarantineend=0;
        
        norm_speed=0;
        quar_marker=0;
        
        
        
    end
    
    methods
        
        function agentObj = agent(this_ID, this_state, this_xpos, this_ypos, this_speed, this_direction,this_recovery, this_quarantine, this_delay, this_duration, this_rest, this_repetition)
         
         if (nargin > 0) && (nargin < 8) 
            agentObj.ID = this_ID;
            agentObj.state = this_state;
            agentObj.xpos = this_xpos;
            agentObj.ypos = this_ypos;
            agentObj.speed = this_speed;
            agentObj.direction = this_direction;
            agentObj.recoverytime = this_recovery;
                        
         end
         
         if nargin > 7
            agentObj.ID = this_ID;
            agentObj.state = this_state;
            agentObj.xpos = this_xpos;
            agentObj.ypos = this_ypos;
            agentObj.speed = this_speed;
            agentObj.direction = this_direction;
            agentObj.recoverytime = this_recovery;
            agentObj.quarantinefraction = this_quarantine;
            agentObj.quarantinedelay = this_delay;
            agentObj.quarantineduration = this_duration;
            agentObj.quarantinerest = this_rest;
            agentObj.norm_speed = this_speed;
            
         end
         
         if nargin > 10
            agentObj.ID = this_ID;
            agentObj.state = this_state;
            agentObj.xpos = this_xpos;
            agentObj.ypos = this_ypos;
            agentObj.speed = this_speed;
            agentObj.direction = this_direction;
            agentObj.recoverytime = this_recovery;
            agentObj.quarantinefraction = this_quarantine;
            agentObj.quarantinedelay = this_delay;
            agentObj.quarantineduration = this_duration
            agentObj.quarantinerest = this_rest;;
            agentObj.quarantinerepetition = this_repetition;
            agentObj.norm_speed = this_speed;
            
         end
         
         ...
      end
      
        
        function  agentObj=iterate(agentObj, worldObj)
        
            %Si esta en cuarentena, su velocidad es 0
            if agentObj.quarantinefraction > 0
                if (agentObj.quarantinecounter > agentObj.quarantinedelay) && (agentObj.quarantinecounter < (agentObj.quarantinedelay+agentObj.quarantineduration))
                    agentObj.speed=agentObj.speed;
                elseif agentObj.quarantinecounter >= (agentObj.quarantinedelay+agentObj.quarantineduration)
                    agentObj.speed=agentObj.norm_speed;
                    if agentObj.quar_marker == 1
                        agentObj.quar_marker=2;
                    end
                elseif agentObj.quarantinecounter == agentObj.quarantinedelay %si ya empezo la cuarentena, deja a algunos quietos al azar
                    if agentObj.repetitioncounter == 1
                        if rand<agentObj.quarantinefraction
                            agentObj.speed=0;  %Una fraccion no se mueve
                            agentObj.quar_marker=1;
                        else
                            agentObj.speed=agentObj.speed;
                        end
                    else
                        if agentObj.quar_marker == 2
                            agentObj.speed = 0;
                            agentObj.quar_marker=1;
                        end
                    end
                elseif agentObj.quarantinecounter < agentObj.quarantinedelay
                    %agentObj.quarantinecounter = agentObj.quarantinecounter+1; %si la cuarentena no ha empezado, avanza un dia
                end
                agentObj.quarantinecounter = agentObj.quarantinecounter+1;
                if agentObj.quarantinerepetition > 1
                    if agentObj.quarantinecounter >= (agentObj.quarantinedelay+agentObj.quarantineduration+agentObj.quarantinerest)
                        if agentObj.repetitioncounter < agentObj.quarantinerepetition
                            agentObj.quarantinecounter = agentObj.quarantinedelay;
                            agentObj.repetitioncounter = agentObj.repetitioncounter+1;
                        end
                    end
                end
            end
            
            
            
            %Si esta infectado, se recupera despues de un rato
            if agentObj.state==1
               if agentObj.recoverycounter>=agentObj.recoverytime %se recupera cuando pasa cierto tiempo
                   agentObj.state=2;
               else
                   agentObj.recoverycounter = agentObj.recoverycounter+1
               end
            end
            

            
            %Encuentra la nueva posicion
            new_xpos = agentObj.xpos + (agentObj.speed * sin(agentObj.direction));
            new_ypos = agentObj.ypos + (agentObj.speed * cos(agentObj.direction));
            new_direction=agentObj.direction;
            
        
            %Choco hacia la derecha || izquierda 
            if new_xpos>worldObj.w || new_xpos<0 
                
                new_direction=-1*agentObj.direction;  %Invierto la dirección
                new_xpos = agentObj.xpos + (agentObj.speed * sin(new_direction));
                new_ypos = agentObj.ypos + (agentObj.speed * cos(new_direction));
                
            end
            
            %choco arriba
            if new_ypos>worldObj.h
                
                if agentObj.direction>0
                    new_direction=mod(-1*agentObj.direction+pi, 2*pi);
                else
                    new_direction=mod(pi-agentObj.direction, 2*pi);
                end
                
                new_xpos = agentObj.xpos + (agentObj.speed * sin(new_direction));
                new_ypos = agentObj.ypos + (agentObj.speed * cos(new_direction));
                
            end
            
            %choco abajo
            if new_ypos<0
                if agentObj.direction>0
                    new_direction=mod(-1*agentObj.direction+pi, 2*pi);
                else
                    new_direction=mod(pi-agentObj.direction, 2*pi);
                end
                
                new_xpos = agentObj.xpos + (agentObj.speed * sin(new_direction));
                new_ypos = agentObj.ypos + (agentObj.speed * cos(new_direction));
            end
            
            
            agentObj.xpos = new_xpos;
            agentObj.ypos = new_ypos;
            agentObj.direction=new_direction;
        end
        
    end
end

