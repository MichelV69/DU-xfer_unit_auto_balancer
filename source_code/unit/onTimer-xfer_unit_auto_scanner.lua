local tagName = msgTag["default"]
unit.stopTimer(msgTag["default"])

checkBalancer()
unit.setTimer(tagName, tickTimeSeconds + longOperationPenaltyFactor)
--- eof ---
