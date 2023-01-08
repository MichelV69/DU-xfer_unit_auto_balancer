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
function balancerIsBusy()
    local balancerStatus = XFR1.getState()
    isBusy = false
    if balancerStatus == 2
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
  statusMessageTable["XFR_Data"] = {material = "Unknown", quantity = -1}
  statusMessageTable["comment"] = "checkBalancer running"

  unit.stopTimer(wss_software.id)
  updateBalancerStatusInfo()
  
  if balancerIsBusy() then
    statusMessageTable["comment"] = "XFRU-L busy on prior order"
    else
    runBalancer()
    end

  unit.setTimer(wss_software.id, tickTimeSeconds)
  end

---
function runBalancer()
  statusMessageTable["XFRUL_Status"] = "Unknown"
  statusMessageTable["XFR_Data"] = {material = "Unknown", quantity = -1}
  statusMessageTable["comment"]  = "runBalancer running"
  
  XFR1.stop()
  updateBalancerStatusInfo()

  if #inputBinsContents == 0
    or #outputBinContents == 0
      then
        statusMessageTable["comment"] = "Bin Data Not Yet Aquired"
        return 
        end

  col_quantity=3
  table.sort(inputBinsContents, function(a, b) return a[col_quantity] > b[col_quantity] end)

  for row, column in ipairs(inputBinsContents) do --- 1
    inputBinOreLitresAvailable = column[3]
    outputBinOreLitresRequired = outputBinBigChunk
    inputBinOreID   = column[1]
    inputBinOreName = column[2]
    
    statusMessageTable["XFR_Data"] = {material = inputBinOreID, quantity = -1}
    statusMessageTable["comment"]  = "Searching Output Bins"
    
    oreNotFoundInOutputBin = true

    for row2, column2 in ipairs(outputBinContents) do
      if column2[1] == inputBinOreID then
        oreNotFoundInOutputBin = false
        outputBinOreLitresAlreadyPresent = column2[3]
        outputBinOreLitresRequired = outputBinBigChunk - outputBinOreLitresAlreadyPresent

        statusMessageTable["XFR_Data"] = {material = inputBinOreName, quantity = outputBinOreLitresRequired}

        if outputBinOreLitresRequired > inputBinOreLitresAvailable then outputBinOreLitresRequired = 0 end
        if outputBinOreLitresAlreadyPresent > inputBinOreLitresAvailable then outputBinOreLitresRequired = 0 end
      end
    end

    if oreNotFoundInOutputBin then
        outputBinOreLitresRequired = outputBinBigChunk
        if outputBinOreLitresRequired > inputBinOreLitresAvailable then outputBinOreLitresRequired = roundUpToPrecision(inputBinOreLitresAvailable / 2) end
        end

    if outputBinOreLitresRequired > 0 then
      XFR1.setOutput(inputBinOreID)
      XFR1.startFor(1)
      updateBalancerStatusInfo()

      statusMessageTable["XFR_Data"] = {material = inputBinOreName, quantity = outputBinOreLitresRequired}
      statusMessageTable["comment"]  = "Transfer started"
      return
      end

    updateBalancerStatusInfo()
    statusMessageTable["XFR_Data"] = {material = "--", quantity = 0}
    statusMessageTable["comment"]  = "Inventory Balance OK"
    end

    return
  end

