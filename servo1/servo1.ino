#include <Servo.h>

Servo myservo;  // create Servo object to control a servo



void setup() {
  myservo.attach(9);  // attaches the servo on pin 9 to the Servo object
  Serial.begin(115200);
}

void loop() {
  Serial.println("Evaluación 0 grados");
  Serial.println("Microseconds");
  myservo.writeMicroseconds(600);                  
  delay(2000);
  Serial.println("Posición");
  myservo.write(0);
  delay(8000);   

  Serial.println("Evaluación 90 grados");
  Serial.println("Microseconds");
  myservo.writeMicroseconds(1500);                  
  delay(2000);
  Serial.println("Posición");
  myservo.write(90);
  delay(5000);

  Serial.println("Evaluación 180 grados");
  Serial.println("Microseconds");
  myservo.writeMicroseconds(2400);                  
  delay(2000);
  Serial.println("Posición");
  myservo.write(180);
  delay(5000);           
}
