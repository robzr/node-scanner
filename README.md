# node-scanner
APA102 / WS2812 effects and effects mixer for ESP8266 / ESP32 on NodeMCU

This repo has a series of reusable effects ("animations") and a mixer class that will control the updating & mixing of the animations and drive the LED strip(s).  Requires nodemcu image with ws2812, color_utils, SPI

## Classes
- *LedMix* - this is the mixer class.  Instantiate this once; this manages the refresh loop. Add any instantiated animations to the animations property.
- *LedScan* - scanning "tail" effect with tunable parameters (speed, brightness, tail length, direction, etc).  Follows HSV color wheel.
- *LedPulse* - pulsing (fade) effect

## Instructions
First, instantiate the mixer class. By default this will begin the refresh loop.
```
  led_mix = LedMix:new {
    strip_size   = 88,
  }
```
There are tunable parameters including the refresh rate (defaults to 180 Hz), see LedMix.lua for details.

Once the mixer has been instantiated, by default it will have registered the alarm for the refresh loop, and is ready to go. Now, you can instantiate your animations and register them.
```
  led_mix << LedPulse:new {
               bright_min = 0,
               bright_max = 255,
               strip_size = led_mix.strip_size,
             }
```

## TODO
- (LedMix) add APA102 abstraction layer
- (LedMix) override \_\_shl (<< operator) in LedMix metatable for adding effects
- (LedMix) add expiration option to animations in LedMix registry hook
- (LedPulse) convert to weighted integer-sine wave based breathing effect
- (LedScan) convert to all integer math for speed
- more effects :) - chase, etc (?)
