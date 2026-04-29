
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
kc = -db2mag(45);
%kc = -1;
cero_c = p1;
polo_c = 80;
C = zpk([-5],[0],kc)

L = minreal(C*P);

S=1/(1+L);
T=1-S;


% figuras
figure();
bode(C,optionss);title("C")

figure();
bode(L,optionss);title("L")


c_dig = c2d(C, Ts, 'tustin')



% 
% % 2. Cálculo de las constantes del PID
% kd = K_sisotool;
% kp = K_sisotool * (z1 + z2);
% ki = K_sisotool * (z1 * z2);
% 
% % 3. Mostrar los resultados en consola
% fprintf('--- Parámetros del Controlador PID ---\n');
% fprintf('Kp (Proporcional) = %.4f\n', kp);
% fprintf('Ki (Integral)     = %.4f\n', ki);
% fprintf('Kd (Derivativo)   = %.4f\n', kd);
% fprintf('------------------------------------\n\n');
% 
% % 4. Verificación: Armamos la función de transferencia para comprobar
% s = tf('s');
% C_pid = kp + ki/s + kd*s;
% 
% disp('Función de transferencia del PID resultante:');
% C_pid

% $$u[k] = u[k-1] - 694.94 e[k] + 567.00 e[k-1]$$