void setup() {
  Serial.begin(115200);
  delay(1000);
  float dato = 1.11; 
  byte* a_enviar = (byte*)&dato;

  unsigned long t_start = micros();

  for (int i = 0; i < 100; i++) {
    Serial.write(a_enviar, 4); 
  }

  unsigned long t_finish = micros();

  Serial.println("\n--- RESULTADO DEL EXPERIMENTO ---");
  Serial.print("Tiempo total para 100 floats: ");
  Serial.print(t_finish - t_start);
  Serial.println(" microsegundos");
}

void loop() {
  // Queda vacío, el experimento se hace una sola vez en el setup
}
