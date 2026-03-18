int count = 0;
int N = 1000;
unsigned long delta_total = 0;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
}

void loop() {
  unsigned long t_init = micros();

  int pot = analogRead(A0);
  float angulo = pot * 270.0 / 1023;
  
  unsigned long t_final = micros();
  unsigned long delta = (t_final - t_init);
  
  count = count + 1;
  delta_total = delta_total + delta;
  //Serial.println(count);
  
  if (count == N) {
    count = 0;
    float frec = 1000000 * N/ (delta_total); 
    Serial.println(frec);
    delta_total = 0;
  }

  //Serial.print("Pot: ");
  //Serial.println(pot);
  //Serial.print("Angulo: ");
  //Serial.println(angulo);

}
