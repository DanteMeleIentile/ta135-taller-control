%% --------------------------------------------------------
% CÓDIGO PARA GENERAR GRÁFICOS PROMEDIO DE LOS EXP. (GEMINI)
% ---------------------------------------------------------
clear all; close all; clc;
load('datos_10_465_46_125.mat'); 
Ts = 20e-3; 

% Configuraciones de tiempo de la ventana
t_half_cycle = 8; % 8 segundos abajo, 8 segundos arriba
t_pad = 1;        % 1 segundo de padding a cada lado
muestras_half = round(t_half_cycle / Ts);
muestras_pad  = round(t_pad / Ts);
muestras_totales = 2 * muestras_half + 2 * muestras_pad;

% 1. Encontrar los flancos de subida (salto de 0 a Ref)
umbral_salto = 0.05; 
flancos = find(diff(ref_d_full) > umbral_salto);

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
d_est_matrix  = NaN(muestras_totales, num_ensayos);
ref_matrix    = NaN(muestras_totales, 1);

% Vector de tiempo centrado para que el salto sea exactamente en t = 8s
vector_tiempo_ventana = (-t_pad : Ts : (2*t_half_cycle + t_pad - Ts))';

for i = 1:num_ensayos
    idx_flanco = inicios_validos(i);
    % Nos movemos 9s para atrás y 9s para adelante del salto
    idx_start = idx_flanco - muestras_half - muestras_pad;
    idx_end   = idx_flanco + muestras_half + muestras_pad - 1;
    
    % Verificamos que no nos salgamos de los límites del vector real
    if idx_start > 0 && idx_end <= length(d_real_full)
        d_real_matrix(:, i) = d_real_full(idx_start:idx_end);
        d_est_matrix(:, i)  = d_est_full(idx_start:idx_end);
        
        % GUARDAMOS LA REFERENCIA SOLO SI AÚN NO LO HICIMOS (Evita el bug del NaN)
        if isnan(ref_matrix(1))
            ref_matrix = ref_d_full(idx_start:idx_end); 
        end
    else
        disp(['Ensayo ', num2str(i), ' descartado automáticamente (cortado por límites de tiempo).']);
    end
end

% Calcular valores para las bandas de tolerancia (5% de la amplitud)
% Usamos 'omitnan' por seguridad
ref_max = max(ref_matrix, [], 'omitnan');
if isnan(ref_max)
    disp('¡ADVERTENCIA! No se pudo extraer la referencia. Revisá los datos crudos.');
    ref_max = 0; % Evita que se rompa el plot si pasa algo raro
end

b0_sup = 0.05 * ref_max;
b0_inf = -0.05 * ref_max;
b1_sup = ref_max * 1.05;
b1_inf = ref_max * 0.95;

