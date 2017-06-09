// class to create the sound for a stone dropping in water
// ---------------------------------------------------------
class Tone {

  float volume;
  float decay;
  float freq;
  float pan;

  AudioContext ac;
  WavePlayer tone_gen;
  Envelope tone_vol;
  Envelope tone_pitch;
  Gain tone_amp;
  Panner tone_pan;

  // ---------------------------------------------------------
  Tone() {
    // ----- define
    ac = new AudioContext(); // dac
    tone_pitch = new Envelope(ac, freq); // pitch control
    tone_gen = new WavePlayer(ac, tone_pitch, Buffer.SINE); // oscillator
    tone_vol = new Envelope(ac, 0); // volume control
    tone_pan = new Panner(ac);
    tone_amp = new Gain(ac, 2, tone_vol); // amplifier

    // ----- connect
    tone_pan.addInput(tone_gen);
    tone_amp.addInput(tone_pan);
    ac.out.addInput(tone_amp);
    ac.start();
  } // CONSTRUCTOR ---------------------------------------------


  // ---------------------------------------------------------
  void set_freq(float _freq) {
    freq = _freq;
  } // ---------------------------------------------------------

  // ---------------------------------------------------------
  void set_pan(float _pan) {
    tone_pan.setPos(_pan);
  } // ---------------------------------------------------------


  // ---------------------------------------------------------
  void trigger(float _freq, float _volume, float _decay, float _pan) {
    freq = _freq;
    volume = _volume;
    decay = _decay;
    tone_pan.setPos(_pan);
    
    tone_pitch.addSegment( (freq * 2), 0.0);

    tone_vol.addSegment(volume, 5); // attack
    tone_vol.addSegment(0.0, decay); // decay
  } // ---------------------------------------------------------

} // CLASS ---------------------------------------------------