function [ mSat dSat ] = quarantine(start, period, dSim, di, de, y0, beta, gamma)
    if start==0
        % Inicia estrategia de aislamiento
        if islogical(di) && islogical(de)            
            % Estrategia cuarentena continua
            title1 = strcat('Intervencion en los primeros', {' '}, ...
                     num2str(period), ' dias');            
            tspan =  [start:1:period];            
            % Simulacion de aislamiento
            [ t, Insolation ] = ode45( @(t,Insolation) odefun(t, ...
                                Insolation, 20, beta, gamma), tspan, y0 );
        else
            % Estrategia de cuarentena con interrupciones
            title1 = strcat('Cuarentena parcial en los primeros', ...
                     {' '}, num2str(period), ' dias');                 
            Insolation = multInsolation(period, di, de, y0, beta, gamma); 
        end               
        % Termina aislamiento
        y0 = Insolation( end,: );        
        
        % Periodo de exposicion
        tspan = [ 0:1:dSim-period ];
        
        % Inicia periodo de exposicion
        [ t, M ] = ode45( @(t,M) odefun(t, M, 0, beta, gamma), tspan, y0 );
        
        % Simulacion Final    
        simulation = [Insolation; M];
        
    else
        % Inicia simulation sin aislamiento
        title1 = strcat('Estrategia de intervencion', {' '}, ...
                 num2str(period), ' dias a partir del dia', {' '}, ...
                 num2str(start) );
        tspan = [ 0:1:start ];
        [ t, M ] = ode45( @(t,M) odefun(t, M, 0, beta, gamma), tspan, y0 );        
        
        % Termina periodo sin aislamiento
        y0 = M( end,: );
        
        % Inicia estrategia de aislamiento con interrupciones
        if islogical(di) && islogical(de)
            % Estrategia cuarentena continua
            tspan = [ 0:1:period ];
            [ t, Insolation ] = ode45( @(t,Insolation) odefun(t, ...
                                Insolation, 20, beta, gamma), tspan, y0 );
        else
            % Estrategia de cuarentena con interrupciones
            Insolation = multInsolation(period, di, de, y0, beta, gamma); 
        end
        
        % Simulacion Final        
        if period == dSim-start
            simulation = [M; Insolation];        
        else
            y0 = Insolation( end,: );
            tspan = [ 0:1:dSim-start-period ];
            [ t, M2 ] = ode45( @(t,M) odefun(t, M, 0, beta, gamma), tspan, y0 );
            simulation = [M; Insolation; M2];
        end
    end      

    % Dinamica Hospitalaria
    demand = simulation(:,2).*.05;    
    plot(simulation(:,2), 'm.-', 'markersize', 10), hold on
    % Calculo del periodo de saturacion
    [ mSat dSat ] = saturation(demand', 0.001); hold on
    % Grafico de la simulacion completa
    title2 = char( strcat( num2str(dSat),{' '},...
             'dias con saturacion de hasta', ...
             {' '}, num2str(mSat), {' '}, ...
             'veces sobre la capacidad'));
    title({strcat('\fontsize{9}',title1{1}) ; title2})
    xlabel('dias'), ylabel('proporcion')
end
