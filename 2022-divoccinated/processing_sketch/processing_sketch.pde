import processing.sound.*;
import java.util.Queue;
import java.util.ArrayDeque;

AudioIn in;
FFT fft;

final color orange = color(252, 111, 3);
final color white = color(255, 255, 255);
final color blue = color(1, 64, 110);
final int totalLayerInFrame = 5;
final float baseWidthOfBorder = 0.9;
final int boxAnimationIteration = 150;
final float fftThreshold = 0.2;
final ArrayList<PImage> images = new ArrayList<PImage>();
final ArrayList<Layer> layers = new ArrayList<Layer>();

int fftBands = 512;
float[] fftSpectrum = new float[fftBands];


int zoomPointX = 0;
int zoomPointY = 0;
int wOffset = 0;

class Layer {
  private int frame = 0;
  private PGraphics graphics;
  private boolean isBox;
  
  Layer(boolean isBox, float offset) {
    this.isBox = isBox;
    float iter = timeLoop(boxAnimationIteration, offset);
  }
  
  void move() {
    this.frame++;
  }
  
  PGraphics getGraphics() {
    return this.graphics;
  }
}

void setup() {
  /// SETUP
  background(0);
  frameRate(30);
  smooth(6);
  
  // prod
  // fullScreen();
  // size(1080, 1920, P2D);
  
  /// dev
  size(540, 980, P2D); // 1/2 of Full HD vertical
  
  /// RUNTINE
  /// ======== audio =======
  fft = new FFT(this, fftBands);
  in = new AudioIn(this, 0);
  in.start();
  fft.input(in);
  
  /// ======== positioning =======
  zoomPointX = width/2;
  zoomPointY = (int)(height - height * 0.3);
  wOffset = (((zoomPointY - height/2) / 9) * 16);
  
  /// ======== layers ======= 
  //for(int i = 0; i < totalLayerInFrame; i++) {
  //  float iter = timeLoop(boxAnimationIteration, i * (boxAnimationIteration / totalLayerInFrame));
  //  float boxWidth = easeInExpo(iter, 1, width + wOffset, 1);
    
  //  int boxTickness = (int)(boxWidth/17 + baseWidthOfBorder);
  //  layers.add(new Layer(
  //    iter,
  //    boxWidth,
  //    drawBox(zoomPointX, zoomPointY, boxWidth, boxTickness, white)
  //  ));
    
  //}
  
  /// ======== assets =======
  images.add(loadImage("choibalsan.jpg"));
  images.add(loadImage("lp_avatar.png"));
  images.add(loadImage("pingu.jpg"));
}

void draw() {
  background(0);
  fft.analyze(fftSpectrum);
  
  float sum = 0;
  for(int i = 0; i < fftBands; i++){
    sum += fftSpectrum[i];
  } 
  // println(sum);
  
  /// draw stripes
  //for(int i = 0; i < totalLayerInFrame; i++) {
  //  float iter = timeLoop(boxAnimationIteration, i * (boxAnimationIteration / totalLayerInFrame));
  //  float boxWidth = easeInExpo(iter, 1, width + wOffset, 1);
    
  //  int boxTickness = (int)(boxWidth/17 + baseWidthOfBorder);
  //  drawBox(zoomPointX, zoomPointY, boxWidth, boxTickness, white);
  //}
  // image(layers.get(4), 50, 50);
  
  for(int i = 0; i < layers.size(); i++) {
    //float iter = timeLoop(boxAnimationIteration, i * (boxAnimationIteration / totalLayerInFrame));
    //float boxWidth = easeInExpo(iter, 1, width + wOffset, 1);
    
    //int boxTickness = (int)(boxWidth/17 + baseWidthOfBorder);
    //image(drawBox(zoomPointX, zoomPointY, boxWidth, boxTickness, white), 0, 0);
    image(layers.get(i).graphics, 0, 0);
    
  }
  
  /// draw graphics
  //float iter = timeLoop(boxAnimationIteration, 0 * (boxAnimationIteration / totalLayerInFrame));
  //float imgWidth = easeInOutSine(iter, 50, width * 0.5, 1);
  //if(iter > 0.5) {
  //  imgWidth = width * 0.5 - imgWidth;
  //} 
  
  //drawImage(zoomPointX, zoomPointY, imgWidth, 1);
  
  /// Final post processing
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    // TODO: impl
    //float rand = random(255);
    //color c = color(rand);
    //pixels[i] = c;
  }
  updatePixels();
}

/// Draw 9:16 ratio box
PGraphics drawBox(int x, int y, float w, int tickness, color clr) {
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.clear();
  pg.background(0, 0);
  pg.smooth(6);
  
  double h = (w / 9) * 16;
  
  int p1x = (int)(x - w/2);
  int p1y = (int)(y - h/2);
  int p2x = (int)(p1x + w);
  int p2y = p1y;
  int p3x = p2x;
  int p3y = (int)(p2y + h);
  int p4x = p1x;
  int p4y = p3y;
  
  pg.stroke(clr);
  pg.strokeWeight(tickness);
  pg.strokeCap(PROJECT);
  
  pg.line(p1x, p1y, p2x, p2y);
  pg.line(p2x, p2y, p3x, p3y);
  pg.line(p3x, p3y, p4x, p4y);
  pg.line(p4x, p4y, p1x, p1y);
  
  pg.endDraw();
  return pg;
}

/// draw image
PGraphics drawImage(int x, int y, float w, float opacity) {
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.clear();
  pg.background(0, 0);
  pg.smooth(6);
  
  float centerOffset = w/2;
  pg.image(images.get(0), zoomPointX - centerOffset, zoomPointY - centerOffset, w, w);
  
  pg.endDraw();
  return pg;
}

// frameCount based animation indicator
float timeLoop(float totalFrameOfLoop, float offset) {
  return (frameCount + offset) % totalFrameOfLoop / totalFrameOfLoop;
}

// derived from Robert Penner’s easing functions
float easeInExpo(float t,float b , float c, float d) {
  return (t==0) ? b : c * (float)Math.pow(2, 10 * (t/d - 1)) + b;
}

// derived from Robert Penner’s easing functions
float easeInCirc(float t, float b, float c, float d) {
  return -c * ((float)Math.sqrt(1 - (t/=d)*t) - 1) + b;
}

// derived from Robert Penner’s easing functions
float easeInOutSine(float t,float b , float c, float d) {
  return -c/2 * ((float)Math.cos(Math.PI*t/d) - 1) + b;
}

// derived from Robert Penner’s easing functions
float easeInOutLinear (float t,float b , float c, float d) {
  return c*t/d + b;
}
