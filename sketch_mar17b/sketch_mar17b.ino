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
    int pot = analogRead(A0);
    float angulo = pot * 293.0 / 1023.0;
    Serial.println(angulo);
  }

}
