---unit.OnStop(1)
unit.stopTimer(msgTag["default"])
unit.stopTimer(msgTag["inBin"])
unit.stopTimer(msgTag["outBin"])
unit.stopTimer(msgTag["screen"])
XFR1.stop()
Screen.setCenteredText(msgTitleAndVersion .. "\n\n STOPPED")
---eof