#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <math.h>
#include <Servo.h>

Adafruit_MPU6050 mpu;

/* Prototipos */
void matlab_send(float* datos, uint32_t cantidad);

/* MACROS */
#define T_LOOP_US       20000
#define US_2_SEG        1000000.0
#define FREC_ENVIO      1
#define GYRO_X_OFFSET   +3.04
#define ALPHA           0.1
#define INITIAL_ANGLE   0 

#define NEUTRO          1520 // +700 y -400
#define K_SERVO_US_DEG  27.78 // Factor de conversión: 500 us / 18 grados

/* --- Vars Controlador --- */
float e_1 = 0.0; // Error en n-1
float e_2 = 0.0; // Error en n-2
float u_1 = 0.0; // Acción de control en n-1
float u_2 = 0.0; // Acción de control en n-2
float setpoint = 0.0; // Ángulo deseado de la barra en grados

/* --- */
unsigned long t_anterior = 0;
uint32_t count_tx        = 0;
float angle_fc = INITIAL_ANGLE;

Servo myservo; 

/* --- */
void setup() {
  Serial.begin(115200);
  myservo.attach(9);
  delay(1000);
  myservo.writeMicroseconds(NEUTRO); 
  
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
  delay(100);
}

void loop() {
  unsigned long t_actual = micros();
  
  if ((t_actual - t_anterior) >= (T_LOOP_US)) {    
    float dt = (t_actual - t_anterior) / US_2_SEG;
    t_anterior = t_actual;
    count_tx++;
    
    /*** DATOS IMU ***/
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);
        
    float angle_acc_x   = atan2(a.acceleration.y, a.acceleration.z) * 180 / PI;
    float gx_deg        = g.gyro.x * 180.0 / PI + GYRO_X_OFFSET;    
    float angle_gyro_x  = angle_fc + gx_deg * dt; 
    angle_fc            = ALPHA * angle_acc_x + (1-ALPHA) * angle_gyro_x;


    
    /*** CONTROLADOR ***/
    float e_0 = setpoint - angle_fc;
    float u_0 = 1.5385 * u_1 - 0.5385 * u_2 + 3.865 * e_0 - 5.2618 * e_1 + 1.7909 * e_2;
    //float u_0 = 1.5385 * u_1 - 0.5385 * u_2 + 0.9983 * e_0 - 1.3592 * e_1 + 0.4626 * e_2;
    
    int pwm_out = NEUTRO + (int)(u_0);
    
    if (pwm_out > NEUTRO + 700) {
      pwm_out = NEUTRO + 700;
      u_0 = (float)(pwm_out - NEUTRO) / K_SERVO_US_DEG; 
    } 
    else if (pwm_out < NEUTRO - 400) {
      pwm_out = NEUTRO - 400;
      u_0 = (float)(pwm_out - NEUTRO) / K_SERVO_US_DEG;
    }
    myservo.writeMicroseconds(pwm_out);
    Serial.println(pwm_out);

    e_2 = e_1;
    e_1 = e_0;
    u_2 = u_1;
    u_1 = u_0;

    /*** ENVÍO SIMULINK ***/
    /*
    if (count_tx == FREC_ENVIO) {
      count_tx = 0;
      float to_send[] = {angle_fc, angle_acc_x, gx_deg, u_0};
      matlab_send(to_send, 4);    
    }
    */
  }
}


void matlab_send(float* datos, uint32_t cantidad) {
  Serial.write("abcd");
  for (int i = 0; i < cantidad; i++) {
    Serial.write((byte*) &datos[i], 4);
  }
}
