#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <math.h>

Adafruit_MPU6050 mpu;

/* Prototipos */
void matlab_send(float* datos, uint32_t cantidad);


/* MACROS */
#define T_LOOP_US   20000
#define US_2_SEG    1000000.0
#define FREC_ENVIO  1

/* --- */
unsigned long t_anterior = 0;
uint32_t count = 0;
float angle_gyro_x = 0.0; 


void setup() {
  Serial.begin(115200);

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
    count++;
    
    /* ***************** */
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);


    float gx_deg        = g.gyro.x * 180.0 / PI + 2;
    angle_gyro_x        = angle_gyro_x + gx_deg * dt;
        
    float angle_acc_x   = atan2(a.acceleration.y, a.acceleration.z) * 180 / PI;

    
    

    /* *********** */
    if (count == FREC_ENVIO) {
      count = 0;
      float to_send[] = {angle_acc_x, angle_gyro_x};
      matlab_send(to_send, 2);    
    }  
    
  }
}


void matlab_send(float* datos, uint32_t cantidad) {
  Serial.write("abcd");
  for (int i = 0; i < cantidad; i++) {
    Serial.write((byte*) &datos[i], 4);
  }
}
