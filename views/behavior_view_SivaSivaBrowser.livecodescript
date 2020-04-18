script "behavior_view_SivaSivaBrowser"
# this behavior is also use  by the view_BrowserLandscape.livecode stack
# 
local sMediaURL,sBrowserURL

#local sPortraitRect, sLandscapeRect, sScreenRect,sBrowserOrientation
local sHackDownloadCompleteFlag

local sLandscapeOnly, sOrientation, sBrowserRect,sHtmlText

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
   put "landscape left,landscape right" into tOrientations
   if sLandscapeOnly then
      put "landscape" into sOrientation
   else
      put "portrait,portrait upside down," before tOrientations
      put "portrait" into sOrientation
   end if
   setCardCoords sOrientation
   if isMobile() then
      mobileSetAllowedOrientations tOrientations
   end if
   resetUI
   hide grc "blankImage"
   send "showBrowser" to me in 10 seconds
end preopenstack

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

command updateUI
   local tBrowser, tLoader, tOrientation, tHeight, tWidth, tUnit
   local tSafeRect, tEdge
   
   put the long id of widget "body" of card "SivaSivaBrowser" into tBrowser
   put the long id of widget "loader" of card "SivaSivaBrowser" into tLoader
   put CardWidth() into tWidth
   put CardHeight() into tHeight
   put safeRect() into tSafeRect
   put tSafeRect into sBrowserRect
   
   -- reported orientation is unreliable so figure it out
   -- manually based on geometry
   if tWidth < tHeight then
      put "portrait" into tOrientation
   else
      put "landscape" into tOrientation
   end if
   
   switch 
      case (tOrientation contains "portrait")
         if getPhoneModel() is "iPhoneX" then
            mobileShowStatusBar
         end if
         
         subtract 50 from item 4 of sBrowserRect
         put item 4 of sBrowserRect + 25 into tEdge
         
         put tWidth/4 into tUnit
         set the loc of button "go-home-portal" of card "SivaSivaBrowser" to (tUnit/2,tEdge)
         set the loc of button "add-favorites" of card "SivaSivaBrowser" to (tUnit*1.5,tEdge)
         set the loc of button "share"  of card "SivaSivaBrowser" to (tUnit*2.5,tEdge)
         set the loc of button "settings-gear" of card "SivaSivaBrowser" to (tUnit*3.5,tEdge)
         break
         
      case (tOrientation contains "landscape")
         if getPhoneModel() is "iPhoneX" then
            mobileHideStatusBar
         end if
         
         add 50 to item 1 of sBrowserRect
         put item 1 of sBrowserRect  - 25 into tEdge
         
         put tHeight/4 into tUnit
         set the loc of button "go-home-portal" of card "SivaSivaBrowser" to (tEdge,tUnit/2) 
         set the loc of button "add-favorites" of card "SivaSivaBrowser" to (tEdge,tUnit*1.5)
         set the loc of button "share"  of card "SivaSivaBrowser" to (tEdge, tUnit*2.5)
         set the loc of button "settings-gear" of card "SivaSivaBrowser" to (tEdge, tUnit*3.5)
         break
         
      default
         -- unknown, face up, face down
         exit updateUI
   end switch
   
   set the rect of tBrowser to sBrowserRect
   set the rect of tLoader to sBrowserRect
   
   set the rect of grc "blankImage" to CardRect()
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
   --ntInfo ( (the lockscreen) & "; show the loader " &  pURL)
end browserDocumentLoadBegin


on browserDocumentLoadComplete pURL
   local tBrowser
   
   --ntinfo ("download flag: " & sHackDownloadCompleteFlag)
   if pURL is not empty then
      --dispatch "hideloader" to me 
      hideLoader
   end if
   show widget "Body"
   show group "footerNavigation"
   put "true" into sLoadSuccessFlag
   put pURL into sBrowserURL
   browser_SetLastURL pURL
   put short name of the target into tBrowser
   put url pURL into sHtmlText
   --ntInfo ( (the lockscreen) & "; show the target: " & tBrowser &"; " &  pURL)
   
end browserDocumentLoadComplete


command hideLoader
   hide widget "loader"
end hideLoader


command showBrowser
   lock screen
   hide widget "loader"
   show widget "Body"
   unlock screen
end showBrowser

on journal_AddEntry
   
   local pData, tTitle, tOutput,tHardToParsePages
   
   # this is a hack  until we figure out the regEx for matchText 
   # for the <title class="whatever"....> in find in Gatsby and other pages
   # we get the title from the original mouseup of the portal screen
   
   put "Pillars of Iraivan" into tHardToParsePages
   
   if sBrowserURL contains "YouTube" then
      # the journal label is taken from the JSON of out navigation dictionary
      # which are appears on this sub nav list.
      # for now, this implemention of Video is contrain to that list
      # leave it for now
      put portal_GetLabel() into tTitle
   else
      # we have some web page, probably in portrait mode
      # it could be HAP page form the /html folder, or a revOIgniter built media page, 
      # or a internal page of some books that Andre build from exploded ePub/Zip
      # the challenge is to get a proper label, especially from the books.
      put getJournalData() into tTitle
      
      if tTitle is not among the items of tHardToParsePages then
         put parseTheHTML(sHTMLtext,"bookmark") into tTitle
      end if
      
      --put titleFromURL(browser_GetLastURL())  into tTitle
      --put parseTheHTML(the htmltext of widget "body","bookmark") into tTitle
      --put titleFromURL(browser_GetLastURL())  into tTitle
      
   end if
   
   put browser_GetLastURL() into pData["url"] 
   
   if sLandscapeOnly then
      
      Journal_RecordEntry "view_BrowserLandscape",tTitle,pData  
   else
      Journal_RecordEntry "view_SivaSivaBrowser",tTitle,pData   
   end if
   --dialog_CustomMsg "Saved to Journal"
end journal_AddEntry


on journalResume  pDataA, pEntryA
   local tBrowser
   put the long id of widget "Body" of cd "SivaSivaBrowser"  into tBrowser 
   set the URL of tBrowser  to pDataA["url"]
   hideLoader
   show tBrowser
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
   show grc "blankImage"
   # we never log the browers stacks as the sLastStack
   # because we may be coming to view a web page from any module
   # which should be designated as sLastStack and not these browers.
   if isMobile() then
      --mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end closestack
