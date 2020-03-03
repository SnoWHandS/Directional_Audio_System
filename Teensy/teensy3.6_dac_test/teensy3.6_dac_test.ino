#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// GUItool: begin automatically generated code
AudioSynthWaveformSine   sine1;          //xy=648,410
AudioOutputAnalogStereo  dacs1;          //xy=1041,417
AudioConnection          patchCord1(sine1, 0, dacs1, 0);
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

}
