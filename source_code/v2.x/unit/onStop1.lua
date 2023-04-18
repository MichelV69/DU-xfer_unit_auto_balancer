---unit.OnStop(1)
unit.stopTimer(MsgTag["default"])
unit.stopTimer(MsgTag["inBin"])
unit.stopTimer(MsgTag["outBin"])
unit.stopTimer(MsgTag["screen"])
XFRU.stop()
Screen.setCenteredText(msgTitleAndVersion .. "\n\n STOPPED")
---eof