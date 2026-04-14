#define TIPO_TEST 1 // 0 -> write; 1 -> flush 

void setup() {
  Serial.begin(115200);
  delay(2000);

  float dato = 1.11; 
  byte* a_enviar = (byte*)&dato;

  #if TIPO_TEST == 0
    Serial.println();
    Serial.println("--- ENVIO CON WRITE ---");
  #elif TIPO_TEST == 1
    Serial.println();
    Serial.println("--- ENVIO CON FLUSH ---");
  #endif

  delay(1000);


  unsigned long t_start = micros();

  for (int i = 0; i < 100; i++) {
    Serial.write(a_enviar, 4); 
  }
  
  #if TIPO_TEST == 1
    Serial.flush(); //se queda esperando que se vacíe el buffer
  #endif
 
  unsigned long t_finish = micros();

  Serial.println();
  Serial.print("Tiempo TOTAL: ");
  Serial.print(t_finish - t_start);
}

void loop() {
}
