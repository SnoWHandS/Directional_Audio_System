#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// GUItool: begin automatically generated code
AudioSynthWaveformSineHires sine_hires1;    //xy=438,268
AudioOutputAnalogStereo  dacs1;          //xy=1041,417
AudioConnection          patchCord1(sine_hires1, 0, dacs1, 0);
AudioConnection          patchCord2(sine_hires1, 1, dacs1, 1);
// GUItool: end automatically generated code
#define LEVEL 1.0
#define FREQ 1000

void setup() {
  AudioMemory(16);                //Needed for audio library to work
  dacs1.analogReference(EXTERNAL);
  sine_hires1.amplitude(1.0);
  sine_hires1.frequency(1000);
}

void loop() {
  // put your main code here, to run repeatedly:

}
