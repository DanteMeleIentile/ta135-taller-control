clear all;close all;clc
s=tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

Ts = 20e-3;
p1=-22;
p2=-23;
k_planta = 0.04133; 
P = k_planta*p1*p2/((s-p1)*(s-p2));

A = [0,         1;
    -(p1*p2), p1+p2];
disp(A);

B = [       0;
    k_planta * p1 * p2];
disp(B);

clear all;close all;clc
s=tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

Ts = 20e-3;
p1=-22;
p2=-23;
k_planta = 0.04133; 
P = k_planta*p1*p2/((s-p1)*(s-p2));

A = [0,         1;
    -(p1*p2), p1+p2];
B = [       0;
    k_planta * p1 * p2];
C = [1, 0]; 
D = 0;


sys_c = ss(A, B, C, D)
sys_d = c2d(sys_c, Ts, 'zoh')
[Ad2, Bd2, Cd2, Dd2] = ssdata(sys_d)

%I = eye(size(A));
%Ad = I + A * Ts;
%Bd = B * Ts;
disp(Ad2);
disp(Bd2);

l1_cont = -30; 
l2_cont = -35; 
l1_z = exp(l1_cont * Ts)
l2_z = exp(l2_cont * Ts)

L_d = place(Ad2', Cd2', [l1_z, l2_z])';
l1_d = L_d(1);
l2_d = L_d(2);

disp('Ganancias del observador en tiempo discreto (L_d):');
disp(['l1_d = ', num2str(l1_d)]);
disp(['l2_d = ', num2str(l2_d)]);