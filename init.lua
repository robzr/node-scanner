
strip_size = 88

ws2812.init()
ws2812.write(string.rep(string.char(0, 0, 0), strip_size))
node.setcpufreq(node.CPU160MHZ)


LedScan = {}

function LedScan:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.size       = o.size      or 88
  o.buffer     = o.buffer    or ws2812.newBuffer(o.size, 3)
  o.i          = o.i         or node.random(o.size)
  o.angle      = o.angle     or node.random(360)
  o.direction  = o.direction or 1
  o.every      = o.every     or 1
  o.skipper    = o.every
  o.brightness = 25 + node.random(125)
  o.tail       = math.floor((150 + 100 / o.every) * o.brightness / 150)
  
  return o
end

function LedScan:update()
  self.skipper = self.skipper == 1 and self.every or self.skipper - 1
  if(self.skipper ~= self.every) then return end

  self.angle = self.angle == 359 and 0 or self.angle + 1

  self.i = self.i + self.direction
  if(self.i == self.size or self.i == 1) then
    self.direction = self.direction * -1
  end

  self.buffer:mix(self.tail, self.buffer)
  self.buffer:set(self.i, color_utils.colorWheel(self.angle))
end


scans = {}
for x=1, 4, 1 do
  scans[x] = LedScan:new{
    size = strip_size,
    every = x * 2 + 1,
 }
end

buff  = ws2812.newBuffer(88, 3)
timer = tmr.create()

timer:alarm(7, 1, function()
  buff:fill(0, 0, 0)
  for i, v in ipairs(scans) do
    v:update()
    buff:mix(255, buff, v.brightness, v.buffer)
  end
  ws2812.write(buff)
end)

-- tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() 
--   timer:unregister()
--   ws2812.write(string.rep(string.char(0, 0, 0), strip_size))
-- end)
