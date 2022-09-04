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
   local tControl, tCard, sNewNews
   put the short name of this card into tCard
   setCardCoords "portrait"
   put the long id of img "homeMainImage" of card "Home" into sMainImage
   hide grp "newsItems"
   hide grp "loadingGroup"
   switch tCard
      case "Home"
         # init set up
         hide grp "globalNavigation"
         showMandala
         dispatch "setGlobalNavVisible" to widget "globalNavTree" with "false"
         setDefaultImage
         
   end switch
   
   updateUIPortal
   
   show btn "brandLogo"
end preOpenCard



on opencard
   News_Fetch
   --send "News_Fetch" to me in 500 milliseconds
   audioIsRunning    
end opencard


#######################

command _USER_INTERACTION
end _USER_INTERACTION

# this is a big deal!
# https://himalayanacademy.com/monastery-tour/?scene=62f4254aa6880ad54f07b143



on mouseup
   local tTarget, tTargetOwner, tUserGuide, tNews
   local tSelection
   
   put the short name of the owner of the target into tTargetOwner
   put the short name of the target into tTarget
   
   # one set of actions occurs if the user hits grp ""bkgndcontrol"
   # Another set, is  trapped by the mouseUp to behavior_GlobalNav because navigition
   # and not about the UI perse
   
   switch tTarget
      local tMsg
      
   case "Topics"
      portal_GoUrl  "https://www.himalayanacademy.com/topics"
      exit mouseup
      break
      
   case "loading"
      --showbusyIndicator false
      exit Mouseup
      break
      
      # beginning News!
   case "news"
      show grp "newsItems"
      exit Mouseup
      break
      
   case "newsDismiss"
      hide grp "newsItems"
      exit Mouseup
      break
      
      -------------
      -- News!
      
   case "TAKA"
      hide grp "newsItems"
      portal_GoURL "https://www.himalayanacademy.com/blog/taka/"
      exit Mouseup
      break
      
   case "Bodhinatha Latest"
      hide grp "newsItems"
      portal_GoStack "Listen"
      put the long name of image "1-2-playlist-image" into tSelection
      send "selectPlayList tSelection" to stack "Listen" in 200 milliseconds
      exit Mouseup
      break
      
   case "Webinars"
      hide grp "newsItems"
      portal_GoURL "https://www.youtube.com/user/kauaiaadheenam/videos"
      exit Mouseup
      break
      
   case "App News"
      hide grp "newsItems"
      News_Fetch
      put url ("file:"& path_Documents()& "assets/info/siva-app-news.html") into tNews
      
      set the htmltext of fld "helpField" to tNews
      
      # end of News!
      
      
      show grc "helpBkg"
      show btn "helpDismiss"
      show fld "helpField"
      lock screen
      deleteMobileControl "helpField"
      # recreate:
      -- set the height of fld "helpField" to the formattedHeight of fld "helpField"
      --set the top of fld "helpField" to the top of grp "helpField"
      send "CreateScroller helpField" to fld "helpField"
      
      unlock screen
      
      break
      
   case "Contact"
      Share_Email
      break
      
      
   case "HelpButton"
      put url ("file:"& path_Assets()& "info/user-guide.html") into tUserGuide
      set the htmltext of fld "helpField" to tUserGuide
      
      
      show grc "helpBkg"
      show btn "helpDismiss"
      show fld "helpField"
      lock screen
      deleteMobileControl "helpField"
      # recreate:
      --set the height of fld "helpField" to the formattedHeight of fld "helpField"
      --set the top of fld "helpField" to the top of grp "helpField"
      send "CreateScroller helpField" to fld "helpField"
      
      unlock screen
      break
      
   case "helpDismiss"
      hide fld "helpField"
      hide btn "helpDismiss"
      hide grc "helpBkg"
      break
end switch

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
      if tTarget is among the items of "Stories,Path to Siva,pathtosiva,Gems of Wisdom,gems,Surprise Me,surprise,Listen,Read,read,Video,Journal,My Menu,Settings" then
         # These are top links, some go  directly to another module stack
         portal_GoStack tTarget
         exit mouseup
      end if
      
      lock screen
      hideMandala
      setSubNavBkgndImage tTarget
      show  img "subNavBkgImage"
      unlock screen
      fetchSubMenu tTarget
      wait 200 milliseconds
      
      show grp "SubNav" with visual effect "dissolve fast"
      break
   case "subNav"
      if abs(item 2 of the mouseloc - item 2 of sStartLoc) < 30 then
         put the value of clickline() into tTarget
         
         # pass the target to journal data. It may be overwritten later
         # but in some cases that will be the only title we can use 
         # for a journal entry
         
         setJournalData tTarget
         portal_DoRowLink tTarget
         
      end if
      break
