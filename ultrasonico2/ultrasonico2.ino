#include <NewPing.h>

const int TRIGGER_PIN = 6; // Pin digital para Trigger
const int ECHO_PIN = 7;    // Pin digital para Echo
const int MAX_DISTANCE = 200; // Distancia máxima en cm

// Crear el objeto sonar
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

int count = 0;
int N = 100;
unsigned long delta_total = 0;

unsigned long t_anterior = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
}

void loop() {
  unsigned long t_actual = micros();



  unsigned long delta = t_actual - t_anterior;
  if ((delta) >= (20000)) {
    
    t_anterior = t_actual;
    
    unsigned long time_ping = sonar.ping(); 
    float dist = time_ping / (2.0 *  29.287);

    Serial.println(dist);
  }

}
