local component = require("component")
local rs = component.redstone
local term = require("term")
local sides = require("sides")
local fs = require("filesystem")
local event = require("event")

term.clear()

while true do

local log = io.open("log", "a") 

print("Enter the password:")
password = term.read(_, _, _, "*")

if password=="brokendebug\n" then

  local _, _, _, _, name = event.pull()

  log:write("\n"..name.." successfully accessed the system as user")
  log:write("\n--------------------------------------------------------------------")

  print("Access granted.")
  rs.setOutput(sides.right, 15)
  os.sleep(5)
  rs.setOutput(sides.right, 0)

  log:close()

else print("Wrong password.")

local _, _, _, _, name = event.pull()

log:write("\n"..name.." unsuccessfully attempted to access the system")
  log:write("\n--------------------------------------------------------------------")

  os.sleep(5)

  log:close()

end

term.clear()

end