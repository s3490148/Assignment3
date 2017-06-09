// a class to create random raindrops on the canvas
// ---------------------------------------------------------
// essentially an invisble bouncing ball that triggers 
// the Ripple class with smaller ripples than the Stone
// ---------------------------------------------------------
class Rain {

  float rain_x;
  float rain_y;
  float density;

  // ---------------------------------------------------------
  Rain() {
  } // ---------------------------------------------------------

  // ---------------------------------------------------------
  void move() {
    density = random(1,10);
    rain_x = random(0,width);
    rain_y = random(0,height);
  }
} // ---------------------------------------------------------