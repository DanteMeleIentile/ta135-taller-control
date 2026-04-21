u = double(out.d2);
y = double(out.d1);
t = double(out.tout);

%save('datos_sin_carrito.mat', 'u', 'y', 't'); %para volcar los datos en un
%archivo
%Para recuperar: load('datos_sin_carrito.mat');

figure;
plot(t, u); hold on;
plot(t, y);

grid on;
xlabel('t');
legend('u', 'y');

Ts = t(2) - t(1);

data = iddata(y, u, Ts);

sys_d = arx(data, [2 2 1]); 
% arx(datos, [a, b,c])
% a = cantidad de polos
% b = retrados de la u
% c = cantidad de retardos de ntrada considerar

polos_d = pole(sys_d);

sys_d; %Para ver MSE y otros datos descomentar

figure;
compare(data, sys_d)

polos_c = log(polos_d) / Ts;

k = dcgain(sys_d) * polos_c(1) * polos_c(2);

sys_c = zpk([], polos_c, k);

figure;
step(sys_c); hold on;
step(sys_d);

%