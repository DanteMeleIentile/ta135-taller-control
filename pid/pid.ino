// --- Parámetros del Controlador Discreto ---
const float b0 = -694.94;
const float b1 = 567.00;

// --- Variables de Estado del Controlador ---
float e_k = 0.0;    // Error actual e[k]
float e_k_1 = 0.0;  // Error pasado e[k-1]
float u_k = 0.0;    // Acción de control actual u[k]
float u_k_1 = 0.0;  // Acción de control pasada u[k-1]

// --- Tiempos y Referencia ---
// Asegurate de que Ts_micros coincida EXACTAMENTE con el Ts que usaste en MATLAB
const unsigned long Ts_micros = 20000; // Ejemplo: 20 ms = 20000 microsegundos
unsigned long tiempo_anterior = 0;

float referencia = 0.0; // Tu setpoint (ej. 0 grados)

void setup() {
  Serial.begin(115200);
  // Aquí inicializas tus sensores y actuadores (IMU, PWM del motor, etc.)
}

void loop() {
  unsigned long tiempo_actual = micros();

  // Se ejecuta solo cuando pasa exactamente el tiempo de muestreo Ts
  if (tiempo_actual - tiempo_anterior >= Ts_micros) {
    tiempo_anterior = tiempo_actual; // Actualizamos el temporizador

    // 1. LEER SENSOR
    float y_k = leer_angulo_sensor(); // Reemplazar por tu función real (ej. lectura de IMU)

    // 2. CALCULAR ERROR
    e_k = referencia - y_k;

    // 3. CALCULAR ACCIÓN DE CONTROL (Ecuación en diferencias)
    u_k = u_k_1 + (b0 * e_k) + (b1 * e_k_1);

    // 4. SATURACIÓN / ANTI-WINDUP (Obligatorio en la práctica)
    // Evita que el controlador pida más de lo que el motor puede dar
    float limite_pwm = 255.0; // Ejemplo para un PWM de 8 bits
    if (u_k > limite_pwm) {
      u_k = limite_pwm;
    } else if (u_k < -limite_pwm) {
      u_k = -limite_pwm;
    }

    // 5. APLICAR AL ACTUADOR
    aplicar_pwm_motor(u_k); // Reemplazar por tu función de motor real

    // 6. ACTUALIZAR VARIABLES PASADAS PARA EL PRÓXIMO CICLO
    e_k_1 = e_k;
    u_k_1 = u_k;
    
    // (Opcional) Enviar por Serial para graficar o debugear
    // Serial.println(y_k); 
  }
  
  // Aquí puedes poner código que no dependa del tiempo estricto
}

// Funciones dummy (debes reemplazarlas por las tuyas)
float leer_angulo_sensor() {
  return 0.0; 
}
void aplicar_pwm_motor(float control) {
  // Lógica para dirección y analogWrite()
}

$$u[k] = u[k-1] - 694.94 e[k] + 567.00 e[k-1]$$
