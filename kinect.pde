import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import spout.*;
import themidibus.*;

// Kinect One
Kinect kinectOne;
int CAMERA_TILT_ONE = 0;

// Kinect Two
Kinect kinectTwo;
int CAMERA_TILT_TWO = 0;

// Spout One
Spout spoutOne;

// Spout Two
Spout spoutTwo;

// Midi Controller
MidiBus CONTROLLER;

PGraphics canvasOne, canvasTwo;

int BOX_SIZE = 2;
int CAMERA_TILT_DUAL = 0;
float SCALE_FACTOR = 1100;

float ROTATE_INCREMENT = 0.015;
float ROTATE_SPEED = 0.15;
float ROTATE_SPEED_MAX = 0.5;
float ROTATE_X = 0;
float ROTATE_Y_ONE = 0;
float ROTATE_Y_TWO = 0;

boolean ROTATE_RIGHT_ONE = false;
boolean ROTATE_LEFT_ONE = false;
boolean ROTATE_RIGHT_TWO = false;
boolean ROTATE_LEFT_TWO = false;

int skip = 6;
float a = 0;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

int canvasWidth = 1920;
int canvasHeight = 1080;

void setup() {

  //fullScreen(P2D,1);
  size(400, 400, P2D);
  //smooth(8);
  background(0);
  
  canvasOne = createGraphics(canvasWidth, canvasHeight, P3D);
  canvasTwo = createGraphics(canvasWidth, canvasHeight, P3D);
  
  CONTROLLER = new MidiBus(this, "Launchpad S", "Launchpad S");
  
  // Kinect One - Controls: Tilt
  CONTROLLER.sendControllerChange(0, 104, 10);
  CONTROLLER.sendControllerChange(0, 105, 10);
  
  // Kinect One - Controls: Rotate Y
  CONTROLLER.sendControllerChange(0, 106, 40);
  CONTROLLER.sendControllerChange(0, 107, 40);
  
  // Kinect One - Controls: Rotate Y AUTO
  CONTROLLER.sendNoteOn(0, 2, 40);
  CONTROLLER.sendNoteOn(0, 3, 40);
  
  
  // Kinect Two - Controls: Tilt
  CONTROLLER.sendControllerChange(0, 108, 10);
  CONTROLLER.sendControllerChange(0, 109, 10);
  
  // Kinect Two - Controls: Rotate Y
  CONTROLLER.sendControllerChange(0, 110, 40);
  CONTROLLER.sendControllerChange(0, 111, 40);
  
  // Kinect Two - Controls: Rotate Y AUTO
  CONTROLLER.sendNoteOn(0, 6, 40);
  CONTROLLER.sendNoteOn(0, 7, 40);
  
  kinectOne = new Kinect(this);
  kinectOne.activateDevice(0);
  kinectOne.initDepth();
  kinectOne.setTilt(CAMERA_TILT_ONE);
  
  kinectTwo = new Kinect(this);
  kinectTwo.activateDevice(2);
  kinectTwo.initDepth();
  kinectTwo.setTilt(CAMERA_TILT_TWO);
  
  spoutOne = new Spout(this);
  spoutOne.createSender("Kinect One");
  
  spoutTwo = new Spout(this);
  spoutTwo.createSender("Kinect Two");
   
  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }

}