%% ---------------- INSPECCIÓN VISUAL ----------------
figure('Name', 'Inspección de Ensayos', 'NumberTitle', 'off', 'Position', [100 100 900 500]);
for i = 1:size(d_real_matrix, 2)
    % Si la columna es toda NaN (se descartó), la saltamos
    if all(isnan(d_real_matrix(:, i)))
        continue; 
    end
    
    clf; 
    hold on; grid on;
    
    % Bandas de tolerancia (Rojo punteado) - Se dividen antes y después de t=8
    plot([-1 8], [b0_sup b0_sup], 'r:', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    plot([-1 8], [b0_inf b0_inf], 'r:', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    plot([8 17], [b1_sup b1_sup], 'r:', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    plot([8 17], [b1_inf b1_inf], 'r:', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    
    % Líneas de tiempo de establecimiento (Magenta)
    xline(2.5, 'm--', 'ts = 2.5s', 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
    xline(10.5, 'm--', 'ts = 10.5s', 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off'); % 8s + 2.5s
    
    % Señales
    plot(vector_tiempo_ventana, ref_matrix, 'k--', 'LineWidth', 2, 'DisplayName', 'Referencia');
    plot(vector_tiempo_ventana, d_real_matrix(:, i), 'b', 'LineWidth', 1.5, 'DisplayName', ['Ensayo ', num2str(i)]);
    
    title(['Inspección visual - Viendo Ensayo N° ', num2str(i)]);
    xlabel('Tiempo [s]'); ylabel('Posición [m]');
    xlim([-1 17]);
    legend('Location', 'best');
    hold off;
    
    disp(['Mostrando Ensayo ', num2str(i), ' de ', num2str(size(d_real_matrix, 2)), ...
          '. Anotá si sirve, y tocá ENTER para ver el siguiente...']);
    pause; 
end
disp('¡Listo! Terminaste de revisar todos los ensayos.');

%% ---------------- SELECCIÓN Y PROMEDIO ----------------
% <--- ¡EDITAR ESTO según lo que anotaste en la inspección visual!
ensayos_buenos = [1, 2, 4, 5, 6, 10]; 

% Filtramos asegurándonos de que no pongamos índices que quedaron vacíos
ensayos_buenos = ensayos_buenos(ensayos_buenos <= size(d_real_matrix, 2));

d_real_filtrada = d_real_matrix(:, ensayos_buenos);
d_est_filtrada  = d_est_matrix(:, ensayos_buenos);

d_real_promedio = mean(d_real_filtrada, 2, 'omitnan');
d_est_promedio  = mean(d_est_filtrada, 2, 'omitnan');



% --- AJUSTE VISUAL DE LA SIMULACIÓN ---
offset_tiempo_sim = 0.0; % Mueve la simulación a la derecha (+) o izquierda (-) en el eje X
offset_amp_sim    = 0.0; % Mueve la simulación hacia arriba (+) o abajo (-) en el eje Y

% Aplicamos el offset de tiempo para recortar correctamente los índices a graficar
t_sim_ajustado = t_sim + offset_tiempo_sim;
idx_sim = find(t_sim_ajustado >= -1 & t_sim_ajustado <= 17);

figure('Name', 'Rendimiento Ball and Beam (Validados)', 'NumberTitle', 'off', 'Position', [150 150 1000 600]);
hold on; grid on;

% Bandas de tolerancia (Fondo)
plot([-1 8], [b0_sup b0_sup], 'r:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot([-1 8], [b0_inf b0_inf], 'r:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot([8 17], [b1_sup b1_sup], 'r:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot([8 17], [b1_inf b1_inf], 'r:', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Tiempos de establecimiento (Fondo)
xline(2.5, 'm--', 'ts = 2.5s', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
xline(10.5, 'm--', 'ts = 10.5s', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');

% A) Todos los ensayos reales (Celeste transparente)
for i = 1:size(d_real_filtrada, 2)
    h_todas = plot(vector_tiempo_ventana, d_real_filtrada(:, i), 'Color', [0.5, 0.7, 1, 0.5], 'LineWidth', 0.5);
    set(get(get(h_todas,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end

% B) Simulación con los offsets aplicados visualmente (Verde raya-punto)
h_sim = plot(t_sim_ajustado(idx_sim), d_real_sim(idx_sim) + offset_amp_sim, 'g-.', 'LineWidth', 2);

% C) Promedio Real (Azul fuerte)
h_promedio = plot(vector_tiempo_ventana, d_real_promedio, 'b', 'LineWidth', 2.5);

% D) Referencia (Negro)
h_ref = plot(vector_tiempo_ventana, ref_matrix, 'k--', 'LineWidth', 1.5);

hold off;
title('Posición (d): Promedio de Ensayos Reales vs Simulación vs Referencia');
xlabel('Tiempo [s]');
ylabel('Posición [m]');
xlim([-1 17]);

legend([h_ref, h_sim, h_promedio], ...
    'Referencia Comandada', ...
    'Respuesta Simulada (Simulink)', ...
    sprintf('Promedio Real (%d ensayos)', length(ensayos_buenos)), ...
    'Location', 'best');