#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// GUItool: begin automatically generated code
AudioSynthToneSweep      tonesweep1;     //xy=655,453
AudioSynthWaveformSineModulated sine1;       //xy=858,449
AudioOutputAnalogStereo  dacs1;          //xy=1041,417
AudioConnection          patchCord1(tonesweep1, sine1);
AudioConnection          patchCord2(sine1, 0, dacs1, 0);
// GUItool: end automatically generated code
#define LEVEL 1.0
#define FREQ 1000

void setup() {
  AudioMemory(16);                //Needed for audio library to work
  dacs1.analogReference(EXTERNAL);
  sine1.amplitude(1.0);
  sine1.frequency(1000);
}

void loop() {
  // put your main code here, to run repeatedly:
  tonesweep1.play(1.0, 144, 3000, 2);
  delay(3000);
}
