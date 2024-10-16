import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port

int canvasSize = 500; // GUI canvas dimensions

// often will use this color for maxColor
int maxColor = 255;

// Font format for text; this var will be reused
// in case I need to change font family for text
PFont font;

// defined analogMax for objects like Joystick and Potentiometer
final int analogMax = 4095;

// Position and Dimension of the Move Box (top left)
int moveRectX = 2;
int moveRectY = canvasSize - canvasSize/5;
int moveRectWidth = canvasSize - (moveRectX * 2);
int moveRectHeight = canvasSize/5 - 1;
int moveRectRadius = int(canvasSize * 0.05);

// Position and Dimension of the Boost Box (top left)
int boostRectX = canvasSize - canvasSize/3;
int boostRectY = canvasSize - int(canvasSize/5 * 1.5);
int boostRectWidth = (canvasSize - (boostRectX));
int boostRectHeight = ((canvasSize/5) - 1)/2;

// move, boost selection and information + input delay
final String[] moves = {"Attack", "Guard", "Calm Down", "Run"};
final String[] boost = {"Low", "Medium", "High"};
int moveCounter = 0;
int boostChoice;
int moveDelay = 400;

// text effect printed for move and typewriting effect
String printText;
float printTextCounter;
int printTextTime;
int printTextDelay = 50;

// Player information placeholder
// Complete version will initialize in setup()
// and instantiate a Player Class instead
int playerHealth = 100;
int playerStamina = 50;
String playerName = "Pointer";

// Player Health and Stamina Box (top left)
int playerRectX = 0;
int playerRectY = 0;
int playerRectWidth = canvasSize/4;
int playerRectHeight = canvasSize/5;

// Enemy information placeholder
// Complete version will initialize in setup()
// and instantiate a Polygon Class instead
int polyHealth = 20;
int polyStamina = 50;
String polyName = "Circle";

// Enemy Health and Stamina Box (top left)
int polyRectX = canvasSize - canvasSize/4;
int polyRectY = 0;
int polyRectWidth = canvasSize/4;
int polyRectHeight = canvasSize/5;

// Current Wave of the battle
int waveNum;

// how time is being checked
int initTime;

void setup()
{
  size(500, 500);
  printArray(Serial.list());
  String portName = Serial.list()[1];
  //println(portName);
  myPort = new Serial(this, portName, 9600); // ensure baudrate is consistent with arduino sketch
  initTime = millis(); // initialize time on setup for the program
  boostChoice = 0;
  printTextCounter = 0;
  printTextTime = 0;
  printText = "";
  waveNum = 1;
  frameRate(15); // refresh 10 times a second;
}

void draw()
{
  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
  }
  val = trim(val);
  if ( val != null ) {  
    display();
    int currTime = millis();
    if (currTime > initTime + moveDelay && printText.isEmpty()) {
      //println(val);
      int[] xyzrb = int(split(val, ','));
      
      // use if statement to check serial input length to prevent ArrayIndexOutOfBounds errors
      if(xyzrb.length == 5) {
        // pass joystick x, y, z, button input, and potentiometer input
        // into each variable
        int x = xyzrb[0];
        int y = xyzrb[1]; // may be used in an item menu perhaps?
        int z = xyzrb[2]; // currently don't know what to do with this
        int b = xyzrb[3];
        int r = xyzrb[4];
        
        // switch to different moves while move left and right on the joy stick
        if (x > analogMax * 0.8 && x <= analogMax) {
          moveCounter = (moveCounter + 1) % moves.length;
          initTime = currTime;
        }
        else if (x < analogMax * 0.2 && x >= 0) {
          moveCounter =  (moveCounter - 1) < 0 ? moves.length - 1 : (moveCounter - 1);
          initTime = currTime;
        }
        
        // change boost mode based on the potentiometer value
        if (r >= 0 && r < analogMax/3) {
          boostChoice = 0;
          initTime = currTime;
        }
        else if (r >= analogMax/3 && r < analogMax/3 * 2) {
          boostChoice = 1;
          initTime = currTime;
        }
        else if (r >= analogMax/3 * 2 && r <= analogMax) {
          boostChoice = 2;
          initTime = currTime;
        }
        
        // checks push button selection to confirm an option
        if (b == 0) {
           selectPrintText(moves[moveCounter]);
           initTime = currTime;
        }
      }
    }
  }
  
}

