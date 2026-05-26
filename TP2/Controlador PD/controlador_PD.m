%save('datosX.mat', 'raw_ang_X', 'raw_u_X', 'raw_dist_X', 'indices_X', 't_v_X', 'ang_X', 'u_X', 'dist_X');
close all;clc
clearvars -except out

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

Ts    = 20e-3;
s=tf('s');
k_b = 0.042; 
p1 = -17;
p2 = -18;
k_c = -6; 
p3  = 0;
p4  = -3.5;

H_total = k_b * (p1) * (p2) * k_c * (p4) /((s-p1)*(s-p2) * (s-p3)*(s-p4))


k_p = 18
k_d = 0.5
p_lejano = 70
C = k_p + k_d * s * p_lejano / (s + p_lejano)
    
C_dig = c2d(C, Ts, 'tustin')
[b, a] = tfdata(C_dig, 'v');
fprintf('float u_0 = %.4f*u_1 + %.4f*e_0  %.4f*e_1;\n', -a(2), b(1), b(2));

pade = zpk([4/Ts], [ -4/Ts],-1);

L = C * H_total* pade;

figure();
bode(L);
%bode(C);
%figure();
%rlocus(L);


%% DATOS REALES
% t_real      = out.tout;
% t_real      = t_real - 0; 
% real_d      = out.real_d ; 
% real_ref    = out.real_ref;
% real_u      = out.real_u;
% flag_sat    = out.flag_sat;

% if any(flag_sat)
%     error('Saturación detectada. Se detiene la ejecución del script.');
% end

disp('Corriendo simulación...');
simOut = sim('sistema_PD'); 

sim_time    = simOut.sim_time; 
sim_d       = simOut.sim_d ;
sim_ref     = simOut.sim_ref;
sim_u       = simOut.sim_u;

figure;
plot(t_real, real_ref, 'b-.', 'LineWidth', 1.5); hold on;
plot(t_real-0.18, real_d + 0.2, 'g', 'LineWidth', 1.5); 
plot(sim_time, sim_d, 'r--', 'LineWidth', 1.5); 
ylabel('d(t) [cm]');
xlabel('Tiempo [s]');
legend('referencia', 'd real', 'd simulado');
xlim([36, 44]);
ylim([-12, 15]);
grid on;
hold off;


figure;
plot(t_real, real_u, 'g', 'LineWidth', 1.5); hold on;
plot(sim_time, sim_u, 'r--', 'LineWidth', 1.5);
xlabel('Tiempo [s]');
ylabel('u(t) [\mus]');
legend('u real', 'u simulado');
xlim([8, 16]);
ylim([-150, 450]);
grid on;
hold off;