--- unit.onStart()
wss_software ={}
wss_software.id = "xfer_unit_auto_scanner"
wss_software.title = "Transfer Unit Auto-Scanner / Auto-Balancer"
wss_software.version = "1.1.2"
wss_software.revision = "08 JAN 2023 11h15 AST"
wss_software.author = "Michel Vaillancourt <902pe_gaming@wolfstar.ca>"

system.print("\n --------------- \n")
msgTitleAndVersion = wss_software.title .. "\n" .. wss_software.version
system.print(msgTitleAndVersion)

---
precisionDigits = 2
precisionValue  = 10^precisionDigits
gramsToKG = 1000
minutes = {}
minutes[1] = 60
minutes[2] = minutes[1]*2
minutes[5] = minutes[1]*5

statusCodeTable = {}
statusCodeTable[1] = {state="Stopped"}
statusCodeTable[2] = {state="Pending"}
statusCodeTable[3] = {state="Jammed"}
statusCodeTable[4] = {state="Storage Full"}
statusCodeTable[5] = {state="No Output"}
statusCodeTable[6] = {state="Running"}
statusCodeTable[7] = {state="No Schemas"}

---
msgTag={}
msgTag["default"] = wss_software.id
msgTag["inBin"]  = "_inputBinsContents"
msgTag["outBin"] = "_outputBinContents"
msgTag["screen"] = "_updateScreen"

tickTimeSeconds = 21
containerVisibleGrid = 7 * 6

--- test stuff is plugged in
system.print("\n --------------- \n")
system.print(wss_software.id .. ":".. XFR1.getClass() .. ":" ..XFR1.getName())
system.print(wss_software.id .. ":".. InputBin1.getClass() .. ":" ..InputBin1.getName() .. ":"..roundDownToPrecision(InputBin1.getItemsVolume()) .. "L Used")
system.print(wss_software.id .. ":".. OutputBin.getClass() .. ":" ..OutputBin.getName() .. ":"..roundDownToPrecision(OutputBin.getItemsVolume()) .. "L Used")

outputBinBigChunk = roundDownToPrecision(OutputBin.getMaxVolume()/containerVisibleGrid)

system.print(wss_software.id .. ": Transfer Chunk Cap will be "..outputBinBigChunk.. "L")

---
local lclFontName= "Montserrat-Light" --export
FontName=[["]].. lclFontName ..[["]]
FontSize= 20 --export

---
inputBinsContents = {}
outputBinContents = {}

Screen.activate()
Screen.setCenteredText(msgTitleAndVersion .. "\n\n BOOTING")

system.print(wss_software.id..":" .. OutputBin.getName() .. ":arming timer for first maximum first run delay in ["..minutes[1].."] seconds")
unit.setTimer(wss_software.id, minutes[1]) 
unit.setTimer(msgTag["outBin"],tickTimeSeconds)
unit.setTimer(msgTag["screen"],tickTimeSeconds)

---eof---