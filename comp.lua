local component = require("component")
local term = require("term")
local event = require("event")

local comp = {}

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

function comp.toTurbine(t,n)

  turbine = component.proxy(t[n])
  return turbine

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

turbines = comp.getTurbines()
c = tableLength(turbines)
curErrors = {}
dErrs = {}
errors = {}
errSums = {}
lastError = 0
proErrors = {}
out = {}
dErr = 0
curFlowDev = {}
lastError = 0

for i=1, c do
	curErrors[i] = 0
	out[i] = 0
	dErrs[i] = 0
	errors[i] = 0
	errSums[i] = 0
	proErrors[i] = 0
	curFlowDev[i] = 0
end

function comp.turbinePID()

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

return comp
