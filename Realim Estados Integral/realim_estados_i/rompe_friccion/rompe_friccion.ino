#include <Arduino.h>
#include <NewPing.h>

#include "config.h"
#include "servo_mod.h"

/* --- Vars SR04 --- */
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

/* --- Parámetros de la prueba --- */
float u_test = 0.0;
float step_u = 2; // Ajustá este valor según qué tan rápido querés que suba la rampa
float dist_inicial = 0.0;

void setup() {
  Serial.begin(115200);
  
  // Inicialización del servo
  myservo.attach(9);
  delay(1000);
  myservo.writeMicroseconds(ORIGEN_U); 
  
  // Aseguramos que la acción de control arranque en 0 (barra horizontal)
  actuador(0);
  delay(2000);

  // Leemos la distancia inicial donde posicionaste la bola
  unsigned long time_ping = sonar.ping();
  dist_inicial = time_ping / (2.0 * 29.287) - ORIGEN_D;

  Serial.println("--- INICIANDO PRUEBA DE FRICCION ---");
  Serial.print("Distancia inicial: ");
  Serial.println(dist_inicial);
  delay(2000);
}

void loop() {
  // 1. Incrementar 'u' gradualmente
  u_test += step_u;
  actuador(u_test);

  // 2. Medir la distancia actual de la bola
  unsigned long time_ping = sonar.ping();
  float dist_actual = time_ping / (2.0 * 29.287) - ORIGEN_D;

  // 3. Imprimir por pantalla (para el Monitor Serie o Serial Plotter)
  Serial.print("U_aplicado: ");
  Serial.print(u_test, 4);
  Serial.print("\t | Distancia: ");
  Serial.println(dist_actual, 4);

  // 4. Pausa para que la rampa suba lentamente
  // Te da tiempo de ver en pantalla el valor exacto de 'u' cuando la bola se mueve
  delay(150); 
}
