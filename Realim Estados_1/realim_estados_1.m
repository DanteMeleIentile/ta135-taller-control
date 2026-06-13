%Realim de estados
clear all;close all;clc
s=tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

Ts      = 20e-3;
k_b     = 0.042; 
p1      = -17;
p2      = -18;
k_c     = -6; 
p3      = 0;
p4      = -3.5;

P = k_b * (p1) * (p2) * k_c * (p4) /((s-p1)*(s-p2) * (s-p3)*(s-p4))

A = [0,         1,      0,      0;
    -(p1*p2), p1+p2,    0,      0;
    0,          0,      0,      1;
    k_c*p4,     0,      0,      p4];

B = [       0;
    k_b * p1 * p2;
            0;
            0];
C = [1,         0,      0,      0;
    0,          0,      1,      0];

D = [0;
    0];


sys_c = ss(A, B, C, D)
sys_d = c2d(sys_c, Ts, 'zoh')
[Ad2, Bd2, Cd2, Dd2] = ssdata(sys_d);

disp(Ad2);
disp(Bd2');

% Observador
l1_cont = -30; 
l2_cont = -40; 
l3_cont = -20; 
l4_cont = -20; 
l1_z = exp(l1_cont * Ts)
l2_z = exp(l2_cont * Ts)
l3_z = exp(l3_cont * Ts)
l4_z = exp(l4_cont * Ts)

L_d = place(Ad2', Cd2', [l1_z, l2_z, l3_z, l4_z])'
l1_d = L_d(1);
l2_d = L_d(2);
l3_d = L_d(3);
l4_d = L_d(4);


% Realimentación de estados
polo_k1 = -15.5;
polo_k2 = -15;
polo_k3 = -3.5+2i;        
polo_k4 = -3.5-2i;
z1_k = exp(polo_k1 * Ts);
z2_k = exp(polo_k2 * Ts);
z3_k = exp(polo_k3 * Ts);
z4_k = exp(polo_k4 * Ts);


K_d = place(Ad2, Bd2, [z1_k, z2_k, z3_k, z4_k]);
K_d = -K_d;

disp('Ganancias del CONTROLADOR (K_d):');
fprintf('const float K[4] = {%.6f, %.6f, %.6f, %.6f};\n', K_d(1), K_d(2), K_d(3), K_d(4));
x1_max = K_d(1) * 8;
x2_max = K_d(2) * 100;
x3_max = K_d(3) * 12;
x4_max = K_d(4) * 25;
fprintf('MAX = %.6f, %.6f, %.6f, %.6f, TOTAL = %.6f};\n', x1_max, x2_max, x3_max, x4_max, abs(x1_max)+abs(x2_max)+abs(x3_max)+abs(x4_max));


%% Toma de datos ARDUINO
t_full          = out.tout;
angle_real_full = out.angle_barra;
angle_est_full  = out.angle_est;
w_real_full     = out.w_real;
w_est_full      = out.w_est;
d_real_full     = out.d_real;
d_est_full      = out.d_est;
vel_simulink_full = out.vel_simulink; 
vel_est_full    = out.vel_est;

t_start = 2.5;  
t_end   = 7.5; 
idx = find(t_full >= t_start & t_full <= t_end);
t_real = t_full(idx) - t_start;
angle_real   = angle_real_full(idx);
angle_est    = angle_est_full(idx);
w_real       = w_real_full(idx);
w_est        = w_est_full(idx);
d_real       = d_real_full(idx);
d_est        = d_est_full(idx);
vel_simulink = vel_simulink_full(idx); 
vel_est      = vel_est_full(idx);


%% Simulación
x0_sim = [0; 0; 0; 80];
disp('Ejecutando simulación SIMULINK...');
sim_data = sim('realim_estados_1', 'ReturnWorkspaceOutputs', 'on'); 
disp('Simulación finalizada');

t_sim     = sim_data.tout;
angle_sim = sim_data.angle_sim;
w_sim     = sim_data.w_sim;
d_sim     = sim_data.d_sim;
vel_sim   = sim_data.vel_sim;



%% -------------- GUARDADO EN MATLAB --------------
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
nombre_archivo = sprintf('datos_ensayo_%s.mat', timestamp);
disp(['Guardando variables en: ', nombre_archivo]);
save(nombre_archivo, ...
    't_full', 'angle_real_full', 'angle_est_full', 'w_real_full', 'w_est_full', 'd_real_full', 'd_est_full', 'vel_simulink_full', 'vel_est_full', ...
    't_real', 'angle_real', 'angle_est', 'w_real', 'w_est', 'd_real', 'd_est', 'vel_simulink', 'vel_est', ...
    't_sim', 'angle_sim', 'w_sim', 'd_sim', 'vel_sim');


%% Graficos compración

% -- Gráfico 1: Ángulo --
figure('Name', 'Ángulo', 'NumberTitle', 'off');
plot(t_real, angle_real, 'b', 'LineWidth', 1.5); hold on;
plot(t_real, angle_est, 'r--', 'LineWidth', 1.5);
plot(t_sim, angle_sim, 'g-.', 'LineWidth', 2); hold off;
title('Ángulo (\theta): Real vs Estimado vs Simulado');
xlabel('Tiempo [s]'); ylabel('Ángulo [rad]'); 
legend('Real (Arduino)', 'Estimado (Observador)', 'Simulación Teórica', 'Location', 'best');
grid on;

% -- Gráfico 2: Velocidad Angular --
figure('Name', 'Velocidad Angular (w)', 'NumberTitle', 'off');
plot(t_real, w_real, 'b', 'LineWidth', 1.5); hold on;
plot(t_real, w_est, 'r--', 'LineWidth', 1.5);
plot(t_sim, w_sim, 'g-.', 'LineWidth', 2); hold off;
title('Velocidad Angular (\omega): Real vs Estimado vs Simulado');
xlabel('Tiempo [s]'); ylabel('Vel. Angular [rad/s]');
legend('Real (Arduino)', 'Estimado (Observador)', 'Simulación Teórica', 'Location', 'best');
grid on;

% -- Gráfico 3: Posición --
figure('Name', 'Posición (d)', 'NumberTitle', 'off');
plot(t_real, d_real, 'b', 'LineWidth', 1.5); hold on;
plot(t_real, d_est, 'r--', 'LineWidth', 1.5);
plot(t_sim, d_sim, 'g-.', 'LineWidth', 2); hold off;
title('Posición (d): Real vs Estimada vs Simulada');
xlabel('Tiempo [s]'); ylabel('Posición [m]'); 
legend('Real (Arduino)', 'Estimada (Observador)', 'Simulación Teórica', 'Location', 'best');
grid on;

% -- Gráfico 4: Velocidad Lineal --
figure('Name', 'Velocidad Lineal (vel)', 'NumberTitle', 'off');
plot(t_real, vel_simulink, 'b', 'LineWidth', 1.5); hold on;
plot(t_real, vel_est, 'r--', 'LineWidth', 1.5);
plot(t_sim, vel_sim, 'g-.', 'LineWidth', 2); hold off;
title('Velocidad Lineal (v): Medida vs Estimada vs Simulada');
xlabel('Tiempo [s]'); ylabel('Velocidad [m/s]');
legend('Derivada Numérica (Real)', 'Estimada (Observador)', 'Simulación Teórica', 'Location', 'best');
grid on;
