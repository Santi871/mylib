
API = require("buttonAPI")
local event = require("event")
local computer = require("computer")
local term = require("term")
local component = require("component")
local gpu = component.gpu
local modem = component.modem
local keyboard = require("keyboard")
local term = require("term")
local comp = require("comp")
local serialization = require("serialization")

--local rs = component.redstone
local colors = require("colors")
local side = require("sides")

modem.open(123)
modem.open(124)

function API.fillTable()
 
  API.setTable("OFF", off, 5,12, 3,4)  
  API.setTable("900", speedLo, 14,21, 3,4)
  API.setTable("1800", speedHi, 23,30, 3,4)

  API.screen()

end

function getClick()
  local _, _, x, y = event.pull(1,touch)
  if x == nil or y == nil then
    local h, w = gpu.getResolution()
    gpu.set(h, w, ".")
    gpu.set(h, w, " ")
  else 
    API.checkxy(x,y)
  end
end

function off()
  local t = {"900", "1800"} -- Which buttons to turn off
  buttonStatus1 = API.toggleButton("OFF", t)
  if buttonStatus1 == true then
    modem.broadcast(123, 0)
  else
    --need code here?
  end
end

function speedLo()
  local t = {"OFF", "1800"}
  buttonStatus2 = API.toggleButton("900", t)
  if buttonStatus2 == true then
    modem.broadcast(123, 900)
  else
    -- # If the button is off (red) do this instead.
  end
end

function speedHi()
  local t = {"OFF", "900"}
  buttonStatus3 = API.toggleButton("1800", t)
  if buttonStatus3 == true then
    modem.broadcast(123, 1800)
  else
    -- if off here
  end
end



function getPacket(_, _, _, _, _, packet)

--local _, _, _, _, _, packet = event.pull(0.1,"modem_message")

--if packet==nil then term.clear() print("Packet nil, terminated") os.exit() end

local t = serialization.unserialize(packet)

gpu.fill(1,6,999,999," ")

for k,v in pairs(t) do 


gpu.set(1,5+k, "Energy gain "..k..": "..v.." RF/t")

 end

end

event.listen("modem_message", getPacket)

term.setCursorBlink(false)
gpu.setResolution(80, 25)
API.clear()
API.fillTable()
API.heading("CONTROL GUI ALPHA")
--API.label(1,24,"A sample Label.")

while true do
  getClick()
  --getPacket()
  if keyboard.isControlDown() then term.clear() event.ignore("modem_message", getPacket) os.exit() end
end



--eof