-- library.onStart(3)
-- configure screen template for output
function renderScreen()
  local ScreenTable = {}
  local input_percent  = roundDownToPrecision(InputBin1.getItemsVolume()/InputBin1.getMaxVolume())
  local output_percent = roundDownToPrecision(OutputBin.getItemsVolume()/OutputBin.getMaxVolume())
    
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
     local input_percent="]] ..containerLoadData(input_percent) .. [["
     local output_percent="]] ..containerLoadData(output_percent) .. [["
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

      itemListShort = #tidyInBinContents
      shortListNotice = "has "
      if itemListShort > 18 then 
        itemListShort = 18 
        shortListNotice = "is limited to the first "
        end
    
      publish_to = getRowColsPosition(layout, 1, vpos+1)
      textMessage = "Primary container list " .. shortListNotice .. #tidyInBinContents .. " items."
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
      vpos = tidy((layout.rows_high - itemListShort - screen_offset - index_offset)/2)

      for ptr=1,itemListShort do
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

    row = row + 2
    publish_to = getRowColsPosition(layout, col, row)
    textMessage = "Fill Level (Input Volume) [" .. input_percent .. "]"
    addText(layers["report_text"], FontText, textMessage, publish_to.x_pos + offset, publish_to.y_pos)    
    row = row + 1
    publish_to = getRowColsPosition(layout, col, row)
    textMessage = "Fill Level (Output Volume) [" .. output_percent .. "]"
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
--- eof --- 