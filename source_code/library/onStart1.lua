-- library.onStart(1)
-- define key functions for use elsewhere
---
function roundUpToPrecision(valueToRound)
  if valueToRound == nil then return 0 end
  local roundedValue = (math.ceil(valueToRound * precisionValue) / precisionValue)
  return roundedValue
end

---
function roundDownToPrecision(valueToRound)
  if valueToRound == nil then return 0 end
  local roundedValue = (math.floor(valueToRound * precisionValue) / precisionValue)
  return roundedValue
end

---
function roundOff(valueToRound)
  if valueToRound == nil then return 0 end
  local roundedValue = math.floor(roundUpToPrecision(valueToRound))
  return roundedValue
end

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
function updateBalancerStatusInfo()
  local balancerStatus = XFR1.getState()
  statusMessageTable["XFRUL_Status"] = statusCodeTable[balancerStatus].state
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
function runBalancer()
  statusMessageTable["XFRUL_Status"] = "Unknown"
  statusMessageTable["XFR_Data"]     = { material = "Unknown", quantity = -1 }
  statusMessageTable["comment"]      = "runBalancer running"

  XFR1.stop()
  updateBalancerStatusInfo()

  if #inputBinsContents == 0
      or #outputBinContents == 0
  then
    statusMessageTable["comment"] = "Bin Data Not Yet Aquired"
    return
  end

  col_quantity = 3
  table.sort(inputBinsContents, function(a, b) return a[col_quantity] > b[col_quantity] end)

  for row, column in ipairs(inputBinsContents) do --- 1
    inputBinOreLitresAvailable     = column[3]
    outputBinOreLitresRequired     = outputBinBigChunk
    inputBinOreID                  = column[1]
    inputBinOreName                = column[2]

    statusMessageTable["XFR_Data"] = { material = inputBinOreID, quantity = -1 }
    statusMessageTable["comment"]  = "Searching Output Bins"

    oreNotFoundInOutputBin         = true

    for row2, column2 in ipairs(outputBinContents) do
      if column2[1] == inputBinOreID then
        oreNotFoundInOutputBin = false
        outputBinOreLitresAlreadyPresent = column2[3]
        outputBinOreLitresRequired = outputBinBigChunk - outputBinOreLitresAlreadyPresent

        statusMessageTable["XFR_Data"] = { material = inputBinOreName, quantity = outputBinOreLitresRequired }

        if outputBinOreLitresRequired > inputBinOreLitresAvailable then outputBinOreLitresRequired = 0 end
        if outputBinOreLitresAlreadyPresent > inputBinOreLitresAvailable then outputBinOreLitresRequired = 0 end
      end
    end

    if oreNotFoundInOutputBin then
      outputBinOreLitresRequired = outputBinBigChunk
      if outputBinOreLitresRequired > inputBinOreLitresAvailable then
        outputBinOreLitresRequired = roundUpToPrecision(inputBinOreLitresAvailable / 4)
      end
    end

    outputBinOreLitresRequired = roundOff(outputBinOreLitresRequired)
    if outputBinOreLitresRequired > 0 then
      XFR1.setOutput(inputBinOreID)
      XFR1.startFor(1)
      updateBalancerStatusInfo()

      statusMessageTable["XFR_Data"] = { material = inputBinOreName, quantity = outputBinOreLitresRequired }
      statusMessageTable["comment"]  = "Transfer started"
      loadsMovedUp()
      return
    end

    updateBalancerStatusInfo()
    statusMessageTable["XFR_Data"] = { material = "--", quantity = 0 }
    statusMessageTable["comment"]  = "Inventory Balance OK"
  end

  return
end

---
function loadTablesForBalancing()
  outBinItemList = OutputBin.getContent()
  if #outBinItemList > 0 then
    outputBinContents = {}

    for _, column in ipairs(outBinItemList) do
      local quantity = math.floor((column.quantity * 100) / 100)
      local item = system.getItem(column.id)
      local item_data = {
        column.id,
        item.locDisplayNameWithSize,
        quantity,
        item.iconPath
      }
      table.insert(outputBinContents, item_data)
    end
  end

  inBinItemList = InputBin1.getContent()
  if #inBinItemList > 0 then
    inputBinsContents = {}
    for _, column in ipairs(inBinItemList) do
      local quantity = math.floor((column.quantity * 100) / 100)
      local item = system.getItem(column.id)
      local item_data = {
        column.id,
        item.locDisplayNameWithSize,
        quantity,
        item.iconPath
      }
      table.insert(inputBinsContents, item_data)
    end
  end
end

---
function screenPulseTick()
  animationPulseIndex = animationPulseIndex + 1
  if animationPulseIndex > #screenPulseTable then animationPulseIndex = 1 end
  return screenPulseTable[animationPulseIndex]
end

function containerLoadData(input_percent)
  mt          = "_"
  lo          = "-"
  med         = "+"
  hi          = "="

  maxBarWidth = 10
  fill_bar    = ""
  barEmpty    = math.ceil(maxBarWidth * (1 - input_percent))
  barFilled   = maxBarWidth - barEmpty

  fillCap     = 3
  if fillCap > barFilled then fillCap = barFilled end
  for i = 1, fillCap, 1
  do
    fill_bar = fill_bar .. lo
    barFilled = barFilled - 1
  end

  fillCap = 3
  if fillCap > barFilled then fillCap = barFilled end
  for i = 1, fillCap, 1
  do
    fill_bar = fill_bar .. med
    barFilled = barFilled - 1
  end

  fillCap = 3
  if fillCap > barFilled then fillCap = barFilled end
  for i = 1, fillCap, 1
  do
    fill_bar = fill_bar .. hi
    barFilled = barFilled - 1
  end

  for i = 1, barEmpty, 1
  do
    fill_bar = fill_bar .. mt
  end

  return fill_bar
end

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

--- eof ---