end switch
end mouseup



on mouseDown
   put the mouseLoc into sStartLoc
end mouseDown


command News_Fetch
   local tLocalNewsPath, tLocalNewsFile, tServerNews
   Local tTargetLine, tServerLatestNews, tLocalNewsDate, tLatestNewsDate
   local tLocalNews, sNewNews
   constant cRemoteNewsFile="siva-app-news.html"
   
   # we fetch old news in Documents fold
   put (path_Documents()&"assets/info/siva-app-news.html") into tLocalNewsPath
   
   # fetch the latest news on server
   put url ("https://www.himalayanacademy.com/media/apps/sivasiva/"& cRemoteNewsFile) into tServerNews
   
   # we tell the app that the  result is empty
   # which case we are able took more a connection
   if the result is not empty then 
      log the result
      exit News_Fetch
   end if
   
   # we get a local file. Otherwise it is empty
   if ( there is a  file tLocalNewsPath) then # parse it for the date
      put  url ("file:"& tLocalNewsPath) into tLocalNews
   else
      put empty into tLocalNews
   end if 
   
   # we test the size of the news in bytes
   if md5digest(tLocalNews) is md5Digest(tServerNews) then
      # here it  is the same
      put "false" into sNewNews
   else 
      # here, it different
      put tServerNews into url ("file:"& path_Documents()&"assets/info/siva-app-news.html")
      put "true" into sNewNews
   end if
   
   showNewsNotification  sNewNews  --of card "Home" of stack "Siva-Siva-Portal"
end news_Fetch

command showNewsNotification pBool
   if exists(fld "notification") then
      visMessageToUser pBool
      if pBool is true then
         put  ("You have the latest " & quote &"App News!" & quote) into fld "notification" of stack "Siva-Siva-Portal"
         wait 500 milliseconds
      end if
   end if
end showNewsNotification


on fetchSubMenu pTarget
   local tMap,tSecondKey,tRowName,tOutput
   local tKeys
   put getNavigationMap() into tMap
   
   put the keys of tMap["portalData"][pTarget]["rowdata"] into tKeys
   sort lines of tKeys ascending numeric
   repeat for each line tSecondLevel in tKeys
      add 1 to tSecondKey
      put tMap["portalData"][pTarget]["rowdata"][tSecondLevel]["rowName"] into tRowName
      put tRowname & cr after tOutput
   end repeat
   # getting the final cr out
   delete char -1 of  tOutput
   put tOutput into fld "subNavfld"
   dispatch "createscroller" to fld "subNavFld" with "subNavFld"
end fetchSubMenu


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
   hide fld "notification"
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
   put "app-img_who-is-siva_1200x800_med" & cr & \
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

command Share_Email sShareItemsA
   local tSubject, tAddress, tBody
   put sShareItemsA["subject"] && "From SivaSivaApp"  into tSubject
   put "sivasiva@hindu.org" into tAddress
   put  sShareItemsA["text"] &  CR & CR  & sShareItemsA["url"] into tBody
   put  cr & cr & "------------------------------------" & cr & \
         "Get the SivaSivaApp today! Go to:" & cr & "https://www.himalayanacademy.com/view/sivasiva" after tBody
   
   if isMobile() = "true" then
      mobileComposeMail tSubject,tAddress,,, tBody
   else
      revMail tAddress,,tSubject,tBody
   end if
   
end share_Email

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


constant kMargin = 12

