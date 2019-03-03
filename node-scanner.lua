LedScan = {}

function LedScan:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.buffer     = o.buffer     or ws2812.newBuffer(o.size, 3)
  o.size       = o.size       or leds_in_strip
  o.i          = o.i          or node.random(o.size)
  o.angle      = o.angle      or node.random(360)

  o.angle_dir  = node.random(2) == 2 and 1 or -1 -- random -1 or 1
  o.direction  = o.direction  or node.random(2) == 2 and 1 or -1 -- random -1 or 1

  o.every      = o.every      or 1
  o.skipper    = o.every

  o.bright_max = o.bright_max or 100
  o.bright_min = o.bright_min or 10
  o.brightness = math.floor(node.random(o.bright_min, o.bright_max))

  o.tail_max   = o.tail_max   or 200 
  o.tail_min   = o.tail_min   or 100

  local tail_range = o.tail_max - o.tail_min

  local tail_factor_speed  = 1 / o.every -- compensate for speed  and brightness
  local tail_factor_bright = (o.brightness - o.bright_min) / (o.bright_max - o.bright_min)
  local tail_factor = (tail_factor_speed + tail_factor_bright) / 2  -- and average
  -- now we take the tail factor and convert to usable fade numbers
  o.tail = o.tail or tail_factor * tail_range + o.tail_min
  
  return o
end

function LedScan:update()
  self.skipper = self.skipper == 1 and self.every or self.skipper - 1
  if(self.skipper ~= self.every) then return end

  if(self.angle_dir == 1) then
    self.angle = self.angle == 359 and 0 or self.angle + 1
  else
    self.angle = self.angle == 0 and 359 or self.angle - 1
  end

  self.i = self.i + self.direction
  if(self.i == self.size or self.i == 1) then
    self.direction = self.direction * -1
  end

  self.buffer:mix(self.tail, self.buffer)
  self.buffer:set(self.i, color_utils.colorWheel(self.angle))
end


function speed_to_every(speed)
  return math.floor(1000 / refresh_timer / speed)
end

scans = {}
for x=1, scanner_count, 1 do
  -- make sure we don't have two scanners going the same rate
  local every
  repeat 
    every = speed_to_every(node.random(10, 65))
    for i, v in ipairs(scans) do
      if(v.every == every) then every = nil end
    end
  until every ~= nil

  scans[x] = LedScan:new{
    size  = leds_in_strip,
    every = every,
  }
--]]--
end

buff  = ws2812.newBuffer(leds_in_strip, 3)
timer = tmr.create()

timer:alarm(refresh_timer, 1, function()
  buff:fill(0, 0, 0)
  for i, v in ipairs(scans) do
    v:update()
    buff:mix(255, buff, v.brightness, v.buffer)
  end
  ws2812.write(buff)
end)

-- tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() 
--   timer:unregister()
--   ws2812.write(string.rep(string.char(0, 0, 0), leds_in_strip))
-- end)
