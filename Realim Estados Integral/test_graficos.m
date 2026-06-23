%% --------------------------------------------------------
% -------- EXTRACCIÓN DE VENTANAS Y PROMEDIO (16s) --------
% ---------------------------------------------------------
% Al principio de tu nuevo script
clear all; close all; clc;
load('datos_10_465_46_125.mat'); 
Ts = 20e-3; % Asegurate de tener el tiempo de muestreo definido

% 1. Encontrar los inicios de cada ciclo de 16s (flancos de subida de la referencia)
% Asumimos que ref_d hace un salto positivo al iniciar el ciclo.
umbral_salto = 0.05; % Ajustar según la amplitud de tu escalón
flancos = find(diff(ref_d_full) > umbral_salto);

% Filtrar flancos que estén demasiado juntos (por si hay ruido en la señal)
muestras_16s = round(16 / Ts); % Cantidad de muestras en 16 segundos
inicios_validos = [];
ultimo_idx = -muestras_16s;

for i = 1:length(flancos)
    if (flancos(i) - ultimo_idx) > (muestras_16s * 0.8) % Margen de seguridad del 80% del periodo
        inicios_validos(end+1) = flancos(i);
        ultimo_idx = flancos(i);
    end
end

disp(['Se detectaron ', num2str(length(inicios_validos)), ' ciclos/ventanas en total.']);

% 2. Extraer las ventanas a matrices (Filas: Tiempo, Columnas: Ensayo N)
% Preasignar matrices (rellenas de NaN por si alguna ventana queda cortada al final)
num_ensayos = length(inicios_validos);
d_real_matrix = NaN(muestras_16s, num_ensayos);
d_est_matrix = NaN(muestras_16s, num_ensayos);
ref_matrix = NaN(muestras_16s, 1); % La referencia es igual en todos, guardamos una

vector_tiempo_ventana = (0:(muestras_16s-1))' * Ts;

for i = 1:num_ensayos
    idx_start = inicios_validos(i);
    idx_end = idx_start + muestras_16s - 1;

    % Asegurar que no nos pasamos del largo del vector original
    if idx_end <= length(d_real_full)
        d_real_matrix(:, i) = d_real_full(idx_start:idx_end);
        d_est_matrix(:, i)  = d_est_full(idx_start:idx_end);
        if i == 1
            ref_matrix = ref_d_full(idx_start:idx_end); % Guardar la ref de la primera ventana
        end
    end
end

%%
figure('Name', 'Inspección de Ensayos', 'NumberTitle', 'off');

for i = 1:size(d_real_matrix, 2)
    clf; % Limpia la figura para no superponer con el ensayo anterior
    hold on; grid on;
    
    % Graficamos la referencia y SOLO el ensayo actual
    plot(vector_tiempo_ventana, ref_matrix, 'k--', 'LineWidth', 2, 'DisplayName', 'Referencia');
    plot(vector_tiempo_ventana, d_real_matrix(:, i), 'b', 'LineWidth', 1.5, 'DisplayName', ['Ensayo ', num2str(i)]);
    
    title(['Inspección visual - Viendo Ensayo N° ', num2str(i)]);
    xlabel('Tiempo [s]'); ylabel('Posición [m]');
    legend('Location', 'best');
    hold off;
    
    % Avisamos por consola y pausamos el código
    disp(['Mostrando Ensayo ', num2str(i), ' de ', num2str(size(d_real_matrix, 2)), ...
          '. Anotá si sirve, y tocá ENTER para ver el siguiente...']);
    
    pause; % El script se frena acá hasta que toques una tecla
end
disp('¡Listo! Terminaste de revisar todos los ensayos.');
% -------------------------------------------

%%

% 3. SELECCIÓN MANUAL DE ENSAYOS BUENOS
% Acá ponés a mano los índices de las ventanas que salieron bien.
% Por ejemplo, si hiciste 10 ensayos y el 3 y el 7 fallaron:
ensayos_buenos = [1, 2, 4, 5, 6, 10]; % <--- ¡EDITAR ESTO A MANO SEGÚN TUS DATOS!

% Filtramos las matrices dejando solo los ensayos buenos
d_real_filtrada = d_real_matrix(:, ensayos_buenos);
d_est_filtrada  = d_est_matrix(:, ensayos_buenos);

% 4. Calcular el Promedio
d_real_promedio = mean(d_real_filtrada, 2, 'omitnan');
d_est_promedio  = mean(d_est_filtrada, 2, 'omitnan');

% Preparar la señal simulada (asumiendo que empieza en 0 y hace el mismo escalón)
% (Tendrías que recortar t_sim para que coincida con los 16 segs si es más larga)
idx_sim = find(t_sim <= 16);


%% 5. Gráfico Final Consolidado
figure('Name', 'Rendimiento Ball and Beam (Ensayos Validados)', 'NumberTitle', 'off', 'Position', [100 100 900 500]);
hold on; grid on;

% A) Graficar todos los ensayos reales como líneas de fondo (Color suave)
% Usamos un azul claro con un poco de transparencia
for i = 1:size(d_real_filtrada, 2)
    h_todas = plot(vector_tiempo_ventana, d_real_filtrada(:, i), 'Color', [0.5, 0.7, 1, 0.5], 'LineWidth', 0.5);
    % Omitimos estas líneas de la leyenda
    set(get(get(h_todas,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end

% B) Graficar el Promedio Real
h_promedio = plot(vector_tiempo_ventana, d_real_promedio, 'b', 'LineWidth', 2.5);

% C) Graficar la Simulación (Verde raya-punto)
h_sim = plot(t_sim(idx_sim), d_real_sim(idx_sim), 'g-.', 'LineWidth', 2);

% D) Graficar la Referencia Escalonada (Naranja o Negro)
h_ref = plot(vector_tiempo_ventana, ref_matrix, 'k--', 'LineWidth', 1.5);

hold off;

title('Posición (d): Promedio de Ensayos Reales vs Simulación vs Referencia');
xlabel('Tiempo [s]');
ylabel('Posición [m]');
xlim([-1 18]);

% Armar la leyenda solo con las líneas principales
legend([h_ref, h_sim, h_promedio], ...
    'Referencia Comandada', ...
    'Respuesta Simulada (Simulink)', ...
    sprintf('Promedio Real (%d ensayos)', length(ensayos_buenos)), ...
    'Location', 'best');