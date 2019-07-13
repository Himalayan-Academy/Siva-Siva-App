script "behavior_view_SivaSivaBrowser"
# this behavior is also use  by the view_BrowserLandscape.livecode stack
# 
local sMediaURL,sBrowserURL

#local sPortraitRect, sLandscapeRect, sScreenRect,sBrowserOrientation
local sHackDownloadCompleteFlag

local sLandscapeOnly, sOrientation, sBrowserRect

# this stack intend to make the UI responsive
# by getting rect of the screen and using those coordinator
# to set the stack size and UI size.

# setBrowserURL  
# is sent from portal_GoURL in the lib_SivaSivaPortal 

on preopenstack
   local tBrowser, tOrientations
   set the fullscreenmode of this stack to empty
   put the short name this stack into tBrowser
   put (tBrowser contains "landscape") into sLandscapeOnly
   if isMobile() then
      put "landscape left,landscape right" into tOrientations
      if sLandscapeOnly then
         put "landscape" into sOrientation
      else
         put "portrait,portrait upside down," before tOrientations
         put "portrait" into sOrientation
      end if
      mobileSetAllowedOrientations tOrientations
   end if
   resetUI
end preopenstack

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

command updateUI theOrientation
   local tBrowser, tLoader, tOrientation, tHeight, tWidth, tUnit
   local tSafeRect, tEdge
   
   put the long id of widget "body" of card "SivaSivaBrowser" into tBrowser
   put the long id of widget "loader" of card "SivaSivaBrowser" into tLoader
   if isMobile() then
      --put mobileDeviceOrientation() into tOrientation
      put mobileOrientation() into tOrientation
   else
      put sOrientation into tOrientation
   end if
   put the width of this card into tWidth
   put the height of this card into tHeight
   put safeRect() into tSafeRect
   put tSafeRect into sBrowserRect
   
   -- initial orientations of "face up", "face down", or "unknown" will
   -- not be drawn correctly if not manually determined like this
   if tOrientation begins with "f" or tOrientation begins with "u" then
      if tWidth < tHeight then
         put "portrait" into tOrientation
      else
         put "landscape" into tOrientation
      end if
   end if
   
   switch 
      case (tOrientation contains "portrait")
         if getPhoneModel() is "iPhoneX" then
            mobileShowStatusBar
         end if
         
         subtract 50 from item 4 of sBrowserRect
         put item 4 of sBrowserRect + 25 into tEdge
         --put (tWidth/2,(tHeight-50)/2) into tBrowserLoc
         --put (0,0,tWidth,(tHeight - 50)) into tBrowserRect
         
         --set loc group "footerNavigation" of card "SivaSivaBrowser" to ( round(tWidth/2),tEdge)
         put tWidth/4 into tUnit
         set the loc of button "go-home-portal" of card "SivaSivaBrowser" to (tUnit/2,tEdge)
         set the loc of button "add-favorites" of card "SivaSivaBrowser" to (tUnit*1.5,tEdge)
         set the loc of button "share"  of card "SivaSivaBrowser" to (tUnit*2.5,tEdge)
         set the loc of button "settings-gear" of card "SivaSivaBrowser" to (tUnit*3.5,tEdge)
         --show group "footerNavigation" of card "SivaSivaBrowser"
         break
         
      case (tOrientation contains "landscape")
         if getPhoneModel() is "iPhoneX" then
            mobileHideStatusBar
         end if
         
         add 50 to item 1 of sBrowserRect
         put item 1 of sBrowserRect  - 25 into tEdge
         --put (0,0,(tWidth- 50),tHeight) into tBrowserRect
         --put ((tWidth+50)/2,tHeight/2) into tBrowserLoc
         
         --set loc group "footerNavigation" of card "SivaSivaBrowser" to ( tEdge,tHeight/2)
         put tHeight/4 into tUnit
         set the loc of button "go-home-portal" of card "SivaSivaBrowser" to (tEdge,tUnit/2) 
         set the loc of button "add-favorites" of card "SivaSivaBrowser" to (tEdge,tUnit*1.5)
         set the loc of button "share"  of card "SivaSivaBrowser" to (tEdge, tUnit*2.5)
         set the loc of button "settings-gear" of card "SivaSivaBrowser" to (tEdge, tUnit*3.5)
         --show group "footerNavigation" of card "SivaSivaBrowser"
         break
         
      default
         -- unknown, face up, face down
         exit updateUI
   end switch
   
   set the rect of tBrowser to sBrowserRect
   --set the loc of tBrowser to tBrowserLoc
   set the rect of tLoader to sBrowserRect
   --set the loc of tLoader to tBrowserLoc
   
   --if (the lockscreen) then unlock screen
end updateUI

command repositionBrowser
   set the rect of widget "body" of card "SivaSivaBrowser" to sBrowserRect
end repositionBrowser

command setBrowserURL pURL
   setJournalFlag (0)
   set the url of widget "body" of cd "SivaSivaBrowser" to pURL
end setBrowserURL

command terminateBrowser
   hide widget "Body"
   hide widget "loader"
   set the url of widget "Body" to empty
