local component = require("component")
local keyboard = require("keyboard")
local term = require("term")
local gpu1 = component.gpu
local sides = require("sides")
local colors = require("colors")
local rs = component.redstone
local comp = require("comp")
 
local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
 
t = comp.getTurbines()
 
term.clear()
 
r1 = io.read()
r2 = io.read()
r3 = io.read()
 
comp.enableAllTurbines(t)
 
while true do
 
tableFlow = pid(t[1],t[2],t[3],r1,r2,r3)
 
 
comp.toTurbine(t,1).setFluidFlowRateMax(tableFlow[1])
comp.toTurbine(t,2).setFluidFlowRateMax(tableFlow[2])
 
if keyboard.isKeyDown(keyboard.keys.space) then term.clear() os.exit() end
 
gpu1.fill(1,1,999,999," ")
 
gpu1.set(1,1, "Current turbine 1 output: " .. math.floor(comp.toTurbine(t,1).getEnergyProducedLastTick()) .. " RF/t")
gpu1.set(1,2, "Current rotor 1 speed: " .. round(comp.toTurbine(t,1).getRotorSpeed(),1) .. " RPM")
gpu1.set(1,3, "Target rotor 1 speed: " .. round(r1,1) .. " RPM")
 
gpu1.set(1,9, "Current turbine 1 flow rate: " .. math.floor(tableFlow[1]))
 
os.sleep(0.5)
 
end