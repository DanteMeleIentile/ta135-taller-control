#include <NewPing.h>

const int TRIGGER_PIN = 6; // Pin digital para Trigger
const int ECHO_PIN = 7;    // Pin digital para Echo
const int MAX_DISTANCE = 200; // Distancia máxima en cm

// Crear el objeto sonar
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

int count = 0;
int N = 100;
unsigned long delta_total = 0;

void setup() {
  Serial.begin(115200);
}

void loop() {
  unsigned long t_init = micros();

  unsigned long time_ping = sonar.ping(); 
  
  float dist = time_ping / (2.0 *  29.287);

  unsigned long t_final = micros();
  
  delta_total += (t_final - t_init);
  count++;

  if (count == N) {
    float frec = (1000000.0 * N) / delta_total;
    Serial.print("Frecuencia de muestreo (Hz): ");
    Serial.println(frec);
    count = 0;
    delta_total = 0;
  }
  
  Serial.print("Distancia: "); Serial.println(dist);
}