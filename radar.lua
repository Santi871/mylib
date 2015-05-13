local component = require("component")
local term = require("term")
local keyboard = require("keyboard")
local gpu = component.gpu
local radar = component.radar

local playersDetected = {}
local slot = 1
local shouldWrite = true

local w, h = gpu.getResolution()

gpu.setResolution(w/5, h/5)

while true do

  radarReturn = radar.getPlayers()

  for k,v in pairs(radarReturn) do

    local name = radarReturn[k]["name"]

    for k,v in pairs(playersDetected) do

      shouldWrite = true

      if name==playersDetected[k] then shouldWrite = false break end

    end

    if shouldWrite==true then table.insert(playersDetected, slot, name) slot = slot + 1 end

  end

  gpu.fill(1, 1, 999, 999, " ")
  gpu.set(1, 1, "Log of detected players:")

  for k,v in pairs(playersDetected) do

    gpu.set(1, 1+k, v)

  end

  if keyboard.isControlDown() then term.clear() gpu.setResolution(w, h) os.exit() end

  os.sleep(5)

end
