local component = require("component")
local term = require("term")
local keyboard = require("keyboard")
local event = require("event")
local computer = require("computer")
local note = require("note")
local shell = require("shell")

-------------DEFAULT SETTINGS--------------

local SCAN_RATE = 1 -- scan rate in Hz (times a second) - higher scan rate requires more energy per tick
local REALISTIC_SCANNING_AND_BEEPING = false -- beep every time a contact is found (slows down refresh rate)
local SHOW_DISTANCE_MARKERS = true -- show distance markers in number of blocks
local SHOW_ALL_ENTITIES = true -- if true, will show mobs as well as players (requires more energy per tick)
local MARKERS_COLOR = "cyan" -- color for the entity markers in hex
local MARKERS_CHARACTER = "■" -- character for the entity markers
local INVERT_X_AXIS = false -- change to true to invert x axis (for calibration purposes)
local INVERT_Y_AXIS = false -- change to true to invert y axis (for calibration purposes)
local MARK_MYSELF = true -- set to false to prevent yourself from drawing on the screen
local HEIGHT_COLORS = true -- set to false to disable height colors
local DISPLAY_HOLOGRAM = false -- set to true to display hologram (requires tier 2 hologram projector)
local HOLOGRAM_SCALE = 1 -- set hologram scale from 0.33 to 3

----------------HELP SCREEN----------------

local args = shell.parse(...)

if args[1]=="help" then

  print("--Radar program usage--")
  print("-Configure the program yourself or use the default values")
  print("-For further configuration, edit the program file")
  print("-While the radar program is running, hold LEFT CTRL to exit")
  print("-Do not forcefully exit using CTRL ALT C - it will leave a registered eventhandler")
  print("-Use ARROW KEY UP and ARROW KEY DOWN to increase and decrease the scale of the Y axis respectively")
  print("-Use ARROW KEY RIGHT and ARROW KEY LEFT to increase and decrease the scale of the X axis respectively")
  print("-If an axis is inverted, you can easily rectify it by changing one of the INVERT AXIS parameters in the program file")
  print("-Made by Santi")

  os.exit()

end

if args[1]=="colorcodes" then

  print("Red: y<=30")
  print("Yellow: y>30 and y<=-10")
  print("White: y>-10 and y<=10")
  print("Cyan: y>10 and y<=30")
  print("Purple: y>30")

  os.exit()

end

----------------INTERNAL UTILITY VARIABLES AND FUNCTIONS-------------------

local colors = {

white = 0xFFFFFF,
orange = 0xFFAA00,
magenta = 0xFF55FF,
lightblue = 0x55FFFF,
yellow = 0xFFFF00,
lime = 0x55FF55,
pink = 0xFF5555,
gray = 0x555555,
lightgray = 0xAAAAAA,
cyan = 0x00AAAA,
purple = 0xAA00AA,
blue = 0x5555FF,
brown = 0x421010,
green = 0x00FF00,
red = 0xFF0000,
black = 0x000000

}

local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-------------COMPONENT CHECK---------------

if not component.isAvailable("gpu") then
  print("ERROR: GRAPHICS CARD NOT FOUND")
  os.exit()
else gpu = component.gpu
end

if not component.isAvailable("radar") then
  print("ERROR: RADAR NOT FOUND")
  os.exit()
else radar = component.radar
end

if not component.isAvailable("hologram") then
   DISPLAY_HOLOGRAM = false
else holo = component.hologram
end

if gpu.maxDepth()<8 then
  print("ERROR: THIS PROGRAM REQUIRES A TIER 3 SCREEN")
  os.exit()
end

if computer.totalMemory()<393216 then
  print("ERROR: THIS PROGRAM REQUIRES AT LEAST A TIER 2 MEMORY STICK")
  os.exit()
end
-------------STARTUP PARAMETERS------------

local w, h = gpu.getResolution()
local halfW = w/2
local halfH = h/2
local zZoom = 1.001 -- these two values must not be integers in order to avoid division by zero
local xZoom = 2.001
local yOffset = 0
local running = true
local _, _, _, _, userName = event.pull(1, "key_up")
gpu.setBackground(colors.black)
if component.isAvailable("hologram") then holo.setScale(HOLOGRAM_SCALE) end

