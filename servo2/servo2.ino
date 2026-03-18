#include <Servo.h>
#define FREC 50
#define FREC_TIME 1000000/FREC

Servo myservo;  // create Servo object to control a servo

unsigned long t_anterior = 0;


void setup() {
  // put your setup code here, to run once:
  myservo.attach(9);  // attaches the servo on pin 9 to the Servo object
  Serial.begin(115200);
}

void loop() {
  unsigned long t_actual = micros();

  unsigned long delta = t_actual - t_anterior;
  if ((delta) >= (FREC_TIME)) {
    
    t_anterior = t_actual;
    int pot = analogRead(A0);
    float angulo = pot * 180.0 / 1023.0;
    Serial.println("Posición");
    myservo.write(angulo);
    Serial.println(angulo);
  }

}