void draw() {

  canvasOne.beginDraw();
  canvasOne.background(0);
  canvasOne.translate(canvasWidth/4, canvasHeight/4, 0);
  canvasOne.rotateY(ROTATE_Y_ONE);

  int[] depthOne = kinectOne.getRawDepth();

  for (int x = 0; x < kinectOne.width; x += skip) {
    for (int y = 0; y < kinectOne.height; y += skip) {

      int offset = x + y*kinectOne.width;
      int rawDepth = depthOne[offset]; // Convert kinect data to world xyz coordinate
      PVector v = depthToWorld(x, y, rawDepth);
      
      //canvasOne.strokeWeight(1);
      canvasOne.stroke(255);
      canvasOne.fill(255);
      canvasOne.pushMatrix();
      canvasOne.translate(
        v.x * SCALE_FACTOR,
        v.y * SCALE_FACTOR,
        SCALE_FACTOR - v.z * SCALE_FACTOR
      );
      canvasOne.box(BOX_SIZE);
      canvasOne.popMatrix();
    
    }
  }
  
  canvasOne.endDraw();
  
  if(ROTATE_LEFT_ONE) {
    ROTATE_Y_ONE += ROTATE_SPEED;
  }

  if(ROTATE_RIGHT_ONE) {
    ROTATE_Y_ONE -= ROTATE_SPEED;
  }
  
  spoutOne.sendTexture(canvasOne);
  //image(canvasOne,0,0);

  canvasTwo.beginDraw();
  canvasTwo.background(0);
  canvasTwo.translate(canvasWidth/4, canvasHeight/4, 0);
  canvasTwo.rotateY(ROTATE_Y_TWO);

  int[] depthTwo = kinectTwo.getRawDepth();
  
  for (int x = 0; x < kinectTwo.width; x += skip) {
    for (int y = 0; y < kinectTwo.height; y += skip) {
      int offset = x + y*kinectTwo.width;
      int rawDepth = depthTwo[offset]; // Convert kinect data to world xyz coordinate
      PVector v = depthToWorld(x, y, rawDepth);
      
      //canvasTwo.strokeWeight(1);
      canvasTwo.stroke(255);
      canvasTwo.fill(255);
      canvasTwo.pushMatrix();
      canvasTwo.translate(
        v.x * SCALE_FACTOR,
        v.y * SCALE_FACTOR,
        SCALE_FACTOR - v.z * SCALE_FACTOR
      );
      canvasTwo.box(BOX_SIZE);
      canvasTwo.popMatrix();
    }
  }
  
  canvasTwo.endDraw();
  
  if(ROTATE_LEFT_TWO) {
    ROTATE_Y_TWO += ROTATE_SPEED;
  }

  if(ROTATE_RIGHT_TWO) {
    ROTATE_Y_TWO -= ROTATE_SPEED;
  }
  
  spoutTwo.sendTexture(canvasTwo);
  //image(canvasTwo, canvasOne.width, 0);

}

void controllerChange(int channel, int number, int value) {
  
  if (number == 104) {
    CAMERA_TILT_ONE += 1;
  } else if (number == 105) {
    CAMERA_TILT_ONE -= 1;
  }
  
  if (number == 104 || number == 105) {
    CAMERA_TILT_ONE = constrain(CAMERA_TILT_ONE, -30, 30);
    kinectOne.setTilt(CAMERA_TILT_ONE);
  }
  
  if (number == 106) {
    ROTATE_LEFT_ONE = !ROTATE_LEFT_ONE; 
  }
  
  if (number == 107) {
    ROTATE_RIGHT_ONE = !ROTATE_RIGHT_ONE;
  }

  if (number == 108) {
    CAMERA_TILT_TWO += 1;
  } else if (number == 109) {
    CAMERA_TILT_TWO -= 1;
  }
  
  if (number == 108 || number == 109) {
    CAMERA_TILT_TWO = constrain(CAMERA_TILT_TWO, -30, 30);
    kinectTwo.setTilt(CAMERA_TILT_TWO);
  }
  
  if (number == 110) {
    ROTATE_LEFT_TWO = !ROTATE_LEFT_TWO; 
  }
  
  if (number == 111) {
    ROTATE_RIGHT_TWO = !ROTATE_RIGHT_TWO;
  }
  
  //if (number == 108) {
  //  CAMERA_TILT_DUAL += 1;
  //} else if (number == 109) {
  //  CAMERA_TILT_DUAL -= 1;
  //}
  
  //if (number == 108 || number == 109) {
  //  CAMERA_TILT_DUAL = constrain(CAMERA_TILT_DUAL, -30, 30);
  //  kinectOne.setTilt(CAMERA_TILT_DUAL);
  //  kinectTwo.setTilt(CAMERA_TILT_DUAL); 
  //}
  
}

void noteOn(int channel, int pitch, int velocity) {
  
  if(pitch == 2){
    if(ROTATE_RIGHT_ONE){
      ROTATE_RIGHT_ONE = !ROTATE_RIGHT_ONE;
    }
    ROTATE_LEFT_ONE = !ROTATE_LEFT_ONE;
  }
  
  if(pitch == 3){
    if(ROTATE_LEFT_ONE){
      ROTATE_LEFT_ONE = !ROTATE_LEFT_ONE;
    }
    ROTATE_RIGHT_ONE = !ROTATE_RIGHT_ONE;
  }
  
  if(pitch == 6){
    if(ROTATE_RIGHT_TWO){
      ROTATE_RIGHT_TWO = !ROTATE_RIGHT_TWO;
    }
    ROTATE_LEFT_TWO = !ROTATE_LEFT_TWO;
  }
  
  if(pitch == 7){
    if(ROTATE_LEFT_TWO){
      ROTATE_LEFT_TWO = !ROTATE_LEFT_TWO;
    }
    ROTATE_RIGHT_TWO = !ROTATE_RIGHT_TWO;
  }
  
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 880) { //change this value for depth
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {
  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;
  PVector result = new PVector();
  double depth = depthLookUp[depthValue]; //rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}
