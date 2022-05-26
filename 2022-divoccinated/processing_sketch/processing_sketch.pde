PImage img;

final color orange = color(252, 111, 3);
final color blue = color(1, 64, 110);
final int totalLayerInFrame = 5;
final int baseWidthOfBorder = 5;
int layerDist;

void setup() {
  background(0);
  frameRate(40);
  size(540, 980, P2D); // 1/2 of Full HD vertical
  layerDist = width / totalLayerInFrame;
  
  /// ==================== ==========
  img = loadImage("choibalsan.jpg");
  smooth(3);
}

float timeLoop(float totalframes, float offset) {
  return (frameCount + offset) % totalframes / totalframes;
}


void draw() {
  background(0);
  // println(timeLoop(60,0));
  int speed = 120;
  
  for(int i = 0; i < totalLayerInFrame; i++) {
    double w = timeLoop(speed, i * (speed / totalLayerInFrame)) * (width+ 50);
    drawBox(width/2, height/2, w, (int)((w / 20) + baseWidthOfBorder));
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
void drawBox(int x, int y, double w, int tickness) {
  double h = (w / 9) * 16;
  
  int p1x = (int)(x - w/2);
  int p1y = (int)(y - h/2);
  int p2x = (int)(p1x + w);
  int p2y = p1y;
  int p3x = p2x;
  int p3y = (int)(p2y + h);
  int p4x = p1x;
  int p4y = p3y;
  
  stroke(orange);
  strokeWeight(tickness);
  strokeCap(PROJECT);
  
  line(p1x, p1y, p2x, p2y);
  line(p2x, p2y, p3x, p3y);
  line(p3x, p3y, p4x, p4y);
  line(p4x, p4y, p1x, p1y);
}
