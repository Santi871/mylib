local component = require("component")
local term = require("term")
local event = require("event")
local computer = require("computer")

local comp = {}

local tempBool1 = false
local tempBool2 = false

component.modem.open(123)
tarRPM = 0

function tableLength(h)
  local a = 0
  for _ in pairs(h) do a = a+1 end
  return a
end

b = {}
slot = 1

function comp.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function comp.getComponent(s)
  local f = component.list(tostring(s))
  local b = {}
  local slotB = 1
  for k in f do table.insert(b, slotB, tostring(k)) slotB = slotB + 1 end
  return b
end

function comp.getTurbines()

        t = component.list("br_turbine")
        local b = { }
        local slot = 1
        for k in t do table.insert(b, slot, tostring(k)) slot = slot + 1 end
        return b

end

local lastEnergy = 0
local currentEnergies = {}
local outputEnergies = {}
local lastEnergies = {}
local finalEnergies = {}
local cellNumber = 0
local lastTimes = {}
local deltaTimes = {}

function comp.getEnergyGains()
  local ACCURACY = 0

  if tempBool1==false then

    out2 = {}
    cells = comp.getComponent("tile_thermalexpansion_cell_resonant_name")
    cellsLength = tableLength(cells)

    for i=1, cellsLength do
      lastTimes[i] = computer.uptime()
      deltaTimes[i] = 0
      currentEnergies[i] = 0
      outputEnergies[i] = 0
      lastEnergies[i] = 0
      finalEnergies[i] = 0
      out2[i] = 0
    end

    tempBool1 = true

  end

    for i=1, cellsLength do
      deltaTimes[i] = computer.uptime() - lastTimes[i]
      lastTimes[i] = computer.uptime()

        currentEnergies[i] = component.proxy(cells[i]).getEnergyStored()
        outputEnergies[i] = (currentEnergies[i] - lastEnergies[i])/(20*deltaTimes[i])

        lastEnergies[i] = currentEnergies[i]
        finalEnergies[i] = comp.round(outputEnergies[i],ACCURACY)
        out2[i] = finalEnergies[i]

    end
return out2
end

function comp.toTurbine(t,n)

  return component.proxy(t[n])

end

function  comp.disableAllTurbines(t)

  local c = tableLength(t)

   for i=1,c do

    component.proxy(t[i]).setActive(false)

   end

end

function comp.enableAllTurbines(t)

  local c = tableLength(t)

    for i=1,c do

      component.proxy(t[i]).setActive(true)

    end

end

function setTarRPM(_, _, _, _, _, v)
	tarRPM = v
end

event.listen("modem_message", setTarRPM)


curErrors = {}
dErrs = {}
errors = {}
errSums = {}
proErrors = {}
out = {}
curFlowDev = {}

function comp.turbinePID()

  if tempBool2==false then

    turbines = comp.getTurbines()
    c = tableLength(turbines)

    for i=1, c do
    	curErrors[i] = 0
    	out[i] = 0
    	dErrs[i] = 0
    	errors[i] = 0
    	errSums[i] = 0
    	proErrors[i] = 0
    	curFlowDev[i] = 0
    end

    tempBool2 = true

  end


	for i=1, c do

			curOut = component.proxy(turbines[i]).getEnergyProducedLastTick()
			curRPM = component.proxy(turbines[i]).getRotorSpeed()
			curErrors[i] = tarRPM-curRPM
			proErrors[i] = 10*curErrors[i]
			errSums[i] = errSums[i] + curErrors[i]
			dErrs[i] = curErrors[i] - errors[i]


			if errSums[i] > 2000 then errSums[i]=2000 end
			if errSums[i] < -2000 then errSums[i]=-2000 end


			curFlowDev[i] = proErrors[i] + errSums[i] + dErrs[i]

			out[i] = curFlowDev[i]

			errors[i] = curErrors[i]

		end

	return out

end

function comp.cleanUp()
  tempBool1 = false
  tempBool2 = false
end

return comp
