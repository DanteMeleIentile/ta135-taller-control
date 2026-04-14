#include <Servo.h>

Servo myservo; 

void setup() {
  myservo.attach(9); 
  Serial.begin(115200);
}

int angle[3] = {1300, 1500, 2200};

void loop() {
  //600 a 2400
 
  myservo.writeMicroseconds(1000);
  for (int i = 0; i < 3; i++){
    Serial.println("TEST");
    Serial.println(i);
    myservo.writeMicroseconds(angle[i]);
    delay(2000);
  }
 
}
