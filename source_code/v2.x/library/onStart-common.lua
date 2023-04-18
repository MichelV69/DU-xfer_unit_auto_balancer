-- library.onStart-common
-- define key functions and globals for use elsewhere
---
--- Global
PrecisionDigits                    = 2
PrecisionValue                     = 10 ^ PrecisionDigits
GramsToKG                          = 1000
Minutes                            = {}
Minutes[1]                         = 60
Minutes[2]                         = Minutes[1] * 2
Minutes[5]                         = Minutes[1] * 5
AnimationPulseIndex                = 1

function RoundUpToPrecision(valueToRound)
  if valueToRound == nil then return 0 end
  local roundedValue = (math.ceil(valueToRound * PrecisionValue) / PrecisionValue)
  return roundedValue
end

---
function RoundDownToPrecision(valueToRound)
  if valueToRound == nil then return 0 end
  local roundedValue = (math.floor(valueToRound * PrecisionValue) / PrecisionValue)
  return roundedValue
end

---
function RoundOff(valueToRound)
  if valueToRound == nil then return 0 end
  local roundedValue = math.floor(RoundUpToPrecision(valueToRound))
  return roundedValue
end

---
function ScreenPulseTick()

  local screenPulseTable             = {}
  screenPulseTable[1]                = "[-=+     ]"
  screenPulseTable[2]                = "[ -=+    ]"
  screenPulseTable[3]                = "[  -=+   ]"
  screenPulseTable[4]                = "[   -=+  ]"
  screenPulseTable[5]                = "[    -=+ ]"
  screenPulseTable[6]                = "[     -=+]"
  screenPulseTable[7]                = "[     -+=]"
  screenPulseTable[8]                = "[     +=-]"
  screenPulseTable[9]                = "[    +=- ]"
  screenPulseTable[10]               = "[   +=-  ]"
  screenPulseTable[11]               = "[  +=-   ]"
  screenPulseTable[12]               = "[ +=-    ]"
  screenPulseTable[13]               = "[+=-     ]"
  screenPulseTable[14]               = "[=+-     ]"
  screenPulseTable[15]               = "[=-+     ]"

  AnimationPulseIndex = AnimationPulseIndex + 1
  if AnimationPulseIndex > #screenPulseTable then AnimationPulseIndex = 1 end
  return screenPulseTable[AnimationPulseIndex]
end

function ContainerFilledBar(input_percent)
  local mt          = "_"
  local lo          = "-"
  local med         = "+"
  local hi          = "="

  local maxBarWidth = 10
  local fill_bar    = ""
  local barEmpty    = math.ceil(maxBarWidth * (1 - input_percent))
  local barFilled   = maxBarWidth - barEmpty

  local fillCap     = 3
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

--- eof ---
