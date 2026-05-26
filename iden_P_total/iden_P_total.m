%save('datosX.mat', 'raw_ang_X', 'raw_u_X', 'raw_dist_X', 'indices_X', 't_v_X', 'ang_X', 'u_X', 'dist_X');
close all;clc
clearvars -except out


t_inicial       = 4.6;
t_final         = 5.6;


%obtengo los datos
% t_real_4        = out.tout;
% raw_ang_4       = out.angle_barra;
% raw_u_4         = out.servo; 
% raw_dist_4      = out.dist;

% indices_4 = (t_real_4 >= t_inicial) & (t_real_4 <= t_final);
% indices = indices_4;
% t_v_4   = t_real_4(indices);
% ang_4   = raw_ang_4(indices);
% u_4     = raw_u_4(indices);
% dist_4  = raw_dist_4(indices);

% figure;
% plot(t_v_4, ang_4, 'b', 'LineWidth', 1.2); 
% hold on; 
% plot(t_v_4, dist_4, 'g', 'LineWidth', 1.5); 
% grid on;
% plot(t_v_4, u_4*0.03, 'r', 'LineWidth', 1.5); 
% grid on;
% title("Ventana de tiempo seleccionada");
% hold off;


%%
Ts    = 20e-3;
s=tf('s');
k_b = 0.042; 
p1 = -17;
p2 = -18;
k_c = -6; 
p3  = 0;
p4  = -3.5;

Hs = k_b * (p1) * (p2) * k_c * (p4) /((s-p1)*(s-p2) * (s-p3)*(s-p4))

polos_s = pole(Hs)


% HORARIO: Simulamos la respuesta del modelo con la entrada real
y_sim_s = lsim(Hs, u_6, t_v_6);

error = dist_6 - y_sim_s;
MSE = mean(error.^2);
fprintf('\nMSE en ventana: %.4f\n', MSE);
RMSE = sqrt(MSE);
fprintf('Error medio real: %.2f \n', RMSE);


figure();
plot(t_v_6, dist_6, 'g', 'LineWidth', 1.5); hold on;
plot(t_v_6, y_sim_s, 'r--', 'LineWidth', 1.5);
plot(t_v_6, ang_6 , 'b', 'LineWidth', 1); 
xlabel('Tiempo (s)');
ylabel('d(t) [cm] / \theta(t) [°]');
xlim([4.5, 5.44]);
ylim([-15, 5]);
legend('d(t) real', 'd(t) estimado', '\theta(t) - IMU', 'Location', 'northeast');
grid on;


% ANTIHORARIO: Simulamos la respuesta del modelo con la entrada real
y_sim_s = lsim(Hs, u_4, t_v_4);

error = dist_4 - y_sim_s;
MSE = mean(error.^2);
fprintf('\nMSE en ventana: %.4f\n', MSE);
RMSE = sqrt(MSE);
fprintf('Error medio real: %.2f \n', RMSE);


figure();
plot(t_v_4, dist_4, 'g', 'LineWidth', 1.5); hold on;
plot(t_v_4, y_sim_s, 'r--', 'LineWidth', 1.5);
plot(t_v_4, ang_4 , 'b', 'LineWidth', 1); 
xlabel('Tiempo (s)');
ylabel('d(t) [cm] / \theta(t) [°]');
xlim([4.6, 5.58]);
ylim([-5, 19.3]);
legend('d(t) real', 'd(t) estimado', '\theta(t) - IMU', 'Location', 'southeast');
grid on;

