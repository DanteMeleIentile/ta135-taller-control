#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <math.h>

Adafruit_MPU6050 mpu;

/* Prototipos */
void matlab_send(float* datos, uint32_t cantidad);


/* MACROS */
#define T_LOOP_MS 20000
#define FREC_ENVIO 1

/* --- */
unsigned long t_anterior = 0;
uint32_t count = 0;

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
  





  if ((t_actual - t_anterior) >= (T_LOOP_MS)) {    
    t_anterior = t_actual;
    count++;
    /* ***************** */
    
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    /*
    Serial.print("Acceleration X: ");
    Serial.print(a.acceleration.x);
    Serial.print(", Y: ");
    Serial.print(a.acceleration.y);
    Serial.print(", Z: ");
    Serial.print(a.acceleration.z);
    Serial.println(" m/s^2");
  
    Serial.print("Rotation X: ");
    Serial.print(g.gyro.x);
    Serial.print(", Y: ");
    Serial.print(g.gyro.y);
    Serial.print(", Z: ");
    Serial.print(g.gyro.z);
    Serial.println(" rad/s");
    Serial.println("");
    */
  /* *********** */
    if (count == FREC_ENVIO) {
      count = 0;

      float angle = atan2(a.acceleration.y, a.acceleration.z) * 180 / PI;
      float to_send[] = {angle};
      matlab_send(to_send, 1);
    
    }  
  }
}


void matlab_send(float* datos, uint32_t cantidad) {
  Serial.write("abcd");
  for (int i = 0; i < cantidad; i++) {
    Serial.write((byte*) &datos[i], 4);
  }
}
