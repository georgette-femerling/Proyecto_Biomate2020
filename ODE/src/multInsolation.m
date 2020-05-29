function simulation = multInsolation(period, de, di, y0, beta, gamma)
    Nperiods = period/(di+de);
    simulation = [];
    for n=[1:1:Nperiods]        
        % Inicia periodo de aislamiento        
        tspan = [0:1:di];
        [ t, Insolation ] = ode45( @(t,SIR) odefun(t, SIR, ...
                            20, beta, gamma), tspan, y0 );        
        % Termina periodo de aislamiento
        y0 = Insolation(end, : );
        % Inicia periodo de exposicion        
        tspan = [0:1:de];
        [ t, Exposition ] = ode45( @(t,SIR) odefun(t, SIR, ...
                            0, beta, gamma), tspan, y0 );
        % Termina periodo de exposicion
        y0 = Exposition(end, : );
        % Periodo completo
        ciclo = [Exposition; Insolation];
        % Alamacenando ciclo
        simulation = [simulation; ciclo];
    end
end
