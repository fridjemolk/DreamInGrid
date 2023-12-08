import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import spout.*;

Minim minim;
AudioInput input;
BeatDetect beat;

float eRadius;
float waveOffset;

int shaderIndex = 1;
float randTime;
float subTime;
boolean randomize;

ArrayList<GShader> shaders;
GShader shader;
PGraphics pg;
PGraphics wave;
int idxShader = -1;

static boolean SHOW_GUI = false; //GUI doesnt do anything at the moment, and actually disables some shader parameters' randomisation, so leave this as false. 

// DECLARE A SPOUT OBJECT
Spout spout;
static boolean SPOUT_ENABLE = true;

void setup() 
{
  
  size(1920, 1080, P2D);
  setupShaders();
  setupGui();  
  setShader(int(random(0,shaders.size()-1)));
  pg = createGraphics(width, height, P2D);
  wave = createGraphics(width, height, P2D);
  
  waveOffset = height * 0.2;

  minim = new Minim(this);

  // use the getLineIn method of the Minim object to get an AudioInput
  input = minim.getLineIn();
  
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beat = new BeatDetect();
  beat.setSensitivity(5);
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  
  randTime = random(600,10000);
  subTime = 0;
  
  ellipseMode(RADIUS);
  eRadius = 20;
  
  randomize = true;
  
  println(" ");
  println("Audio input buffer size: " + input.bufferSize());
  
  println(" ");
  println("Shaders Loaded: ");
  
  for (int i=0; i<shaders.size(); i++) {
    println(shaders.get(i).path);
  }
  println(" ");
  
  if(SPOUT_ENABLE){
    // CREATE A NEW SPOUT OBJECT
    spout = new Spout(this);
    spout.setSenderName("DreamInGrid Spout Sender");
  }
}

void draw() 
{ 
  //Make sure the time between shader changes isnt too small
  if(randTime < 400){
    randTime = 1000;
  }
  
  //Run beat detection on this frame's audio buffer
  beat.detect(input.mix);
  
  //Make sure the shader index is within the range of the array size, and check if its time to pick a new shader
  shaderIndex = wrap(shaderIndex, 0, shaders.size()-1);
  if(((millis()-subTime) > randTime) && randomize) {
    subTime = millis();
    shaderIndex = int(random(0,shaders.size()-1));
    randTime = random(600,10000);
    println("NEW SHADER TIME!!!... next shader will b chosen in: " + randTime + "ms");
  }
  //Update which shader is being rendered this frame
  setShader(shaderIndex);
  
  background(0);
  
  //Randomise the current shader's parameters on a HiHat detection 
  if( beat.isHat()){
     shader.setShaderParametersOnHat(); 
     //println("HAT :D RANDOMizing ur shaderz .....");
  }
  
  //Advance shader time by a random amount on a kick drum detection
  if( beat.isKick() ) {
    shader.setShaderParameters(random(250.0,750.0));
    //println("KICK :D moving foward in time.....");
  } else {
    //Update the shader parameters for this frame
    shader.setShaderParameters(0);
  }
  
  //Draw the shader to a pgraphics buffer
  pg.beginDraw();
  pg.shader(shader.shader);
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();
  
  //Draw the shader buffer to the canvas
  fill(0);
  rect(0, 0, 480, height);
  image(pg, 0, 0); 
  
  stroke(255);
  
  //Draw a rectangle over the whole canvas, with a transparency based on how recently a snare drum was detected
  push();
  noStroke();
  float a = map(eRadius, 20, 80, 0, 255);
  fill(255, 255, 255, a);
  if ( beat.isSnare()) eRadius = 80;
  blendMode(ADD);
  rect(0, 0, width, height);
  eRadius *= 0.8;
  if ( eRadius < 20 ) eRadius = 20;
  pop();

  //Draw the waveforms to the waveform' pgraphics buffer so we can see what we are monitoring
  float xOffset = (width/input.bufferSize());
  wave.beginDraw();
  wave.background(0,0,0,0);
  wave.push();
    wave.strokeWeight(2);
    wave.noFill();
    wave.stroke(255,255,255);
    float waveformAmplitude = 300;
    for(int i = 0; i < input.bufferSize() - 1; i++)
    {
      float xPos = map(float(i),0,float(input.bufferSize()),float(0),float(width));
      
      wave.line( xPos, 
      waveOffset + input.left.get(i)*waveformAmplitude, 
      xPos+xOffset, 
      waveOffset + input.left.get(i+1)*waveformAmplitude );
      
      wave.line( xPos, 
      (height-waveOffset) + input.right.get(i)*waveformAmplitude, 
      xPos+xOffset, 
      (height-waveOffset) + 
      input.right.get(i+1)*waveformAmplitude );
      
    }
  wave.pop();
  wave.endDraw();
  //Draw the wave buffer to the canvas. this is the last thing we draw, so its on top 
  image(wave,0,0);
  
  //Send this frame out with Spout
  if(SPOUT_ENABLE){
    // Send spout at the size of the window    
    spout.sendTexture();
  }
}

int wrap(int val, int min, int max){
  
  if(val < min){
    val = max;
  } else if (val > max){
    val = min;
  }
  
  return val;
}
 
void keyPressed() {
  if (key == 'd') {
    shaderIndex += 1;
    println("Switching to shader " + wrap(shaderIndex, 0, shaders.size()-1));
  } 
  else if (key == 'a') {
    shaderIndex -= 1;
    println("Switching to shader " + wrap(shaderIndex, 0, shaders.size()-1));
  } 
  else if (key == 'r'){
    if(randomize){
      println("~!Disabiling Random Mode!~");
    } else {
      println("~!Enabling Random Mode!~");
    }
    randomize = !randomize;
    
  }
  else {
    for(int i = 0; i < 10; i++){
       if(key == char(i+48)){ //0 is at address 48 in ASCII
         println("Switching to shader " + i);
         if(i == 0){
           i = 10;
         }
         shaderIndex = i;
       }
    }
  }
}
