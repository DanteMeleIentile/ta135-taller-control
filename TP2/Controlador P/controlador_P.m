%save('datosX.mat', 'raw_ang_X', 'raw_u_X', 'raw_dist_X', 'indices_X', 't_v_X', 'ang_X', 'u_X', 'dist_X');
close all;clc
clearvars -except out

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

Ts  = 20e-3;
s=tf('s');
p1  = -18
p2  = -17
k_b = +0.042;
H_barra = p1*p2*k_b /((s-p1)*(s-p2));

p3  = 0;
p4  = -3.5;
k_c = -6; 
H_carrito = k_c * p4/((s-p3)*(s-p4));

H_total = H_barra * H_carrito


C_k = 20;

L = C_k * H_total;

H_total_dig = c2d(H_total, Ts, 'tustin');

%figure();
%bode(H_total);

% figure();
% bode(L);
% figure();
% rlocus(L);
%% Movimiento de variables
real_d = real_d - 5;
real_ref = real_ref - 5;


%% DATOS REALES
% t_real      = out.tout;
% t_real      = t_real - 12.26; 
% real_d      = out.real_d - 15; 
% real_ref    = out.real_ref - 15;
% real_u      = out.real_u;




disp('Corriendo simulación...');
simOut = sim('sistema_P'); 


sim_time    = simOut.sim_time; 
sim_d       = simOut.sim_d - 5;
sim_ref     = simOut.sim_ref - 5;
sim_u       = simOut.sim_u;

figure;
plot(t_real, real_ref, 'b-.', 'LineWidth', 1.5); hold on;
plot(t_real, real_d, 'g', 'LineWidth', 1.5); 
plot(sim_time, sim_d, 'r--', 'LineWidth', 1.5); 
xlabel('Tiempo [s]');
ylabel('d(t) [cm]');
legend('referencia', 'd real', 'd simulado');
xlim([8, 16.5]);
grid on;
hold off;


figure;
plot(t_real, real_u, 'g', 'LineWidth', 1.5); hold on;
plot(sim_time, sim_u, 'r--', 'LineWidth', 1.5);
xlabel('Tiempo [s]');
ylabel('u(t) [\mus]');
legend('u real', 'u simulado');
xlim([8, 16.5]);
ylim([-150, 250]);
grid on;
hold off;