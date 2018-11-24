script "behavior_WordTile"

local sDragging,sMyHomes,sOneHome

On MouseDown
   # don't let user drag an image that was placed successfully: put the uWordLocations of me into sMyHomes
   
   if the uInPlace of me <> "true" then
      set the layer of me to top
      --     grab me
      put true into sDragging
   end if
end MouseDown


on mouseMove x,y
   if not sDragging then exit mouseMove
   set the loc of me to minMax(the rect of this cd)
   glowtile me, word 1 of checkHomeProximity()
end mouseMove

function minMax pRect -- get a point within bounds
   if pRect = "" then
      put the rect of this card into pRect
   end if
   put max(item 1 of pRect,min(item 3 of pRect,the mouseh)) into x
   put max(item 2 of pRect,min(item 4 of pRect,the mousev)) into y
   return x,y
end minMax


on mouseUp
   put me into tWhatControl
   -- outOfFrame
   put false into sDragging
   put checkHomeProximity() into tIsHome
   lockInPlace
   checkCompletion
end mouseUp

command lockInPlace
   put the long id of me into pTile
   set the loc of me to sMyHomes[sOneHome]
   set the uInPlace  of me to "true" 
   delete variable sMyHomes[sOneHome]
   set the uWordLocations of me to sMyHomes
   set the showborder of me to "false"
   relayer me after grc "startHere"
   --  runpixie  # deprecated for now... was in stack script... may resurrect in v2
   glowtile me, false
end lockInPlace

command clueGoHome
   put the uWordLocations of me into sMyHomes
   dispatch "setGlowTile" to this card with  "large" 
   relayer me to front of card "word-puzzle"
   glowtile me, true
end clueGoHome


on mouseRelease
  put false into sDragging
end mouseRelease

## We need to disallow dragging outside the bounds
## of the card:

command outOfFrame

   put the rect of this card into tBounds
   put the loc of me into tMyLoc
   put tMyLoc into tStartLoc
    
   switch
      case  ( (item 2 of tMyLoc) > (item 4 of tBounds) )
         put  (item 4 of tBounds -20) into tVaxis
         put tVaxis into item 2 of tMyloc
         put 1 into tOutOfBoundsFlag
         break
      case (item 2 of tMyLoc <0) 
         put 30 into item 2 of tMyloc
         put 1 into tOutOfBoundsFlag
         break
      case ( (item 1 of tMyLoc) > (item 3 of tBounds) )
         put item 3 of tBounds-20 into tHaxis
         put tHaxis into item 1 of tMyLoc
         put 1 into tOutOfBoundsFlag
         break
      case (item 1 of tMyLoc <0) 
         put 30 into item 1 of tMyloc
         put 1 into tOutOfBoundsFlag
   end switch
   if  tOutOfBoundsFlag = 1 then
      set the loc of me to tMyLoc
      put 0 into tOutOfBoundsFlat
   end if
   
   # MONITOR:
     --put tStartLoc & cr & tMyLoc & cr & tBounds
   
end outOfFrame

function checkHomeProximity # Cause tile to snap to location if close
   
   repeat for each key pLoc in sMyHomes
      put the abs of  (item 1 of the loc of me - item 1 of sMyHomes[pLoc]) into tLeftDistance
      put the abs of  (item 2 of the loc of me - item 2 of sMyHomes[pLoc]) into tTopDistance
      
      if (the abs of  (item 1 of the loc of me - item 1 of of sMyHomes[pLoc])  < 30) AND \
            (the abs of  (item 2 of the loc of me - item 2 of  of sMyHomes[pLoc]) <30) then
         --put pLoc into sOneHome
         lockInPlace
         return true
         exit repeat
      end if
   end repeat
   
   return false  
end checkHomeProximity


######## Problem wih this function:
## if you have multiple instances of the same word
## their cWord Prop is the same
## The match only finds the formatted rect of the first one
## the others will not return true when near their original locations.

-- function checkHomeProximity
--   put the cWord of me into tWord
--   put fld "_quote" into tQuote
--   set wholematches to true
--   put 0 into tSkip
--   repeat 
--     put wordOffset(tWord,tQuote,tSkip) into tNum
--     if tNum = 0 then return false -- shouldn't happen
--     put tNum+tSkip into tNum
--     if not the uInPlace of img ("word_" & tNum) then exit repeat
--     add tNum to tSkip
--   end repeat
--   get the formattedRect of word tNum of fld "_quote"
--   put item 1 to 2 of it into tTopleft
--   if spaceOpen(tTopleft) and (the mouseloc is within it) then
--     return "true" && tTopLeft
--   end if
--   return false  
-- end checkHomeProximity

-- function spaceOpen pTopLeft -- for imgs
--   repeat for each line l in the uWordlist of this cd
--     if l = the short name of me then next repeat
--     if the topleft of img l = pTopLeft then return false
--   end repeat
--   return true
-- end spaceOpen


on mouseDoubleDown pButtonNumber
   
end mouseDoubleDown


on mouseEnter
   
end mouseEnter