command updateUIPortal
   
   local tControl, tBrandImage, tBottomMargin, tMenuBkgnd, tTop, tBottom, tRect
   local tLoadingNotice, tTouchTrap, tBrandLogo
   local tHelpButton, tHelpBkg, tHelpFieldGrp, tHelpField, tHelpDismiss
   local tNews, tNotification, tExplanationMarker, tNewsItems
   local tPortalLabel
   
   #  UI responsive
   
   put the long id of img "homeMainImage" of card "Home" into sMainImage
   put the long id of img "subNavBkgImage" of card "Home" into tMenuBkgnd
   put the long id of button "brandLogo" of card "Home" into tBrandLogo
   
   setImageToFullCardLoc sMainImage,"portrait",0,0
   centerMe sMainImage,0,0
   setImageToFullCardLoc tMenuBkgnd,"portrait",0,0
   centerMe tMenuBkgnd,0,0
   
   topCenterMe tBrandLogo,150 
   
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
         
         put the long id of button "brandLogo" of me into tControl
         topCenterMe tControl,0
         put (the bottom of tControl)+kMargin into tTop
         
         put the long id of btn "backgroundOverlay" into tControl
         centerMe tControl
         
         # home image
         
         put long Id of img "HomeMainImage" into tControl
         setImageToFullCardLoc tControl, "portrait", 0
         centerMe tControl, 0, 0
         
         # Buttons and Nav
         
         put the long id of img "hideNavMandala" into tControl
         bottomCenterMe tControl,20
         put (the top of tControl)-kMargin into tBottom
         
         put the long id of img "showNavMandala" into tControl
         bottomCenterMe tControl,25
         
         put the long id of button "openGlobalNavTree" into tControl
         bottomLeftMe tControl, 18, 18
         
         put the long id of grp "navMandala" into tControl
         if CardHeight() < 736 then
            set the textSize of tControl to 14
            set the textSize of fld "pathtosiva" to 13
            set the rect of tControl to (0,tTop,CardWidth(),tBottom)
            set the height of fld "gems" to 27 -- need to reduce to account for text height change
            updateNavMandalaUI
         else if CardHeight() > 900 then
            centerMe tControl, the bottom of button "brandLogo", CardHeight() - the top of img "hideNavMandala"
         else
            topCenterMe tControl,75
         end if
         
         put (0,tTop,CardWidth(),tBottom) into tRect
         put the long id of widget "globalNavTree" of me into tControl
         set the rect of tControl to tRect
         
         put the long id of grc "subNavBkgnd" into tControl
         set the rect of tControl to tRect
         
         put the long id of fld "subNavFld" into tControl
         put the left of tControl into item 1 of tRect
         set the rect of tControl to tRect
         
         put the long id of btn "helpButton" into tHelpButton
         bottomRightMe tHelpButton, 20, 40
         
         put the long id of grc "helpBkg" into tHelpBkg
         set the rect of tHelpBkg to CardRect()
        
         put the long id of fld "helpField" into tHelpField
         set the width of tHelpField to (CardWidth() - 30)
         topLeftMe tHelpField, 15, 45
         
         put the long id of button "helpDismiss" into tHelpDismiss
         topRightMe tHelpDismiss, 0, 0
         
         break
         
   end switch
   
   put the long id of grp "newsItems" into tNewsItems
   centerMe tNewsItems, -80
   
   # background group of all cards
   
   put the long id of group "audioGlobalControl" of me into tControl
   topRightMe tControl,70,20
   
   put the long id of fld "Notification" of me into tControl
   bottomCenterMe tControl,100
   
   put the long id of grc "touchTrap" of me into tTouchTrap
   put the long id of grc "loading" of me into tLoadingNotice
   set the rect of tTouchTrap to cardRect()
   bottomCenterMe tLoadingNotice,173
   
end updateUIPortal

