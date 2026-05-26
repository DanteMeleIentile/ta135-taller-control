close all;clc
clearvars -except out

t_inicial       = 0;
t_final         = 5;
Ts              = 20e-3;


t_real_1        = out.tout;
raw_ang_1       = out.angle_barra;
raw_u_1         = out.servo; 
raw_dist_1      = out.dist;

indices_1 = (t_real_1 >= t_inicial) & (t_real_1 <= t_final);
indices = indices_1;
t_v_1   = t_real_1(indices);
ang_1   = raw_ang_1(indices);
u_1     = raw_u_1(indices);
dist_1  = raw_dist_1(indices);

figure;
plot(t_v_1, dist_1, 'b', 'LineWidth', 1.2); 
hold on; 
plot(t_v_1, u_1 * 0.03, 'g', 'LineWidth', 1.5); 
grid on;
title("Ventana de tiempo seleccionada");
hold off;

%%

s=tf('s');
p1  = -18
p2  = -17
k_b = +0.04;
H_barra = p1*p2*k_b /((s-p1)*(s-p2));

p3  = 0;
p4  = -3.5;
k_c = 21; 
H_carrito = k_c /((s-p3)*(s-p4));

H_total = H_barra * H_carrito


figure();
rlocus(H_total);

dist_simulada_total = lsim(H_total, u_1, t_v_1);

figure;
plot(t_v_1, (dist_1 - 22.3), 'g', 'LineWidth', 1.5); hold on;
plot(t_v_1, dist_simulada_total , 'r--', 'LineWidth', 1.5); hold on;
plot(t_v_1, u_1 , 'b', 'LineWidth', 1.5); 
title('Planta Completa (4 Polos): Distancia Real vs Simulada');
xlabel('Tiempo [s]');
ylabel('Distancia [m]');
ylim([-20, 20]);
xlim([0, 5]);
legend('Distancia Real (Sensor)', 'Distancia Simulada (Modelo)');
grid on;
hold off;
