script "behavior_ImagePuzzles"
global gPuzzleLevel
local sTargetOwner, sTarget
local sIsHome,sImageForTiles
local sTiles,sMsg, sMyHome

on preOpenStack
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
      set the fullscreenmode of this stack to empty
      iphoneSetAudioCategory "playback" 
   end if
end preOpenStack

on preopenCard
   setCardCoords "portrait"
end preopencard

on opencard
   local tShortName
   put the short name of this card into tShortName
   
   switch tShortName
      case "Title"  
         visual effect "dissolve" very slow
         send "go to card 2" to me in 500 milliseconds
         break
         
         
   end switch
   
   
end opencard


on mouseup
   local tTips
   
   put the short name of the owner of the target into sTargetOwner
   put the short name of the target into sTarget
   
   switch sTarget
      case "backArrow"
         portal_GoStack ("Siva-Siva-Portal")
         break
         
      case "Make a Puzzle"
         toggleInfoPanel
         
         makePuzzle
         break
         
      case "infoPanel"
         toggleInfoPanel
         break
         
         
         -- INFO PANEL BEHAVIOR 
         
         
         
         
         
         -- UTILITiES
         
      case "Clear"
         clearImageTiles
         break
         
      case "Store"
         local uImageGanesh1
         put (the rect of  img "mah36lin.jpg") into uImageGanesh1["rect"]
         put the imageData of  img "mah36lin.jpg" into uImageGanesh1["image"]
         set the uImage_puzzle1 of this stack to uImageGanesh1
         break
         
         
         
         
   end switch
end mouseup

   -------------- 
   local tImageWidth, tImageHeight, tImageData
   local tInitialLeft, tInitialTop, tTileNumber, tCrossCount
   local tTileWidth,tTileheight,tRightEdge,tBottomEdge
   local tLeftCoord,tTopCoord
   
on makePuzzle
   clearImageTiles
   lock screen
   
   put the rect of the last image into tImageData["rect"]
   put the imageData of the last image into tImageData["image"]
   set the name of the last image to "currentpuzzle"
      
   set the rect of grc "puzzleFrame" to  tImageData["rect"]
   set the loc of grc "puzzleFrame" to the loc of this card
   show grc "puzzleFrame"
   
   put the width of img "currentpuzzle"  into tImageWidth
   put the height of img "currentpuzzle"   into tImageHeight
   put the left of image "currentPuzzle" into  tInitialLeft
   put the top of image "currentPuzzle" into tInitialTop
   
   if gPuzzleLevel is empty then
      put 4 into gPuzzleLevel
      set the hilitedbutton of group "puzzleLevels" to btn "4"
   end if
   
   put 1 into tTileNumber
   
   put sqrt(gPuzzleLevel) into tCrossCount
   
   put tImageWidth/tCrossCount into tTileWidth
   put tImageheight/tCrossCount into tTileHeight
   put (tTileWidth+tInitialLeft) into tRightEdge # initialize first tile location
   put (tTileHeight+tInitialTop) into tBottomEdge
   put tInitialLeft into tLeftCoord
   put tInitialTop into tTopCoord
   
   local tNextTileName, tTileLocation,tTileList
   # do one row at a time horizontally
   repeat tCrossCount Times
      # Each iteration we drop down one row (see below)
      
      repeat tCrossCount times #1 row across
         copy img "CurrentPuzzle" to this card
         put "tile_" & tTileNumber into tNextTileName
         set the name of the last Image to tNextTileName
         crop image tNextTileName  to tLeftCoord, tTopCoord, tRightEdge, tBottomEdge
         put the loc of image tNextTileName into tTileLocation
         set the uTileLocation of image tNextTileName to tTileLocation
         # put tTileLocation & cr after tLocations  #MONITOR
         put tNextTileName & cr after tTileList
         set the behavior of image tNextTileName to the long id of btn "tileScript"
         
         add tTileWidth to tLeftCoord
         add tTileWidth to tRightEdge
         add 1 to tTileNumber
      end repeat
      
      #initialize locations for the next row
      
      # first drop down one tile height
      add tTileHeight to  tTopCoord 
      
      # move back to the left edge
      put tInitialLeft into tLeftCoord
      
      # reset right edge
      put (tTileWidth+tInitialLeft) into tRightEdge
      
      # set a new bottom coordinate
      # based on the current top of this row of tiles
      put (tTileHeight  + tTopCoord) into tBottomEdge
      
   end repeat
   
   
   set the uTileList of this card to tTileList
   delete img "CurrentPuzzle"
   unlock screen
   distributeTiles
   # put tLocations & cr & cr & tCoords #MONITOR
