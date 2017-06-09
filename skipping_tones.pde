// Skipping_Tones - a generative musical instrument
// -----------------------------------------------------
// * click and drag the mouse to throw a stone
// * edit the sound from the 'controls' pannel
// -----------------------------------------------------

import beads.*; // audio library
import controlP5.*; // gui library

// ---------- declare gui
ControlP5 gui; // Class instance;

// ---------- declare stones
ArrayList<Stone> stones; // list of active skipping stones
float stone_x, stone_y; // stone's location - pass to class when mouse released
float sling_x, sling_y; // how far the sling has been pulled while mousePressed
float stone_size;

// ---------- declare ripples
ArrayList<Ripple> ripples; // list of active ripples

// ---------- declare tones
ArrayList<Tone> tones;
float freq;
float volume;
float max_volume;
float decay; // sets the maximum scale value
float tone_decay; // the actual value sent to the class
float pan;

boolean quantise_b; // true = apply custom scale to frequency
boolean scale_b; // true = draw the scale to screen
float pitches[] = new float[7]; // a collection of frequency values
int pitch; // from 0-6 - scans the pitches array
float frequency; // the value sent to the class
float octave; // number to multiply frequency by

// ---------- declare rain
Rain rain; // Class instance;
float density; // how much time between droplets?
boolean rain_drop; // rain, or no rain?
boolean rain_sound; // do rain drops make a sound?
float rain_decay; // how long do the sounds last?
float rain_volume;

// -----------------------------------------------------
void setup() {
  size(600, 600, P2D);
  surface.setTitle("Skipping Tones");
  
  PImage icon = loadImage("icon.png");
  surface.setIcon(icon);

  // ----- define gui
  gui = new ControlP5(this); // (this) = parent class
  setup_gui(); // draws the controls to screen

  // ---------- define stones
  stones = new ArrayList<Stone>();
  stone_size = 25; // can change this with a slider in the GUI

  // ---------- define ripples
  ripples = new ArrayList<Ripple>();

  // ---------- define tones
  max_volume = 0.3;
  scale_b = false;
  tones = new ArrayList<Tone>();
  define_scale();

  // ---------- define rain
  rain = new Rain();
  density = 1;
  rain_drop = false;
  rain_sound = false;
  rain_decay = 1000;
} // -----------------------------------------------------


// -----------------------------------------------------
void draw() {
  background(150, 200, 250);

  draw_sling(); // from mouse pressed location, to current mouse location
  skip_stone(); // move, resize, and display stone, make tone and ripples
  update_ripples(); // grow and fade each ripple cluster, remove old tones
  update_tones(); // remove old tones
  rain_maker(); // move rain location, trigger ripple
  draw_scale(); // draw the scale lines on screen
} // -----------------------------------------------------


// -----------------------------------------------------
void mousePressed() {
  // while the mouse is held - fix the stone in place
  if (gui.isMouseOver() == false) {
    stone_x = mouseX;
    stone_y = mouseY;
  }
} // -----------------------------------------------------


// -----------------------------------------------------
void mouseReleased() {
  // add a new stone to the array
  if (gui.isMouseOver() == false) {
    stones.add( new Stone(stone_x, stone_y, stone_size) );
  }
} // -----------------------------------------------------


// -----------------------------------------------------
void draw_sling() {
  if (gui.isMouseOver() == false) { // if gui switch is on

    // if mouse is pressed - fix the stone and draw the sling
    // otherwise - draw the stone at current mouse position
    if (mousePressed == true) {
      sling_x = mouseX;
      sling_y = mouseY;

      fill(100); // draw the fixed stone
      noStroke();
      ellipse(stone_x, stone_y, stone_size, stone_size);

      strokeWeight(5); // draw the sling
      stroke(250, 200, 0);
      line(stone_x, stone_y, sling_x, sling_y);
    } else {

      fill(150); // draw the new stone
      noStroke();
      ellipse(mouseX, mouseY, stone_size, stone_size);
    }
  }
} // -----------------------------------------------------


