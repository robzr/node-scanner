LedPulse = {}

function LedPulse:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.strip_size = o.strip_size or 50
  o.buffer = o.buffer or ws2812.newBuffer(o.strip_size, 3)

  o.direction  = o.direction  or 1

  o.interval   = o.interval   or 10 
  o.skipper    = o.interval

  o.bright_max = o.bright_max or 25
  o.bright_min = o.bright_min or 1
  o.bright = o.bright_min  -- brightness is used to mix, bright for fills

  -- used in mix
  o.brightness = 255  -- o.bright_min 
  
  return o
end

function LedPulse:update()
  self.skipper = self.skipper == 1 and self.interval or self.skipper - 1
  if(self.skipper ~= self.interval) then return end

  self.bright = self.bright + self.direction
  if(self.bright >= self.bright_max or self.bright <= self.bright_min) then
    self.direction = self.direction * -1
  end

  self.buffer:fill(self.bright, self.bright, self.bright)  -- RGB
--   self.buffer:fill(color_utils.hsv2grb(0, 0, self.bright)) -- HSV
end

