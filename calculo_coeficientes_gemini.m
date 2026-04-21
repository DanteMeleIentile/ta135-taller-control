clearvars -except out

%% --- 1. CONFIGURACIÓN INICIAL ---
angle_stacionario = 18.4;
K_servo = angle_stacionario/500; % Conversión de PWM a grados (Acción virtual)
Ts = 20e-3;
offset_y = 0.3;

% Ventana de tiempo para la identificación
t_inicial = 10.0;
t_final = 40.0;

%% --- 2. EXTRACCIÓN Y PREPROCESAMIENTO ---
t_real = out.tout;
raw_y = out.d1;
raw_u = out.d2; 

y_proc = raw_y + offset_y; % Aplicar offset a la salida medida
u_proc = raw_u * K_servo;  % Convertir PWM a grados comandados

% Filtrado por ventana de tiempo
indices = (t_real >= t_inicial) & (t_real <= t_final);
y_v = y_proc(indices);
u_v = u_proc(indices);
t_v = t_real(indices);

%% --- 3. MÉTODO MANUAL (Mínimos Cuadrados Puros) ---
% Ecuación: y(n+2) = a1*y(n+1) + a2*y(n) + b1*u(n)
Y_obs = y_v(3:end); 
X_reg = [y_v(2:end-1), y_v(1:end-2), u_v(1:end-2)]; % Retraso de 2 muestras
alpha = X_reg \ Y_obs;
a1 = alpha(1); a2 = alpha(2); b1 = alpha(3);

num_z_manual = b1; 
den_z_manual = [1, -a1, -a2];
Hz_manual = tf(num_z_manual, den_z_manual, Ts); 
Hs_manual = d2c(Hz_manual, 'zoh');

%% --- 4. PREPARACIÓN BLINDADA PARA EL TOOLBOX ---
% A. Detectar NaNs e Infinitos
indices_malos = isnan(y_v) | isinf(y_v) | isnan(u_v) | isinf(u_v);
y_v(indices_malos) = [];
u_v(indices_malos) = [];
t_v(indices_malos) = [];

% B. Forzar a vectores columna (N x 1) y castear a double
y_v = double(y_v(:));
u_v = double(u_v(:));
t_v = double(t_v(:));
Ts  = double(Ts);

%% --- 5. INTEGRACIÓN SYSTEM IDENTIFICATION TOOLBOX ---
% Empaquetado
datos_id = iddata(y_v, u_v, Ts);

% Modelo ARX (Discreto: 2 polos, 1 coeficiente de entrada, 1 muestra de retraso)
sys_arx = arx(datos_id, [2 1 2]); 
Hz_arx = tf(sys_arx.B, sys_arx.A, Ts);

% Modelo TFEST (Continuo Directo: 2 polos, 0 ceros)
sys_tf = tfest(datos_id, 2, 0); 
Hs_tfest = tf(sys_tf.Numerator, sys_tf.Denominator);

%% --- 6. IMPRESIÓN DE RESULTADOS ---
clc;
fprintf('=== RESULTADOS DE IDENTIFICACIÓN ===\n');

fprintf('\n--- 1. MÉTODO MANUAL (Continuo vía ZOH) ---\n');
tf(Hs_manual)

fprintf('\n--- 2. TOOLBOX: Modelo ARX (Discreto) ---\n');
tf(Hz_arx)

fprintf('\n--- 3. TOOLBOX: Modelo TFEST (Continuo Directo) ---\n');
tf(Hs_tfest)

%% --- 7. GRÁFICOS COMPARATIVOS ---
% Figura 1: Preprocesamiento original
figure('Name', 'Preprocesamiento de Datos');
plot(t_real, raw_y, 'b', 'LineWidth', 1.2); hold on; 
plot(t_real, y_proc, 'r', 'LineWidth', 1.5); 
grid on; 
legend('y_{raw} (Original)', 'y_{proc} (Con Offset)', 'Location', 'best'); 
title('Preprocesamiento de Datos (IMU)');
xlabel('Tiempo [s]'); ylabel('Ángulo [grados]');

% Simulaciones (lsim) de los tres modelos para comparar contra la realidad
y_sim_manual = lsim(Hz_manual, u_v, t_v);
y_sim_arx    = lsim(Hz_arx, u_v, t_v);
y_sim_tfest  = lsim(Hs_tfest, u_v, t_v);

% Figura 2: Comparativa de Modelos vs Planta Real
figure('Name', 'Comparación de Modelos Identificados');
plot(t_v, y_v, 'k', 'LineWidth', 2); hold on;
plot(t_v, y_sim_manual, 'r--', 'LineWidth', 1.5);
plot(t_v, y_sim_arx, 'b--', 'LineWidth', 1.5);
plot(t_v, y_sim_tfest, 'g--', 'LineWidth', 1.5);
plot(t_v, u_v, 'm-', 'LineWidth', 1); % Mostrar el escalón comandado
title('Comparación Global: Planta Real vs. Modelos Identificados');
xlabel('Tiempo [s]'); ylabel('Ángulo [grados]');
legend('Planta Real (IMU limpia)', 'Modelo Manual', 'Modelo ARX', 'Modelo TFEST', 'Entrada Comandada (u)', 'Location', 'SouthEast');
grid on;