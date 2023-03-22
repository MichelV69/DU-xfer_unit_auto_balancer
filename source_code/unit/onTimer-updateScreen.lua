local tagName = msgTag["screen"]
unit.stopTimer(tagName)

---===
tidyInBinContents = {}

for _, column in ipairs(inputBinsContents) do
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
updateBalancerStatusInfo()
renderScreen()

unit.setTimer(tagName, 0.5)
--- eof ---