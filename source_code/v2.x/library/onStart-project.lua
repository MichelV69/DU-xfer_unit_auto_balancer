---
TimersAreRunning = false
function BootTimers()
  unit.setTimer(MsgTag["inBin"], TickTimeSeconds * 0.1)
  unit.setTimer(MsgTag["outBin"], TickTimeSeconds * 0.2)
  unit.setTimer(MsgTag["balance"], TickTimeSeconds * 1.0)
  unit.setTimer(MsgTag["screen"], TickTimeSeconds * 1.2)
  unit.setTimer(MsgTag["default"], TickTimeSeconds * 5.5)
  TimersAreRunning = true
end --- function BootTimers()

---
function StopAllTimers()
  unit.stopTimer(MsgTag["screen"])
  unit.stopTimer(MsgTag["inBin"])
  unit.stopTimer(MsgTag["outBin"])
  unit.stopTimer(MsgTag["balance"])
  unit.stopTimer(MsgTag["default"])
  TimersAreRunning = false
end --- function StopAllTimers()

---
function LoadInputBinInventory()
  -- stop timer
  local msgTag = MsgTag["inBin"]
  unit.stopTimer(msgTag)
  -- get input container contents
  local retrySeconds = InputBin.updateContent()

  -- if return time is zero do stuff
  if retrySeconds == 0 then
    local inBinItemList = InputBin.getContent()
    if #inBinItemList > 0 then
      InputBinContents = {}
      for _, column in ipairs(inBinItemList) do
        local quantity = RoundDownToPrecision(column.quantity)
        local item = system.getItem(column.id)
        local item_data = {
          column.id,
          item.locDisplayNameWithSize,
          quantity,
          item.iconPath
        }
        if quantity > (OutputBinBigChunk * 0.345) then
          table.insert(InputBinContents, item_data)
        end
      end
    end
    retrySeconds = TickTimeSeconds * 3
  end

  -- if return time is not zero, set timer to return time
  unit.setTimer(msgTag, retrySeconds)
end --- function  LoadInputBinInventory()

---
function LoadOutputBinInventory(reason)
  -- stop timer
  local msgTag = MsgTag["outBin"]
  unit.stopTimer(msgTag)

  if reason then
    StatusMessageTable["comment"] = "(chg in OutputBin detected)"
  else
    StatusMessageTable["comment"] = "(checking OutputBin)"
  end

  local retrySeconds = OutputBin.updateContent()

  if retrySeconds == 0 then
    local outBinItemList = OutputBin.getContent()
    if #outBinItemList > 0 then
      OutputBinContents = {}

      for _, column in ipairs(outBinItemList) do
        local quantity = RoundDownToPrecision(column.quantity)
        local item = system.getItem(column.id)
        local item_data = {
          column.id,
          item.locDisplayNameWithSize,
          quantity,
          item.iconPath
        }
        table.insert(OutputBinContents, item_data)
      end
    else
      StatusMessageTable["comment"] = "(waiting for OutputBin to answer)"
    end
  end

  if retrySeconds > 0 then
    unit.setTimer(msgTag, retrySeconds)
  end
end --- function LoadOutputBinInventory()

---
function RunBalancer()
  StatusMessageTable["XFRUL_Status"] = "Unknown"
  StatusMessageTable["XFR_Data"]     = { material = "Unknown", quantity = -1 }
  StatusMessageTable["comment"]      = "RunBalancer running"

  XFRU.stop()

  if #InputBinContents == 0
      or #OutputBinContents == 0
  then
    StatusMessageTable["comment"] = "Bin Data Not Yet Aquired"
    return
  end

  local col_quantity = 3
  local outputBinOreLitresAvailable = OutputBin.getMaxVolume() - OutputBin.getItemsVolume()
  table.sort(InputBinContents, function(a, b) return a[col_quantity] > b[col_quantity] end)

  for row, column in ipairs(InputBinContents) do
    local outputBinOreLitresRequired = OutputBinBigChunk
    local inputBinOreID              = column[1]
    local inputBinOreName            = column[2]
    local inputBinOreQTY             = column[3]

    StatusMessageTable["XFR_Data"]   = { material = inputBinOreName, quantity = -1 }
    StatusMessageTable["comment"]    = "Searching Output Bins - " .. inputBinOreName

    for row2, column2 in ipairs(OutputBinContents) do
      local outputBinOreID   = column2[1]
      local outputBinOreName = column2[2]
      local outputBinOreQTY  = column2[3]

      if outputBinOreID == inputBinOreID then
        outputBinOreLitresRequired = OutputBinBigChunk - outputBinOreQTY
      end
      StatusMessageTable["XFR_Data"] = { material = inputBinOreName, quantity = outputBinOreLitresRequired }
    end -- for row2, column2

    if outputBinOreLitresRequired < 0 then
      outputBinOreLitresRequired = 0
    end
    if outputBinOreLitresRequired > outputBinOreLitresAvailable then
      outputBinOreLitresRequired = 0
    end

    outputBinOreLitresRequired = RoundOff(outputBinOreLitresRequired)
    if outputBinOreLitresRequired > 0 then
      XFRU.setOutput(inputBinOreID)
      XFRU.startMaintain(OutputBinBigChunk)

      StatusMessageTable["XFR_Data"] = { material = inputBinOreName, quantity = OutputBinBigChunk }
      StatusMessageTable["comment"]  = "Transfer started"
      return
    end

    StatusMessageTable["XFR_Data"] = { material = "--", quantity = 0 }
    StatusMessageTable["comment"]  = "Inventory Balance OK"
  end -- for row, column

  return
end --- function RunBalancer()

---
function UpdateBalancerStatusInfo()
  local balancerStatus = XFRU.getState()
  StatusMessageTable["XFRUL_Status"] = StatusCodeTable[balancerStatus].state

  if balancerStatus == UNIT_WORKING
      and TimersAreRunning then
    StopAllTimers()
  end

  if balancerStatus ~= UNIT_WORKING
      and not TimersAreRunning then
    BootTimers()
  end

  return
end --- function UpdateBalancerStatusInfo()

--- eof ---
