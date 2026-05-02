%save('nombre.mat')
close all;clc
clearvars -except out;


%valores de la ventana
t_inicial   = 0;
t_final     = 1.6;
Ts          = 20e-3;

%obtengo los datos
t_real          = out.tout;
raw_angle_barra = out.angle_barra;
raw_servo       = out.servo; 
raw_dist        = out.dist;

indices = (t_real >= t_inicial) & (t_real <= t_final);
t           = t_real(indices);
angle_barra = raw_angle_barra(indices);
servo       = raw_servo(indices);
dist        = raw_dist(indices);

%Resultados
figure;
plot(t, angle_barra, 'b', 'LineWidth', 1.2); 
hold on; 
%plot(t_real, raw_servo, 'r', 'LineWidth', 1.5); 
%hold on;
plot(t, dist, 'g', 'LineWidth', 1.5); 
grid on;
hold off;


%% CUADRADOS
Y_obs = dist(3:end); 
X_reg = [dist(2:end-1), dist(1:end-2), angle_barra(1:end-2)]; 

alpha = X_reg \ Y_obs;
a1 = alpha(1);
a2 = alpha(2);
b1 = alpha(3);

num_z = [0, 0, b1];
den_z = [1, -a1, -a2];
Hz_carrito = tf(num_z, den_z, Ts);

Hs_carrito = d2c(Hz_carrito, 'tustin');

clc;
disp('--- Modelo del Carrito Identificado ---');
fprintf('Polos discretos (Z):\n');
disp(pole(Hz_carrito));
% En el plano Z, un integrador puro está en z = 1

fprintf('Polos continuos (S):\n');
disp(pole(Hs_carrito));
% En el plano S, un integrador puro está en s = 0

%% Simulación vs Realidad
% Simulamos la respuesta de nuestro modelo ante la entrada real de la IMU
dist_simulada = lsim(Hz_carrito, angle_barra, t);

figure;
plot(t, dist - 4, 'g', 'LineWidth', 1.5); hold on;
plot(t, dist_simulada, 'r--', 'LineWidth', 1.5);
title('Carrito: Posición Real vs Modelo Identificado');
legend('Distancia Real (Sensor)', 'Distancia Modelo');
grid on;


%% BARRA
s = tf('s');
p1_barra = -18; 
p2_barra = -17;
% Ganancia de la barra (Ajustar si tu K_servo era distinto en el TP1)
K_barra = p1_barra * p2_barra; 
Hs_barra = K_barra * 20 / ((s - p1_barra) * (s - p2_barra));


p1_carro = -0.35; 
p2_carro = -205;
K_carro = 1; 
Hs_carrito_manual = K_carro / ((s - p1_carro) * (s - p2_carro));

H_total = Hs_barra * Hs_carrito_manual; 
dist_simulada_total = lsim(H_total, servo, t);

figure;
plot(t, dist - 4, 'g', 'LineWidth', 1.5); hold on;
plot(t, dist_simulada_total, 'r--', 'LineWidth', 1.5);
title('Planta Completa (4 Polos): Distancia Real vs Simulada');
xlabel('Tiempo [s]');
ylabel('Distancia [m]');
legend('Distancia Real (Sensor)', 'Distancia Simulada (Modelo)');
grid on;
hold off;

% Mostramos los polos finales por consola
clc;
disp('--- Polos de la Planta Completa (H_total) ---');
disp(pole(H_total));


%%
t_inicial   = 0;
t_final_2     = 7;


indices_2 = (t_real >= t_inicial) & (t_real <= t_final_2);
t_real_2    = t_real(indices_2);
servo_2       = raw_servo(indices_2);
dist_2        = raw_dist(indices_2);


dist_simulada_full = lsim(H_total, servo_2, t_real_2);

figure;
% Mantenemos el offset de -4 que usaste en tus gráficos anteriores
plot(t_real_2, dist_2 - 4, 'g', 'LineWidth', 1.5); hold on; 
plot(t_real_2, dist_simulada_full, 'r--', 'LineWidth', 1.5);

title('Validación Cruzada: Planta Completa vs Tren de Escalones');
xlabel('Tiempo [s]');
ylabel('Distancia [m]');
legend('Distancia Real (Sensor)', 'Distancia Simulada (Modelo)');
grid on;
hold off;

% Opcional: Calcular el error cuadrático en toda la ventana para tener un número
error_validacion = (dist_2 - 4) - dist_simulada_full;
MSE = mean(error_validacion.^2);
fprintf('\nError Cuadrático Medio (MSE) en la validación: %.4f\n', MSE);