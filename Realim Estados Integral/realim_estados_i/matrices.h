#ifndef CONTROL_MATRICES_H
#define CONTROL_MATRICES_H

const float Ad[4][4] = {
    {0.9514,    0.0141,         0,         0},
   {-4.3128,    0.4581,         0,         0},
    {0.0041,    0.0000,    1.0000,    0.0193},
    {0.3986,    0.0033,         0,    0.9324},
};

const float Bd[4] = {0.0020,    0.1811,    0.0000,    0.0003};  

/* --- OBSERVADOR --- */
const float L[4][2] = {
	{0.289797,		-0.000019},
	{-4.444508,		0.000284},
	{0.003480,		0.713263},
	{0.392420,		5.204323},
};

/* --- REALIMENTACIÓN DE ESTADOS --- */
#define ANTI_WINDUP_MAX     +1100.0
#define ANTI_WINDUP_MIN     -ANTI_WINDUP_MAX

//const float K[5] = {8.793140, 0.134488, 23.377781, 5.413247, -0.292679};//+12 OK
//const float K[5] = {9.265710, 0.149172, 24.315834, 5.610372, -0.306707}; // -10 OK
//winduo +1450.0

//mejorar
const float K[5] = {12.308343, 0.240620, 31.802033, 6.982385, -0.470912};

#endif
