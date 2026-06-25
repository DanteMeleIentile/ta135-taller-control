%% --------------------------------------------------------
% GRAFICADOR MULTIPLES RESULTADOS (UNIVERSAL: SALTOS + Y -)
% ---------------------------------------------------------
clear all; close all; clc;
% Cargar los datos. Asegurate de que existan las variables de los 4 estados.
load('datos_20_465_46_125_A.mat'); 
Ts = 20e-3; 

% Configuraciones de tiempo de la ventana
t_half_cycle = 8;   % 8 segundos abajo, 8 segundos arriba
t_pad = 0.5;        % padding a cada lado
muestras_half = round(t_half_cycle / Ts);
muestras_pad  = round(t_pad / Ts);
muestras_totales = 2 * muestras_half + 2 * muestras_pad;

% 1. Encontrar los flancos (saltos hacia arriba o hacia abajo)
umbral_salto = 0.5; % Umbral subido a 0.5 para aislar saltos francos
flancos = find(abs(diff(ref_d_full)) > umbral_salto);

% Filtrar flancos (asegurar que haya al menos 16s entre ellos)
inicios_validos = [];
ultimo_idx = -muestras_totales;
for i = 1:length(flancos)
    if (flancos(i) - ultimo_idx) > (2 * muestras_half * 0.8) 
        inicios_validos(end+1) = flancos(i);
        ultimo_idx = flancos(i);
    end
end
disp(['Se detectaron ', num2str(length(inicios_validos)), ' saltos a la referencia.']);

% 2. Extraer ventanas (Desde -1s hasta 17s)
num_ensayos = length(inicios_validos);
d_real_matrix = NaN(muestras_totales, num_ensayos);
ang_matrix    = NaN(muestras_totales, num_ensayos); % Matriz Angulo
w_matrix      = NaN(muestras_totales, num_ensayos); % Matriz Vel Angular
v_matrix      = NaN(muestras_totales, num_ensayos); % Matriz Vel Carro
ref_matrix    = NaN(muestras_totales, 1);

% Vector de tiempo centrado
vector_tiempo_ventana = (-t_pad : Ts : (2*t_half_cycle + t_pad - Ts))';
for i = 1:num_ensayos
    idx_flanco = inicios_validos(i);
    idx_start = idx_flanco - muestras_half - muestras_pad;
    idx_end   = idx_flanco + muestras_half + muestras_pad - 1;
    
    if idx_start > 0 && idx_end <= length(d_real_full)
        d_real_matrix(:, i) = d_real_full(idx_start:idx_end);
        
        ang_matrix(:, i)    = angle_real_full(idx_start:idx_end); 
        w_matrix(:, i)      = w_real_full(idx_start:idx_end);     
        v_matrix(:, i)      = vel_est_full(idx_start:idx_end);    
        
        if isnan(ref_matrix(1))
            ref_matrix = ref_d_full(idx_start:idx_end); 
        end
    else
        disp(['Ensayo ', num2str(i), ' descartado automáticamente.']);
    end
end

% --- CÁLCULO UNIVERSAL DE LAS BANDAS DE TOLERANCIA ---
ref_inicial = ref_matrix(1);        % Dónde estaba antes del salto
ref_final   = ref_matrix(end);      % A dónde fue
amplitud    = abs(ref_final - ref_inicial); % Tamaño real del salto

if isnan(amplitud) || amplitud == 0
    disp('Advertencia: No se pudo medir la amplitud. Forzando a 10.');
    amplitud = 10; 
end

tolerancia = 0.05 * amplitud; % 5% del viaje

b0_sup = ref_inicial + tolerancia;
b0_inf = ref_inicial - tolerancia;
b1_sup = ref_final + tolerancia;
b1_inf = ref_final - tolerancia;

%% ---------------- INSPECCIÓN VISUAL (SOLO DISTANCIA) ----------------
figure('Name', 'Inspección de Ensayos', 'NumberTitle', 'off', 'Position', [100 100 900 500]);
for i = 1:size(d_real_matrix, 2)
    if all(isnan(d_real_matrix(:, i))), continue; end
    clf; hold on; grid on;
    
    plot([-1 17], [b0_sup b0_sup], 'r:', 'LineWidth', 1.2);
    plot([-1 17], [b0_inf b0_inf], 'r:', 'LineWidth', 1.2);
    plot([-1 17], [b1_sup b1_sup], 'r:', 'LineWidth', 1.2);
    plot([-1 17], [b1_inf b1_inf], 'r:', 'LineWidth', 1.2);
    xline(2.5, 'm--'); xline(10.5, 'm--'); 
    
    plot(vector_tiempo_ventana, ref_matrix, 'k--', 'LineWidth', 2);
    plot(vector_tiempo_ventana, d_real_matrix(:, i), 'b', 'LineWidth', 1.5);
    
    title(['Inspección visual - Viendo Ensayo N° ', num2str(i)]);
    xlabel('Tiempo [s]'); ylabel('Posición [m]'); xlim([-1 17]); hold off;
    
    disp(['Mostrando Ensayo ', num2str(i), '. Anotá si sirve, y tocá ENTER para ver el siguiente...']);
    pause; 
end

%% ---------------- SELECCIÓN Y PROMEDIO GENERAL ----------------
% <--- ¡EDITAR ESTO según lo que anotaste en la inspección visual!
%ensayos_buenos = [2, 4,5, 9, 10]; %-10 A
%ensayos_buenos = [3, 4, 5, 6, 7, 8 ,9]; % -10 B
%ensayos_buenos = [2, 4, 6, 7, 8,9,15, 16 ,17,19,21,22,23,24]; % 20 B
ensayos_buenos = [4, 6, 7, 8, 9 ,10,18,20,22,24,27,31]; % 20 temp
ensayos_buenos = ensayos_buenos(ensayos_buenos <= size(d_real_matrix, 2));

