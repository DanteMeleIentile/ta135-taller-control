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

#define ENVIO_PULSE     50
#define OFFSET_SERVO    300

/* --- Vars Controlador --- */


/* --- Vars Observador --- */
const float Ad[2][2] = {
  {0.9246,    0.0128},
  {-6.4529,    0.3507}
};

const float Bd[2] = {0.0031, 0.2667};  

const float L1 = 0.22992;
const float L2 = -4.1872; 

float x1_hat = 0.0; 
float x2_hat = 0.0; 


/* --- */
unsigned long t_anterior = 0;
uint32_t count_tx        = 0;
float angle_fc = INITIAL_ANGLE;

Servo myservo; 
uint32_t count_pulse    = 0;
uint32_t estado_pulse   = 0;
float pulse             = 0;

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

  x1_hat = INITIAL_ANGLE;
  
  delay(100);
}

void loop() {
  unsigned long t_actual = micros();
  
  if ((t_actual - t_anterior) >= (T_LOOP_US)) {    
    float dt = (t_actual - t_anterior) / US_2_SEG;
    t_anterior = t_actual;
    count_tx++;
    count_pulse++;
    
    /*** DATOS IMU ***/
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);
        
    float angle_acc_x   = atan2(a.acceleration.y, a.acceleration.z) * 180 / PI;
    float gx_deg        = g.gyro.x * 180.0 / PI + GYRO_X_OFFSET;    
    float angle_gyro_x  = angle_fc + gx_deg * dt; 
    angle_fc            = ALPHA * angle_acc_x + (1-ALPHA) * angle_gyro_x;


    if (count_pulse >= ENVIO_PULSE) {
      count_pulse = 0;
      if (estado_pulse == 0) {
        pulse = +OFFSET_SERVO;
        myservo.writeMicroseconds(NEUTRO + pulse); //Anti-Horario
        estado_pulse = 1;       
      } 
      else if (estado_pulse == 1) {
        pulse = -OFFSET_SERVO;
        myservo.writeMicroseconds(NEUTRO + pulse); //Horario
        estado_pulse = 0;
      }
    }

    
    float error_est = angle_fc - x1_hat;
    float x1_hat_k_1 = (Ad[0][0] * x1_hat) + (Ad[0][1] * x2_hat) + (L1 * error_est) + (Bd[0] * pulse);
    float x2_hat_k_1 = (Ad[1][0] * x1_hat) + (Ad[1][1] * x2_hat) + (L2 * error_est) + (Bd[1] * pulse);
    
    x1_hat = x1_hat_k_1;
    x2_hat = x2_hat_k_1;
    
    
    

    

    /*** ENVÍO SIMULINK ***/
    
    if (count_tx == FREC_ENVIO) {
      count_tx = 0;
      float to_send[] = {angle_fc, x1_hat, gx_deg, x2_hat};
      matlab_send(to_send, 4);    
    }
  }
}


void matlab_send(float* datos, uint32_t cantidad) {
  Serial.write("abcd");
  for (int i = 0; i < cantidad; i++) {
    Serial.write((byte*) &datos[i], 4);
  }
}
