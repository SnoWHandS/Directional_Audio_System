/*
  Demo of the audio sweep function.
  The user specifies the amplitude,
  start and end frequencies (which can sweep up or down)
  and the length of time of the sweep.

  Modified to eliminate the audio shield, and use Max98357A mono I2S chip.
  https://smile.amazon.com/gp/product/B07PS653CD/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1

  Pins:    Teensy 4.0  Teensy 3.x

  LRCLK:  Pin 20/A6 Pin 23/A9
  BCLK:   Pin 21/A7 Pin 9
  DIN:    Pin 7   Pin 22/A8
  Gain:   see below see below
  Shutdown: N/C   N/C
  Ground: Ground    Ground
  VIN:    3.3v    3.3v

  Gain setting:

  15dB  if a 100K resistor is connected between GAIN and GND
  12dB  if GAIN is connected directly to GND
   9dB  if GAIN is not connected to anything (this is the default)
   6dB  if GAIN is conneted directly to Vin
   3dB  if a 100K resistor is connected between GAIN and Vin.  */

#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// GUItool: begin automatically generated code
AudioSynthToneSweep tonesweep1; //xy=102,174
AudioAmplifier    amp1;   //xy=324,172
AudioOutputI2S    i2s1;   //xy=538,168
AudioConnection   patchCord1 (tonesweep1, amp1);
AudioConnection   patchCord2 (amp1, 0, i2s1, 0);
// GUItool: end automatically generated code

const float t_ampx  = 0.8;
const int t_lox = 10;
const int t_hix = 22000;
const float t_timex = 10;   // Length of time for the sweep in seconds

void setup(void)
{
  // Wait for at least 3 seconds for the USB serial connection
  Serial.begin (9600);
  while (!Serial && millis () < 3000)
    ;

  delay (3000);

  AudioMemory (2);
  amp1.gain (0.5);

  Serial.println("setup done");

  if (!tonesweep1.play (t_ampx, t_lox, t_hix, t_timex)) {
    Serial.println ("ToneSweep - play failed");
    while (1)
      ;
  }

  // wait for the sweep to end
  Serial.println ("Tonesweep up started");
  while (tonesweep1.isPlaying ())
    ;

  // and now reverse the sweep
  Serial.println ("Tonesweep down started");
  if (!tonesweep1.play (t_ampx, t_hix, t_lox, t_timex)) {
    Serial.println("ToneSweep - play failed");
    while (1)
      ;
  }

  // wait for the sweep to end
  while (tonesweep1.isPlaying ())
    ;
  Serial.println("Done");
}

void loop(void)
{
}
