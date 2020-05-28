function SIR = odefun(t,y, alfa, beta, gamma)
SIR = zeros(3,1);
SIR(1) = -beta * y(1) * y(2)/(1 + alfa * y(3));
SIR(2) =  beta * y(1) * y(2)/(1 + alfa * y(3)) - gamma*y(2);
SIR(3) =  gamma* y(2);
end