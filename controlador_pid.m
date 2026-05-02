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
    
    % x0 = [pocisiconincial; velocidad_incial]
    x2_0 = 0;
    x1_0 = 5 * pi / (180);
    x0 = [x1_0; x2_0];
    %initial(sys_fisc, x0);
    
    
    
    % ----- DISEÑO CONTROLADOR ----- %
    kc = -1 * db2mag(55);
    C = zpk([-12, -15],[0, -80],kc)
    pid(C)
    
    L = minreal(C*P);
    
  
    % ----- GRAFICOS ----- %
    figure();
    bode(P,optionss);title("P")
    
    figure();
    bode(C,optionss);title("C")
    
    figure();
    bode(L,optionss);title("L")
    
    %%
    % ----- CONTROL DIGITAL ----- %
    c_dig = c2d(C, Ts, 'tustin')
    
    pid = Kp + Ki * 1/s + Kd * s;

%0.004 * ki
% con esta configuracion el controlador satura 
% acciones de control
% derivatvo = 25 , integrak = 5, proporcional = 10

% $$u[k] = u[k-1] - 694.94 e[k] + 567.00 e[k-1]$$