int count = 0;
int N = 100;
unsigned long delta_total = 0;

void setup() {
  Serial.begin(115200);
  Serial.println(ADCSRA, BIN);
}

void loop() {
  unsigned long t_init = micros();

  int pot = analogRead(A0);
  //float angulo = pot * 270.0 / 1023.0; 
  
  unsigned long t_final = micros();
  unsigned long delta = (t_final - t_init);
  
  count = count + 1;
  delta_total = delta_total + delta;
  
  if (count == N) {
    float tiempo_promedio = (float)delta_total / N;
    Serial.println(tiempo_promedio);

    count = 0;
    delta_total = 0;

    
    float frec = 1000000.0 / tiempo_promedio; 
    Serial.println(frec);
        
  }
  /*
  Serial.print("Pot: ");
  Serial.println(pot);
  Serial.print("Angulo: ");
  Serial.println(angulo);
  Serial.print("Tiempo: ");
  Serial.println(delta);
  */
}
