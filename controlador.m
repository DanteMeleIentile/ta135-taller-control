clear all; close all; clc
s = tf('s');

Ts = 20e-3;
p1 = -17;
p2 = -18;
k_planta = 0.042; 


A = [0,         1;
    -(p1*p2), p1+p2];
B = [       0;
    k_planta * p1 * p2];
C = [1, 0]; 
D = 0;

sys_c = ss(A, B, C, D);
sys_d = c2d(sys_c, Ts, 'zoh');
[Ad2, Bd2, Cd2, Dd2] = ssdata(sys_d);
%% Observador

l1_cont = -30; 
l2_cont = -40; 
l1_z = exp(l1_cont * Ts);
l2_z = exp(l2_cont * Ts);

L_d = place(Ad2', Cd2', [l1_z, l2_z])';

disp('Ganancias del OBSERVADOR (L_d):');
fprintf('l1_d = %.4f\n', L_d(1));
fprintf('l2_d = %.4f\n\n', L_d(2));

%% Realimentación de estados

polo_c1_cont = -20;
polo_c2_cont = -25;
z1_c = exp(polo_c1_cont * Ts);
z2_c = exp(polo_c2_cont * Ts);

K_d = place(Ad2, Bd2, [z1_c, z2_c]);

disp('Ganancias del CONTROLADOR (K_d):');
fprintf('k1 = %.4f\n', K_d(1));
fprintf('k2 = %.4f\n', K_d(2));