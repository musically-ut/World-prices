
// Learnt this trick from @blprnt, save a screen shot whenever 's' key is pressed.
void keyPressed() { 
  if (key == 's') save( "screen_shots/" + hour() + "_" + minute() + "_" + second() + ".png"); 
}

PImage world_map_img;
PFont font;

int angle = 0;

// Fixing the size of the map here
int width = 800, height = 480;
float pi = 3.14159;

/** Calculation of cost of living/month in USD: 
 *  i. 40 home-cooked meals
 *  ii. 20 Meals taken outside
 *  iii. 5 bottles of coke
 *  iv. 2 trips via train
 *  v. Apartment rent
 */

int INDEX = 0, X_POS = 1, Y_POS = 2;

float cities_info[][] = {
  // City index, relative x, relative y
  {0, 0.85625, 0.35416666},	// Ikoma, Nara, Japan
  {1, 0.2375, 0.37083334},	// Atlanta, GA
  {2, 0.2078125, 0.37708333},	// College Station, Texas
  {3, 0.225, 0.30833334},	// Madison, WI, US
  {4, 0.6890625, 0.47291666},   // Hyderabad
  {5, 0.265625, 0.31875},	// Midtown Manhattan
  {6, 0.2546875, 0.31875},	// State College,PA
  {7, 0.1375, 0.27916667},	// Bellevue, WA
  {8, 0.25, 0.30208334},	// Toronto
  {9, 0.49375, 0.28333333}	// Lausanne, SW
};

// The indexes are as described in cities_info
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

// The maximum cost of living in a city, will be initialized on the first call
// to get_city_color
float max_cost = -1;

// Get the color of the city from the cost of living in it
color get_city_color(int city_index) {
  if(max_cost == -1) {
    for(int ii=0; ii < cost_of_living.length; ii++) {
      max_cost = (max_cost < cost_of_living[ii]) ? cost_of_living[ii] : max_cost;
    }
  }
  
  int r = int(255 * (cost_of_living[city_index] / max_cost));
  int g = int(255 * (1 - cost_of_living[city_index] / max_cost));
  int b = 100;
  int a = 255;
  return color(r, g, b, a);
}
  

void setup(){
  size(width, height, P3D);
  frameRate(30);

  // Loading the world map 
  // Taken from http://en.wikipedia.org/wiki/Wikipedia:Blank_maps
  world_map_img = loadImage("world_map_wikipedia.png");

  // Loading the font
  font = loadFont("TimesNewRomanPSMT-20.vlw");
  textAlign(CENTER);

  // Setting the font with the height (in pixels)
  textFont(font, 20);
}

// To get location of points on the map relative to the width and height chosen
// for the map.
void mousePressed() {
  println("(" + mouseX/float(width) + "," + mouseY/float(height) + ")");
}

void draw(){
  background(0);
  smooth();
  // Change height of the camera with mouseY
  angle += 1;
  angle %= 360;

  tint(0, 153, 204, 255);
  image(world_map_img, 0, 0, width, height);
  float pos_x, pos_y;
  // smooth();
  for(int ii = 0; ii < cities_info.length; ii++) {
    // Set both the fill color as well as the stroke color
    fill(get_city_color(int(cities_info[ii][INDEX])));
    stroke(get_city_color(int(cities_info[ii][INDEX])));

    pos_x = cities_info[ii][X_POS] * width;
    pos_y = cities_info[ii][Y_POS]* height;
    pushMatrix();
    translate(pos_x, pos_y, 0);
    ellipse(0, 0, 10, 10);
    // text(char(int('0') + int(cities_info[ii][INDEX])), 0, 0);    
    popMatrix();
    }
  camera(
    width * cos(angle * pi / 180.0), height * sin(angle * pi / 180), 500.0, // eyeX, eyeY, eyeZ
    width/2, height/2, 0.0, // centerX, centerY, centerZ
    0.0, 1.0, 0.0); // upX, upY, upZ

}
