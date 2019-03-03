leds_in_strip = 88
refresh_timer = 10                 -- in milliseconds, lower is better until it crashes
scanner_count = node.random(2, 5)  -- how many scanners


node.setcpufreq(node.CPU160MHZ)
ws2812.init()
ws2812.write(string.rep(string.char(0, 0, 0), leds_in_strip))

function startup()
  dofile('node-scanner.lua')
end

tmr.alarm(0, 2500, 0, startup)
