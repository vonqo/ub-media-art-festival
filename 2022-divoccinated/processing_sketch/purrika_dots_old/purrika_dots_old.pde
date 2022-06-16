/**
 * Purrka Dots.
 * Draw image with color dot.
 * run : processing-java --force --sketch=/path/to/PurrkaDots/ --run "image path"
 * 
 * @author @deconbatch
 * @version 0.4
 * created 0.1 2017.10.22
 * updated 0.2 2017.10.28 Many micro dots + little giant dots, no middle dots
 * updated 0.3 2018.12.23
 * updated 0.4 2019.03.21 rewrote whole codes with same concept, less dots, use edge detection
 * updated 0.5 2022.06.06 (vonqo edit) frame saving with transparent background
 * 
 * Processing 4.0
 * 2022.06.06
 */

import java.util.Random;
final String fileName = "img/ajliindaraa.png";
final String outputName = "frame/ajliindaraa.png";
PGraphics pg;

void setup() {

  size(1080, 1080);
  colorMode(HSB, 360, 100, 100, 100);
  smooth();
  noStroke();
  noLoop();
  pg = createGraphics(width, height);
  
}

void draw() {
  pg.smooth();
  pg.beginDraw();
  pg.noStroke();
  pg.colorMode(HSB, 360, 100, 100, 100);
  
  int caseWidth  = 150;
  int baseCanvas = width - caseWidth * 2;

  // I brought dots pattern parameters in class.
  DotsParams bp = new BackgroundParams();
  DotsParams sp = new SpotParams();
  DotsParams ep = new EdgeParams();
  DotsParams dp = new DetailParams();
  
  ImageLoader imgLoader = new ImageLoader(baseCanvas);
  PImage img = imgLoader.load();

  // edge detection
  int edgeAry[][] = detectEdge(img);
  
  pg.background(0.0, 0.0);
  // background(0.0, 0.0, 90.0, 100.0);
  pg.translate((width - img.width) / 2, (height - img.height) / 2);

  // draw dots pattern
  putDots(bp, img, edgeAry);
  putDots(sp, img, edgeAry);
  putDots(ep, img, edgeAry);
  putDots(dp, img, edgeAry);
  
  pg.endDraw();
  
  pg.save(outputName);
  // saveFrame("frames/0001.png");
  exit();

}

/**
 * putDots : draw dots.
 * @param  _dp       : dots pattern parameters class.
 * @param  _img      : origimal photo image.
 * @param  _edge     : detented edge information.
 */
private void putDots(DotsParams _dp, PImage _img, int[][] _edge) {

  int   drawCntMax = _dp.drawCntMax();
  int   idxDiv     = _dp.initDiv();
  float baseSiz    = _dp.baseSize();

  Utils ut = new Utils();

  for (int drawCnt = 1; drawCnt < drawCntMax; ++drawCnt) {

    float prmSat = map(drawCnt, 1, drawCntMax, 1.0, 0.4);
    float prmAlp = map(drawCnt, 1, drawCntMax, 1.0, 0.0);
    
    for (int idxH = 0; idxH < _img.height; idxH += idxDiv) {
      for (float idxW = 0; idxW < _img.width; idxW += idxDiv) {
      
        float brushAlp = ut.gaussdist(50.0, 30.0, 20.0) * prmAlp;
        float brushSiz = baseSiz * (0.5 + ut.gaussdist(0.5, 0.5, 0.2));

        int pointW = constrain(round(idxW + ut.gaussdist(0.0, idxDiv * 0.6, idxDiv * 0.3)), 0, _img.width - 1);
        int pointH = constrain(round(idxH + ut.gaussdist(0.0, idxDiv * 0.6, idxDiv * 0.3)), 0, _img.height - 1);

        if (_dp.isTarget(_edge, pointW, pointH)) {
          color cPoint = _img.pixels[pointH * _img.width + pointW];
          pg.fill(hue(cPoint), saturation(cPoint), brightness(cPoint), brushAlp);
          pg.ellipse(pointW, pointH, brushSiz, brushSiz);
        }   

      }
    }
  }
}

/* ---------------------------------------------------------------------- */
/**
 * Utils : utility methods
 */
private class Utils {

  Random rnd;

  Utils() {
    rnd = new Random();
  }

  /**
   * gaussdist : returns Gaussian distributed random.
   * @param  _mean      : mean value of Gaussian distribution
   * @param  _limit     : max value of abs(deviation)
   * @param  _deviation : standard deviation of Gaussian distribution
   * @return float      : _mean - _limit < Gaussian distributed random < _mean + _limit
   */
  private float gaussdist(float _mean, float _limit, float _deviation) {
    if (_limit == 0) {
      return _mean;
    }

    float gauss = (float) rnd.nextGaussian() * _deviation;
    // not good idea
    if (abs(gauss) > _limit) {
      gauss = pow(_limit, 2) / gauss;
    }
    return _mean + gauss;

  }
}

/**
 * detectEdge : detect edge of photo image.
 * @param  _img      : detect edge of thid image.
 * @return int[x][y] : 2 dimmension array. it holds 0 or 1, 1 = edge
 */
