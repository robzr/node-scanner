LedScan = {}

function LedScan:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.strip_size = o.strip_size or 50

  o.buffer     = o.buffer     or ws2812.newBuffer(o.strip_size, 3)
  o.location   = o.location   or node.random(o.strip_size)
  o.angle      = o.angle      or node.random(360)
  o.angle_dir  = o.angle_dir  or node.random(2) == 2 and 1 or -1 -- random -1 or 1
  o.direction  = o.direction  or node.random(2) == 2 and 1 or -1 -- random -1 or 1

  o.interval   = o.interval   or 1
  o.skipper    = o.interval

  o.bright_max = o.bright_max or 75   -- Max brightness; 0-255
  o.bright_min = o.bright_min or 10   -- Min brightness; 0-255
  o.brightness = o.brightness or node.random(o.bright_min, o.bright_max)

  o.tail_max   = o.tail_max   or 200  -- Max tail fade; 0-255
  o.tail_min   = o.tail_min   or 100  -- Min tail fade; 0-255

  local tail_factor_speed  = 1 / o.interval -- compensate for speed & brightness
  local tail_factor_bright = (o.brightness - o.bright_min) / (o.bright_max - o.bright_min)
  local tail_factor = (tail_factor_speed + tail_factor_bright) / 2  -- and average
  -- now we take the tail factor and convert to usable fade numbers
  o.tail = o.tail or tail_factor * (o.tail_max - o.tail_min) + o.tail_min
  
  return o
end

function LedScan:update()
  self.skipper = self.skipper == 1 and self.interval or self.skipper - 1
  if(self.skipper ~= self.interval) then return end

  if(self.angle_dir == 1) then
    self.angle = self.angle == 359 and 0 or self.angle + 1
  else
    self.angle = self.angle == 0 and 359 or self.angle - 1
  end

  self.location = self.location + self.direction
  if(self.location == self.strip_size or self.location == 1) then
    self.direction = self.direction * -1
  end

  if(self.tail == 128) then
    self.buffer:fade(2)
  else
    self.buffer:mix(self.tail, self.buffer)
  end

  self.buffer:set(self.location, color_utils.colorWheel(self.angle))
end
