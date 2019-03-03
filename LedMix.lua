LedMix = {}

function LedMix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  --[[
  o.auto_load    = o.auto_load    or 1
  o.load_from    = o.load_from    or {}
  --]]--
  o.stop_after   = o.stop_after   or false
  o.strip_size   = o.strip_size   or 50   -- # LEDs
  o.refresh_rate = o.refresh_rate or 200  -- Hz

  o.animations   = {}
  o.buffer = ws2812.newBuffer(o.strip_size, 3)

  o:clear(o.strip_size)

  o.timer = tmr.create()

  --[[ 
  if(#o.load_from > 0) then  -- autoload at random if setup
    for i=1, o.auto_load do
      table.insert(o.animations,
                   o.load_from[node.random(#o.load_from)]:new{
                     strip_size = o.strip_size,
                     interval   = o:find_interval(20, 65),
                   })
    end
  end
  --]]--

  if(o.auto_start == nil or o.auto_start) then o:start() end

  return o
end

function LedMix:clear(strip_size)
  local strip_size = strip_size or self.strip_size or 1024

  ws2812.init()
  ws2812.write(string.rep(string.char(0, 0, 0), strip_size))
end

-- This function will try to find an unused interval, but return what it must
function LedMix:find_interval(slowest, fastest)
  slowest = slowest or 10   -- speed in pps (pixels per second)
  fastest = fastest or 100  -- 

  local highest = self:speed_to_interval(slowest)  -- convert to interval
  local lowest  = self:speed_to_interval(fastest)  --

  local saturated = true  -- are all intervals in the range in use already?
  for i=lowest, highest do
    local found = false
    for j, animation in ipairs(self.animations) do
      if(animation.interval == i) then found = true end
    end
    if(found == false) then saturated = false end
  end

  local interval  -- now lets find a random one that is unused, or if it's saturated
  repeat          --  then any random value will do
    interval = node.random(lowest, highest)
    for i, animation in ipairs(led_mix.animations) do
      if(animation.interval == interval and saturated == false) then interval = nil end
    end
  until interval ~= nil

  return interval
end

function LedMix:refresh_timer()
  return math.floor(1000 / self.refresh_rate)
end

function LedMix:speed_to_interval(speed)
  return math.floor(self.refresh_rate / speed)
end

function LedMix:start()
  self.timer:alarm(self:refresh_timer(), 1, function()
    self:update()
  end)
  if(self.stop_after) then self:stop() end
end

function LedMix:stop(when)
  when = when or self.stop_after or 1
  tmr.create():alarm(when, tmr.ALARM_SINGLE, function() 
    self.timer:unregister()
    self:clear()
 end)
end

function LedMix:update()
  self.buffer:fill(0, 0, 0)
  for i, animation in ipairs(self.animations) do
    animation:update()
    self.buffer:mix(255, self.buffer, animation.brightness, animation.buffer)
  end
  ws2812.write(self.buffer)
end


LedMix:clear()
