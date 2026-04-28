
clear all;close all;clc
s=tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';



Ts = 20e-3;
k_planta = -0.099863;
p1= 10.14;
P = k_planta * s/( (s+p1) * (s-p1) )

p1_cuad = 10.14^2; % 102.8196

% Forma Canónica Controlable
A = [0, 1; 
     p1_cuad, 0];
     
B = [0; 
     1];
     
C = [0, k_planta];
D = 0;


sys_fisc = ss(A, B, C, D)


% x0 = [posición_inicial; velocidad_inicial]
x0 = [5*pi/180; 0]; 
initial(sys_fisc, x0);
kc = -1%db2mag(50);
cero_c = p1;
polo_c = 80;
C = zpk([-p1, -p1],[0, -polo_c],kc)

L = minreal(C*P);


S=1/(1+L);
T=1-S;


% figuras
figure();
bode(C,optionss);title("C")

figure();
bode(L,optionss);title("L")

