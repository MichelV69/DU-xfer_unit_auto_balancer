local tagName = msgTag["inBin"]
unit.stopTimer(msgTag["inBin"])

if balancerIsFree() then
    local retrySeconds = InputBin1.updateContent()

    if retrySeconds == 0 then
        loadTablesForBalancing()
        successPenaltyUp()
        local nextCallSeconds = tickTimeSeconds + longOperationPenaltyFactor + getSuccessPenaltySeconds()
        unit.setTimer(msgTag["outBin"], nextCallSeconds)
    else
        statusMessageTable["comment"] = "(waiting for InputBin to answer)"
        unit.setTimer(tagName, retrySeconds)
    end
else
    unit.setTimer(tagName, minutes[2])
end
