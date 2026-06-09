#ifndef HARDWARE_SERVO_H
#define HARDWARE_SERVO_H

#include <Servo.h>

// --- Configuración Mecánica del Servo ---
#define ORIGEN_U        1520   // Pulso neutro central
#define SERVO_PIN       9
#define SAT_MAX         700    // Límite superior relativo (+700 us)
#define SAT_MIN        -400    // Límite inferior relativo (-400 us)

// Instancia global del servo
Servo myservo;

/**
 * Escribe en el servo la acción de control 'u' aplicando los límites
 * de saturación para proteger el hardware.
 */
void writeProtectedServo(float u) {
    // Aplicar límites de saturación a la acción de control relativa
    if (u > SAT_MAX) u = SAT_MAX;
    if (u < SAT_MIN) u = SAT_MIN; 
    
    // Calcular pulso absoluto final
    int pwm_out = ORIGEN_U + (int)u;
    
    // Enviar señal física al servo
    myservo.writeMicroseconds(pwm_out);
}

#endif