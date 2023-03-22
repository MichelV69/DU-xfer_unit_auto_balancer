local tagName = msgTag["outBin"]
unit.stopTimer(msgTag["outBin"])

if balancerIsFree() then
  local retrySeconds = OutputBin.updateContent()

  if retrySeconds == 0 then
    loadTablesForBalancing()
    local nextCallSeconds = tickTimeSeconds + longOperationPenaltyFactor
    unit.setTimer(msgTag["inBin"], nextCallSeconds)
  else
    statusMessageTable["comment"] = "(waiting for OutputBin to answer)"
    unit.setTimer(tagName, retrySeconds)
  end
else
  unit.setTimer(tagName, minutes[2])
end
--- eof ---
