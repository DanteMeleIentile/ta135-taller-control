#ifndef CONFIG_H
#define CONFIG_H

#define T_LOOP_US       20000
#define US_2_SEG        1000000.0
#define FREC_ENVIO      1

#define GYRO_X_OFFSET   +3.04
#define ALPHA           0.1
#define ORIGEN_D        15.0 

/* --- Sensor de distancia --- */
const int TRIGGER_PIN  = 6;
const int ECHO_PIN     = 7;
const int MAX_DISTANCE = 450;
const int MIN_DISTANCE = 30;

/* --- Condiciones Iniciales --- */
#define INITIAL_ANGLE   0 
#define INITIAL_W       0 
#define INITIAL_D       -12.0 
#define INITIAL_V       0 

#endif