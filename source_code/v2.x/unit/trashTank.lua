--- time ... what does it do, anyway?

  longOperationPenalty               = 0
  longOperationPenaltyFactor         = 3
  
  local numberOfInstalledBalancers   = 8 --export Change this to however many PBs you will have running at the same time.
  successPenalty                     = 0
  successPenaltyMax                  = roundOff(roundUpToPrecision(1.2 * numberOfInstalledBalancers))
  
  loadsMoved                         = 0



  system.print(wss_software.id ..
":" .. OutputBin.getName() .. ":arming timer for first maximum first run delay in [" .. minutes[1] .. "] seconds")

unit.setTimer(wss_software.id, minutes[1])
