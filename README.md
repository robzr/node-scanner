# node-scanner
APA102 / WS2812 effects and effects mixer for ESP8266 / ESP32 on NodeMCU

This repo has a series of reusable effects ("animations") and a mixer class that will control the updating & mixing of the animations and drive the LED strip(s).  Requires nodemcu image with ws2812, color_utils, SPI

## Classes
- *LedMix* - this is the mixer class.  Instantiate this once; this manages the refresh loop. Add any instantiated animations to the animations property.
- *LedScan* - scanning "tail" effect with tunable parameters (speed, brightness, tail length, direction, etc).  Follows HSV color wheel.
- *LedPulse* - pulsing (fade) effect

## TODO
- (LedPulse) convert to weighted integer-sine wave based breathing effect
- (LedScan) convert to all integer math for speed
- more effects :)
