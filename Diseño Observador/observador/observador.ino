#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <math.h>
#include <NewPing.h>

#include "config.h"
#include "matrices.h"
#include "servo_mod.h"

Adafruit_MPU6050 mpu;

/* Prototipos */
void matlab_send(float* datos, uint32_t cantidad);

/* MACROS */
#define ENVIO_PULSE     50 * 0.5

/* --- Vars Controlador --- */


/* --- Vars estado --- */
float x1_hat = INITIAL_ANGLE; 
float x2_hat = INITIAL_W; 
float x3_hat = INITIAL_D; 
float x4_hat = INITIAL_V; 



/* --- */
unsigned long t_anterior = 0;
uint32_t count_tx        = 0;
float angle_fc = INITIAL_ANGLE;


/* --- Vars SR04 --- */
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);


/* --- Vars. Servo --- */ 
uint32_t count_pulse    = 0;
uint32_t estado_pulse   = 0;
float u                 = 0;




/* --- */
void setup() {
  Serial.begin(115200);
  myservo.attach(9);
  delay(1000);
  myservo.writeMicroseconds(ORIGEN_U); 
  
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_44_HZ);

  delay(5000);
}

void loop() {
  unsigned long t_actual = micros();
  
  if ((t_actual - t_anterior) >= (T_LOOP_US)) {    
    float dt = (t_actual - t_anterior) / US_2_SEG;
    t_anterior = t_actual;
    count_tx++;
    count_pulse++;
    
    
    /* --- DATOS IMU --- */
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);
        
    float angle_acc_x   = atan2(a.acceleration.y, a.acceleration.z) * 180 / PI;
    float gx_deg        = g.gyro.x * 180.0 / PI + GYRO_X_OFFSET;    
    float angle_gyro_x  = angle_fc + gx_deg * dt; 
    angle_fc            = ALPHA * angle_acc_x + (1-ALPHA) * angle_gyro_x;


    /* --- DATOS SR04 --- */
    unsigned long time_ping = sonar.ping(); 
    float dist = time_ping / (2.0 * 29.287) - ORIGEN_D;
    
    
    if (count_pulse >= ENVIO_PULSE) {
      count_pulse = 0;
      if (estado_pulse == 0) {
        u = +200;
        actuador(u); //Anti-Horario
        estado_pulse = 1;       
      } 
      else if (estado_pulse == 1) {
        u = -230;
        actuador(u); //Horario
        estado_pulse = 0;
      }
    }

       
    /* --- IMPLEMENTACIÓN OBSERVADOR --- */
    float error_angle = angle_fc - x1_hat;
    float error_dist  = dist     - x3_hat;
    
    float x1_hat_k_1 = (Ad[0][0] * x1_hat) + (Ad[0][1] * x2_hat) + (Ad[0][2] * x3_hat) + (Ad[0][3] * x4_hat)
                      + (L[0][0] * error_angle) + (L[0][1] * error_dist)
                      + (Bd[0] * u);
                      
    float x2_hat_k_1 = (Ad[1][0] * x1_hat) + (Ad[1][1] * x2_hat) + (Ad[1][2] * x3_hat) + (Ad[1][3] * x4_hat)
                      + (L[1][0] * error_angle) + (L[1][1] * error_dist)
                      + (Bd[1] * u);

    float x3_hat_k_1 = (Ad[2][0] * x1_hat) + (Ad[2][1] * x2_hat) + (Ad[2][2] * x3_hat) + (Ad[2][3] * x4_hat)
                      + (L[2][0] * error_angle) + (L[2][1] * error_dist)
                      + (Bd[2] * u);

    float x4_hat_k_1 = (Ad[3][0] * x1_hat) + (Ad[3][1] * x2_hat) + (Ad[3][2] * x3_hat) + (Ad[3][3] * x4_hat)
                      + (L[3][0] * error_angle) + (L[3][1] * error_dist)
                      + (Bd[3] * u);


    
    x1_hat = x1_hat_k_1;
    x2_hat = x2_hat_k_1;
    x3_hat = x3_hat_k_1;
    x4_hat = x4_hat_k_1;


    /*** IMPLEMENTACIÓN CONTROLADOR ***/
    //float u = 1;
    
    /*** ACTUALIZACIÓN CONTROLADOR ***/
    /*
     *  
     */
    
      

    /*** ENVÍO SIMULINK ***/
    if (count_tx == FREC_ENVIO) {
      count_tx = 0;
      float to_send[] = {angle_fc, x1_hat, gx_deg, x2_hat, dist, x3_hat, x4_hat, u};
      matlab_send(to_send, 8);    
    }
    
  }
}


void matlab_send(float* datos, uint32_t cantidad) {
  Serial.write("abcd");
  for (int i = 0; i < cantidad; i++) {
    Serial.write((byte*) &datos[i], 4);
  }
}
