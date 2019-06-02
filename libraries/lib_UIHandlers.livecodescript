script "lib_UIHandlers"
local sCardRect,sCardWidth,sCardHeight, sCardLoc,sHorizCenter, sVertCenter
Local sCurrentGraphicRect,
************************
on __RESPONSIVE
end __RESPONSIVE

# because of inconsistency  we cannot be sure that resizeStack is invoked
# so we are setting explicit setters and getters  for card geometry

########################
-- Get card geometry 

command gotUILibrary
   answer "Go UIHandler Lib" with "OK"
end gotUILibrary



command setCardCoords x,y
   put the long id of this card into tCard
   put the rect of tCard into sCardRect
   put item 3 of sCardRect into sCardWidth
   put item 4 of sCardRect into sCardHeight
   --put x into sCardWidth
   --put y into sCardHeight
   put sCardWidth/2 into sHorizCenter
   put sCardHeight/2 into sVertCenter
   put the loc of tCard into sCardLoc
end setCardCoords


command setScreenRectCoords
   put the screenRect into tScreenRect
   put item 3 of tScreenRect into sScreenWidth
   put item 4 of tScreenRect into sScreenHeight
   put sScreenHeight/2 into sScreenVertCenter
   put sScreenwidth/2 into sScreenHorizCenter
   put sScreenWidth-sCardWidth into sWidthDiff
   put sScreenHeight-sCardHeight into sHeightDiff
   put  sHeightDiff into fld "notification"
end setScreenRectCoords


function CardRect
   return sCardRect
end CardRect

function CardWidth
   return sCardWidth
end CardWidth

function CardHeight
   return sCardHeight
end CardHeight

function CardLoc
   return sCardLoc
end CardLoc

function horizCenter
   return sHorizCenter
end horizCenter

function vertCenter
   return sVertCenter
end vertCenter


####################
-- positioning, various kinds
-- many of these methods would put the control it the same place
-- it is depend on whether you choose to "think" about it as 
-- relation to top of the card, of the bottom of the card

command centerMe pControl pHeaderHeight,pFooterHeight
   # use to center on screen, if the is a foot and header
   # you send those params and pcontrol center in remaining space.
   # This only handles vertical space
   
   put (cardHeight()-pHeaderHeight-pFooterHeight) /2 into tYaxis
   set the loc of pControl to ( horizCenter(),tYaxis )
   
end centerMe


command topCenterMe pControl,y
   # place a control at the bottom of the screen
   # can be any width, even beyond the width the card.
   # y is single integer which is from the top of card
   # It empty, defaults to center to screen
   
   set the loc of pControl to cardLoc()
   set the top of pControl to  y
   
end topCenterMe

command topRightMe pControl,x,y
   # for a control whose bounds are fully inside the card
   # use X to offset from the right of the card
   # and y is from the top 
   
   set topRight of pControl to (CardWidth()-x,y)
   
end topRightMe

command bottomRightMe pControl, x, y
   # for a control whose bounds are fully inside the card
   # use X to offset from the right of the card
   # and y to from the bottom.
   
   set  bottomright of pControl to (CardWidth()-x,CardHeight()-y)
   
end bottomRightMe

command bottomLeftMe pControl, x, y
   # for a control whose bounds are fully inside the card
   # use X to offset from the left  of the card
   # and y to from the bottom.
   
   set  bottomleft of pControl to (0+x,CardHeight()-y)
   
end bottomLeftMe

command bottomCenterMe pControl, y
   # place a control at the bottom of the screen
   # can be any width, even beyond the width the card.
   # Y is offset from the bottom
   
   set the loc of pControl to cardLoc()
   set the bottom of pControl to cardHeight()-y
end bottomCenterMe 

####################
on ___IMAGEManipulation
end ___IMAGEManipulation


# we typically have the some requirement
# change image by height, width.
# we always need to know it original size

command insertImageDimensions pImage
   put ( (the formattedwidth of pImage) & "x" & (the formattedheight of pImage) ) into sCurrentGraphicRect
end insertImageDimensions

function getRectOfCurrentGrc
   return sCurrentGraphicRect
end getRectOfCurrentGrc

command setRectOfCurrentGrc pimage
   put the formattedWidth of  pImage into tFWd
   put the formattedHeight of  pImage into tFHt
   put (tFWd & "x" & tFHt) into sCurrentGraphicRect
end setRectOfCurrentGrc

## NOTE: for the following handlers to work you must pass
## the rect in the form of  width x height  this this form ("736x552")
## and the long ID of the target image to "pImage" 

on resizeToHeight pImage,pSize
   set the itemdel to "x"
   put item 1 of sCurrentGraphicRect into tOrigImgWidth
   put item 2 of sCurrentGraphicRect into tOrigImgHeight
   # it may not be necessary
   if pSize > tOrigImgHeight then exit resizeToHeight
   put (pSize)/tOrigImgHeight  into tRatio
   put (tOrigImgWidth * tRatio) into tNewWidth
   put (tOrigImgHeight * tRatio) into tNewHeight
   set the rect of pImage to 0,0,tNewWidth,tNewHeight  
