function startup()
  dofile('LedMix.lua')
  dofile('LedPulse.lua')
  dofile('LedScan.lua')

  led_mix = LedMix:new{
    strip_size   = 88,
    refresh_rate = 200,  -- 100 Hz is safe for modest use, but faster is better
  }

--[[
  for x=1, node.random(1, 3) do
    led_mix.animations[x] = LedScan:new{
      bright_max = 30,
      bright_min = 10,
      strip_size = led_mix.strip_size,
      interval   = led_mix:find_interval(20, 65),
    }
  end
--]]

  table.insert(led_mix.animations,
               LedPulse:new{
                 bright_min = 0,
                 bright_max = 255,
                 interval   = 3,
                 strip_size = led_mix.strip_size,
               })
end


node.setcpufreq(node.CPU160MHZ)
tmr.alarm(0, 1500, 0, startup)

-- file.remove("init.lua")
