function vacuna(TVi, TVd, dSim, y0, beta, gamma, epsilon, V)
    if TVi == 0
        titleplot = strcat('Vacuna del dia 0 al dia', {' '}, num2str(TVd), num2str(V*100), '%');
        % Inicia vacunacion
        tspan =  [TVi:1:TVd];
        % Simulacion de aislamiento
        [ t, SIR_vac ] = ode45( @(t,SIR_vac) SIR_vacuna(t,SIR_vac, ...
             beta,gamma,epsilon), tspan, y0 );
        % Termina aislamiento
        y0 = SIR_vac(TVd,: );
        % Periodo despues de la vacuna
        tspan = [ 0:1:dSim-TVf ];
        % Inicia periodo despues de la vacuna
        [ t, M ] = ode45( @(t,M) odefun(t, M, 0, beta, gamma), tspan, y0 );
        % Simulacion Final    
        simulation = [SIR_vac; M]; 
    else
        titleplot = strcat('Vacuna del dia', {' '}, num2str(TVi), ' al dia ', {' '}, num2str(TVi + TVd), ' al ', {' '}, num2str(V*100), '%');
        % Inicia simulation sin vacuna
        tspan = [ 0:1:TVi ];
        [ t, M ] = ode45( @(t,M) odefun(t, M, 0, beta, gamma), tspan, y0 );
        % Ultimo estado
        y0 = M( end,: );
        % Inicia vacunacion
        tspan = [ 0:1:TVd ];
        [ t, SIR_vac ] = ode45( @(t,SIR_vac) SIR_vacuna(t,SIR_vac, ...
             beta,gamma,epsilon), tspan, y0 );
        % Simulacion Final        
        if TVd == dSim-TVi
            simulation = [M; SIR_vac];        
        else
            y0 = SIR_vac( end,: );
            tspan = [ 0:1:dSim-TVi-TVd ];
            [ t, M2 ] = ode45( @(t,M) odefun(t, M, 0, beta, gamma), tspan, y0 );
            simulation = [M; SIR_vac; M2];
        end
    end
    plot(simulation(:,2), '.-', 'markersize', 8), hold all
    xlabel('dias'), ylabel('proporcion') 
    
end
