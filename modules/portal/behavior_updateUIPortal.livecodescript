script "behavior_updateUIPortal"
after preopencard
   lock screen
   setCardCoords "portrait"
   updateUIPortal
   unlock screen
end preopencard


on resizeStack x,y,ox,oy
   lock screen
   -- When coming from a landscape stack, card rect is not updated correctly
   -- and the resizeStack is called with a landscape rect.  If an answer is
   -- inserted here, a second resizeStack gets sent with the correct rect.
   setCardCoords "portrait"
   updateUIPortal
   unlock screen
end resizeStack


command updateUIPortal
   local pControl, tBrandImage, tBottomMargin
   
   if safeBottomMargin() > 0 then
      put 0 into tBottomMargin
   else
      put 8 into tBottomMargin
   end if
   
   # background group of all cards
   
   put the long id of group "audioGlobalControl" of me into pControl
   topRightMe pControl,40,15
   
   put the long id of fld "Notification" of me into pControl
   topCenterMe pControl,150
   
   switch (the short name of this card)
      case "Home"
         if isMobile() then
            mobileHideStatusBar
         end if
         
         # Backgrond
         
         put the long id of btn "backgroundOverlay" into pControl
         centerMe pControl
         
         # Main Image
         # Opens SivaSiva Brand Image, which we locate
         # subsequent in image of content and managed 
         # from the home 
         
         put the long id of button "brandLogo" of me into pControl
         topCenterMe pControl,20
         
         
         put long Id of img "HomeStoryMainImage" into pControl
         put path_Assets()& "img/siva-darshan/who-is-siva_1200x800.jpg" into tBrandImage
         set filename of pControl to tBrandImage
         setImageToFullCardLoc pControl, "portrait", 0
         centerMe pControl, 0, 0
         
         
         put the long id of btn "goNext" into pControl
         bottomCenterMe pControl,tBottomMargin    
         ntInfo ("Go Next loc: " & location of  btn "goNext" )
         
         put the long id of button "openGlobalNav" into pControl
         bottomLeftMe pControl,0,tBottomMargin 
         
         break
         
      case  "mainNav"
         if getPhoneModel() is "iPhoneX" then
            mobileShowStatusBar
         end if
         
         put the long id of grp "footer" into pControl
         bottomCenterMe pControl,tBottomMargin
         
         put the long id of btn "backgroundOverlay" into pControl
         centerMe pControl
         
         put the long id of button "brandLogo" of me into pControl
         topCenterMe pControl,20
         
         put the long id of grp "globalPortalMap" into pControl
         topCenterMe pControl,55
         
         updatePortalMap
         
         break
         
   end switch
end updateUIPortal


command updatePortalMap
   constant kMap = "Gems,Surprise,Listen,Look,Practice,Read,Websites,Fun,Journal,My Home"
   constant kSpace = 15
   constant kEdge = 10
   constant kLogoOverlap = 26
   constant kMaxHeight = 100
   constant kMaxWidth = 190
   
   local tTop, tLeft, tBottom, tRight, tWidth, tHeight, tButtonID, tFieldID
   local tLeftLeft, tLeftRight, tRightLeft, tRightRight, tLeftSide, tRect, tExtraH, tExtraV
   
   put the bottom of button "brandLogo" of me - kLogoOverlap into tTop
   put the top of grp "footer" into tBottom
   put max(kEdge, safeSideMargin()) into tLeft
   put CardWidth() - tLeft into tRight
   
   put ((tBottom - tTop) / 5) - kSpace into tHeight
   if tHeight > kMaxHeight then
      put tHeight - kMaxHeight into tExtraV
      put kMaxHeight into tHeight
   else
      put 0 into tExtraV
   end if
   put (tRight - tLeft - kSpace) / 2 into tWidth
   if tWidth > kMaxWidth then
      put (tWidth - kMaxWidth) * 0.7 into tExtraH
      put kMaxWidth into tWidth
   else
      put 0 into tExtraH
      put 0 into tExtraV -- only add vertical space if horizontal space added
   end if
   put tLeft + tExtraH into tLeftLeft
   put tLeftLeft + tWidth into tLeftRight
   put tRight - tExtraH into tRightRight
   put tRightRight - tWidth into tRightLeft
   
   put true into tLeftSide
   repeat for each item tObjectName in kMap
      put the long id of btn tObjectName of grp "GlobalPortalMap" into tButtonID
      put the long id of fld tObjectName of grp "GlobalPortalMap" into tFieldID
      if tLeftSide then
         put tTop + tHeight into tBottom
         put (tLeftLeft, tTop, tLeftRight, tBottom) into tRect
         put false into tLeftSide
      else
         put (tRightLeft, tTop, tRightRight, tBottom) into tRect
         put tTop + tHeight + kSpace + tExtraV into tTop
         put true into tLeftSide
      end if
      set the rect of tButtonID to tRect
      set the width of tFieldID to tWidth
      set the bottomLeft of tFieldID to the bottomLeft of tButtonID
   end repeat
   
end updatePortalMap
