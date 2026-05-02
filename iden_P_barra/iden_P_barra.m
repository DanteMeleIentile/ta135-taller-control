%save('nombre.mat')
close all;clc
clearvars -except out


t_inicial   = 0.5;
t_final     = 1.5;
Ts          = 20e-3;

%obtengo los datos
t_real_1        = out.tout;
raw_ang_1       = out.angle_barra;
raw_u_1         = out.servo; 
raw_dist_1      = out.dist;

indices = (t_real_1 >= t_inicial) & (t_real_1 <= t_final);
t_v_1   = t_real_1(indices);
ang_1   = raw_ang_1(indices);
u_1     = raw_u_1(indices);
dist_1  = raw_dist_1(indices);

figure;
plot(t_v_1, ang_1, 'b', 'LineWidth', 1.2); 
hold on; 
plot(t_v_1, u_1 * 0.03, 'g', 'LineWidth', 1.5); 
grid on;
title("Ventana de tiempo seleccionada");
hold off;


%%
% Ecuación: y(n+2) = a1*y(n+1) + a2*y(n) + b1*u(n)
Y_obs = ang_1(3:end); 
X_reg = [ang_1(2:end-1), ang_1(1:end-2), u_1(1:end-2)]; % retraso de 2 muestras
% lo que hace es poner un cero de fase no minimaen continua para simular el
% restraso de 2 muestras

% Minimos cuadrados
alpha = X_reg \ Y_obs;
a1 = alpha(1);
a2 = alpha(2);
b1 = alpha(3);

% Funciones de transferencia
num_z = [b1]; % retraso de 2 muestras
den_z = [1, -a1, -a2];
Hz = tf(num_z, den_z, Ts);

Hs = d2c(Hz, 'tustin');
s=tf('s');
p1  = -22
p2  = -23
k_c = +0.04133;
Hs = p1*p2*k_c /((s-p1)*(s-p2));

polos_z = roots(den_z)
polos_s = pole(Hs)

% Simulamos la respuesta del modelo con la entrada real
y_sim_z = lsim(Hz, u_1, t_v_1);
y_sim_s = lsim(Hs, u_1, t_v_1);

error = ang_1 - y_sim_s;
MSE = mean(error.^2);
fprintf('\nMSE en ventana: %.4f\n', MSE);


figure();
plot(t_v_1, ang_1, 'g', 'LineWidth', 1.5); hold on;
plot(t_v_1, y_sim_s, 'y--', 'LineWidth', 1.5);
plot(t_v_1, u_1 * 0.03, 'b', 'LineWidth', 1); 
title('Planta Real vs. Modelo Identificado');
legend('Real', 'Estimación', 'Entrada (u)');
grid on;