private int[][] detectEdge(PImage _img) {

  int edgeAry[][] = new int[_img.width][_img.height];
  for (int idxW = 0; idxW < _img.width; ++idxW) {  
    for (int idxH = 0; idxH < _img.height; ++idxH) {
      edgeAry[idxW][idxH] = 0;
    }
  }
    
  _img.loadPixels();
  for (int idxW = 1; idxW < _img.width - 1; ++idxW) {  
    for (int idxH = 1; idxH < _img.height - 1; ++idxH) {

      int pixIndex = idxH * _img.width + idxW;

      // saturation difference
      float satCenter = saturation(_img.pixels[pixIndex]);
      float satNorth  = saturation(_img.pixels[pixIndex - _img.width]);
      float satWest   = saturation(_img.pixels[pixIndex - 1]);
      float satEast   = saturation(_img.pixels[pixIndex + 1]);
      float satSouth  = saturation(_img.pixels[pixIndex + _img.width]);
      float lapSat = pow(
                         - satCenter * 4.0
                         + satNorth
                         + satWest
                         + satSouth
                         + satEast
                         , 2);

      // brightness difference
      float briCenter = brightness(_img.pixels[pixIndex]);
      float briNorth  = brightness(_img.pixels[pixIndex - _img.width]);
      float briWest   = brightness(_img.pixels[pixIndex - 1]);
      float briEast   = brightness(_img.pixels[pixIndex + 1]);
      float briSouth  = brightness(_img.pixels[pixIndex + _img.width]);
      float lapBri = pow(
                         - briCenter * 4.0
                         + briNorth
                         + briWest
                         + briSouth
                         + briEast
                         , 2);

      // hue difference
      float hueCenter = hue(_img.pixels[pixIndex]);
      float hueNorth  = hue(_img.pixels[pixIndex - _img.width]);
      float hueWest   = hue(_img.pixels[pixIndex - 1]);
      float hueEast   = hue(_img.pixels[pixIndex + 1]);
      float hueSouth  = hue(_img.pixels[pixIndex + _img.width]);
      float lapHue = pow(
                         - hueCenter * 4.0
                         + hueNorth
                         + hueWest
                         + hueSouth
                         + hueEast
                         , 2);

      // bright and saturation difference
      if (
          brightness(_img.pixels[pixIndex]) > 30.0
          && lapSat > 20.0
          ) edgeAry[idxW][idxH] = 1;

      // bright and some saturation and hue difference
      if (
          brightness(_img.pixels[pixIndex]) > 30.0
          && saturation(_img.pixels[pixIndex]) > 10.0
          && lapHue > 100.0
          ) edgeAry[idxW][idxH] = 1;

      // just brightness difference
      if (lapBri > 100.0) edgeAry[idxW][idxH] = 1;

    }
  }

  return edgeAry;
}

/**
 * DotsParams : holding dots pattern parameters.
 */
interface DotsParams {

  /**
   * isTarget : is this point(x, y) drawing target?
   * @return true : draw target
   */
  Boolean isTarget(int _points[][], int _x, int _y);

  /**
   * just returns parameter value
   */
  int   drawCntMax();
  int   initDiv();
  float baseSize();

}

public class BackgroundParams implements DotsParams {
  
  public Boolean isTarget(int _points[][], int _x, int _y) {
    // every point
    return true;
  }

  public int drawCntMax() {
    return 3;
  }
  public int initDiv() {
    return 500;
  }
  public float baseSize() {
    return 150;
  }

}

public class EdgeParams implements DotsParams {

  public Boolean isTarget(int _points[][], int _x, int _y) {
    // only edge is target
    if (_points[_x][_y] == 1) {
      return true;
    }
    return false;
  }

  public int drawCntMax() {
    return 10;
  }
  public int initDiv() {
    return 20;
  }
  public float baseSize() {
    return 30;
  }
  
}

public class SpotParams extends EdgeParams {

  public int drawCntMax() {
    return 5;
  }
  public int initDiv() {
    return 100;
  }
  public float baseSize() {
    return 60;
  }
  
}

public class DetailParams extends EdgeParams {

  public int drawCntMax() {
    return 20;
  }
  public int initDiv() {
    return 4;
  }
  public float baseSize() {
    return 2;
  }
  
}

/**
 * ImageLoader : load and resize image
 */
public class ImageLoader {

  PImage imgInit;
  String imgPass;

  ImageLoader(int baseCanvas) {

    if (args == null) {
      // you can use your photo in ./data/your_image.jpg
      imgPass = fileName;
    } else {
      // args[0] must be image path
      imgPass = args[0];
    }    
    imgInit = loadImage(imgPass);

    float rateSize = baseCanvas * 1.0 / max(imgInit.width, imgInit.height);
    imgInit.resize(floor(imgInit.width * rateSize), floor(imgInit.height * rateSize));

    println(int(imgInit.width)); // Image width
    println(int(imgInit.height)); // Image height

  }

  /**
   * load : return loaded image
   */
  public PImage load() {
    return imgInit;
  }

}

/*
Copyright (C) 2019- deconbatch

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