% Promedios
d_real_promedio = mean(d_real_matrix(:, ensayos_buenos), 2, 'omitnan');
ang_promedio    = mean(ang_matrix(:, ensayos_buenos), 2, 'omitnan');
w_promedio      = mean(w_matrix(:, ensayos_buenos), 2, 'omitnan');
v_promedio      = mean(v_matrix(:, ensayos_buenos), 2, 'omitnan');

% Ajuste simulación
offset_tiempo_sim = -16.0; 
offset_amp_sim    = 0.0; 
t_sim_ajustado = t_sim + offset_tiempo_sim;
idx_sim = find(t_sim_ajustado >= -1 & t_sim_ajustado <= 17);

%% ---------------- GRÁFICOS FINALES (4 FIGURAS) ----------------
% FIGURA 1: DISTANCIA (d)
figure('Name', 'Estado x3: Distancia', 'Position', [50 300 800 400]);
hold on; grid on;
plot([-1 17], [b0_sup b0_sup], 'k:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot([-1 17], [b0_inf b0_inf], 'k:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot([-1 17], [b1_sup b1_sup], 'k:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot([-1 17], [b1_inf b1_inf], 'k:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
xline(2.5, 'm--', 'ts = 2.5s', 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
xline(10.5, 'm--', 'ts = 10.5s', 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');

is_first = true;
for i = ensayos_buenos
    if is_first
        plot(vector_tiempo_ventana, d_real_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5, 'DisplayName', 'Mediciones');
        is_first = false;
    else
        h_todas = plot(vector_tiempo_ventana, d_real_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5);
        set(get(get(h_todas,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end
if exist('d_real_sim', 'var')
    plot(t_sim_ajustado(idx_sim), d_real_sim(idx_sim) + offset_amp_sim, 'g-.', 'LineWidth', 2, 'DisplayName', 'Simulación');
end
plot(vector_tiempo_ventana, ref_matrix, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Ref');
plot(vector_tiempo_ventana, d_real_promedio, 'r', 'LineWidth', 2.5, 'DisplayName', 'Prom. Mediciones');
hold off; xlabel('Tiempo [s]'); ylabel('d(t) [cm]'); xlim([-1 17]); legend('Location', 'best');

%%
% FIGURA 2: ÁNGULO (theta)
figure('Name', 'Estado x1: Ángulo', 'Position', [100 250 800 400]);
hold on; grid on;
is_first = true;
for i = ensayos_buenos
    if is_first
        plot(vector_tiempo_ventana, ang_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5, 'DisplayName', 'Mediciones');
        is_first = false;
    else
        h_todas = plot(vector_tiempo_ventana, ang_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5);
        set(get(get(h_todas,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end
if exist('angle_real_sim', 'var')
    plot(t_sim_ajustado(idx_sim), angle_real_sim(idx_sim), 'g-.', 'LineWidth', 2, 'DisplayName', 'Simulación');
end
plot(vector_tiempo_ventana, ang_promedio, 'r', 'LineWidth', 2.5, 'DisplayName', 'Prom. Mediciones');
hold off; xlabel('Tiempo [s]'); ylabel('$\theta(t) \ [^\circ]$', 'Interpreter', 'latex'); xlim([6 12]); legend('Location', 'best');

%%
% FIGURA 3: VELOCIDAD DEL CARRO (v)
figure('Name', 'Estado 4: Velocidad del Carro', 'Position', [150 200 800 400]);
hold on; grid on;
is_first = true;
for i = ensayos_buenos
    if is_first
        plot(vector_tiempo_ventana, v_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5, 'DisplayName', 'Mediciones');
        is_first = false;
    else
        h_todas = plot(vector_tiempo_ventana, v_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5);
        set(get(get(h_todas,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end
if exist('vel_est_sim', 'var')
    plot(t_sim_ajustado(idx_sim), vel_est_sim(idx_sim), 'g-.', 'LineWidth', 2, 'DisplayName', 'Simulación');
end
plot(vector_tiempo_ventana, v_promedio, 'r', 'LineWidth', 2.5, 'DisplayName', 'Prom. Mediciones');
hold off; xlabel('Tiempo [s]'); ylabel('$\dot{d}(t)$ [cm/s]', 'Interpreter', 'latex'); xlim([4 14]); legend('Location', 'best');


% FIGURA 4: VELOCIDAD ANGULAR (w)
figure('Name', 'Estado x2: Velocidad Angular', 'Position', [200 150 800 400]);
hold on; grid on;
is_first = true;
for i = ensayos_buenos
    if is_first
        plot(vector_tiempo_ventana, w_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5, 'DisplayName', 'Mediciones');
        is_first = false;
    else
        h_todas = plot(vector_tiempo_ventana, w_matrix(:, i), 'Color', [0.5, 0.7, 1, 0.9], 'LineWidth', 0.5);
        set(get(get(h_todas,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end
if exist('w_est_sim', 'var')
    plot(t_sim_ajustado(idx_sim), w_est_sim(idx_sim), 'g-.', 'LineWidth', 2, 'DisplayName', 'Simulación');
end
plot(vector_tiempo_ventana, w_promedio, 'r', 'LineWidth', 2.5, 'DisplayName', 'Prom. Mediciones');
hold off; xlabel('Tiempo [s]'); ylabel('w(t) [°/s]'); xlim([6 12]); legend('Location', 'best');