end terminateBrowser

Local sStartLoadTime,sTimePassed,sLoadSuccessFlag

# BUG iOS does not respond to message  "browserDocumentLoadBegin"
# the loading Spinner and cancel command remain on screen.
# it works on Android and desktop. This is needed in case the URL does load
# and the user wants to break/leave the connection.

# the "hack" is to add it the browserDocumentLoadComplete
# this means is take a second so longer to appear on ios
# than on Android

# An Android we have a separate issue. 
# browserDocumentLoadComplete  is sent twice
# and two entries are made the journal 
# because "journal_addEntry" is trigger two times
# ( I assume because browserDocumentLoadComplete is fired twice?)
# the first is triggeed outside the message path
# and give "bogus" information to a jounal.sqlite record
# The second one is inside the message path.    journal_AddEntry fires twice
# and we get a correct record. Both records the appear the journal on Android
# this does not happen on desktop and iOS

on browserDocumentLoadBegin pURL
   ntinfo ("begin load url , body is visible: "& (the vis of widget "body"))
   set layer of widget "loader" to "top"
   set htmltext of widget "Loader" to fld "loaderHTML"
   show widget "loader"
   show group "footerNavigation"
   ntInfo ( (the lockscreen) & "; show the loader " &  pURL)
end browserDocumentLoadBegin


on browserDocumentLoadComplete pURL
   local tBrowser
   
   ntinfo ("download flag: " & sHackDownloadCompleteFlag)
   if pURL is not empty then
      dispatch "hideloader" to me 
   end if
   show widget "Body"
   show group "footerNavigation"
   put "true" into sLoadSuccessFlag
   put pURL into sBrowserURL
   browser_SetLastURL pURL
   put short name of the target into tBrowser
   
   ntInfo ( (the lockscreen) & "; show the target: " & tBrowser &"; " &  pURL)
   
end browserDocumentLoadComplete


command hideLoader
   hide widget "loader"
end hideLoader


on journal_AddEntry
   -- should pData be a parameter?
   local pData, tTitle
   try
      parseTheHTML (the htmlText of widget "body"),"Title"
   end try
   put browser_GetLastURL() into pData["weburl"] 
   put browser_GetLastPageTitle() into tTitle
   if sLandscapeOnly then
      --if sBrowserOrientation = "landscape" then
      Journal_RecordEntry "view_BrowserLandscape",tTitle,pData  
   else
      Journal_RecordEntry "view_SivaSivaBrowser",tTitle,pData   
   end if
   
end journal_AddEntry


on journalResume  pDataA, pEntryA
   local tBrowser
   put the long id of widget "Body" of cd "SivaSivaBrowser"  into tBrowser 
   set the URL of tBrowser to pDataA["weburl"]
end journalResume

-- not sure where this variable declaration really goes
local sShareItemsA
command share_Items
   local tWebPage
   put browser_GetLastURL() into tWebPage
   put tWebPage into sShareItemsA["url"]  
   if tWebPage contains "Youtube" then # we have a video
      put "Watch this Video!" into sShareItemsA["subject"]
      put "Shared from the new SivaSiva App." into sShareItemsA["text"]
   else
      put "Check out this web page!" into sShareItemsA["subject"]
      put "Shared from the SivaSiva App" into sShareItemsA["text"]
   end if
   return sShareItemsA
end share_Items

command resetUI
   set the url of widget "body" of cd "SivaSivaBrowser" to empty
   hide widget "body" of cd "SivaSivaBrowser"
   show widget "loader" of cd "SivaSivaBrowser"
   put the rect of widget "body" of cd "SivaSivaBrowser" into sBrowserRect
end resetUI

on closestack
   # we never log the browers stacks as the sLastStack
   # because we may be coming to view a web page from any module
   # which should be designated as sLastStack and not these browers.
   if isMobile() then
      --mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end closestack


####################
# Brian's Original standalone test


--on preOpenStack
--   clearLog
--   addLog "preOpenStack"

--   # set up objects for geometry
--   put the long id of widget "body" of card "SivaSivaBrowser" into sBrowser
--   put the long id of widget "loader" of card "SivaSivaBrowser" into sLoader
--   put the long id of group "footerNavigation"  of card "SivaSivaBrowser" into sFooter
--   # widget the footer have to be located
--   put the long id of button "go-home-portal" of card "SivaSivaBrowser" into sGoHomeBtn
--   put the long id of button "add-favorites" of card "SivaSivaBrowser" into sAddFavoritesBtn
--   put the long id of button "share"  of card "SivaSivaBrowser" into sShareBtn
--   put the long id of button "settings-gear" of card "SivaSivaBrowser" into sSettingBtn

--   # this behavior  is used in two different stack
--   # the landscape one must be opened after closing a portrait stack
--   # you cannot go in window of the a portrait stack

--   put the short name this stack into sBrowserStack

--   if sBrowserStack contains "landscape" then
--      put  "landscape" into sBrowserStack
--      # use for video/YouTube Channel
--      put "landscape" into sBrowserOrientation