--------------STARTUP SCREEN---------------

term.clear()
print("Component check passed!")
print("---Setup screen---")
print("Skip and use default values? Y/N")
local SHOW_STARTUP_SCREEN = string.lower(io.read())

if SHOW_STARTUP_SCREEN=="n" then

  print("Set scan rate in Hz (times a second) - higher scan rate requires more energy per tick")
  SCAN_RATE = io.read()

  print("Realistic scanning and beeping? (slows down refresh rate) - true/false")
  REALISTIC_SCANNING_AND_BEEPING = string.lower(io.read())=="true"

  print("Show distance markers in number of blocks? - true/false")
  SHOW_DISTANCE_MARKERS = string.lower(io.read())=="true"

  print("Scan for mobs? - true/false")
  SHOW_ALL_ENTITIES = string.lower(io.read())=="true"

  if component.isAvailable("hologram") then
    print("Display hologram? - true/false")
    DISPLAY_HOLOGRAM = string.lower(io.read())=="true"
  end

  print("Change marker color in function of height? - true/false")
  HEIGHT_COLORS = string.lower(io.read())=="true"

  print("Mark myself on the radar? - true/false")
  MARK_MYSELF = string.lower(io.read())=="true"

  if not HEIGHT_COLORS then

  print("Set entity marker color:")
  MARKERS_COLOR = string.lower(io.read())

  end

end

print("Setup complete. Starting program...")
os.sleep(2)

-------------INTERNAL FUNCTIONS-------------

