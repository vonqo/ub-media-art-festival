PImage img;

final color orange = color(252, 111, 3);
final color white = color(255, 255, 255);
final color blue = color(1, 64, 110);
final int totalLayerInFrame = 5;
final int baseWidthOfBorder = 1;
final int boxAnimationIteration = 150;

void setup() {
  background(0);
  frameRate(30);
  size(540, 980, P2D); // 1/2 of Full HD vertical
  
  /// ==================== ==========
  img = loadImage("choibalsan.jpg");
  smooth(3);
}

void draw() {
  background(0);
  
  
  for(int i = 0; i < totalLayerInFrame; i++) {
    float iter = timeLoop(boxAnimationIteration, i * (boxAnimationIteration / totalLayerInFrame));
    float boxWidth = easeInCirc(iter, 1, width + 500, 1);
    int boxTickness = (int)(boxWidth / 17) + baseWidthOfBorder;
    
    drawBox(width/2, (int)(height - height/3.5), boxWidth, boxTickness);
  }
  
  //drawBox(width/2, height/2, width/3, 4);
  //image(img, 0, 0);
  //drawBox(width/2, height/2, width/4, 2);
  
  /// Final post processing
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    
    //float rand = random(255);
    //color c = color(rand);
    //pixels[i] = c;
    
  }
  updatePixels();
}

/// draw 9:16 ratio box
void drawBox(int x, int y, float w, int tickness) {
  double h = (w / 9) * 16;
  
  int p1x = (int)(x - w/2);
  int p1y = (int)(y - h/2);
  int p2x = (int)(p1x + w);
  int p2y = p1y;
  int p3x = p2x;
  int p3y = (int)(p2y + h);
  int p4x = p1x;
  int p4y = p3y;
  
  stroke(white);
  strokeWeight(tickness);
  strokeCap(PROJECT);
  
  line(p1x, p1y, p2x, p2y);
  line(p2x, p2y, p3x, p3y);
  line(p3x, p3y, p4x, p4y);
  line(p4x, p4y, p1x, p1y);
}

// frameCount based animation indicator
float timeLoop(float totalFrameOfLoop, float offset) {
  return (frameCount + offset) % totalFrameOfLoop / totalFrameOfLoop;
}

// derived from Robert Penner’s easing functions
float easeInCirc(float t, float b, float c, float d) {
  return -c * ((float)Math.sqrt(1 - (t/=d)*t) - 1) + b;
}

/// based on a quintic equation where `f(t) = t⁵`
float easeInQuint(float t) {
  return t * t * t * t * t;
}

/// based on a quartic equation where `f(t) = t⁴`
float easeInQuart(float t) {
  return t * t * t * t;
}
