#ifndef CONTROL_MATRICES_H
#define CONTROL_MATRICES_H

// --- Matrices del Observador Discreto ---
const float Ad[4][4] = {
    {0.9514,    0.0141,         0,         0},
   {-4.3128,    0.4581,         0,         0},
    {0.0041,    0.0000,    1.0000,    0.0193},
    {0.3986,    0.0033,         0,    0.9324},
};

const float Bd[4] = {0.0020,    0.1811,    0.0000,    0.0003};  

const float L[4][2] = {
  {0.463532,    -0.000019},
  {-4.336666,   0.000052},
  {0.003480,    0.886998},
  {0.387015,    8.654391},
};

// --- Ganancias del Controlador (Para agregar las tuyas) ---
const float K1 = -10.5; // Valores de ejemplo, cambialos por los tuyos
const float K2 = -2.1;
const float F  = 1.0;

#endif