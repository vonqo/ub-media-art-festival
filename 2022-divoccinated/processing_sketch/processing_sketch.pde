// The Loop v1.0
// @author @vonqo
// @version 0.2
// Processing 4.0b8

import processing.sound.*;
//import processing.video.*;
import java.util.Collections;

//Capture cam;
AudioIn in;
FFT fft;

/// Candiate colors
final color orange = color(252, 111, 3);
final color white = color(255, 255, 255);
final color blue = color(47, 164, 255);
final color tanagerTurquose = color(149, 219, 229); // #0782E5
final color tealBlue = color(7, 130, 130);
final color navy = color(14, 24, 95);
final color charcoal = color(16, 24, 32);
final color yellow = color(254, 231, 21);
final color midnightBlue = color(30, 31, 38);
final color midnightGrey = color(72, 73, 82);
final color periwinkle = color(208, 225, 249);
final color conquelicot = color(254, 68, 21); // #FE4415

/// Constants
final color bgColor = midnightBlue;
final color borderColor = midnightGrey;
final color tintColor = yellow;

final int totalLayerInFrame = 12;
final float baseWidthOfBorder = 0.9;
final int boxAnimationIteration = 250;
//final float fftThreshold = 0.01;
//final float fftThresholdMax = 1;

final float fftThreshold = 5;
final float fftThresholdMax = 20;

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
  private PImage image;
  private boolean isBox;
  
  private color clr;
  private int imgIndex;
  private float imgVisibility;
  
  private int leftOffset = 0;
  private int topOffset = 0;
  private float ww = 0;
  
  Layer(int id, boolean isbox, int frameOffset) {
    this.id = id;
    this.isBox = isbox;
    this.frame += frameOffset;
    imgVisibility = 0;
    if(isbox) {
      // this.clr = colorPool[int(random(colorPool.length))];
    } else {
      this.imgIndex = int(random(images.size()));
      this.image = images.get(this.imgIndex);
    }
  }
  
  void reset() {
    frame = 0;
    if(isBox) {
      // this.clr = colorPool[int(random(colorPool.length))];
    } else {
      this.imgVisibility = 0; 
      this.imgIndex = int(random(images.size()));
      this.image = images.get(this.imgIndex);
    }
  }
  
  boolean move() {
    this.frame++;
    if(boxAnimationIteration < frame) {
      return false;
    }
    
    float iter = ((float)frame / boxAnimationIteration);
    this.ww = easeInExpo(iter, 1, width + wOffset, 1);
    this.topOffset = int(zoomPointY - this.ww * 0.85);
    this.leftOffset = int(zoomPointX - this.ww * 0.5);
  
    if(isBox) {
      int boxTickness = int(this.ww / 18 + baseWidthOfBorder);
      this.graphics = drawBox(this.ww, boxTickness, borderColor,  350 * iter);
    } 
    return true;
  }
  
  public void showImage(float w) {
    //if (cam.available()) {
    //  cam.read();
    //  image(cam, this.leftOffset, this.topOffset, w, w * 1.7);
    //} else {
    //  // image(this.image, this.leftOffset, this.topOffset, w, w * 1.7);
    //}
    // image(cam, this.leftOffset, this.topOffset, w, w * 1.7);
    
     image(this.image, this.leftOffset, this.topOffset, w, w * 1.7);
  }
  
  public float getWidth() {
    return this.ww;
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
  
  public int getFrame() {
    return this.frame;
  }
  
  public color getColor() {
    return this.clr;
  }
}

/// ================================================= ///
/// ================================================= ///
void setup() {
  background(bgColor);
  frameRate(26);
  smooth(0);
  
  // prod
  // fullScreen();
  // size(1080, 1920, P2D);
  // size(720, 1280, P2D);
  
  /// dev
  size(540, 980, P2D); // 1/2 of Full HD vertical
  // size(360, 640, P2D);
  
  /// RUNTINE
  /// ======== audio =======
  fft = new FFT(this, fftBands);
  in = new AudioIn(this, 0);
  in.start();
  fft.input(in);
  
  /// ======== assets =======
  images.add(loadImage("images/1.png"));
  images.add(loadImage("images/2.png"));
  images.add(loadImage("images/3.png"));
  images.add(loadImage("images/4.png"));
  images.add(loadImage("images/5.png"));
  images.add(loadImage("images/6.png"));
  images.add(loadImage("images/7.png"));
  images.add(loadImage("images/8.png"));
  images.add(loadImage("images/9.png"));
  images.add(loadImage("images/10.png"));
  images.add(loadImage("images/11.png"));
  images.add(loadImage("images/12.png"));
  
  /// ======== camera =======
  //String[] cameras = Capture.list();
  //cam = new Capture(this, cameras[0]);
  //cam.start();  
  
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

// Not to be reproduced
/// ================================================= ///
/// ================================================= ///
void draw() {
  background(bgColor);
  fft.analyze(fftSpectrum);
  //println(frameRate);
  
  for(int i = 0; i < layers.size(); i++) {
    Layer layer = layers.get(i);
    
    if(layer.move()) {
      if(layer.isBox()) {
        tint(255,255);
        image(layer.getGraphics(), layer.getLeftOffset(), layer.getTopOffset());
      } else {
        float visibility = setVisibleViaNoise();
        if(visibility != 0) {
          
          float a = boxAnimationIteration * 0.88;
          float b = 0;
          int imgFrame = layer.getFrame();
          if(imgFrame > a) {
             b = ((boxAnimationIteration - imgFrame) / a) * 2024 * visibility;
          } else {
             b = (imgFrame / a) * 256 * visibility;
          }
          
          // tint(layer.getColor(), b);
          tint(tintColor, b);
          layer.showImage(layer.getWidth());
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
  return 1f;
  
  //float sum = 0;
  //for(int i = 0; i < fftBands; i++){
  //  sum += fftSpectrum[i];
  //}
  
  //println(sum);
  
  //if(fftThreshold < sum) {
  //  float tmp = sum/fftThresholdMax;
  //  if(tmp > 1) {
  //    return 1;
  //  }
  //  return tmp;
  //}
  //return 0;
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
  pg.background(0,0);
  
  pg.tint(255, visibility);
  pg.image(images.get(index), 0, 0, ww, hh);
  
  pg.endDraw();
  return pg;
}

PImage getImage(int index, float w, float visibility) {
  return images.get(index);
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


/*
Copyright (C) 2022 - vonqo

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
*/
