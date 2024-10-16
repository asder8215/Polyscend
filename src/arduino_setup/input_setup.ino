#define BUTTON_PIN 15 // push button pin
#define POTENTIOMETER_PIN 13 // potentiometer pin
int xyzPins[] = {39, 32, 33};   //x, y, z(switch) pins

void setup() {
  Serial.begin(9600);
  // use internal pullup resistor for click on push button
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  // use internal pullup resistor for click control on joystick
  pinMode(xyzPins[2], INPUT_PULLUP);
}

void loop() {
  // reading values from push button, joystick, and potentiometer
  int buttonState = digitalRead(BUTTON_PIN);
  int xVal = analogRead(xyzPins[0]);
  int yVal = analogRead(xyzPins[1]);
  int zVal = digitalRead(xyzPins[2]);
  int pRes = analogRead(POTENTIOMETER_PIN);

  // printing it out (necessary for Processing IDE to receive inputs)
  Serial.printf("%d,%d,%d,%d,%d", xVal, yVal, zVal, buttonState, pRes);
  Serial.println();
  // delay on receiving inputs from all sources
  delay(100);
}