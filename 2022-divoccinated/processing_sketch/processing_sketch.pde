import processing.sound.*;
import java.util.Collections;

AudioIn in;
FFT fft;

final color orange = color(252, 111, 3);
final color white = color(255, 255, 255);
final color blue = color(1, 64, 110);

final int totalLayerInFrame = 12;
final float baseWidthOfBorder = 0.9;
final int boxAnimationIteration = 150;
final float fftThreshold = 0.05;
final float fftThresholdMax = 0.4;

final ArrayList<PImage> images = new ArrayList<PImage>();
final ArrayList<Layer> layers = new ArrayList<Layer>();

final int fftBands = 256;
float[] fftSpectrum = new float[fftBands];

int zoomPointX = 0;
int zoomPointY = 0;
int wOffset = 0;

/// ================================================= ///
/// ================================================= ///
class Layer {
  private int id;
  private int frame = 0;
  private PGraphics graphics;
  private boolean isBox;
  
  private int imgIndex;
  private float imgVisibility;
  
  private int leftOffset = 0;
  private int topOffset = 0;
  
  Layer(int id, boolean isbox, int frameOffset) {
    this.id = id;
    this.isBox = isbox;
    this.frame += frameOffset;
    imgVisibility = 0;
    imgIndex = int(random(images.size()));
  }
  
  void reset() {
    frame = 0;
    if(isBox) {
      
    } else {
      imgVisibility = 0;
      imgIndex = int(random(images.size()));
    }
  }
  
  boolean move() {
    this.frame++;
    if(boxAnimationIteration < frame) {
      return false;
    }
    
    float iter = ((float)frame / boxAnimationIteration);
    float boxWidth = easeInExpo(iter, 1, width + wOffset, 1);
    this.topOffset = int(zoomPointY - boxWidth * 0.85);
    this.leftOffset = int(zoomPointX - boxWidth * 0.5);
  
    if(isBox) {
      int boxTickness = int(boxWidth / 12 + baseWidthOfBorder);
      this.graphics = drawBox(boxWidth, boxTickness, white,  350 * iter);
    } else {
      float a = boxAnimationIteration * 0.65;
      float b = 0;
      if(frame > a) {
         b = ((boxAnimationIteration - frame) / a) * 512 * imgVisibility;
      } else {
         b = (frame / a) * 256 * imgVisibility;
      }
      this.graphics = drawImage(imgIndex, boxWidth, b);
    }
    return true;
  }
  
  public int getLeftOffset() {
    return this.leftOffset;
  }
  
  public int getTopOffset() {
    return this.topOffset;
  }
  
  public PGraphics getGraphics() {
    return this.graphics;
  }
  
  public boolean isBox() {
    return this.isBox;
  }
  
  public void setImageVisibility(float imgVisibility) {
    this.imgVisibility = imgVisibility;
  }
}

/// ================================================= ///
/// ================================================= ///
void setup() {
  background(0);
  frameRate(26);
  smooth(0);
  
  // prod
  // fullScreen();
  // size(1080, 1920, P2D);
  // size(720, 1280, P2D);
  
  /// dev
  size(540, 980, P2D); // 1/2 of Full HD vertical
  
  /// RUNTINE
  /// ======== audio =======
  fft = new FFT(this, fftBands);
  in = new AudioIn(this, 0);
  in.start();
  fft.input(in);
  
  /// ======== assets =======
  images.add(loadImage("choibalsan.jpg"));
  images.add(loadImage("lp_avatar.png"));
  images.add(loadImage("pingu.jpg"));
  
  /// ======== positioning =======
  zoomPointX = width/2;
  zoomPointY = (int)(height * 0.7);
  wOffset = (((zoomPointY - height/2) / 9) * 16);
  
  /// ======== init layers ======= 
  float layerDiff = (float)boxAnimationIteration / totalLayerInFrame;
  for(int i = 1; i <= totalLayerInFrame; i++) {
    Layer layer;
    
    // even or odd
    if((i | 1) > i) {
      layer = new Layer(i, true, int(i * layerDiff));
    } else {
      layer = new Layer(i, false, int(i * layerDiff));
    }
    layers.add(layer);
  }
  
}

/// ================================================= ///
/// ================================================= ///
void draw() {
  background(0);
  fft.analyze(fftSpectrum);
  println(frameRate);
  // println(sum);
  
  for(int i = 0; i < layers.size(); i++) {
    Layer layer = layers.get(i);
    if(layer.move()) {
      if(layer.isBox()) {
        image(layer.getGraphics(), layer.getLeftOffset(), layer.getTopOffset());
      } else {
        float visibility = setVisibleViaNoise();
        if(visibility != 0) {
          layer.setImageVisibility(visibility);
          image(layer.getGraphics(), layer.getLeftOffset(), layer.getTopOffset());
        }
      }
    } else {
      layer.reset();
      rotateLayers();
    }
  }
  
  /// Final post processing
  //loadPixels();
  //for (int i = 0; i < pixels.length; i++) {
  //  // TODO: impl
  //  //float rand = random(255);
  //  //color c = color(rand);
  //  //pixels[i] = c;
  //}
  //updatePixels();
}

float setVisibleViaNoise() {
  float sum = 0;
  for(int i = 0; i < fftBands; i++){
    sum += fftSpectrum[i];
  }
  if(fftThreshold < sum) {
    float tmp = sum/fftThresholdMax;
    if(tmp > 1) {
      return 1;
    }
    return tmp;
  }
  return 0;
}

/// Draw 9:16 ratio box
PGraphics drawBox(float w, int tickness, color clr, float opacity) {
  //w = w/2;
  //tickness = tickness/2;
  
  int ww = (int(w) - tickness);
  int hh = (int(w * 1.7) - tickness);
  PGraphics pg = createGraphics(ww + tickness, hh + tickness);
  pg.smooth(4);
  pg.beginDraw();
  pg.background(0, 0);
  
  int p1x = tickness/2;
  int p1y = tickness/2;
  int p2x = int(p1x + ww);
  int p2y = p1y;
  int p3x = p2x;
  int p3y = int(p2y + hh);
  int p4x = p1x;
  int p4y = p3y;
  
  pg.stroke(clr, opacity);
  pg.strokeWeight(tickness);
  pg.strokeJoin(MITER);
  pg.strokeCap(PROJECT);
  pg.noFill();
  pg.beginShape();
  pg.vertex(p1x, p1y);
  pg.vertex(p2x, p2y);
  pg.vertex(p3x, p3y);
  pg.vertex(p4x, p4y);
  pg.vertex(p1x, p1y);
  pg.vertex(p2x, p2y);
  
  pg.endShape();
  pg.endDraw();
  return pg;
}

/// draw image
PGraphics drawImage(int index, float w, float visibility) {
  // w = w/2;
  
  int ww = int(w);
  int hh = int(w * 1.7);
  PGraphics pg = createGraphics(ww, hh);
  pg.smooth(60);
  pg.beginDraw();
  
  pg.tint(255, visibility);
  pg.image(images.get(index), 0, 0, ww, hh);
  
  pg.endDraw();
  return pg;
}

/// rotate layers;
void rotateLayers() {
  Collections.rotate(layers, 1);
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
