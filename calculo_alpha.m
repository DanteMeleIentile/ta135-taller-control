% --- Identificación por Cuadrados Mínimos ---

% Vector de observaciones (desde el segundo dato hasta el final)
Y_obs = y(2:end); 

% Matriz de regresores X [y_n, u_n]
X_reg = [y(1:end-1), u(1:end-1)]; 

% Cálculo de parámetros alpha usando la ecuación normal
% El operador '\' en MATLAB resuelve (X'*X)\X'*Y de forma eficiente
alpha = X_reg \ Y_obs;

% Asignación de coeficientes identificados
cy_identificado = alpha(1);
cu_identificado = alpha(2);

% Visualización de resultados
fprintf('Coeficiente cy (salida anterior): %.4f\n', cy_identificado);
fprintf('Coeficiente cu (entrada anterior): %.4f\n', cu_identificado);