
void setup(void) {
	Serial.begin(115200);
	delay(100);
}

void loop() {
	float d1=1.4, d2=-5.8, d3=16.546721;
  
	// Matlab send
  matlab_send(d1,d2,d3);
  delay(1000);
}

void matlab_send(float dato1, float dato2, float dato3){
  Serial.write("abcd");
  byte * b = (byte *) &dato1;
  Serial.write(b,4);
  b = (byte *) &dato2;
  Serial.write(b,4);
  b = (byte *) &dato3;
  Serial.write(b,4);
  //etc con mas datos tipo float. Tambien podría pasarse como parámetro a esta funcion un array de floats.
}
