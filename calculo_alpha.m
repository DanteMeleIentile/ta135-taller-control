%clear all;close all;clc
clearvars -except out
Ts = 20e-3;           
t_inicial = 60 ;      
t_final = 80;       

offset_y = 0.0;      
offset_u = 0.0; 

% --- Extracción y Preprocesamiento de Datos ---
raw_y = out.d1; 

%TIEMPO
%t = (0:length(raw_y)-1)' * Ts;
t = out.tout;
u = out.d2;

% Filtrado por ventana de tiempo
indices = (t >= t_inicial) & (t <= t_final);
y_proc = raw_y(indices) - offset_y;
u_proc = u(indices) + offset_u;
t_proc = t(indices);

% --- Cuadrados Mínimos---
retardo = 4;
Y_obs = y_proc(2+retardo:end);

X_reg = [y_proc(2+retardo-1:end-1), y_proc(2+retardo-2:end-2), u_proc(2:end-retardo)];

alpha = X_reg \ Y_obs;

a1 = alpha(1);
a2 = alpha(2);
b1 = alpha(3);


num_z = [0, 0, b1]; 
den_z = [1, -a1, -a2];
Hz = tf(num_z, den_z, Ts)


% Conversión a continuo usando ZOH (ideal para escalones)
Hs = d2c(Hz, 'zoh') * 1.3;
polos = eig(Hs)

% --- Resultados ---
fprintf('Coeficientes identificados:\n');
fprintf('a1: %.4f, a2: %.4f, b1: %.4f\n', a1, a2, b1);
disp('Función de Transferencia Continua:');
tf(Hs)

figure();
step(Hs);

%%
% --- (Asumiendo que ya tienes tu Hs calculado sin ceros y tus variables t_proc, u_proc y y_proc) ---

% --- SIMULACIÓN DEL MODELO CONTINUO CON ENTRADA REAL ---
% lsim evalúa el modelo continuo (Hs) usando la entrada medida (u_proc) en los instantes (t_proc)
y_sim_continua = lsim(Hs, u_proc, t_proc);

% --- RESULTADOS Y GRÁFICAS ---
figure('Name', 'Validación del Modelo Continuo', 'Color', 'w');

% Gráfica 1: Planta Real vs Modelo Continuo
plot(t_proc, y_proc + offset_y*2, 'b', 'LineWidth', 1.5); hold on;
plot(t_proc, y_sim_continua, 'r--', 'LineWidth', 1.5);
grid on;
title('Respuesta: Datos Reales vs Modelo Continuo H(s)');
ylabel('Amplitud (Ángulo)');
legend('Salida Real (Medida)', 'Salida Modelo Continuo', 'Location', 'best');


sa