end makePuzzle

on distributeTiles
   local tTilesShelf,tShelfWidth
   local tShelfheight,tX,tY
   
   put the uTileList of this card into sTiles
   repeat for each line x in sTiles
      # set up random locations that fall inside the Scattered Tile Zone area
      # left position at least 100 pixels from the edge for long words 
      # put the rect of grc "tilesShelf" into tTilesShelf
      put the rect of this card into tTilesShelf
      split tTilesShelf by "," 
      
      # Use a hidden grc as the location for tiles
      -- put (the width of grc "tilesShelf")-120 into tShelfWidth
      --  put (the height of grc "tilesShelf")-120 into tShelfHeight
      
      # Use the whole card for spreading out tiles
      
      put (the width of this card) -100 into tShelfWidth
      put (the height of this card) -100 into tShelfheight
      
      put random(tShelfWidth) + (tTilesShelf[1])+60 into tX
      put random(tShelfHeight) + (tTilesShelf[2])+50 into tY
      
      #set the loc of img x to tX,tY
      move img x to  tX,tY in 80 milliseconds
   end repeat
end distributeTiles

command toggleInfoPanel
   if the bottom of grp "makeTiles"  >  800 then 
      move grp "makeTiles"  relative 0,-120 without waiting
   else 
      move grp "makeTiles"   relative  0,120 without waiting
   end if
end toggleInfoPanel

on clearImageTiles
   hide grc "puzzleFrame"
   
   try
      repeat with x = 1 to 200
         delete image ("tile_" & x)
      end repeat
   end try
   set the uTileList of this card to empty
   
end clearImageTiles

on checkCompletion 
   local  tTargetLocs,tImgLocs
   
  put the uTileList of this card into sTiles 
  repeat for each line x in sTiles 
    put the uTileLocation of img x & cr after tTargetLocs 
    put the loc of img x & cr after tImgLocs 
  end repeat 
  sort tTargetLocs numeric by item 2 of each 
  sort tImgLocs numeric by item 2 of each 
  sort tTargetLocs numeric by item 1 of each 
  sort tImgLocs numeric by item 1 of each 
  if tTargetLocs = tImgLocs then 
       #stopTimer 
      put "Congratulations! " & cr & "You did it!" into sMsg
   fireCompletedAction sMsg
  end if 
end checkCompletion 

command fireCompletedAction pMsg
   answer pMsg with "OK"
end fireCompletedAction


function checkHomeProximity # Cause tile to snap to location if close
   local tLeftDistance, tTopDistance
   put the uTileLocation of me into sMyHome
   put the abs of  (item 1 of the loc of me - item 1 of sMyHome) into tLeftDistance
   put the abs of  (item 2 of the loc of me - item 2 of sMyHome) into tTopDistance
   
   if (the abs of  (item 1 of the loc of me - item 1 of sMyHome)  < 20) AND \
         (the abs of  (item 2 of the loc of me - item 2 of sMyHome) <20) then
      return "true" 
   else
      
      return false  
   end if
end checkHomeProximity


function getLocation tCoords
   local theX, theY
     put trunc ( (item 3 of tCoords - item 1 of tCoords)/2)  + trunc ( ( item 1 of tCoords) ) into theX
      put trunc ( (item 4 of tCoords - item 2 of tCoords)/2)  + trunc (item 2 of tCoords) into theY
      return (theX,theY)
end getLocation


------------
on closestack
   portal_SetLastStack "imagepuzzles"
end closestack
