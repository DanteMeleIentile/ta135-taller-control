clearvars -except out

angle_stacionario = 18.4;
K_servo = angle_stacionario/500; % para obtener el comando del servo en angulo
Ts = 20e-3;
offset_y = 0.3;
%valores de la ventana
t_inicial = 11.9;
t_final = 12.9;

%obtengo los datos
t_real = out.tout;
raw_angle_barra = out.angle_barra;
raw_servo = out.servo; 
raw_dist = out.dist; 


%Resultados
figure;
plot(t_real, raw_angle_barra, 'b', 'LineWidth', 1.2); 
hold on; 
plot(t_real,raw_servo, 'r', 'LineWidth', 1.5); 
hold on;
plot(t_real,raw_dist, 'g', 'LineWidth', 1.5); 
grid on;
title('Datos sin y con offset');
legend('y_{raw} (Original)', 'y_{proc} (Con Offset)');
hold off;

%save('nombre.mat')

