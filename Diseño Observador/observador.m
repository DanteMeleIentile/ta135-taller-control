clear all;close all;clc
s=tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

Ts      = 20e-3;
k_b     = 0.042; 
p1      = -17;
p2      = -18;
k_c     = -6; 
p3      = 0;
p4      = -3.5;

P = k_b * (p1) * (p2) * k_c * (p4) /((s-p1)*(s-p2) * (s-p3)*(s-p4))

A = [0,         1,      0,      0;
    -(p1*p2), p1+p2,    0,      0;
    0,          0,      0,      1;
    k_c*p4,     0,      0,      p4];

B = [       0;
    k_b * p1 * p2;
            0;
            0];
C = [1,         0,      0,      0;
    0,          0,      1,      0];

D = 0;


sys_c = ss(A, B, C, D)
sys_d = c2d(sys_c, Ts, 'zoh')
[Ad2, Bd2, Cd2, Dd2] = ssdata(sys_d);

%I = eye(size(A));
%Ad = I + A * Ts;
%Bd = B * Ts;
disp(Ad2);
disp(Bd2');

%%
l1_cont = -30; 
l2_cont = -40; 
l3_cont = -20; 
l4_cont = -20; 
l1_z = exp(l1_cont * Ts)
l2_z = exp(l2_cont * Ts)
l3_z = exp(l3_cont * Ts)
l4_z = exp(l4_cont * Ts)

L_d = place(Ad2', Cd2', [l1_z, l2_z, l3_z, l4_z])'
l1_d = L_d(1);
l2_d = L_d(2);
l3_d = L_d(3);
l4_d = L_d(4);

% Impresión Valores L
fprintf('const float L[4][2] = {\n');
for i = 1:4
    fprintf('\t{%.6f,\t\t%.6f}', L_d(i,1), L_d(i,2));
    if i < 5, fprintf(',\n'); else fprintf('\n'); end
end
fprintf('};\n');

%%
%save('observador_XX_XX_XX_XX.mat', 't_real', 'angle_real', 'angle_est', 'w_real', 'w_est', 'd_real', 'd_est', 'vel_est', 'vel_simulink', 'u_real');
t_real          = out.tout;
angle_real      = out.angle_barra;
angle_est       = out.angle_est;
w_real          = out.w_real;
w_est           = out.w_est;
d_real          = out.d_real;
d_est           = out.d_est;
vel_est         = out.vel_est;
vel_simulink    = out.vel_simulink;
u_real          = out.u;

