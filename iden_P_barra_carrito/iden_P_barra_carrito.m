%save('datosX.mat', 'raw_ang_X', 'raw_u_X', 'raw_dist_X', 'indices_X', 't_v_X', 'ang_X', 'u_X', 'dist_X');
close all;clc
clearvars -except out


t_inicial       = 25.6;
t_final         = 26.6;

offset_dist_3   = 2.5; 

%obtengo los datos
t_real_3        = out.tout;
raw_ang_3       = out.angle_barra;
raw_u_3         = out.servo; 
raw_dist_3      = out.dist;

indices_3 = (t_real_3 >= t_inicial) & (t_real_3 <= t_final);
indices = indices_3;
t_v_3   = t_real_3(indices);
ang_3   = raw_ang_3(indices);
u_3     = raw_u_3(indices);
dist_3  = raw_dist_3(indices) - offset_dist_3;

figure;
plot(t_v_3, ang_3, 'b', 'LineWidth', 1.2); 
hold on; 
plot(t_v_3, dist_3, 'g', 'LineWidth', 1.5); 
grid on;
plot(t_v_3, u_3*0.03, 'r', 'LineWidth', 1.5); 
grid on;
title("Ventana de tiempo seleccionada");
hold off;


%%
% Ecuación: y(n+2) = a1*y(n+1) + a2*y(n) + b1*u(n)
Y_obs = dist_3(3:end); 
X_reg = [dist_3(2:end-1), dist_3(1:end-2), ang_3(1:end-2)]; % retraso de 2 muestras
% lo que hace es poner un cero de fase no minimaen continua para simular el
% restraso de 2 muestras

% Minimos cuadrados
alpha = X_reg \ Y_obs;
a1 = alpha(1);
a2 = alpha(2);
b1 = alpha(3);

% Funciones de transferencia
num_z = [0, 0, b1]; % retraso de 2 muestras
den_z = [1, -a1, -a2];
Ts    = 20e-3;
Hz = tf(num_z, den_z, Ts);

Hs = d2c(Hz, 'tustin');
pole(Hs)
s=tf('s');
p1  = 0;
p2  = -3.5;
k_c = 6; 
Hs = k_c*(-p2) /((s-p1)*(s-p2));

polos_z = roots(den_z);
polos_s = pole(Hs)

% Simulamos la respuesta del modelo con la entrada real
y_sim_z = lsim(Hz, ang_3, t_v_3);
y_sim_s = lsim(Hs, ang_3, t_v_3);

error = dist_3 - y_sim_s;
MSE = mean(error.^2);
fprintf('\nMSE en ventana: %.4f\n', MSE);
RMSE = sqrt(MSE);
fprintf('Error medio real: %.2f grados\n', RMSE);


figure();
plot(t_v_3, dist_3, 'g', 'LineWidth', 1.5); hold on;
plot(t_v_3, y_sim_s, 'r--', 'LineWidth', 1.5);
plot(t_v_3, ang_3 , 'b', 'LineWidth', 1); 
xlabel('Tiempo (s)');
ylabel('d(t) [cm] / \theta(t) [°]');
legend('d(t) real', 'd(t) estimado', '\theta(t) - IMU', 'Location', 'southeast');
grid on;