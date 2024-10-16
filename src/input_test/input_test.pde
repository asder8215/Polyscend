/*
  Serial Joystick
 Takes in X,Y,Z serial input from a joystick
 */

import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port

int canvasSize = 500;
int analogMax = 4095;

void setup()
{
  size(500, 500);
  printArray(Serial.list());
  String portName = Serial.list()[1];
  println(portName);
  myPort = new Serial(this, portName, 9600); // ensure baudrate is consistent with arduino sketch
}

void draw()
{
  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
  }
  val = trim(val);
  if ( val != null ) {
    background(255);
    //println(val);
    int[] xyzrb = int(split(val, ','));

    // use if statement to check serial input length to prevent ArrayIndexOutOfBounds errors
    if (xyzrb.length == 5) {
      int x = xyzrb[0];
      int y = xyzrb[1];
      int z = xyzrb[2];
      int b = xyzrb[3];
      int r = xyzrb[4];
      
      float circleX = map(x, 0, analogMax, 0, canvasSize);
      float circleY = map(y, 0, analogMax, 0, canvasSize);
      float radius = map(r, 0, analogMax, 0, canvasSize/2);
      int fillColor = (z == 0 ? 255 : (b == 1) ? 0 : 255);

      fill(fillColor);
      circle(circleX, circleY, radius);
    }
  }
}
