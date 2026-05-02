clearvars -except out

angle_stacionario = 18.4;
K_servo = angle_stacionario/500; % para obtener el comando del servo en angulo
Ts = 20e-3;
offset_y = 0.3;
%valores de la ventana
t_inicial = 1.9;
t_final = 2.8

%obtengo los datos
t_real = out.tout;
raw_y = out.dist;
raw_u = out.servo; 

y_proc = raw_y + offset_y; % offset para y
u_proc = raw_u * K_servo;

% Ventana 
indices = (t_real >= t_inicial) & (t_real <= t_final);
y_v = y_proc(indices);
u_v = u_proc(indices);
t_v = t_real(indices);

% Ecuación: y(n+2) = a1*y(n+1) + a2*y(n) + b1*u(n)
Y_obs = y_v(3:end); 
X_reg = [y_v(2:end-1), y_v(1:end-2), u_v(1:end-2)]; % retraso de 2 muestras
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

Hs = d2c(Hz, 'tustin')
s=tf('s');
%p1=-21; p2=-20;
%Hs = p1*p2/((s-p1)*(s-p2));

polos_z = roots(den_z);
polos_s = pole(Hs); 

%polos_s1 = log(polos_z)/Ts %calculo a mano de los polos en continuo para verificar

% Simulamos la respuesta del modelo con la entrada real
y_sim_z = lsim(Hz, u_v, t_real(indices));
y_sim_s = lsim(Hs, u_v, t_real(indices));

%% Resultados

%Discreto
%fprintf('Función de Transferencia Discreta H(z):\n');
%tf(Hz)
%fprintf('Polos discretos (Z):\n');
disp(polos_z);

%Continuo
fprintf('Función de Transferencia Continua H(s):\n');
tf(Hs)
fprintf('Polos continuos (S):\n');
disp(polos_s);

%% Graficos

% Datos medidos
% figure;
% plot(t_real, raw_y, 'b', 'LineWidth', 1.2); 
% hold on; 
% plot(t_real, y_proc, 'r', 'LineWidth', 1.5); 
% grid on;
%title('Datos sin y con offset');
% legend('y_{raw} (Original)', 'y_{proc} (Con Offset)');
% hold off; 

% Angulo servo y angulo barra
figure;
plot(t_v, y_v,'g', 'LineWidth', 1.5);
hold on; 
plot(t_v, u_v, 'r','LineWidth', 1.5);
grid on;
title('Ventana utilizado');
legend('angulo_barra', 'angulo_servo');
hold off; 

% % Respusta a escalon discreto y continuo
figure;
step(Hs*angle_stacionario);
hold on; 
step(Hz*angle_stacionario);

figure;
plot(t_real(indices), y_v, 'g', 'LineWidth', 1.5); hold on;
plot(t_real(indices), y_sim_z, 'r--', 'LineWidth', 1.5);
plot(t_real(indices), y_sim_s, 'y--', 'LineWidth', 1.5);
plot(t_real(indices), u_v, 'b', 'LineWidth', 1); 
title('Planta Real vs. Modelo Identificado');
legend('Ángulo IMU', 'Modelo (discreto)', 'Modelo (continuo)', 'Entrada (u)');
grid on;