// -----------------------------------------------------
void skip_stone() {
  for (int i=0; i<stones.size(); i++) { // for every stone thrown
    Stone stone = stones.get(i);

    stone.move(); // move stone across the canvas
    stone.skip(); // change stones size and height
    stone.show(); // display the stone

    set_tone(stone); // update tone properties depending on stone location

    // if the stone touches the water - make a ripple + tone
    if (stone.stone_size <= 1) {
      ripples.add( new Ripple(stone.stone_x, stone.stone_y, stone.skip_height) );

      tones.add( new Tone() ); // add a new instance to the tones array
      Tone tone = tones.get( tones.size() -1 );
      tone.trigger(frequency, volume, tone_decay, pan); // trigger the last tone made
    }

    // if the stone goes off screen - delete it
    if (stone.stone_x < 0 || stone.stone_x > width || stone.stone_y < 0 || stone.stone_x > height) stones.remove(i);

    // if the stone loses momentum - delete it
    // by leaving this till the end - one last ripple is made as the stone sinks
    if (stone.skip_height <= 1) stones.remove(i); // remove the stone
  }
} // -----------------------------------------------------


// -----------------------------------------------------
void set_tone(Stone stone) {
  // update tone properties depending on stone location
  // quantisation can be turned on mid-skip

  if (quantise_b == true) { 
    // map tone frequency to custom scale
    pitch = (int)map(stone.stone_y, height, 0, 0, 7); 
    pitch = constrain(pitch, 0, 6);
    frequency = pitches[pitch];
  } else {
    // map tone frequency to stone location
    frequency = map(stone.stone_y, height, 0, 65.40, 123.47);
    frequency = frequency * octave /2;
  }

  volume = map(stone.skip_height, 0, stone_size, 0.0, max_volume); // vol = stone height ~ volume
  tone_decay = map(stone.skip_height, 0, stone_size, 0, decay); // decay = stone height ~ decay time
  pan = map(stone.stone_x, 0, width, -1.0, 1.0); // pan = stone x_position
} // -----------------------------------------------------


// -----------------------------------------------------
void update_ripples() { // for each current ripple
  for (int i=0; i<ripples.size(); i++) {
    Ripple ripple = ripples.get(i);
    ripple.make(); // draw the ripples to screen
    if (ripple.alpha < 1) ripples.remove(i); // remove old ripples
  }
} // -----------------------------------------------------


// -----------------------------------------------------
void update_tones() { // for each current tone
  for (int i=0; i<tones.size(); i++) {
    Tone tone = tones.get(i);
    // if tone has gone quiet - delete it
    if (tone.tone_vol.getCurrentValue() < 0.01) tones.remove(i);
  }
} // -----------------------------------------------------


// -----------------------------------------------------
void rain_maker() {
  if (rain_drop == true) { // if gui switch is on
    rain.move();
    if (frameCount % 50 < density) {
      ripples.add( new Ripple(rain.rain_x, rain.rain_y, rain.density) );
    }
  }

  if (rain_sound == true) {
    if (random(1, density) < density * 0.3) {

      tones.add( new Tone() );
      Tone tone = tones.get( tones.size() -1 );

      if (quantise_b == true) { 
        // map rain frequency to custom scale
        pitch = (int)map(rain.rain_y, height, 0, 0, 7);
        pitch = constrain(pitch, 0, 6);
        frequency = pitches[pitch] * 4;
      } else { 
        // map rain frequency to location on screen
        frequency = map(rain.rain_y, height, 0, 65.40, 123.47);
        frequency = frequency * octave * 2;
      }

      pan = map(rain.rain_x, 0, width, -1.0, 1.0); // pan = x_position
      tone.trigger(frequency, rain_volume, rain_decay, pan); // trigger the tone
    }
  }
} // -----------------------------------------------------



// -----------------------------------------------------
void draw_scale() {
  if (scale_b == true) { // if gui switch is on
    int scale_line = height/7;
    for (int i=6; i > 0; i--) {
      fill(255, 150);
      stroke(255, 150);
      strokeWeight(1);
      text( (pitches[i] * octave), (width - 40), scale_line - 5);
      line(0, scale_line, width, scale_line);
      scale_line = scale_line + height/7;
    }
  }
} // -----------------------------------------------------

// -----------------------------------------------------
void define_scale() {
  pitches[0] = 65.40; // C-2
  pitches[1] = 73.41; // D-2
  pitches[2] = 82.40; // E-2
  pitches[3] = 87.30; // F-2
  pitches[4] = 97.99; // G-2
  pitches[5] = 110.00; // A-2
  pitches[6] = 123.47; // B-2

  for (int i=0; i<7; i++) {
    pitches[i] = pitches[i] * octave /2;
  }
} // -----------------------------------------------------



