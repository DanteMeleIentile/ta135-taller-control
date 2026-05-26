close all;clc
clearvars -except out


Ts    = 1;
s=tf('s');
k_p = -0.004233; 
pp = -0.002397;

H = k_p/(s-pp);


k_c = -1 * db2mag(16);
z1 = -0.05;

C = k_c * (s - z1)/ (s)

L = minreal(H * C);
figure();
bode(L);
figure();
rlocus(L);

z = tf('z', Ts);
s_discreta = (z - 1) / (Ts * z);
C_z = k_c * (s_discreta - z1)/ (s_discreta)

C_z = minreal(C_z)