---
function loadTablesForBalancing()

  outBinItemList = OutputBin.getContent()
  if #outBinItemList > 0 then
    outputBinContents = {}

      for _,column in ipairs(outBinItemList) do
        local quantity = math.floor((column.quantity*100)/100)
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
      for _,column in ipairs(inBinItemList) do
        local quantity = math.floor((column.quantity*100)/100)
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

  system.print(OutputBin.getName() .. ":loadTablesForBalancing: in/out: [" .. #inputBinsContents .. "/" .. #outputBinContents .. "]")
  end

---
function screenPulseTick()
    animationPulseIndex = animationPulseIndex + 1
    if animationPulseIndex > #screenPulseTable then animationPulseIndex = 1 end
    return screenPulseTable[animationPulseIndex]
    end
---
function renderScreen()
  local ScreenTable={}
  --Parameters (1)
   ScreenTable[1]=[[
     local FontName=]] .. FontName ..[[
     local FontSize=]] .. FontSize ..[[
     local S_Title="]] .. wss_software.title ..[["
     local S_Version="]] .. wss_software.version ..[["
     local S_Revision="]] .. wss_software.revision ..[["
     local timeStamp="]] .. epochTime() ..[[" 
     local xfer_l_name="]] ..OutputBin.getName() .. [["
     local XFRUL_Status="]] ..statusMessageTable["XFRUL_Status"] .. [["
     local XFR_material="]] ..statusMessageTable["XFR_Data"].material .. [["
     local XFR_quantity="]] ..statusMessageTable["XFR_Data"].quantity .. [["
     local comment="]] ..statusMessageTable["comment"] .. [["
     local notDeadYet="]] ..screenPulseTick() .. [["
   ]]

  -- general layout(2)
  ScreenTable[2]=[[
      --Layers
      local layers={}
      layers["background"]  = createLayer()
      layers["shading"]     = createLayer()
      layers["report_text"] = createLayer()
      layers["footer_text"] = createLayer()
      layers["header_text"] = createLayer()
      
      --util functions
      function tidy(valueToRound)
        precisionDigits = 2
        precisionValue  = 10^precisionDigits
        if valueToRound == nil then return 0 end
        local roundedValue = (math.floor(valueToRound * precisionValue) / precisionValue)
        return roundedValue
        end
        
      function getRowColsPosition(layout, col, row)
        if col > layout.cols_wide then col = layout.cols_wide end
        x_pos = (layout.col_width * col) + layout.margin_left
        if row > layout.rows_high then row = layout.rows_high end
        y_pos = (layout.row_height * row) + layout.margin_top
        return {x_pos = x_pos, y_pos = y_pos}
      end 
          
      --Scr Resolution
      local rx, ry=getResolution()
      local layout = {}
      layout.cols_wide = tidy(rx/(FontSize*1.2))
      layout.col_width = tidy(rx/layout.cols_wide)
      
      layout.rows_high = tidy(ry/(FontSize*1.2))
      layout.row_height = tidy(ry/layout.rows_high)
      
      layout.margin_top = tidy((ry * 0.1) / 2)
      layout.margin_bottom = layout.margin_top
      layout.margin_left = tidy((rx * 0.1) / 2)
      layout.margin_right = layout.margin_left
      
      --Font Setups
      local offsetStepPX = 24
      local fontSizeStep = 2
      local FontText=loadFont(FontName , FontSize)
      local FontTextSmaller=loadFont(FontName , FontSize - fontSizeStep)
      local FontTextBigger=loadFont(FontName , FontSize + fontSizeStep)
    ]]

    --get data to publish (3)
    ScreenTable[3]=[[
      local json=require('dkjson')
      local input=json.decode(getInput()) or {}
      local tidyInBinContents=input	
    ]]    
    
    -- header and footer (4)
    ScreenTable[4]=[[
      local vpos = 1
      publish_to = getRowColsPosition(layout, 1, vpos)
      textMessage = S_Title .. " v" .. S_Version .. " (" .. S_Revision .. ")"
      addText(layers["header_text"], FontTextSmaller, textMessage, publish_to.x_pos, publish_to.y_pos)
      
      publish_to = getRowColsPosition(layout, 1, vpos+1)
      textMessage = "There are " .. #tidyInBinContents .. " Rows of data to publish."
      addText(layers["header_text"], FontTextSmaller, textMessage, publish_to.x_pos, publish_to.y_pos)
  
      col = tidy(layout.cols_wide/3)
      row = layout.rows_high - 3
      
      publish_to = getRowColsPosition(layout, col, row)
      textMessage = "screen last updated: ["..timeStamp.."]"
      addText(layers["footer_text"], FontTextSmaller, textMessage, publish_to.x_pos, publish_to.y_pos)
    ]]

    --- bin contents listing (5)
    ScreenTable[5]=[[
      screen_offset = 2
      index_offset  = 1
      vpos = tidy((layout.rows_high - #tidyInBinContents - screen_offset - index_offset)/2)
      for ptr=1,#tidyInBinContents do
          local item = tidyInBinContents[ptr][1]
          local quantity = tidyInBinContents[ptr][2]
      
          local row = vpos + ptr
          local col = 2
          publish_to = getRowColsPosition(layout, col, row)
          textMessage = item .. ":"
          addText(layers["report_text"], FontText, textMessage, publish_to.x_pos, publish_to.y_pos)    
      
          offset = tidy(offsetStepPX * 0.8 * FontSize)
          textMessage = quantity
          addText(layers["report_text"], FontText, textMessage, publish_to.x_pos + offset, publish_to.y_pos)    
          end
     ]]

  --- XFR-U-L Status Display (6)
  ScreenTable[6]=[[
    
    offset = offsetStepPX * FontSize
    textMessage = xfer_l_name
    local row = vpos + 1
    local col = 2
    publish_to = getRowColsPosition(layout, col, row)
    addText(layers["report_text"], FontTextBigger, textMessage, publish_to.x_pos + offset, publish_to.y_pos)    

    row = row + 1
    publish_to = getRowColsPosition(layout, col, row)
    textMessage = "Status : "..XFRUL_Status
    addText(layers["report_text"], FontText, textMessage, publish_to.x_pos + offset, publish_to.y_pos)    

    row = row + 1
    publish_to = getRowColsPosition(layout, col, row)
    textMessage = "Working On : "..XFR_material.." ("..XFR_quantity..")"
    addText(layers["report_text"], FontText, textMessage, publish_to.x_pos + offset, publish_to.y_pos) 

    row = row + 1
    publish_to = getRowColsPosition(layout, col, row)
    textMessage = "Of Note : "..comment
    addText(layers["report_text"], FontText, textMessage, publish_to.x_pos + offset, publish_to.y_pos)    

    row = row + 2
    publish_to = getRowColsPosition(layout, col, row)
    textMessage = notDeadYet
    addText(layers["report_text"], FontText, textMessage, publish_to.x_pos + offset, publish_to.y_pos)    
   
  ]]
  
  --Animation (7)
  ScreenTable[7]=[[
    requestAnimationFrame(5)
  ]]

  --RENDER
   function ScreenRender()
    local screenTemplate=table.concat(ScreenTable)

    Screen.setRenderScript(screenTemplate)
   end
   ScreenRender()
  end
---
--- eof ---