local function updateScreen()

  gpu.fill(1, 1, w, h, " ")
  gpu.setForeground(colors.lightgray)
  gpu.set(halfW, halfH, "-- 0")

  if SHOW_DISTANCE_MARKERS then
  gpu.set(halfW-16*1/zZoom, halfH, "¦ 16")
  gpu.set(halfW-32*1/zZoom, halfH, "¦ 32")
  gpu.set(halfW-64*1/zZoom, halfH, "¦ 64")
  gpu.set(halfW+16*1/zZoom, halfH, "¦ 16")
  gpu.set(halfW+32*1/zZoom, halfH, "¦ 32")
  gpu.set(halfW+64*1/zZoom, halfH, "¦ 64")

  gpu.set(halfW, halfH-16*1/xZoom, "-- 16")
  gpu.set(halfW, halfH-32*1/xZoom, "-- 32")
  gpu.set(halfW, halfH-64*1/xZoom, "-- 64")
  gpu.set(halfW, halfH+17*1/xZoom, "-- 16")
  gpu.set(halfW, halfH+33*1/xZoom, "-- 32")
  gpu.set(halfW, halfH+65*1/xZoom, "-- 64")
  end

  gpu.set(2, 47, "X axis zoom: "..round(1/(xZoom/2),1).."x")
  gpu.set(2, 48, "Y axis zoom: "..round(1/(zZoom),1).."x")
  gpu.set(2, 49, "Z axis offset: "..yOffset)
  local freeMemory = round(computer.freeMemory()/1000,0)
  gpu.set(140, 49, "Free memory: "..freeMemory.." kB")


  if DISPLAY_HOLOGRAM then holo.clear()
  holo.set(24, 16, 24, 1)
  end

  if not HEIGHT_COLORS then gpu.setForeground(colors[MARKERS_COLOR]) end

  for k,v in pairs(radarScanReturn) do

    y = radarScanReturn[k]["y"] - yOffset

    if HEIGHT_COLORS then

      if y<=-30 then gpu.setForeground(colors.red) end
      if y>-30 and y<=-10 then gpu.setForeground(colors.yellow) end
      if y>-10 and y<=10 then gpu.setForeground(colors.white) end
      if y>10 and y<=30 then gpu.setForeground(colors.cyan) end
      if y>30 then gpu.setForeground(colors.purple) end

    end

    if MARK_MYSELF or not MARK_MYSELF and radarScanReturn[k]["name"]~=userName then

      if INVERT_X_AXIS and not INVERT_Y_AXIS then

        gpu.set(halfW + radarScanReturn[k]["z"]/-zZoom, halfH - radarScanReturn[k]["x"]/xZoom, MARKERS_CHARACTER.." "..radarScanReturn[k]["name"])

        if DISPLAY_HOLOGRAM then
        holo.set(24 - (((radarScanReturn[k]["z"] + 32) * 48) / 64 - 24)/2, 16 + (((radarScanReturn[k]["y"] + 32) * 32) / 64 - 16)/2, 24 - (((radarScanReturn[k]["x"] + 32) * 48) / 64 - 24)/2, 2)
        end

      end

      if INVERT_Y_AXIS and not INVERT_X_AXIS then

        gpu.set(halfW + radarScanReturn[k]["z"]/zZoom, halfH - radarScanReturn[k]["x"]/-xZoom, MARKERS_CHARACTER.." "..radarScanReturn[k]["name"])

        if DISPLAY_HOLOGRAM then
        holo.set(24 + (((radarScanReturn[k]["z"] + 32) * 48) / 64 - 24)/2, 16 + (((radarScanReturn[k]["y"] + 32) * 32) / 64 - 16)/2, 24 + (((radarScanReturn[k]["x"] + 32) * 48) / 64 - 24)/2, 2)
        end

      end

      if INVERT_X_AXIS and INVERT_Y_AXIS then

        gpu.set(halfW + radarScanReturn[k]["z"]/-zZoom, halfH - radarScanReturn[k]["x"]/-xZoom, MARKERS_CHARACTER.." "..radarScanReturn[k]["name"])

        if DISPLAY_HOLOGRAM then
        holo.set(24 - (((radarScanReturn[k]["z"] + 32) * 48) / 64 - 24)/2, 16 + (((radarScanReturn[k]["y"] + 32) * 32) / 64 - 16)/2, 24 + (((radarScanReturn[k]["x"] + 32) * 48) / 64 - 24)/2, 2)
        end

      end

      if not INVERT_X_AXIS and not INVERT_Y_AXIS then

        gpu.set(halfW + radarScanReturn[k]["z"]/zZoom, halfH - radarScanReturn[k]["x"]/xZoom, MARKERS_CHARACTER.." "..radarScanReturn[k]["name"])

        if DISPLAY_HOLOGRAM then
        holo.set(24 + (((radarScanReturn[k]["z"] + 32) * 48) / 64 - 24)/2, 16 + (((radarScanReturn[k]["y"] + 32) * 32) / 64 - 16)/2, 24 - (((radarScanReturn[k]["x"] + 32) * 48) / 64 - 24)/2, 2)
        end

      end

    if REALISTIC_SCANNING_AND_BEEPING then note.play(67, 0.05) end

    end

  end

end

local function keyDownListener(_, _, _, key)

  if key==29 then -- screen cleanup and unregister eventlistener
    gpu.setResolution(w, h)
    gpu.setForeground(0xffffff)
    event.ignore("key_down", keyDownListener)
    if component.isAvailable("hologram") then holo.clear() end
    running=false
  end

  if event.pull(0.1, "key_down")==nil then -- prevents holding down arrow keys which makes it freak out

    if key==209 then yOffset = yOffset - 1 updateScreen() end

    if key==201 then yOffset = yOffset + 1 updateScreen() end

    if key==200 then xZoom = xZoom - 0.1 updateScreen() end

    if xZoom<0 then xZoom=0.1 end

    if key==208 then xZoom = xZoom + 0.1 updateScreen() end

    if key==203 then zZoom = zZoom + 0.1 updateScreen() end

    if key==205 then zZoom = zZoom - 0.1 updateScreen() end

    if zZoomz<0 then zZoom=0.1 end

  end

end

--------------EVENT LISTENER---------------

event.listen("key_down", keyDownListener)

-----------------MAIN LOOP-----------------

while running do
  if SHOW_ALL_ENTITIES then
    radarScanReturn = radar.getEntities()
  else radarScanReturn = radar.getPlayers()
  end

  updateScreen()
  os.sleep(1/SCAN_RATE)
end

if not running then term.clear() os.exit() end

--eof
