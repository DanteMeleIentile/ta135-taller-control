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
#define GYRO_X_OFFSET   +3.18
#define ALPHA           0.05
#define INITIAL_ANGLE   0

#define ENVIO_PULSE     100
#define NEUTRO          1500 //0° según IMU
#define OFFSET_SERVO    0 //Valor de inclinación para caracterizar la barra

/* --- */
unsigned long t_anterior = 0;
uint32_t count_tx        = 0;

uint32_t count_pulse     = 0;
uint32_t estado_pulse    = 0;

float angle_fc = INITIAL_ANGLE;

Servo myservo; 

/* --- */
void setup() {
  Serial.begin(115200);
  myservo.attach(9);
  delay(1000);
  myservo.writeMicroseconds(1500); 
  

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
    count_pulse++;
    
    /* ***************** */
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);
       
    float angle_acc_x   = atan2(a.acceleration.y, a.acceleration.z) * 180 / PI;
    
    float gx_deg        = g.gyro.x * 180.0 / PI + GYRO_X_OFFSET;    
    float angle_gyro_x  = angle_fc + gx_deg * dt;         //Con corrección 
    angle_fc            = ALPHA * angle_acc_x + (1-ALPHA) * angle_gyro_x;
    

    /* *********** */
    if (count_tx == FREC_ENVIO) {
      count_tx = 0;
      float to_send[] = {1,1, angle_fc};
      matlab_send(to_send, 3);    
    }

    if (count_pulse >= ENVIO_PULSE) {
      count_pulse = 0;
      
      if (estado_pulse == 0) {
        myservo.writeMicroseconds(NEUTRO + OFFSET_SERVO);
        estado_pulse = 1;
      } 
      else if (estado_pulse == 1) {
        myservo.writeMicroseconds(NEUTRO);
        estado_pulse = 2;
      } 
      else {
        myservo.writeMicroseconds(NEUTRO);
        estado_pulse = 0;
      }
    }
    
  }
}


void matlab_send(float* datos, uint32_t cantidad) {
  Serial.write("abcd");
  for (int i = 0; i < cantidad; i++) {
    Serial.write((byte*) &datos[i], 4);
  }
}