end resizeToHeight

on resizeToWidth pImage,pSize 
   set the itemdel to "x"
   put item 1 of sCurrentGraphicRect into tOrigImgWidth
   put item 2 of sCurrentGraphicRect into tOrigImgHeight
   # it may not be necessary
   if pSize > tOrigImgWidth then exit resizeToWidth
   put pSize/tOrigImgWidth into tRatio 
   put (tOrigImgWidth * tRatio) into tNewWidth
   put (tOrigImgHeight * tRatio) into tNewHeight
   set the rect of  pImage to 0,0,tNewWidth,tNewHeight
end resizeToWidth

#  when we want a background in to fill the screen
# but leave room for footer we can this
#  You must pass  the long id of the image, pOrientation,otherwise fails
# you do have to pass footer, 

command setImageToFullCardLoc pImage, pOrientation, x,y
   # param x = if you to want a shorter image
   setRectOfCurrentGrc pImage
   if pOrientation="portrait" then
      --      if isMobile() then
      --         resizeToHeight pImage,(the height of this card + sHeightDiff -  x)
      --         else
      resizeToHeight pImage,(the height of this card - x)
      --   end if
   else
      resizeTowidth pImage,(the height of this card - x)
   end if
end setImageToFullCardLoc

on toggleImgSize pImage, pFullSize, pTargetSize,pLocation 
   # we may not always this rect of the images from  the metadata
   # May as well just find out what it is right here.
   # pImage is the long ID of the image
   # you do not use "img ## to refer to it... just "pImage"
   
   -- if second param is empty we toggle it; otherwise set it as specified;
   -- called from main img script when tapped and when main cd closes to reset
   
   if pFullSize = "" then -- calculate if it's already full size
      put (the width of  pImage > the width of this cd) into pFullSize
      # true for landscape (width is greater); false for portrait (height is greater)
   end if
   put the formattedWidth of  pImage into tFWd
   put the formattedHeight of  pImage into tFHt
   
   if pFullSize then -- reduce to fit
      resizeToWidth pImage,pTargetSize
   else -- return to full size
      resizeToHeight pImage,tFHt
   end if
   
   # set the location of image, 
   # it is empty, assume to card rect
   if pLocation = empty then
      set the loc of  pImage to the loc of this cd
   else
      set the loc of  pImage to pLocation
   end if
end toggleImgSize



on ___VISUALEFFECTS
END ___VISUALEFFECTS

##########################################################
## VISUAL EFFECTS
##########################################################

--> GRAPHIC EFFECTS

## OuterGlow

function OuterglowA pTint,pColor,pBlendMode,pOpacity,pFilter,pSize,pSpread
   if pTint is empty then
      put pColor into outerglow["color"]
      put pBlendMode into  outerglow["blendMode"]
      put pOpacity into  outerglow["opacity"] 
      put pFilter into  outerglow["filter"]
      put pSize into  outerglow["size"]
      put pSpread into outerglow["spread"]
      returnouterglow
      exit outerGlowA
   end if
   put "color|blendMode|opacity|filter|size|spread" into pParams
   switch pTint
      case "softBrown"
         put "255,255,0|normal|255|box3Pass|30|50" into pValues
         break
   end switch
   set itemDel to "|"
   repeat with x =1 to 6
      put item x of pParams into pParam
      put item x of pValues into outerglow[pParam]
   end repeat
   return outerglow
   
end OuterglowA

--> GRADIENT SETTINGS

command setGradient pObject
   # Param "pObject" works locally with simple object reference like  graphic "header"
   # otherwise you should  pass the long ID of the object
   
   local tNewGradientArray
   
   # be careful when cutting and paste to and from email
   # tabs may get replace by spaces:
   
   put "from	208,-201|mirror	false|quality	good|ramp	0.13000,255,255,255,0" & return into tNewGradientArray
   put "0.62001,60,11,9,212|repeat	1|to	208,-304|type	linear|via	536,-201|wrap	true" after tNewGradientArray
   
   split tNewGradientArray by "|" and tab
   set the fillGradient of pObject to tNewGradientArray
   
end setGradient

--> FADE WITH BLENDLEVEL
-- Better to use dissolve.

# BR note that hide and show with visual effect "dissolve" also works, 
# tends to run very fast on mobile

command object_FadeIn  pEffectsTarget, newBlendLevel, someIncrement, someDelay
   set the blendLevel of  pEffectsTarget  to newBlendLevel
   if newBlendLevel > 0 then
      subtract someIncrement from newBlendLevel
      send "object_FadeIn pEffectsTarget, newBlendLevel,someIncrement,someDelay" to me in someDelay milliseconds
   else
      set the blendLevel of pEffectsTarget to 0
   end if
end object_FadeIn

command object_FadeOut  pEffectsTarget, newBlendLevel, someIncrement, someDelay
   set the blendLevel of  pEffectsTarget  to newBlendLevel
   if newBlendLevel <100 then
      add someIncrement to newBlendLevel
      send "object_FadeOut pEffectsTarget, newBlendLevel,someIncrement,someDelay" to me in someDelay milliseconds
   else
      set the blendLevel of pEffectsTarget to 100
   end if
