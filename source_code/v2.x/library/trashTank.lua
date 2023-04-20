---
function balancerIsBusy()
  local balancerStatus = XFR1.getState()
  isBusy = false
  if balancerStatus == 2
      or balancerStatus == 3
      or balancerStatus == 6 then
    isBusy = true
  end
  return isBusy
end

function balancerIsFree()
  return (balancerIsBusy() == false)
end


---
function checkBalancer()
  statusMessageTable["XFRUL_Status"] = "Unknown"
  statusMessageTable["XFR_Data"] = { material = "Unknown", quantity = -1 }
  statusMessageTable["comment"] = "checkBalancer running"

  unit.stopTimer(wss_software.id)
  updateBalancerStatusInfo()


  longOperationPenalty = 0

  if balancerIsBusy() then
    statusMessageTable["comment"] = "XFRU-L busy on prior order"
    longOperationPenalty = tickTimeSeconds * longOperationPenaltyFactor

    if balancerIsJammed() then
      XFR1.stop()
      longOperationPenalty = 1
      forceExpireInputCache()
    end
  else
    runBalancer()
  end

  unit.setTimer(wss_software.id, tickTimeSeconds + longOperationPenaltyFactor)
end

---



---
function successPenaltyUp()
  successPenalty = successPenaltyMax
  return
end

---
function successPenaltyDown()
  successPenaltyFloor = 0
  successPenalty = successPenalty - 1
  if successPenalty < successPenaltyFloor then successPenalty = successPenaltyFloor end
  return
end



---
function getSuccessPenaltySeconds()
  return successPenalty * tickTimeSeconds
end

---
function loadsMovedUp()
  loadsMoved = loadsMoved + 1
  if loadsMoved > 2 then
    loadsMoved = 0
    forceExpireOutputCache()
  end
  return
end

---
function forceExpireOutputCache()
  statusMessageTable["comment"] = "Expiring cache"
  outputBinContents             = {}
  return
end

---
function forceExpireInputCache()
  statusMessageTable["comment"] = "Expiring cache"
  inputBinContents              = {}
  return
end

---
function balancerIsJammed()
  local balancerStatus = XFR1.getState()
  IsJammed = false
  if balancerStatus == 3 then
    IsJammed = true
  end
  return IsJammed
end

--- eof 