#include <NewPing.h>

const int TRIGGER_PIN = 6;
const int ECHO_PIN = 7;
const int MAX_DISTANCE = 200;

NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

int count = 0;
int N = 50;
unsigned long delta_total = 0;
float suma_distancias = 0;

void setup() {
  Serial.begin(115200);
  Serial.println("-----------------");
}


void loop() {
  unsigned long t_init = micros();
  
  unsigned long time_ping = sonar.ping(); 
  

  unsigned long t_final = micros();
  
  delta_total += (t_final - t_init);
  count++;
  
  /*
  float dist = time_ping / (2.0 * 29.287);
  suma_distancias += dist;
  //Serial.println(dist);
  */
  
  if (count == N) {
    float tiempo_promedio = (float)delta_total / N;
    count = 0;
    delta_total = 0;

    /*
    float dist_promedio = suma_distancias / N;
    suma_distancias = 0;
    Serial.print("Dist: ");
    Serial.println(dist_promedio);
    */
    
    Serial.print("Tiempo: ");
    Serial.println(tiempo_promedio);

   
  }

  delay(30); 
}
