import processing.opengl.*;
import codeanticode.gsvideo.*;

/** This class represents the city on the canvas */
class CityMark {
  PVector loc;
  color[] palette;
  int mark_height, radius;
  float[] radiuses;
  float jitter;
  PVector[] centers;

  CityMark(PVector city_loc, color city_color, float intensity_) {
    mark_height = int(100 * intensity_);
    radius = 10;
    jitter = radius / 4;
    loc = city_loc;

    palette = new color[mark_height];
    radiuses = new float[mark_height];
    centers = new PVector[mark_height];

    float r = red(city_color);
    float g = green(city_color);
    float b = blue(city_color);

    color invis_color = color(r, g, b, 0);
    for(int ii=0; ii < mark_height; ii++) {
      palette[ii] = lerpColor(city_color, invis_color, float(ii)/mark_height);
      centers[ii] = new PVector(random(-jitter, jitter), random(-jitter, jitter));
      radiuses[ii] = random(0, radius) * float(mark_height - ii) / mark_height;
    }
  }

  void draw() {

    pushMatrix();
    translate(loc.x * width, loc.y * height, 0);

    for(int ii=0; ii < mark_height; ii++) {
      // Keep moving one pixel higher
      translate(0, 0, 1);
      fill(palette[ii]);
      stroke(palette[ii]);
    
      ellipse(
        centers[ii].x,
	centers[ii].y,
	radiuses[ii],
	radiuses[ii]);
    }

    // Move the circles a pixel above while reducing the radius, imitates a
    // firelike effect.
    for(int ii=mark_height-1; ii > 0; ii--) {
      centers[ii] = centers[ii - 1];
      radiuses[ii] = pow(mark_height - ii, 0.5) / pow(mark_height, 0.5) * radiuses[ii - 1];
    }

    // Place a random circle at the bottom
    radiuses[0] = random(0, radius);
    centers[0] = new PVector(random(-jitter, jitter), random(-jitter, jitter));

    popMatrix();
  }
}

PImage world_map_img;
PFont font;
GSMovieMaker mm;

boolean recording = false;
float angle = 0;
int fps = 30;

PVector[] cities_info = {
  new PVector(0.85625, 0.35416666),   // Ikoma, Nara, Japan
  new PVector(0.2375, 0.37083334),    // Atlanta, GA
  new PVector(0.2078125, 0.37708333), // College Station, Texas
  new PVector(0.225, 0.30833334),     // Madison, WI, US
  new PVector(0.6890625, 0.47291666), // Hyderabad
  new PVector(0.265625, 0.31875),     // Midtown Manhattan
  new PVector(0.2546875, 0.31875),    // State College,PA
  new PVector(0.1375, 0.27916667),    // Bellevue, WA
  new PVector(0.25, 0.30208334),      // Toronto
  new PVector(0.49375, 0.28333333)    // Lausanne, SW
};  

/** Calculation of cost of living/month is in USD. 
 * Formula:
 *  i. 40 home-cooked meals
 *  ii. 20 Meals taken outside
 *  iii. 5 bottles of coke
 *  iv. 2 trips via train
 *  v. Apartment rent
 */
float cost_of_living[] = {
  903.34,
  571.5,
  600,
  1107.5,
  243.00445,
  2054.5,
  705,
  1970,
  1123.325,
  1362
};
CityMark city_marks[];
	
// The maximum cost of living in a city, will be initialized on the first call
// to get_city_color
float max_cost = -1;

color red = color(255, 0, 0);
color green = color(0, 255, 0);

// Get the color of the city from the cost of living in it
color get_city_color(int city_index) {
  return lerpColor(green, red, cost_of_living[city_index] / max_cost);
}
  

void setup(){
  size(800, 480, OPENGL);
  smooth();
  frameRate(fps);
  
  // Loading the world map 
  // Taken from http://en.wikipedia.org/wiki/Wikipedia:Blank_maps
  world_map_img = loadImage("world_map_wikipedia.png");

  // Loading the font
  font = loadFont("TimesNewRomanPSMT-20.vlw");
  textAlign(CENTER);

  // Setting the font with the height (in pixels)
  textFont(font, 20);

  // Finding the maximum cost of living in a city
  for(int ii=0; ii < cost_of_living.length; ii++) {
    max_cost = (max_cost < cost_of_living[ii]) ? cost_of_living[ii] : max_cost;
  }

  // Initializing the City Markers
  city_marks = new CityMark[cities_info.length];
  for(int ii=0; ii < cities_info.length; ii++) {
    city_marks[ii] = new CityMark(
    				cities_info[ii],		// Location
				get_city_color(ii),		// Color
				cost_of_living[ii]/max_cost);	// Intensity
  }
}

// To get location of points on the map relative to the width and height chosen
// for the map.
//   Was used for finding out the location of the cities
void mousePressed() {
  println("(" + mouseX/float(width) + "," + mouseY/float(height) + ")");
}

// This is to start/stop recording the Video
void keyPressed() {
  // Learnt this trick from @blprnt, save a screen shot when 's' key is pressed.
   if (key == 's') 
    save( "screen_shots/" + 
      year() + "_" +
      month() + "_" +
      day() + "_" +
      hour() + "_" +
      minute() + "_" +
      second() + ".png"); 

  if(key == ' ' && !recording) {
    String video_file_name = "videos/" + year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second() + ".ogg";
    // Save as THEORA in a OGG file as MEDIUM quality:
    mm = new GSMovieMaker(this, width, height, video_file_name, GSMovieMaker.THEORA, GSMovieMaker.MEDIUM, fps);
    mm.start();
    recording = true;
  } else if (key == ' ' && recording) {
    mm.finish();
    exit();
  }
}
    

void draw(){
  background(0);
  angle += 0.5;
  if(angle > 360) angle = 0;

  tint(0, 153, 204, 255);
  image(world_map_img, 0, 0, width, height);
  float pos_x, pos_y;
  for(int ii = 0; ii < city_marks.length; ii++) {
    city_marks[ii].draw();
  }

  float center_x = width/2;
  float center_y = height/2;
  float center_z = 0.0;

  float eye_x = 400 * cos(angle * PI / 180) + center_x;
  float eye_y = 400 * sin(angle * PI / 180) + center_y;
  float eye_z = 200.0;
  camera(
    eye_x, eye_y, eye_z, 
    center_x, center_y, center_z, 
    0.0, 0.0, -1.0); // upX, upY, upZ

  if(recording) {
    loadPixels();
    mm.addFrame(pixels);
  }

  println(frameRate);
}

