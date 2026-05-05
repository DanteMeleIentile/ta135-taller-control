clear all;close all;clc
s=tf('s');

Ts = 20e-3;

k_planta = -0.099863;
p_planta = 10.14;
P = k_planta * s/( (s+p_planta) * (s-p_planta) )

% Forma Canónica Controlable
p1_cuad = 10.14^2;
A = [0, 1 ; 
     p1_cuad, 0];
B = [-0.099863; 0];
C = [1, 0];
D = 0;

sys_fisc = ss(A, B, C, D);

% x0 = [pos_inicial; velocidad_incial]
x1_0 = 5 * pi / (180);
x2_0 = 0;
x0 = [x1_0; x2_0];
%initial(sys_fisc, x0);



% ----- DISEÑO CONTROLADOR ----- %
kc = -1 * db2mag(56.5);
C = zpk([-11, -12],[0, -80], kc)
pid(C)

L = minreal(C*P);

%%

% ----- GRAFICOS ----- %
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';


%figure();
%bode(P,optionss);title("P")

%figure();
%bode(C,optionss);title("C")

figure();
bode(L,optionss);title("L")

%%
% ----- CONTROL DIGITAL ----- %
c_dig = c2d(C, Ts, 'tustin')

%pid = Kp + Ki * 1/s + Kd * s;

%0.004 * ki
% con esta configuracion el controlador satura 
% acciones de control
% derivatvo = 25 , integrak = 5, proporcional = 10

% $$u[k] = u[k-1] - 694.94 e[k] + 567.00 e[k-1]$$

%%
k_s = pid(C)
C_pid = (k_s.Kp - 300) + (k_s.Ki+300) /s + (k_s.Kd+3)*s/(k_s.Tf * s+1 )

c_dig = c2d(C_pid, Ts, 'tustin')
simu = pid(C_pid)

% últ probado en clase (vídeo): %C_pid = (-316) + (-2100) /s + (0)*s/(k_s.Tf * s+1 ) 