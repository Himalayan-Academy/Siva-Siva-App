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

on preOpenCard
   local pControl, pCard
   put the short name of this card into pCard
   setCardCoords "portrait"
   put the long id of img "homeMainImage" of card "Home" into sMainImage
   
   
   # init set up
   
   hide img  "homeMainImage" 
   show  btn "backgroundOverlay" 
   show img  "hideNavMandala" 
   hide img  "showNavMandala" 
   dispatch "setGlobalNavVisible" to widget "globalNavTree" with "false"
   switch pCard
      case "Home"
         show grp "navMandala" 
         setUpBrandImage
         setDefaultImage
         break
      case "read-menu"
         --set the filename of sMainImage to brandImagePath(pImage)
         
         
         break
         
   end switch
   
   updateUIPortal
   
   show btn "brandLogo"
end preOpenCard

on opencard
   audioIsRunning    
end opencard


#######################

command _USER_INTERACTION
end _USER_INTERACTION

on mouseup 
   local tTarget
   put the short name of the target into tTarget
   
   --switch (the short name of this card)
      --case "Home"
         switch tTarget
            case "hideNavMandala"
               hide btn "brandLogo"
               hide grp "globalNavTree"
               hide grp "navMandala"
               hide btn "backgroundOverlay"
               show img "homeMainImage"
               show img "showNavMandala"
               hide img "hideNavMandala"
               break
            case "showNavMandala"
               show btn "brandLogo"
               hide grp "globalNavTree"
               show btn "backgroundOverlay"
               hide img "homeMainImage"
               show grp "navMandala"
               hide img "showNavMandala"
               show img "hideNavMandala"
               break
         end switch
         
 --end switch
end mouseup

#######################

command setDefaultImage 
   --breakpoint
   
   #  see lib_SivaSiva | setUpBrandImage  
   # where we set the cache with a branc image number 
   
   local pImage, tPaths, tBrandImages, tTotalBrandImages
   
   put getCache("BrandImage") into sBrandImageNumber
   put the long id of img "homeMainImage" of card "Home" into sMainImage
   put _brandImages() into tBrandImages
   
   # will get this out when we close Sivasiva.app
   # the user get a new brand image only opening the app.
   
   # variable is undefined at this point
   --setCache "TotalBrandImages", tTotalBrandImages
   
   put line sBrandImageNumber of tBrandImages into pImage
   set the filename of sMainImage to brandImagePath(pImage)
   
   #  UI responsive
   put the long id of img "homeMainImage" of card "Home" into sMainImage
   setImageToFullCardLoc sMainImage,"portrait",0,0
   centerMe sMainImage,0,0
   show btn "brandLogo"
   show sMainImage with visual effect "dissolve"
   
   # optimize disk operations *after* the display is finished updating
   
   put the number of lines of tBrandImages into tTotalBrandImages
   setPref "preferences/modules/portal/totalBrandImages", tTotalBrandImages
   
end setDefaultImage

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
         "app-img_04-tatpurusha_opt-80_552w-portrait" & cr & \
         "app-img_05-ishana_opt-80_552w-portrait" & cr & \
         "app-img_hap-0140_552w-portrait" & cr & \
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
   
   switch (the short name of this card)
      case "Home"
         if isMobile() then
            mobileHideStatusBar
         end if
         
         # background
         
         put the long id of button "brandLogo" of me into pControl
         topCenterMe pControl,0
         
         put the long id of btn "backgroundOverlay" into pControl
         centerMe pControl
         
         # home image
         
         put long Id of img "HomeMainImage" into pControl
         setImageToFullCardLoc pControl, "portrait", 0
         centerMe pControl, 0, 0
         
         # bButtons and Nav
         
         put the long id of grp "navMandala" into pControl
         topCenterMe pControl,120
         -- centerMe pControl
         
         put the long id of img "hideNavMandala" into pControl
         bottomCenterMe pControl,20
         
         
         put the long id of img "showNavMandala" into pControl
         bottomCenterMe pControl,20
         
         put the long id of button "openGlobalNavTree" into pControl
         topLeftMe pControl, -16, 0
         
         
         break
         
      default
         put the long id of widget "globalNavTree" of me into pControl
         set the width of pControl to CardWidth()
         topCenterMe pControl,60
         
         break
   end switch
   
   # background group of all cards
   
   put the long id of group "audioGlobalControl" of me into pControl
   topRightMe pControl,70,20
   
   put the long id of fld "Notification" of me into pControl
   topCenterMe pControl,150
   
end updateUIPortal


on pushNotificationRegistrationError pErrorMessage
   
end pushNotificationRegistrationError
