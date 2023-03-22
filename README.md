# Transfer Unit Auto-Scanner / Auto-Balancer

## rlease version / revision 
 + 1.1.9 / 22 MAR 2023 12h30 AST

## contact 
  + "Michel Vaillancourt <902pe_gaming@wolfstar.ca>"
  + https://www.twitch.tv/902pe_gaming

# Purpose

* Allows a single "Transfer Unit Large" (XFRU-L) to keep two containers inventories similiar on a batch-by-batch basis. If the "Primary" or "Input" container has 11 different sets of items in it, this can potentially result in over a half-million quanta per pair of containers. Further, it dramatically simplifies small "omni-factory" builds.
* Allows simple oversight of container-set inventories via glance-at screens.

# DRM / Fees
  + None.
  + Given that a single XFRU-L is 70,000q, I probably just saved you a bundle with this project. I'll happily accept donations, but they are *not* required.
    + In-game Name: PE902Gaming

# Warranty
  + No. Use at your own risk. I use it, it works, but you aren't me (be happy about that).

# Requirements

  + Two (2) Containers, Size Small or larger.
    * *NB* : If there is a size difference, the Primary or Input Container should be the larger of the two containers.
  + One (1) "Programming Board XS"
  + One (1) "Transfer Unit L"
  + One (1) Screen Unit of any size.
    * Currently only "landscape format" screens have been tested.
    * *NB* : Many large screens in an area will cause a substantial FPS impact. This is a known issue with the game engine.
      * I personally use "Modern Screen S" and it seems to be okay up to a dozen or so in my factory.
      
# Installation

  1. Deploy the containers.
      1. Load the "Primary" or "Input" Container with whatever items you wish stacks of automatically moved to the "Secondary" or "Output" Container.
      1. Manually move one (1) unit of an item into the "Secondary" or "Output" Container.
      * *NB* : 'Balancing' / 'Batch-Transfer' operations ***will not run*** until you do this.
  1. Deploy the "Transfer Unit L" and link the two (2) containers, as usual.
  1. Deploy the "Programming Board XS"
  1. Copy-Paste the JSON LUA of the latest version of the script to the "Programming Board XS".
    * Right-Click the "Programming Board XS", select "Advanced", then select "Paste Lua configuration from clipboard"
  1. Enter Build Mode for your factory, select the "Link Elements Tool", right-click the "Programming Board XS", click "Select an OUT plug to link to ...", select "[XFR1, Control] and link to it as usual.
      1. Repeat this process for the "Screen", the "InputBin1", and the "OutputBin"
      1. Exit Build Mode
  1. "Activate" the "Programming Board XS" and watch the LUA channel for activity.
      1. The Screen should light up after a moment.
  1. The "Transfer Unit L" should start working on it's first batch within two (2) minutes, depending on how busy your factory is. 

# Behaviour Issues

  1. The software is very "chatty" in the LUA channel. 
      1. It's going to stay that way for a while until I'm completely convinced it does what I think it should.
    
# Known Issues (this release)

  1. ***(FIXED)*** The time stamp is in raw seconds, and not human-friendly.
  1. ***(TBFxd)*** The software is very "chatty" in the LUA channel.
      1. Some work done on this; moving a lot of the diagnoistic info to the screen.
  1. ***(FIXED)*** The more of these things there are, the less accurate they get because of polling lag forced by NQ.
      1. Add a "success penalty" to force Balancers with fresh data to go to the back of the line.
  1. ***(TBFxd)*** Directly related to the above item, you might find that with a lot of these running a couple of them
   get "overzealous" about transfering ALL THE THINGS from Primary to Secondary. Until I get the polling system written, 
   every once in a while, it's worth manually moving everything from Secondary back to Primary and then letting it
   re-balance.
      1. This might be a non-issue for super busy factories where the Secondary is getting pulled from heavily.
      I'm running an Omni-factory build, so every once in a while its a minor pest.

# Thanks To

  + Novian:    Aviator1280 (example code)
  + Novian:    LocuraDU (example code)
  + Novian:    Jericho1060 (example code)
  + Web Tool:  https://onlinejsontools.com/prettify-json (human-readable JSON)