private command updateNavMandalaUI
   local tGroup, tHeight, tWidth, tLoc, tMidX, tMidY, tDiameter, tControl, tRadius, tDeltaX, tDeltaY
   
   put the long id of grp "navMandala" into tGroup
   put the width of tGroup into tWidth
   put the height of tGroup into tHeight
   put the loc of tGroup into tLoc
   put item 1 of tLoc into tMidX
   
   setBottomAndLoc the long id of fld "Topics", the bottom of tGroup, tMidX
   setBottomAndLoc the long id of widget "Topics", the top of fld "Topics" - 3, tMidX
   
   setTopAndLoc the long id of grc "gems", the top of tGroup, tMidX
   set the loc of fld "gems" to the loc of grc "gems"
   
   setTopAndLoc the long id of fld "read", (the bottom of grc "gems")+kMargin, tMidX
   setTopAndLoc the long id of grc "read", the bottom of fld "read", tMidX
   set the loc of widget "read" to the loc of grc "read"
   
   setBottomAndLoc the long id of fld "Practice", (the top of widget "Topics")-kMargin, tMidX
   setBottomAndLoc the long id of grc "Practice", the top of fld "Practice", tMidX
   set the loc of widget "Practice" to the loc of grc "Practice"
   
   put (the top of grc "Practice" - the top of grc "read") into tDiameter
   put (the bottom of grc "read" + the top of grc "Practice")*.5 into tMidY
   put tMidY into item 2 of tLoc
   set the width of grc "News" to the formattedWidth of fld "Surprise" + 7
   set the height of grc "News" to the formattedWidth of fld "pathtosiva" + 2
   set the height of fld "News" to the formattedheight of fld "News"
   set the loc of fld "News" to tLoc
   set the loc of grc "News" to tLoc
   
   put the long id of grc "upTriangle" into tControl
   set the height of tControl to tDiameter
   set the width of tControl to tDiameter
   set the loc of tControl to tLoc
   
   put the long id of grc "downTriangle" into tControl
   set the height of tControl to tDiameter
   set the width of tControl to tDiameter
   set the loc of tControl to tLoc
   
   put (tDiameter - 8) / 2 into tRadius
   put tRadius/2 into tDeltaY
   put tDeltaY*sqrt(3) into tDeltaX
   
   set the loc of grc "Stories" to (tMidX-tDeltaX, tMidY-tDeltaY)
   set the loc of widget "Stories" to the loc of grc "Stories"
   setBottomAndLoc the long id of fld "Stories", the top of grc "Stories", tMidX-tDeltaX
   set the loc of grc "listen" to (tMidX+tDeltaX, tMidY-tDeltaY)
   set the loc of widget "listen" to the loc of grc "listen"
   setBottomAndLoc the long id of fld "listen", the top of grc "listen", tMidX+tDeltaX
   set the loc of grc "fun" to (tMidX-tDeltaX, tMidY+tDeltaY)
   set the loc of widget "fun" to the loc of grc "fun"
   setTopAndLoc the long id of fld "fun", the bottom of grc "fun", tMidX-tDeltaX
   set the loc of grc "look" to (tMidX+tDeltaX, tMidY+tDeltaY)
   set the loc of widget "look" to the loc of grc "look"
   setTopAndLoc the long id of fld "look", the bottom of grc "look", tMidX+tDeltaX
   
   setBottomAndLoc the long id of fld "Journal", (the bottom of tGroup)-15, tMidX-tDeltaX-3
   setBottomAndLoc the long id of widget "Journal", (the top of fld "Journal")-3, tMidX-tDeltaX
   setBottomAndLoc the long id of fld "Settings", (the bottom of tGroup)-15, tMidX+tDeltaX+1
   setBottomAndLoc the long id of button "Settings", (the top of fld "Settings")-3, tMidX+tDeltaX
   
   set the rect of grc "pathtosiva" to the rect of grc "News"
   set left of grc "pathtosiva" to the left of  grc "Stories" + 5
   set top of grc "pathtosiva" to the bottom of  grc "Gems" + 5
   set the height of fld "pathtosiva" to the formattedheight of fld "pathtosiva"
   set the loc of fld "pathtosiva" to (the loc of grc "pathtosiva" )
   --set the top of fld "pathtosiva" to (the top of grc "pathtosiva" + 5 )
   
   set the rect of grc "Surprise" to the rect of grc "News"
   set right of grc "Surprise" to the right of  grc "Listen" - 5
   set top of grc "Surprise" to the bottom of  grc "Gems" + 5
   set the height of fld "Surprise" to the formattedheight of fld "Surprise"
   set the loc of fld "Surprise" to (the loc of grc "Surprise" )
   --set the top of fld "Surprise" to (the top of grc "Surprise" + 5 )
end updateNavMandalaUI


private command setTopAndLoc pControl, pTop, pXLoc
   local tLoc
   set the top of pControl to pTop
   put the loc of pControl into tLoc
   set the loc of pControl to (pXLoc, item 2 of tLoc)
end setTopAndLoc

private command setBottomAndLoc pControl, pBottom, pXLoc
   local tLoc
   set the bottom of pControl to pBottom
   put the loc of pControl into tLoc
   set the loc of pControl to (pXLoc, item 2 of tLoc)
end setBottomAndLoc
