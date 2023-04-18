local tagName = MsgTag["screen"]
unit.stopTimer(tagName)

---===
local tidyInBinContents = {}

if #InputBinContents then
  for _, column in ipairs(InputBinContents) do
    local itemID    = column[1]
    local quantity  = column[3]
    local item      = system.getItem(itemID)
    local item_data = { item.locDisplayNameWithSize, quantity }
    table.insert(tidyInBinContents, item_data)
  end
  col_quantity = 2
table.sort(tidyInBinContents, function(a, b) return a[col_quantity] > b[col_quantity] end)
---===

local json = require('dkjson')
Screen.setScriptInput(json.encode(tidyInBinContents))
else
  StatusMessageTable["comment"]    = "Still Searching Input Bins"
end

UpdateBalancerStatusInfo()
RenderScreen()

unit.setTimer(tagName, 0.5)
--- eof ---