// -----------------------------------------------------
void setup_gui() {

  // group is a Class of ControlP5 - like setup for the GUI
  Group skipping_tones = gui.addGroup("Controls")
    // Class instance = gui.addGroup("title")
    .setPosition(15, 20)
    .setBackgroundHeight(350)
    .setWidth(200)
    .setBackgroundColor(color(255, 50));


  // ----- STONE
  Textlabel stone_label;
  stone_label = gui.addTextlabel("stone_label")
    .setText("Stone:")
    .setPosition(15, 20)
    .setColorValue(000000)
    .setGroup(skipping_tones);

  // ----- STONE SIZE
  gui.addSlider("stone_size")
    .setPosition(20, 40)
    .setRange(10, 40)
    .setValue(25)
    .setColorBackground(color(50, 50, 100))
    .setGroup(skipping_tones);

  // ----- TONE
  Textlabel tone_label;
  tone_label = gui.addTextlabel("tone_label")
    .setText("Tone:")
    .setPosition(15, 65)
    .setColorValue(000000)
    .setGroup(skipping_tones);

  // ----- VOLUME
  gui.addSlider("max_volume")
    .setPosition(20, 85)
    .setRange(0.0, 0.3)
    .setValue(0.3)
    .setColorBackground(color(50, 50, 100))
    .setGroup(skipping_tones); // close this section by relating it back to the group

  // ----- DECAY
  gui.addSlider("decay")
    .setPosition(20, 105)
    .setRange(50.0, 2000.0)
    .setSize(100, 10)
    .setValue(tone_decay)
    .setColorBackground(color(50, 50, 100))
    .setGroup(skipping_tones);

  // ----- OCTAVE
  gui.addSlider("set_octave")
    .setRange(1, 5)
    .setValue(3)
    .setPosition(20, 125)
    .setSize(100, 10)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .setGroup(skipping_tones);

  // ----- SHOW SCALE
  gui.addToggle("show_scale")
    .setPosition(20, 150)
    .setSize(40, 10)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setGroup(skipping_tones);

  // ----- QUANTISE
  gui.addToggle("quantise")
    .setPosition(80, 150)
    .setSize(40, 10)
    .setGroup(skipping_tones);


  // ----- RAIN
  Textlabel rain_label;
  rain_label = gui.addTextlabel("rain_label")
    .setText("Rain:")
    .setPosition(15, 190)
    .setColorValue(000000)
    .setGroup(skipping_tones);

  // ----- VOLUME
  gui.addSlider("rain_volume")
    .setPosition(20, 210)
    .setRange(0.0, 0.5)
    .setValue(0.2)
    .setColorBackground(color(50, 50, 100))
    .setGroup(skipping_tones);

  // ----- DENSITY
  gui.addSlider("density")
    .setPosition(20, 250)
    .setRange(1, 10)
    .setValue(1)
    .setColorBackground(color(50, 50, 100))
    .setGroup(skipping_tones);

  // ----- DECAY
  gui.addSlider("rain_decay")
    .setPosition(20, 230)
    .setRange(1, 1000)
    .setValue(10)
    .setColorBackground(color(50, 50, 100))
    .setGroup(skipping_tones);

  // ----- DROP
  gui.addToggle("drop")
    .setPosition(20, 270)
    .setSize(40, 10)
    .setGroup(skipping_tones);

  // ----- SOUND
  gui.addToggle("sound")
    .setPosition(80, 270)
    .setSize(40, 10)
    .setGroup(skipping_tones);
} // GUI ----------------------------------------------


// -----------------------------------------------------
void show_scale(boolean show_scale_b) {
  if (show_scale_b == true) {
    scale_b = true;
  } else {
    scale_b = false;
  }
} // -----------------------------------------------------

// -----------------------------------------------------
void quantise(boolean _quantise) {
  if (_quantise == true) {
    quantise_b = true;
  } else {
    quantise_b = false;
  }
} // -----------------------------------------------------

// -----------------------------------------------------
void set_octave(int _octave) {
  octave = _octave;
  define_scale();
} // -----------------------------------------------------

// -----------------------------------------------------
void drop(boolean _drop) {
  if (_drop == true) {
    rain_drop = true;
  } else {
    rain_drop = false;
  }
} // -----------------------------------------------------

// -----------------------------------------------------
void sound(boolean _sound) {
  if (_sound == true) {
    rain_sound = true;
  } else {
    rain_sound = false;
  }
} // -----------------------------------------------------