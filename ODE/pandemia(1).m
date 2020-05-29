clc, clear

%% Parametros
% Numero basico de reproduccion
Ro    = 2.8;
% periodo de exposicion
gamma = 1/14;
% Transmicion
beta  = Ro*gamma;
alfa  = 0;
% Poblacion
N     = 800;
% Dias de simulacion
dSim = 200;
% Condiciones Inciales
I0    = 1 / N;
S0    = 1 - I0;
R0    = 0;
y0    = [S0 I0 R0];
%Tiempo de integracion
tspan = [0:1:dSim];



%% Simulacion sin aislamiento
figure(1)
disp('Fig1')
fig = figure;
subplot(2,1,1)
[ t, SIRb ] = ode45( @(t,SIR) odefun(t,SIR, ...
              alfa,beta,gamma), tspan, y0 );
I     = SIRb( :, 2 );
plot(   t,SIRb( :, 1 ), '.-', ...
        t,SIRb( :, 2 ), '.-', ...
        t,SIRb( :, 3 ), '.-', ...
        'markersize'  , 10 ), hold on
peak  = max(I);
days  = [0:1:dSim];
dpeak = days(I==peak)

plot(   dpeak, peak, '.', 'markersize', 25 ), hold on   
title( 'Simulacion sin intervencion' )
xlabel('dias' ), ylabel( 'proporcion' )
legend('S', 'I', 'R', 'pico infeccioso')

subplot(2,1,2)
dexp =  10;
plot(   I(1:20), '.-','markersize', 15 ), hold on   
plot(   10, I(10), '.','markersize', 20 ), hold off
title( 'Inicio de la fase exponencial')
xlabel('dias'), ylabel('proporcion')
legend('I', 'Inicia fase exponencial')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.1.pdf','-dpdf');




%% Exploracion de parametros
figure(2)
disp('Fig2')
fig = figure;
subplot(2,1,1)
for alfa = 0:25
    [ t, SIR ]       =  ode45( @(t,SIR) odefun(t, SIR, ...
                        alfa, beta, gamma), tspan, y0 );
    fin ( alfa+1, :) =  SIR( end, [1 3] );
    Peak( alfa+1   ) =  max( SIR( :, 2) );
    FinalI( alfa+1 ) =  sum( SIR( :, 2) );
    if mod( alfa,5 ) == 0
        plot( SIR(: ,2), 'linewidth', 3 ), hold on        
    end   
end
legend( 'alfa = 0' ,'alfa = 5' ,'alfa = 10',...
        'alfa = 15','alfa = 20','alfa = 25' )
title(  'Impacto en el pico infeccioso')
xlabel( 'dias'), ylabel('proporcion')

subplot(  2,1,2)
plot(     0:25, fin(:,1), '.-', ...
          0:25, fin(:,2), '.-', ...
          0:25, Peak    , '.-', ...
         'markersize'   ,  15 ), hold off       
legend(  'No infectados', 'Impacto epidemia', 'Pico')
xlabel(  'alfa'), ylabel( 'proporcion')
title(   'Impacto del aislamiento')
suptitle('Dinamica de aislamiento')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.2.pdf','-dpdf');



%% Sin intervencion vs intervencion estricta
figure(3)
disp('Fig3')
fig = figure;
plot( t, SIRb(:,2), '.-', 'markersize', 10 ), hold on

% Intervencion intensiva
[ t, SIR ] = ode45( @(t,SIR) odefun(t, SIR, ...
             20, beta, gamma), tspan, y0 );
demand     = SIR(:,2).*.05;
plot( t, SIR(:,2), '.-', 'markersize', 10 ), hold on
saturation(demand', 0.001);
title( 'Efecto de aislamiento estricto')
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.3.pdf','-dpdf');


%% Intervenciones Iniciales
figure(4)
disp('Fig4')
fig = figure;
subplot(2,2,1)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 15, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,2)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 30, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,3)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 60, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,4)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 90, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')
suptitle('Intervenciones iniciales')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.4.pdf','-dpdf');



%% Intervenciones en fase exponencial
figure(5)
disp('Fig5')
fig = figure;
fig = figure;
subplot(2,2,1)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 15, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,2)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 30, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,3)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 60, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,4)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 90, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')
suptitle('Intervenciones en fase exponencial')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.5.pdf','-dpdf');



%% Intervenciones en el pico infeccioso
figure(6)
disp('Fig6')
fig = figure;
subplot(2,2,1)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 15, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,2)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 30, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,3)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 60, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,4)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 90, dSim, false, false, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')
suptitle('Intervenciones en el pico infeccioso')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.6.pdf','-dpdf');




%% Intervenciones parciales iniciales
figure(7)
disp('Fig7')
fig = figure; 
subplot(2,2,1)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 15, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,2)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 30, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,3)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 60, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,4)
plot(   t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(0, 90, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')
suptitle('Intervenciones parciales iniciales')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.7.pdf','-dpdf');




%% Intervenciones parciales en fase exponencial
figure(8)
disp('Fig8')
fig = figure;
subplot(2,2,1)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 15, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,2)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 30, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,3)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 60, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,4)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dexp, 90, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')
suptitle('Intervenciones parciales en fase exponencial')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.8.pdf','-dpdf');




%% Intervenciones parciales en el pico infeccioso
figure(9)
disp('Fig9')
fig = figure;
subplot(2,2,1)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 15, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,2)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 30, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,3)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 60, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')

subplot(2,2,4)
plot(t, SIRb(:,2), '.', 'markersize', 10 ), hold on
[n p] = quarantine(dpeak, 90, dSim, 2, 5, y0, beta, gamma);
legend('I sin aislamiento', 'I aislamento', 'demanda', 'capacidad')
suptitle('Intervenciones en el pico infeccioso')

fig.PaperPositionMode = 'manual';
orient(fig,'landscape');
print(fig,'fig1.9.pdf','-dpdf');

close all
