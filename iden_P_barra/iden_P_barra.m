%save('datosX.mat', 'raw_ang_X', 'raw_u_X', 'raw_dist_X', 'indices_X', 't_v_X', 'ang_X', 'u_X', 'dist_X');
close all;clc
clearvars -except out


t_inicial   = 0.7;
t_final     = 1.2;
Ts          = 20e-3;

%obtengo los datos
t_real_2        = out.tout;
raw_ang_2       = out.angle_barra;
raw_u_2         = out.servo; 
raw_dist_2      = out.dist;

indices_2 = (t_real_2 >= t_inicial) & (t_real_2 <= t_final);
indices = indices_2;
t_v_2   = t_real_2(indices);
ang_2   = raw_ang_2(indices);
u_2     = raw_u_2(indices);
dist_2  = raw_dist_2(indices);

figure;
plot(t_v_2, ang_2, 'b', 'LineWidth', 1.2); 
hold on; 
plot(t_v_2, u_2 * 0.03, 'g', 'LineWidth', 1.5); 
grid on;
title("Ventana de tiempo seleccionada");
hold off;


%%
% Ecuación: y(n+2) = a1*y(n+1) + a2*y(n) + b1*u(n)
Y_obs = ang_2(3:end); 
X_reg = [ang_2(2:end-1), ang_2(1:end-2), u_2(1:end-2)]; % retraso de 2 muestras
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
p1  = -23
p2  = -22
k_c = +0.03897; %ang_x / u_x
Hs = p1*p2*k_c /((s-p1)*(s-p2));

polos_z = roots(den_z)
polos_s = pole(Hs)

% Simulamos la respuesta del modelo con la entrada real
y_sim_z = lsim(Hz, u_2, t_v_2);
y_sim_s = lsim(Hs, u_2, t_v_2);

error = ang_2 - y_sim_s;
MSE = mean(error.^2);
fprintf('\nMSE en ventana: %.4f\n', MSE);


figure();
plot(t_v_2, ang_2, 'g', 'LineWidth', 1.5); hold on;
plot(t_v_2, y_sim_s, 'y--', 'LineWidth', 1.5);
plot(t_v_2, u_2 * 0.03, 'b', 'LineWidth', 1); 
title('Planta Real vs. Modelo Identificado');
legend('Real', 'Estimación', 'Entrada (u)');
grid on;