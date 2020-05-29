function [nmaxSat daySat] = saturation(demand, capacity)
    nmaxSat = false;
    daySat  = false;    
    % Calculo de saturacion    
    idx = demand > capacity;
    time   = 0:length(demand);
    time   = time(idx);
    sat = demand(idx);
    plot(demand, 'go', 'markersize', 3), hold on
    yline(capacity, 'k--'); hold on    
    if ~isempty(sat)
        plot(time([1 end]), sat([1 end]), 'r.', 'markersize', 30), hold on
        % Porentaje de sobre saturacion
        nmaxSat = (max(demand)*100/capacity -100)/100;
        maxSat = num2str( nmaxSat );
        % Periodo saturacion
        daySat = length(sat);        
    end
    
end