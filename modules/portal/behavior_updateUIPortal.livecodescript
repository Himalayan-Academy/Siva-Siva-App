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
   
   switch pCard
      case "Home"
         # init set up
         hide grp "globalNavigation"
         showMandala
         dispatch "setGlobalNavVisible" to widget "globalNavTree" with "false"
         setDefaultImage
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
   local tTarget,tTargetOwner
   put the short name of the owner of the target into tTargetOwner
   put the short name of the target into tTarget
   
   # one set of actions occurs if the user hits grp ""bkgndcontrol"
   # Another set, is  trapped by the mouseUp to behavior_GlobalNav because navigition
   # and not abpout the UI perse
   
   switch tTargetOwner
      case "bkgndControls"
         switch tTarget
            case "hideNavMandala"
               setDefaultImage
               hideMandala
               break
            case "showNavMandala"
               if the vis of  grp "subNav" is true then hide grp "subNav"
               showMandala
            break
      end switch
      break
   case "globalNavTree"
      hide grp "subNav"
      break
   case "navMandala"
      if tTarget is among the items of "Stories,Gems of Wisdom,gems,Surprise Me,surprise,Listen,Video,Journal,My Menu" then
         # These are top links, some go  directly to another module stack
         portal_GoStack tTarget
         exit mouseup
      end if
      
      hideMandala
      setSubNavBkgndImage tTarget
      show  img "subNavBkgImage"
      dispatch "fetchSubMenu" to grp "navMandala" with tTarget
      wait 400 milliseconds
      
      show grp "SubNav" with visual effect "dissolve fast"
      break
   case "subNav"
      put the value of clickline()  into tTarget
      portal_DoRowLink tTarget
      break
end switch

end mouseup

#######################

# use the return state of home screen
command showMandala
   lock screen
   hide grp "globalNavigation"
   # hide sub nav menu
   hide grp "subNav"
  hide img "homeMainImage"
   hide img "subNavBkgImage"
   show btn "brandLogo"
   hide grp "globalNavigation"
   show btn "backgroundOverlay"
   show grp "navMandala"
   hide img "showNavMandala" # button
   show img "hideNavMandala" # button
   unlock screen
end showMandala

# or to just see the image and priod to show 
# the sub-nav menu on screen
command hideMandala
   hide btn "brandLogo"
   hide grp "globalNavigation"
   hide grp "navMandala"
   hide btn "backgroundOverlay"
   show img "homeMainImage"
   show img "showNavMandala"
   hide img "hideNavMandala"
end hideMandala

command hideSubNav
   hide grp "SubNav"
end hideSubNav


command setDefaultImage pContext
   --breakpoint
   
   #  see lib_SivaSiva | setUpBrandImage  
   # where we set the cache with a branc image number 
   
   local pImage, tPaths, tBrandImages, tTotalBrandImages
   
   --put getCache("BrandImage") into sBrandImageNumber
   put the long id of img "homeMainImage" of card "Home" into sMainImage
   put _brandImages() into tBrandImages
   
   # will get this out when we close Sivasiva.app
   # the user get a new brand image only opening the app.
   
   # variable is undefined at this point
   --setCache "TotalBrandImages", tTotalBrandImages
   put the number of lines of tBrandImages into tTotalBrandImages
   put random(tTotalBrandImages) into sBrandImageNumber
   put line sBrandImageNumber of tBrandImages into pImage
   set the filename of sMainImage to photoImagePath(pImage)
   setImageToFullCardLoc sMainImage,"portrait"
   centerMe sMainImage
   # optimize disk operations *after* the display is finished updating
   
   put the number of lines of tBrandImages into tTotalBrandImages
   setPref "preferences/modules/portal/totalBrandImages", tTotalBrandImages
   
end setDefaultImage 
      
      
      
command setSubNavBkgndImage pMenu
   local tMenuBkgnd, pImage, tPortalScreens, tPath
   
   put the long id of img "subNavBkgImage" into tMenuBkgnd
   
   switch pMenu
      case "read"
         put "portal-screens/Iravan-pillars-ceiling_opt-80.jpg" into tPath
         break
         
      case "stories"
         put "portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg" into tPath
         break
         
      case "fun"
         put "portal-screens/Ganesha-Muruga-and-children_opt-80.jpg" into tPath
         break
         
      case "practice"
         put "photography/app-img_dias_monks_brains_552w-portrait/app-img_dias_monks_brains_552w-portrait_med.jpg" into tPath
         
         break
         
      case "look"
         put "portal-screens/listen_Rajam-bhajan-BB20_DxO_opt-80.jpg" into tPath
         break
         
      case "surprise"
         put "portal-screens/Orion_Nebula_-_Hubble_2006_mosaic_18000_opt-70.jpg" into tPath
         break
   end switch
   put path_Assets() & "img/"  before tPath
   set the filename of tMenuBkgnd to tPath
   centerMe tMenuBkgnd
   setImageToFullCardLoc tMenuBkgnd,"portrait",0,0
   
end setSubNavBkgndImage 

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
         "app-img_siva_552w-portrait"& cr & \
         "app-img_kadavul_nataraja_shrine_552w-portrait" & cr & \
         "app-img_img_1444_736h-landscape_med" & cr & \
         "app-img_ganagta02_l_552w-portrait" & cr & \
         "app-img_dscn1092_552w-portrait" & cr & \
         "app-img_book_siva_yogi_big_736h-square" & cr & \
         "app-img_book_siva_face_736h-square" & cr & \
         "app-img_agamasivadancing_736h-square" & cr & \
         "app-img_70s_siva_poster_552w-portrait" & cr & \
         "app-img_44_sharma_siva_552w-portrait" & cr & \
         "app-img_34_linga_liberation_552w-portrait" & cr & \
         "app-img_sinha_10_552w-portrait" & cr & \
         "app-img_sinha_3_552w-portrait" & cr & \
         "app-img_sinha_6_552w-portrait" & cr & \
         "app-img_sinha_8_552w-portrait"  \
         into tBrandImages
   return tBrandImages
end _brandImages

function PhotoImagePath pImage
   local tPath
   put path_Assets() & "img/photography/" & pImage & "/" \
         & pImage & "_med.jpg" into tPath
   return tPath
end PhotoImagePath

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
   
   local pControl, tBrandImage, tBottomMargin, sMenuBkgnd
   
   #  UI responsive
   put the long id of img "homeMainImage" of card "Home" into sMainImage
   put the long id of img "subNavBkgImage" of card "Home" into sMenuBkgnd
   setImageToFullCardLoc sMainImage,"portrait",0,0
   centerMe sMainImage,0,0
   setImageToFullCardLoc sMenuBkgnd,"portrait",0,0
   centerMe sMenuBkgnd,0,0
   show btn "brandLogo"
   --show sMainImage with visual effect "dissolve"
   
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
         topCenterMe pControl,75
         -- centerMe pControl
         
         put the long id of img "hideNavMandala" into pControl
         bottomCenterMe pControl,20
         
         
         put the long id of img "showNavMandala" into pControl
         bottomCenterMe pControl,20
         
         put the long id of button "openGlobalNavTree" into pControl
         topLeftMe pControl, -16, 0
         
         put the long id of widget "globalNavTree" of me into pControl
         set the width of pControl to CardWidth()
         topCenterMe pControl,60
         
         break
         
   end switch
   
   # background group of all cards
   
   put the long id of group "audioGlobalControl" of me into pControl
   topRightMe pControl,70,20
   
   put the long id of fld "Notification" of me into pControl
   bottomCenterMe pControl,100
   
end updateUIPortal

