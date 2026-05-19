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

#define ENVIO_PULSE     50 * 3
#define OFFSET_SERVO    100

/* --- Vars Controlador --- */


/* --- Vars Observador --- */
const float Ad[3][3] = {
  {0.9514,    0.0141,      0},
  {-4.3128,   0.4581,      0},
  {0,         0,         1.0},
};


const float Bd[3] = {0.0020, 0.1811, 0};  

const float L[3][2] = {
  {0.4054,  0.0372},
  {-4.289,  0.0029},
  {0.0373,  0.0051},
};

float x1_hat = 0.0; 
float x2_hat = 0.0; 
float x3_hat = 0.0; 


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
    //Sesgo introducido
    gx_deg = gx_deg + 20;

    
    
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
    
    float error_angle = angle_fc - x1_hat;
    float error_w     = gx_deg   - (x2_hat + x3_hat);
    
    
    float x1_hat_k_1 = (Ad[0][0] * x1_hat) + (Ad[0][1] * x2_hat) + (Ad[0][2] * x3_hat)
                      + (L[0][0] * error_angle) + (L[0][1] * error_w)
                      + (Bd[0] * pulse);

    float x2_hat_k_1 = (Ad[1][0] * x1_hat) + (Ad[1][1] * x2_hat) + (Ad[1][2] * x3_hat)
                  + (L[1][0] * error_angle) + (L[1][1] * error_w)
                  + (Bd[1] * pulse);

    float x3_hat_k_1 = (Ad[2][0] * x1_hat) + (Ad[2][1] * x2_hat) + (Ad[2][2] * x3_hat)
                      + (L[2][0] * error_angle) + (L[2][1] * error_w)
                      + (Bd[2] * pulse);
    
    x1_hat = x1_hat_k_1;
    x2_hat = x2_hat_k_1;
    x3_hat = x3_hat_k_1;
    
      

    /*** ENVÍO SIMULINK ***/
    if (count_tx == FREC_ENVIO) {
      count_tx = 0;
      float to_send[] = {angle_fc, x1_hat, gx_deg, x2_hat, 0, x3_hat};
      matlab_send(to_send, 6);    
    }
  }
}


void matlab_send(float* datos, uint32_t cantidad) {
  Serial.write("abcd");
  for (int i = 0; i < cantidad; i++) {
    Serial.write((byte*) &datos[i], 4);
  }
}
