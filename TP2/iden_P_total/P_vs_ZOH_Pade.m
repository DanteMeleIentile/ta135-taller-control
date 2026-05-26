close all;clc

fs = 50;        
Ts = 1/fs;     
s = tf('s');

set(groot, 'DefaultLineLineWidth', 2); 

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

P = +269.89 / (s * (s+17) * (s+18) * (s+3.5)); 

ZOH = ((1 - exp(-Ts*s)) / s) * (1/Ts);

[num, den] = pade(Ts, 1);
ZOH_pade = minreal(((tf(num, den) - 1) / -s) * (1/Ts));

figure('Name', 'Planta Continua');
bode(P, optionss);
grid on; xlim([0.1 200]);
title('Planta Continua P(s)');
figure('Name', 'Planta + ZOH Exacto');
bode(P * ZOH, optionss);
grid on; xlim([0.1 200]);
title('Planta con Retenedor ZOH Exacto');
figure('Name', 'Planta + Padé');
bode(P * ZOH_pade, optionss);
grid on; xlim([0.1 200]);
title('Planta con Aproximación de Padé (Orden 1)');



figure('Name', 'Comparativa Completa (Fase)');
options_comparativa = optionss;
options_comparativa.MagVisible = 'off'; 

bode(P, 'g-', P * ZOH, 'b--', P * ZOH_pade, 'r:', options_comparativa); 
grid on; xlim([0.1 200]); 

ylim([-450, 0]); 

legend('P(s)', 'P(s) + ZOH', 'P(s) + Padé');
title('');

set(groot, 'DefaultLineLineWidth', 'remove');