--   else 
--      put  "portrait" into sBrowserStack
--      # regular brower stack supports orientation changes
--      # Web site starts out in portrait mode
--      put "portrait" into sBrowserOrientation 
--   end if

--   if isMobile() then
--      if sBrowserOrientation = "landscape"   then
--         mobileSetAllowedOrientations "landscape left"
--      else
--         mobileSetAllowedOrientations "portrait,landscape left,landscape right"
--      end if
--      put mobileDeviceOrientation() into sBrowserOrientation
--   end if
--   setBrowserURL
--end preOpenStack

--on opencard
--   local x, y
--   put the width  of this card into x
--   put the height of this card into y

--   # Logging
--   addLog "openCard" && the short name of this card
--   addLog tab & "CardRect:" && the rect of this card
--   addLog tab & "Screenrect:" && the screenrect

--   # send initial layout
--   if sBrowserOrientation = "portrait" then
--      updateUI "portrait",x,y
--   else
--      updateUI "landscape",x,y
--   end if
--end opencard

--on orientationChanged
--   #put empty into fld "log"
--   clearLog
--   addlog "=================="
--   addLog "orientationChanged"
--   if isMobile () then
--      put mobileDeviceOrientation() into sBrowserOrientation
--      addLog tab & sBrowserOrientation
--   end if
--   #then a resizestack is called:
--end orientationChanged

--on resizeStack x,y,ox,oy
--   lock screen
--   addLog ("resizeStack " & x & ", " & y & ", " & ox & ", " & oy) 
--   addLog tab & "CardRect:" && the rect of this card
--   addLog tab & "Screenrect:" && the screenrect
--   updateUI sBrowserOrientation
--   unlock screen
--end resizeStack

--command updateUI theOrientation

--   --hide widget "body" # in case we want to see the log


--   local x,y, tBrowserRect, tBrowserLoc, tUnit

--   # get coords now after changes to screen
--   put the width  of this card into x
--   put the height of this card into y

--   put x into sCdWidth
--   put y into sCdHeight

--   #---- LOGGING
--   addLog "updateUI" && theOrientation
--   addLog tab & "Card X-Y:" && x & ", " & y
--   addLog tab & "CardRect:" && the rect of this card
--   addLog tab & "Screenrect:" && the screenrect

--   switch 
--      case (theOrientation contains "face up") 
--      case (theOrientation contains "unknown")  
--      case (theOrientation contains "portrait upside down") 
--      case (theOrientation contains "face down") 
--         exit to top
--         break
--      case (theOrientation contains "portrait") 
--         --hide widget "body" # in case we want to log
--         put (0,0,sCdWidth,(sCdHeight - 50)) into tBrowserRect
--         put (sCdWidth/2,((sCdHeight-50)/2) ) into tBrowserLoc

--         set the loc of fld "log" of cd "SivaSivaBrowser" to (sCdWidth/2,sCdHeight/2)

--         positionbody tBrowserRect, tBrowserLoc
--         set the loc of sFooter to ( round(sCdWidth/2),sCdHeight - 25)
--         put sCdWidth/4 into tUnit
--         set the loc of sGoHomeBtn to (tUnit/2,sCdHeight-25)
--         set the loc of sAddFavoritesBtn to (tUnit*1.5,sCdHeight-25)
--         set the loc of sShareBtn to (tUnit*2.5,sCdHeight-25)
--         set the loc of sSettingBtn to (tUnit*3.5,sCdHeight-25)
--         break

--      case (theOrientation contains "landscape")
--         put (0,0,sCdWidth-50,(sCdHeight)) into tBrowserRect
--         put ((sCdWidth/2+25),(sCdHeight/2)) into tBrowserLoc
--         --         put (0,350,sCdWidth-50,(sCdHeight)) into tBrowserRect
--         --         put ((sCdWidth/2+25),(sCdHeight-32)) into tBrowserLoc
--         positionbody tBrowserRect, tBrowserLoc
--         set loc sFooter to ( 25,sCdHeight/2)
--         put sCdHeight/4 into tUnit
--         set the loc of sGoHomeBtn to (25,tUnit/2) 
--         set the loc of sAddFavoritesBtn to (25,tUnit*1.5)
--         set the loc of sShareBtn to (25, tUnit*2.5)
--         set the loc of sSettingBtn to (25, tUnit*3.5)
--         break
--   end switch

--end updateUI

--command positionbody tBrowserRect, tBrowserLoc
--   --breakpoint
--   set the rect of sBrowser  to tBrowserRect
--   set the loc of sBrowser to  tBrowserLoc
--   set the rect of sLoader  to tBrowserRect
--   set the loc of sLoader to  tBrowserLoc
--      set the rect of fld "log" of cd "SivaSivaBrowser" to  (80,0,sCdWidth,sCdHeight-200)
--      set the topleft of btn "clear log" to 0,0
--   addLog "FinalBrowserRect" && the rect of sBrowser && the loc of sBrowser
--   addLog "the vis of widget Body" && the vis of widget "body"
--end positionbody



