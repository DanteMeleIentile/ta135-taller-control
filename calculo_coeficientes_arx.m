clearvars -except out

angle_stacionario = 18.4;
K_servo = angle_stacionario/500; % para obtener el comando del servo en angulo
Ts = 20e-3;
offset_y = 0.3;
t_inicial = 10.0; %valores de la ventana
t_final = 40.0;

%obtengo los datos
t_real = out.tout;
raw_y = out.d1;
raw_u = out.d2; 

y_proc = raw_y + offset_y; % offset para y
u_proc = raw_u * K_servo;

% Ventana 
indices = (t_real >= t_inicial) & (t_real <= t_final);
y_v = double(y_proc(indices));
u_v = double(u_proc(indices));
t_v = double(t_real(indices));

%% Minimos cuadrados

data = iddata(y_v, u_v, Ts);

sys_arx = arx(data, [2 2 1]); 
% arx(datos, [a, b,c])
% a = cantidad de polos
% b = retrados de la u
% c = cantidad de retardos de ntrada considerar
Hz_arx = tf(sys_arx.B, sys_arx.A, Ts);

% Modelo TFEST (Continuo Directo: 2 polos, 0 ceros)
sys_tf = tfest(data, 2, 0); 
Hs_tfest = tf(sys_tf.Numerator, sys_tf.Denominator);

%Simulaciones
y_sim_arx    = lsim(Hz_arx, u_v, t_v);
y_sim_tfest  = lsim(Hs_tfest, u_v, t_v);

%% Resultados

fprintf('\n Modelo ARX (Discreto)\n');
tf(Hz_arx)

fprintf('\n Modelo TFEST (Continuo)\n');
tf(Hs_tfest)

%% Graficos

figure;
plot(t_v, y_v, 'g--', 'LineWidth', 2); hold on;
plot(t_v, y_sim_arx, 'b--', 'LineWidth', 1.5);
plot(t_v, y_sim_tfest, 'c--', 'LineWidth', 1.5);
plot(t_v, u_v, 'r', 'LineWidth', 1);
title('Planta Real vs Modelos Identificados');
xlabel('Tiempo [s]'); ylabel('Ángulo [grados]');
legend('IMU', 'Modelo ARX (discreto)', 'Modelo TFEST (continuo)', 'Entrada (u)', 'Location', 'SouthEast');
grid on;
