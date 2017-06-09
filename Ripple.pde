// # creates the visuals of a stone dropping in water
// ---------------------------------------------------------
// when a ripple is created give it:
// * x/y position
// * stone_height
// ---------------------------------------------------------
// the draw_ripples() loop is called in the parent class
// it cycles through each instance of the ripple and:
// - increases the size
// - decreases the alpha
// - stone height = number of rings
// ---------------------------------------------------------
// - stone size will effect the number of rings
// - stone size will also effect the size of ripples
// - add a map where stone_size changes fade_rate
// ---------------------------------------------------------
class Ripple {

  float ripple_x;
  float ripple_y;
  float size = 1;
  float ring_count;
  float alpha = 255;
  float grow_rate = 0.6;
  float fade_rate = 2.5;


  // ---------------------------------------------------------
  Ripple (float _ripple_x, float _ripple_y, float _stone_height) {
    ripple_x = _ripple_x;
    ripple_y = _ripple_y;
    ring_count = map(_stone_height, 0, 25, 1,7);
  } // CONSTRUCTOR ---------------------------------------------


  // ---------------------------------------------------------
  void make() {
    noFill();
    strokeWeight(1);

    size = size + grow_rate; // grow the ripples
    alpha = alpha - fade_rate; // fade the ripples

    for (int i=1; i<ring_count; i++) { // draw the ripple cluster
      stroke(255, alpha * (i * 0.2) ); // fade each ring individually
      ellipse(ripple_x, ripple_y, size*i, size*i); // draw each ring
    }
  } // ---------------------------------------------------------
  
  
  // ---------------------------------------------------------
  float get_alpha(){
   return alpha;
  } // ---------------------------------------------------------
  
} // CLASS ---------------------------------------------------