end object_FadeOut


#####################
on __MOTION
end __MOTION

on moveMe pControlName, pHorz, pVert, pSpeed -- use move instead of visual effect to prevent Android issues
   # "moveControl" is a reserve message in LC 
   # hence the name "move Me" -- pass 0 pHorz for vertical move and 0 to pVert to horizontal move
   put pHorz,pVert into tPt
   move control pControlName relative tPt in pSpeed milliseconds
end moveMe


######################
on _STATUS_INDICATORS
end _STATUS_INDICATORS

command visMessageToUser pBool
   if there is a fld "notification" then
      if pBool then
         show fld "notification"
         send "visMessageToUser false" to the topstack in 2 second
      else
         hide fld "notification" 
      end if
   end if
end visMessageToUser

command display_SetStatusBarVis visBoolean
   if visBoolean then
      mobileShowStatusBar
   else
      mobileHideStatusBar
   end if        
end display_SetStatusBarVis

command showLoaderGIF pBool
   if exists (img "loader.gif") then
      if pBool is true then 
         show img "loader.gif"   
         set the repeatCount of img "loader.gif" to -1
      else 
         set the repeatCount of img "loader.gif" to 0    
         hide img "loader.gif"
      end if 
   end if 
end showLoaderGIF


# adopted from Gurudeva app by jacqueline land,am gay
on setGrpVis pGrpName,pLabel, pVis --jg: manages favorites and share groups with one handler
   -- Uses "move" which eliminates visual effect issues on Android
   --   -- pGrpName = short name of target grp 
   --   -- pLabel = message label
   --   -- pVis = boolean
   
   --   set the layerMode of grp pGrpName to "dynamic"
   --   if pVis then -- show it
   --      set the top of grp pGrpName to the height of this cd
   --      set the vis of grp pGrpName to true
   --      moveGrp pGrpName, -tVDist, cMoveSpeed
   --      highlightSelectedTab pLabel
   --      set the vis of grp "statusMessageControls" to pVis --jg: do it last on show, first on hide
   --   else -- hide it
   --      set the vis of grp "statusMessageControls" to pVis
   --      put the height of this cd - the top of grp pGrpName into tVDist
   --      moveGrp pGrpName, tVDist, cMoveSpeed
   --      set the vis of grp pGrpName to false
   --      clearTabHighlights
   --   end if
   --   set the layerMode of grp pGrpName to "static"
end setGrpVis

on revealSearchControls pVis --jg: combined reveal/hide handlers
   -- pVis = boolean
   
   if there is no grp "searchControls" then -- unplaced on current cd; just set vis & exit
      set the vis of bg "searchControls" to pVis
      exit revealSearchControls
   end if 
   if  pVis <> false  then -- show it
      --jg: horiz centering for mobile screens:
      set the loc of grp "searchControls" to the loc of this cd
      set the bottom of grp "searchControls" to 0
      put empty into fld "searchString" -- of card "Main-view"
      set the vis of group "searchControls" to true
      moveGrp "searchControls",0, the height of grp "searchControls", cMoveSpeed
      focus on fld "searchString" --jg: force mobile keyboard
      select after fld "searchString"
      -- highlightSelectedTab "search" # from gurudeva app, not implements
   else -- hide it
      focus on nothing
      moveGrp "searchControls",0, -(the height of grp "searchControls"), cMoveSpeed
      hide group "SearchControls"
      put empty into fld "searchString" 
      -- clearTabHighlights # from gurudeva app, not implements
   end if  
end revealSearchControls
command display_Log
   portal_GoStack "Log"
end display_Log

######################
-- Global Audio Controls

on  __AUDIO
end  __AUDIO

command audioIsRunning  
   # show global speaker when it installed  on a card
   # inside group audioGlobalControl 
   if runningAudioIndicatorVis() = "true" then
      if there is a widget "turnOffAudio"  then 
         show widget "turnOffAudio" 
      end if
   end if
end audioIsRunning

function runningAudioIndicatorVis visBool
   if isMobile() then
      put mobileControls() into tList
      if tList contains "audioPlayer" then 
         put "true" into sStopRunningAudio
      else
         put "false" into sStopRunningAudio
      end if
   end if
   return sStopRunningAudio
end runningAudioIndicatorVis

command turnOffAudio 
   # called by the speaker "widget" if it is showing
   if  sStopRunningAudio is "true" then
      
      # the audioPlayer exists, if may be paused.
      # we will start is again.  
      
      mobileControlDo "audioPlayer", "play"
      put "pause" into sStopRunningAudio
      
   else
      # delete it
      
      deleteMobileControl "audioPlayer"
      put "false" into sStopRunningAudio
      if exists (widget "turnOffAudio") then
         hide widget "turnOffAudio"
      end if
   end if
end turnOffAudio

function isAudioPlay
   repeat while pName is among the lines of mobileControls()
      mobileControlDelete pName
   end repeat
   
end isAudioPlay

