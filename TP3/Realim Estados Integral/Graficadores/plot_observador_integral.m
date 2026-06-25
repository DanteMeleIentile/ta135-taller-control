%% --------------------------------------------------------
% VALIDACIÓN DEL OBSERVADOR: REAL vs ESTIMADO vs SIMULADO
% ---------------------------------------------------------
clear all; close all; clc;

% Cargar los datos (Cambiá el nombre por el archivo que quieras ver)
load('datos_-10_465_46_125_B.mat'); 

% Definir ventana de tiempo para analizar
t_start = 0;  
t_end   = 120; % Ajustar según cuántos escalones quieras mostrar
inicio = 92;
fin  = 102;
t_sim_offset = 0; % Ajustar para alinear la simulación con el inicio del escalón real

% Recorte de vectores según la ventana de tiempo
idx = find(t_full >= t_start & t_full <= t_end);
t_real = t_full(idx) - t_start;

% Extracción de variables Reales y Estimadas (Arduino)
angle_real   = angle_real_full(idx);
angle_est    = angle_est_full(idx);
w_real       = w_real_full(idx);
w_est        = w_est_full(idx);
d_real       = d_real_full(idx);
d_est        = d_est_full(idx);
vel_simulink = vel_simulink_full(idx); % Derivada numérica de la distancia (Sucia)
vel_est      = vel_est_full(idx);
ref_d_real   = ref_d_full(idx); 
%%

% -- Gráfico 1: Ángulo --
figure('Name', 'Validación - Ángulo', 'NumberTitle', 'off', 'Position', [100 100 800 400]);
plot(t_real, angle_real, 'b-', 'LineWidth', 1); hold on; % Celeste (Real)
plot(t_real, angle_est, 'r--', 'LineWidth', 2);                          % Rojo (Estimado)
hold off;
xlabel('Tiempo [s]'); ylabel('$\theta(t) \ [^\circ/s]$', 'Interpreter', 'latex'); 
legend('Medido', 'Estimado', 'Location', 'best');
grid on; xlim([inicio, fin]);

% Gráfico 2: Velocidad Angular --
figure('Name', 'Validación - Velocidad Angular (w)', 'NumberTitle', 'off', 'Position', [150 150 800 400]);
plot(t_real, w_real, 'b', 'LineWidth', 1); hold on;
plot(t_real, w_est, 'r--', 'LineWidth', 2);
hold off;
xlabel('Tiempo [s]');
ylabel('$\dot{\theta}(t) \ [^\circ/s]$', 'Interpreter', 'latex');
legend('Medido', 'Estimado', 'Location', 'best');
grid on; xlim([inicio, fin]);

% -- Gráfico 3: Posición --
figure('Name', 'Validación - Posición (d)', 'NumberTitle', 'off', 'Position', [200 200 800 400]);
plot(t_real, d_real, 'b', 'LineWidth', 1.5); hold on; % Acá sí el real fuerte porque el SR04 es la base
plot(t_real, d_est, 'r--', 'LineWidth', 2);
plot(t_real, ref_d_real, 'k:', 'LineWidth', 1.5, 'DisplayName', 'Referencia'); 
hold off;
xlabel('Tiempo [s]'); ylabel('$d(t)$ [cm]', 'Interpreter', 'latex'); 
legend('Medido', 'Estimado', 'Referencia', 'Location', 'best');
grid on; xlim([inicio, fin]);

%%
% -- Gráfico 4: Velocidad Lineal --
figure('Name', 'Validación - Velocidad Lineal (vel)', 'NumberTitle', 'off', 'Position', [250 250 800 400]);
plot(t_real, vel_simulink, 'b', 'LineWidth', 1); hold on; % Derivada muy transparente porque es ruidosa
plot(t_real, vel_est, 'r--', 'LineWidth', 2);
hold off;
xlabel('Tiempo [s]'); ylabel('$\dot{d}(t)$ [cm/s]', 'Interpreter', 'latex');
legend('Calculado*', 'Estimado', 'Location', 'best');
grid on; xlim([96, 99]);