// Draw the UI of Polyscend
void display() {
  background(0);
  
  // Move box
  fill(0, 0, 0); // rect is filled black inside 
  stroke(maxColor); // maxColor borders
  rect(moveRectX, moveRectY, moveRectWidth, moveRectHeight);
  
  // Move text choice and position on UI
  fill(maxColor, maxColor, maxColor); // text filled maxColor
  stroke(maxColor); // text border is maxColor
  font = createFont("pixel_operator/PixelOperator.ttf", 128);
  textFont(font);
  textAlign(CENTER);
  textSize(canvasSize * 0.1); // may change this size to match with moveRect
  text("< " + moves[moveCounter] + " >", canvasSize/2, moveRectY + moveRectHeight/1.5);
  
  // Boost box
  fill(0, 0, 0); // boost is filled black inside 
  stroke(maxColor); // maxColor borders
  rect(boostRectX, boostRectY, boostRectWidth, boostRectHeight);
  
  // Initial word "Boost" in the box
  fill(maxColor, maxColor, maxColor); // text filled maxColor
  stroke(maxColor); // text border is maxColor
  textFont(font);
  textAlign(LEFT);
  textSize(boostRectWidth/6);
  text("Boost: ", boostRectX + 5, boostRectY + (canvasSize - moveRectY)/2 - boostRectWidth/10);
  
  // Color for low, medium, high boost options
  if (boostChoice == 0) {
    fill(maxColor, 0, 0); // red
  }
  else if (boostChoice == 1) {
    fill(0, maxColor, maxColor); // cyan
  }
  else if (boostChoice == 2) {
    fill(0, maxColor, 0); // green
  }
  
  // Boost Choice
  text(boost[boostChoice], boostRectX + boostRectWidth/2 - 10, boostRectY + (canvasSize - moveRectY)/2 - boostRectWidth/10);
  
  // Player box
  fill(0, 0, 0); // rect is filled black inside 
  stroke(maxColor); // maxColor borders
  rect(playerRectX, playerRectY, playerRectWidth, playerRectHeight);
  
  // Player Name, Health, and Stamina text
  fill(maxColor, maxColor, maxColor); // text filled maxColor
  stroke(maxColor); // text border is maxColor
  textFont(font);
  textAlign(LEFT);
  textSize(playerRectWidth/5.4);
  text(playerName, playerRectX + 5, playerRectY + playerRectWidth/6);
  text("Health: " + playerHealth, playerRectX + 5, (playerRectY + playerRectWidth/6) * 2.5);
  text("Stamina: " + playerHealth, playerRectX + 5, (playerRectY + playerRectWidth/6) * 4);
  
  // Polygon box
  fill(0, 0, 0); // rect is filled black inside 
  stroke(maxColor); // maxColor borders
  rect(polyRectX, polyRectY, polyRectWidth, polyRectHeight);
  
  // Polygon Name, Health, and Stamina text
  fill(maxColor, maxColor, maxColor); // text filled maxColor
  stroke(maxColor); // text border is maxColor
  textFont(font);
  textAlign(RIGHT);
  textSize(polyRectWidth/5.4);
  text(polyName, polyRectX + polyRectWidth - 5, polyRectY + polyRectWidth/6);
  text("Health: " + polyHealth, polyRectX + polyRectWidth - 5, (polyRectY + polyRectWidth/6) * 2.5);
  text("Stamina: " + polyStamina, polyRectX + polyRectWidth - 5, (polyRectY + polyRectWidth/6) * 4);
  
  // Polygon drawn on center of screen
  fill(0, 0, 0); // shape is filled black inside 
  stroke(maxColor); // maxColor borders
  switch (polyName) {
    case "Circle":
      circle(canvasSize/2, canvasSize/2.5, 150);
  }
  
  // Wave Num text
  fill(maxColor, maxColor, maxColor); // text filled maxColor
  stroke(maxColor); // text border is maxColor
  textFont(font);
  textAlign(CENTER);
  textSize(canvasSize * 0.1);
  text("Wave " + waveNum, canvasSize/2, canvasSize * 0.1);
  
  // If a move was selected, perform this type writer effect
  // on the move
  if (!printText.isEmpty()) {
    typewriteText(0, moveRectY - 60, width - boostRectWidth, 100);
  }
}

// Selects what text should be printed on screen
// based on the option chosen
void selectPrintText(String option){
  switch (option) {
    case "Attack":
      printText = "You hit the attack move!";
      break;
    case "Guard":
      printText = "You hit the guard move!";
      break;
    case "Calm Down":
      printText = "You hit the calm down move!";
      break;
    case "Run":
      printText = "You hit the run move!";
      break;
    default: // this will likely not be triggered
      printText = "No choice made yet";
      break;
  }
}

// some code inspired from p5 website:
// https://editor.p5js.org/cfoss/sketches/SJggPXhcQ
// does the typewriting effect on text at specified coordinates
// and with a given sized text box
void typewriteText(int x, int y, int textWidth, int textHeight){
  int currTime = millis();
  if (printTextCounter < printText.length() && currTime > printTextTime + printTextDelay) {
    println("This happened");
    fill(maxColor, maxColor, maxColor); // text will be printed out white for now
    stroke(maxColor); // border of text will be white for now
    font = createFont("pixel_operator/PixelOperator.ttf", 128); // constant font for now; could make this variable
    textFont(font);
    textAlign(LEFT); /// left aligned
    textSize(30);
    text(printText.substring(0, int(printTextCounter + 1)), x, y, textWidth, textHeight);
    printTextCounter += 1;
    printTextTime = currTime;
  }
  else if (printTextCounter == printText.length()){
    delay(500);
    printTextCounter = 0;
    printText = "";
  }
}
