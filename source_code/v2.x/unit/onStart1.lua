--- unit.onStart(1)
wss_software = {}
wss_software.id = "xfer_unit_auto_scanner"
wss_software.title = "Transfer Unit Auto-Scanner / Auto-Balancer"
wss_software.version = "2.0.0"
wss_software.revision = "18 APR 2023 19h47 AST"
wss_software.author = "Michel Vaillancourt <902pe_gaming@wolfstar.ca>"

system.print("\n --------------- \n")
msgTitleAndVersion = wss_software.title .. "\n" .. wss_software.version
system.print(msgTitleAndVersion)

---

StatusMessageTable                 = {}
StatusMessageTable["XFRUL_Status"] = "Booting"
StatusMessageTable["XFR_Data"]     = { material = "Unknown", quantity = -1 }
StatusMessageTable["comment"]      = "Booting"

---
MsgTag                             = {}
MsgTag["default"]                  = wss_software.id
MsgTag["inBin"]                    = "_inputBinContents"
MsgTag["outBin"]                   = "_outputBinContents"
MsgTag["screen"]                   = "_updateScreen"

ContainerVisibleGrid               = 7 * 6

--- test stuff is plugged in
system.print("\n --------------- \n")
system.print(wss_software.id .. ":" .. XFRU.getClass() .. ":" .. XFRU.getName())
system.print(wss_software.id ..
":" ..
InputBin.getClass() .. ":" .. InputBin.getName() .. ":" .. RoundDownToPrecision(InputBin.getItemsVolume()) .. "L Used")
system.print(wss_software.id ..
":" ..
OutputBin.getClass() .. ":" .. OutputBin.getName() .. ":" .. RoundDownToPrecision(OutputBin.getItemsVolume()) .. "L Used")

OutputBinBigChunk = RoundDownToPrecision(OutputBin.getMaxVolume() / ContainerVisibleGrid)
OutputBinBigChunk = RoundOff(OutputBinBigChunk)

system.print(wss_software.id .. ": Transfer Chunk Cap will be " .. OutputBinBigChunk .. "L")

---
local lclFontName = "Montserrat-Light" --export
FontName = [["]] .. lclFontName .. [["]]
FontSize = 20                         --export

---
InputBinContents  = {}
OutputBinContents = {}

Screen.activate()
Screen.setCenteredText(msgTitleAndVersion .. "\n\n" .. OutputBin.getName() .. "\n\n BOOTING")

TickTimeSeconds = 32
unit.setTimer(MsgTag["inBin"], TickTimeSeconds * 0.1)
unit.setTimer(MsgTag["outBin"], TickTimeSeconds * 0.2)
unit.setTimer(MsgTag["screen"], TickTimeSeconds * 1.2)
---eof---