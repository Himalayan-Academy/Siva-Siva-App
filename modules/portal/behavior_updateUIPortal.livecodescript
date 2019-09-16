script "behavior_updateUIPortal"
global sConfigA
local sStartLoc,sScreenRect
local sLastImage, sMainImage,sBrandImageNumber


##################
-- At the top of this script we use functions and handlers
-- related to the logic of stack contents 
-- the idea is not to put that code in the binary stack
-- the stack is applied as a behavior to multiple cards
-- as such, you may need to include logic related related to a given card here
-- BR:
-- 2019-08 Caveat: Brian: the surprise card still has an old "behavior_PortalCard"
-- which we many need to deprecate and more the logic for behavior on the 
-- old "panel" navigation to here. I will leave that to you.

on preopenCard
   local pControl, pCard
   put the short name of this card into pCard
   
   setCardCoords "portrait"
   
   switch pCard
      case "Home"
         setUpBrandImage
         setDefaultImage
         put empty into fld "homeStoryText"
         put the long id of fld "homeStoryText" into pControl
         centerMe pControl,0,5
         break
      case "MainNav"
         hide button "goToMainNav" of group "footer" of me
         show button "goHome" of group "footer" of me
         break
   end switch
   
   updateUIPortal
   audioIsRunning
   
   show btn "brandLogo"
end preopenCard

on opencard
   News_Fetch
end opencard

command  setDefaultImage 
   --breakpoint
   
   local pImage, tPaths
   
   put getCache("BrandImage") into sBrandImageNumber
   put the long id of img "homeStoryMainImage" of card "Home" into sMainImage
   put _brandImages() into tBrandImages
   
   # will get this out when we close Sivasiva.app
   # the user get a new brand image only opening the app.
   
   setCache TotalBrandImages, tTotalBrandImages
   
   put line sBrandImageNumber of tBrandImages into pImage
   set the filename of sMainImage to brandImagePath(pImage)
   
  #  UI responsive
   put the long id of img "homeStoryMainImage" of card "Home" into sMainImage
   setImageToFullCardLoc sMainImage,"portrait",0,0
   centerMe sMainImage,0,0
   show btn "brandLogo"
   show sMainImage with visual effect "dissolve"
   
   # optimize disk operations *after* the display is finished updating
   
   put the number of lines of tBrandImages into tTotalBrandImages
   setPref "preferences/modules/portal/totalBrandImages", tTotalBrandImages
   
end  setDefaultImage

## I suppose there is a better way to store these
## to KISS suggest we do it right here.
## see the close stack handler for the number increment

private function _brandImages
   local tBrandImages
   put "app-img_who-is-siva_1200x800" & cr & \
         "app-img_06-sadasiva_opt-80_552w-portrait" & cr & \
         "app-img_01-sadyojata_opt-80_552w-portrait" & cr & \
         "app-img_02-vamadeva_opt-80_552w-portrait" & cr & \
         "app-img_03-aghora_opt-80_552w-portrait" & cr & \
         "app-img_03_painting_tree_552w-portrait" & cr & \
         "app-img_04-tatpurusha_opt-80_552w-portrait" & cr & \
         "app-img_05-ishana_opt-80_552w-portrait" & cr & \
         "app-img_28_sahasrara_736h-landscape" & cr & \
         "app-img_70's_siva_poster_552w-portrait" & cr & \
         "app-img_book_siva_face_736h-square" & cr & \
         "app-img_book_siva_yogi_big_736h-square" & cr & \
         "app-img_hap-0140_552w-portrait" & cr & \
         "app-img_shivlinga-amarnath-shiva_736h-landscape" & cr & \
         "app-img_sinha_9_552w-portrait" & cr & \
         "app-img_siva_552w-portrait"\
         into tBrandImages
   return tBrandImages
end _brandImages

function brandImagePath pImage
   local tPath
   put path_Assets() & "img/photography/" & pImage & "/" \
         & pImage & "_med.jpg" into tPath
   return tPath
end brandImagePath

--on closestack
--   saveUserPrefs sBrandImageNumber
--   pass closestack
--end closestack

-- BM:  From MainNav card script
command tellUserToGetFavorites 
   doAnswer "There are no Favorites in My Home yet. Go to the Journal." && \
         "Click the star by some of your Favorites. They will then appear in My Home", \
         "OK","downloadAffirmed"
end tellUserToGetFavorites

command downloadAffirmed
   lock screen
   portal_GoStack "Journal"
   unlock screen
end downloadAffirmed


#######################

command _RESPONSIVE
end _RESPONSIVE

#######################
-- RESPONSIVE CODE
-- This section is related to geometry of objects
-- Please do not place functions or handlers here
-- that relate to the stack content logic 
-- of course, if the content logic requires updating the binary
-- with new objects, then those object will need to added
-- to upDateUIPortal handler in the switch 
-- to deals with different cards
###############

--after preopencard
--   lock screen
--   setCardCoords "portrait"
--   updateUIPortal
--   unlock screen
--end preopencard


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
