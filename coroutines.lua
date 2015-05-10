local component = require("component")
local keyboard = require("keyboard")
local term = require("term")
local gpu = component.gpu
local sides = require("sides")
local colors = require("colors")
local comp = require("comp")
local modem = component.modem
local serialization = require("serialization") 

turbine = coroutine.create(function()

while true do

t = comp.getTurbines()

comp.enableAllTurbines(t)

tableFlow = comp.turbinePID()

c = tableLength(t)

for k,v in pairs(t) do

comp.toTurbine(t, k).setFluidFlowRateMax(tableFlow[k])

end


if keyboard.isControlDown() then comp.cleanUp() term.clear() os.exit() end

os.sleep(0.5)

coroutine.yield()

end

end

)

cell = coroutine.create(function()

while true do

 results = comp.getEnergyGains()

 gpu.fill(1,1,999,999," ")

 c = tableLength(results)

--for i=1,c do

 --gpu.set(1,i,"Energy gain "..i..": "..results[i].." RF/t")

--end

 if keyboard.isControlDown() then  comp.cleanUp() term.clear() os.exit() end

packet = serialization.serialize(results)

modem.broadcast(124, packet)

os.sleep(1)

coroutine.yield()

end

end

)

while true do

coroutine.resume(turbine)
coroutine.resume(cell)
if keyboard.isControlDown() then os.exit() end

end
