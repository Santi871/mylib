local component = require("component")
local term = require("term")
local comp = require("comp")
local keyboard = require("keyboard")
local modem = component.modem
local gpu = component.gpu

local CALIBRATION_OFFSET = 21

local w, h = gpu.getResolution()

gpu.setResolution(w/6, h/6)

cells = comp.getComponent("tile_thermalexpansion_cell_resonant_name")

maxEnergy = component.proxy(cells[1]).getMaxEnergyStored()

lastEnergy = component.proxy(cells[1]).getEnergyStored()

while true do

 currentEnergy = component.proxy(cells[1]).getEnergyStored()
 outputEnergy = ((currentEnergy - lastEnergy)/20)
 lastEnergy = currentEnergy

 finalEnergy = comp.round(outputEnergy - (outputEnergy/CALIBRATION_OFFSET),0)
 chargePercentage = comp.round(currentEnergy/maxEnergy*100,0)

 gpu.fill(1,1,999,999," ")
 gpu.set(1,1,"Energy gain: "..finalEnergy.." RF/t")
 gpu.set(1,2,'Charge percentage: '..chargePercentage..'%')

 if keyboard.isKeyDown(keyboard.keys.space) then gpu.setResolution(w, h) term.clear() os.exit() end

os.sleep(1)

end