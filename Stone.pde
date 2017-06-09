// # an object that moves across the canvas
// -----------------------------------------------------
// Stone (constructor)
// * x/y position
// * tension
// * height
// * size
// -----------------------------------------------------
// move();
// * the distance it moves is based on the sling tension when released
// * tension = stone position - sling position when released
// * need to drop the tension slightly on each loop - looses momentum
//
// skip();
// * shrink the stone's size by stone_weight
// * when the size drops below 5 it resets to the height
// * when the size resets the height drops slightly
// * it does this until the height is less than 1
// -----------------------------------------------------
class Stone {

  float stone_x, stone_y;
  float tension_x, tension_y;
  float stone_size;
  float stone_weight;
  float skip_height;
  float skip_distance;

  // -----------------------------------------------------
  Stone(float _stone_x, float _stone_y, float _stone_size) {
    stone_x = _stone_x;
    stone_y = _stone_y;
    stone_size = _stone_size;
    skip_height = stone_size;
    
    // stone weight is proportional to the size of the stone
    stone_weight = (stone_size * 0.09);

    // tension is proportional to the length of the sling
    tension_x = stone_x - sling_x;
    tension_y = stone_y - sling_y;
    tension_x = tension_x/10;
    tension_y = tension_y/10;
    
    //skip_distance = (tension_x - tension_y);
    //if (skip_distance < 0) skip_distance = skip_distance *-1;

    
    
    // skip distance is proportional to the tension + the stone weight
    skip_distance = (tension_x - tension_y) - stone_weight;
    if (skip_distance < 0) skip_distance = skip_distance *-1;
    skip_distance = skip_distance / 30;
    skip_distance = map(skip_distance, 0,30, 3.0,1.0);
  } // -----------------------------------------------------


  // -----------------------------------------------------
  void move() {
    // moves strangely because of how tension is calculated
    stone_x = stone_x - tension_x;
    stone_y = stone_y - tension_y;
    
    // slow the stone down with each bounce
    // currently reverses the direction because of the move function
    //tension_x = tension_x - 0.6;
    //tension_y = tension_y - 0.6;
  } // -----------------------------------------------------


  // -----------------------------------------------------
  void skip() {
    if (stone_size > 1) { // while in the air
      stone_size = stone_size - stone_weight; // shrink the stone's size
    } else { // if it touches the water
      stone_size = skip_height; // reset the size to the height
      if (skip_height > 1) skip_height = skip_height - skip_distance;
    }
  } // -----------------------------------------------------


  // -----------------------------------------------------
  void show() {
    // this makes the stone transparent when it hits the water
    // but I want to remove the stone - not hide it
    //if ( stone_height < 2) {
    //  fill(0, 0);
    //} else {
    //  fill(50);
    //}
    
    fill(50);
    noStroke();
    ellipse(stone_x, stone_y, stone_size, stone_size); // draw the stone
  } // -----------------------------------------------------

} // -----------------------------------------------------