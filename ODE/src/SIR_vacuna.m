function SIR_vac = SIR_vacuna(t, y, beta, gamma, epsilon)%, TVi, TVf)
SIR_vac = zeros(3,1);
% ODE model
SIR_vac(1) = -beta * y(1) * y(2) - epsilon * y(1);
SIR_vac(2) = beta * y(1) * y(2) - gamma * y(2);
SIR_vac(3) = gamma * y(2) + epsilon * y(1);
end