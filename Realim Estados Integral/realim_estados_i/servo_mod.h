#ifndef HARDWARE_SERVO_H
#define HARDWARE_SERVO_H

#include <Servo.h>

#define ORIGEN_U        1580   
#define SERVO_PIN       9
#define SAT_MAX         400    
#define SAT_MIN        -400    

// Instancia global del servo
Servo myservo;


void actuador(float u) {
    if (u > SAT_MAX) u = SAT_MAX;
    if (u < SAT_MIN) u = SAT_MIN; 
    
    int pwm_out = ORIGEN_U + (int)u;
    
    myservo.writeMicroseconds(pwm_out);
}

#endif
