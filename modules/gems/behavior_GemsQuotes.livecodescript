script "behavior_GemsQuotes"
/* 
This script  is the behavior assigned to card 1 
"image-quotes"  of the gems stack

*/

--> Variables
# sCurrentRealm is an  integer 1, 2 or 3  not a string!

global sConfigA
local sOnLine,sCurrentRealm,sViewState,sCurrentSourceURL,sTruncFirstLine
local sJournalData

--> Events

on restoreFromJournalEntry pDataA
   --lock screen
   --ntInfo "restoring from journal"
   put pDataA into sJournalData
   put sJournalData["realm"] into sConfigA["currentRealm"]
   preOpenCard
   --dispatch "set_sJournalData" to this card with pDataA
   OpenCard
end restoreFromJournalEntry

on preOpenCard 
   --breakpoint
   
   # ideally we only call this in start up   
   
   # Make sure our photo cache is updated   
   --  jnanam_UpdatePhotoCache
   
   
   # Clean the card so we don't get a flash back to previous content
   
   put empty into fld "gems-quote"
end preOpenCard

on openCard
   lock screen
   local tImageFile, tNextImagePath, tControl
   --ntInfo "gems opencard"
   audioIsRunning     
   
   if isMobile() then
      put the filename of image "gems-Image" into tImageFile
      set the itemdel to "/"  
      put   (sivasiva_AssetFolder()&"/img/photography/"  & (item -2 to -1 of tImageFile) ) \
            into tNextImagePath
      set the filename of img "gems-image" to tNextImagePath 
   end if 
   
   put 0 into sViewState
   
   # determine if you can show online context icon
   --   put connectivity_PingServer() into sOnline
   -- put true into sOnline
   
   
   setCardTitle 
   
   --ntInfo "fetchQuote"
   fetchQuote 
   --ntInfo "fetchImage"
   fetchImage
   --ntInfo "done"
   ntinfo "Open cards gems: lockscreen is: " & the lockscreen
   
   unlock screen
end opencard


on setCardTitle
   local tTitles, tRealm
   if sJournalData is empty then 
      put itemOffset(sConfigA["currentRealm"],"God,Soul,Life")  into sCurrentRealm
      if sCurrentRealm = 0 then 
         put random(3) into sCurrentRealm
      end if
      put "Realm of God,Realm of Soul,Realm of Life" into tTitles
      put item sCurrentRealm of tTitles into tRealm
   else
      put sJournalData["realm"] into tRealm
   end if
   put tRealm into fld "title"     
   -- set the acceleratedRendering of this stack to true
end setCardTitle

on closecard
   --set the acceleratedRendering of this stack to false
   --resetUI
end closecard

command fetchQuote
   local tConnectionID, tCats, tQuoteSQL, tQuote, aSelectedQuotes, pQuoteID, tSource
   hide button "loadContext"
   
   
   set the uSourceURL of button "loadContext" to empty
   put JnanamDB() into tConnectionID
   
   if sJournalData is empty  then # coming portal stack, we want random quote
      
      if sCurrentRealm is empty then
         put itemOffset(sConfigA["currentRealm"],"God,Soul,Life") into sCurrentRealm
      end if
      
      ## Fetch quote a randon quote from same category
      
      put line sCurrentRealm of the uRealmCats of this card into tCats
      put _getRandomSQL() into tQuoteSQL
      replace ":1" with tCats in tQuoteSQL
      
      dbSetSQL tQuoteSQL
      put (char 1 to 35 of tQuote)& "..." into sTruncFirstLine
      put textEncode(sTruncFirstLine,"UTF8") into sTruncFirstLine
      # store the quote id. see lib_SivaSivaMedia
      
      put dbGet("quote", tConnectionID) into aSelectedQuotes
      ntInfo "Quote from dbase"
      put textDecode ( aSelectedQuotes[1]["content"], "UTF8")  into tQuote
      setLastQuoteID (aSelectedQuotes[1]["quote_id"])
      replace "\n" with cr in tQuote
      put (char 1 to 35 of tQuote)& "..." into sTruncFirstLine
      --put getLastQuoteID() # check
   else 
      put sJournalData["lastQuote"] into pQuoteID 
      dbLike "quote_id",pQuoteID
      put dbGet("quote", tConnectionID) into aSelectedQuotes
      put textDecode  (aSelectedQuotes[1]["content"],"UTF8")  into tQuote
   end if
   
   replace "\n" with cr in tQuote
   put tQuote into fld "gems-quote"
   
   if isMobile() then
      
      # there is no way to dynamically fetch the new formatted height if the
      # next quote is longer than the last one. Our only option is to delete
      # and recreate the mobilescroller on the fly      
      
      #scroller_Delete "scrolling gems field"
      deleteMobileControl "gems-quote"
      # recreate:
      if the formattedheight of fld "gems-quote" > the height of fld "gems-quote" then
         send "CreateScroller gems-quote" to fld "gems-quote"
         #set the mobile_VerticalScroller of fld "gems-quote" to "scrolling gems field"
      end if
      
   end if
   
   put textDecode ( aSelectedQuotes[1]["source_url"], "UTF8") into tSource
   
   
   --------------------
   # We are going to set context to "sleeping
   --   see button "loadContext"
   --on mouseUp
   --   deleteMobileControl "gems-quote"
   --   toggleReadContext ("true")
   --end mouseUp
   
   
   # We need to use https, but if we change all the URL in the dbase on the server
   # then we need a little test/fork
   
   --   if (char 1 to 5 of tSource) <> "https" then
   --      replace "http" with "https" in tSource
   --   end if
   
   --   if sOnLine ="true" then
   --      if tSource <> empty then
   --         # some bogus data in this field so confirm 
   --         if char 1 to 5 of tSource ="https" then
   --            set the uSourceURL of button "loadContext" to tSource
   --            put tSource into sCurrentSourceURL  # for sharing 
   --            show button "loadContext"
   --         end if
   --      end if
   --   end if
   
end fetchQuote

command fetchImage
   local tRealm, tImgSQL, tImageFileID, tNextImagePath, tControl
   // AAG: Tip, folders in Android change every time the application
   // is launched. So storing a full path (assets) for the image
   // will break the next time the app launches. Below
   // there is a paste from adb logcat showing the difference:
   //
   //
   // gems image /data/app/com.himalayanacademy.com.sivasiva-PoonAnie94UgFQSw4WAasg==/base.apk/assets/img/photography/app-img_shutterstock_3322947_736h-landscape/app-img_shutterstock_3322947_736h-landscape_med.jpg  
   // gems image /data/app/com.himalayanacademy.com.sivasiva-5cEvxO85YuYpwj-Vi3VIyg==/base.apk/assets/img/photography/app-img_13_hatha_736h-landscape/app-img_13_hatha_736h-landscape_med.jpg 
   // 
   // Notice that the package changes between launches.
   //                       
   if sJournalData = empty then
      put sConfigA["currentRealm"] into tRealm
      put _getRandomImageSQL() into tImgSQL
      replace ":1" with tRealm in tImgSQL
      dbSetSQL tImgSQL
      put dbGet ("file_id", JnanamDB()) into tImageFileID
      put textDecode ( tImageFileID[1]["file_id"], "UTF8")  into tImageFileID     
      put "img/photography/"  & tImageFileID & "/" & tImageFileID & "_med.jpg" into tNextImagePath
   else
      put sJournalData["lastImage"] into tNextImagePath   
   end if
   --ntInfo "gems image" && tNextImagePath
   
   put the long id of img "gems-image" into tControl
   set the filename of tControl to sivasiva_AssetFolder() & tNextImagePath   
   setImageToFullCardLoc tControl, "portrait"
   set the loc of tControl to CardLoc()
   
   setLastImagePath tNextImagePath
   
   show image "gems-Image" 
   
   put empty into sJournalData
   # otherwise you get the same quote over and over again!
   
end fetchImage

on updateImages
   jnanam_UpdatePhotoCache
end updateImages
 
private function _getRandomSQL
   local tSQL
   put the uRandomSQLQuery of this card into tSQL
   return tSQL
end _getRandomSQL

private function _getRandomImageSQL
   local tSQL
   put the uRandomImageSelect of this card into tSQL
   return tSQL
end _getRandomImageSQL


--> Handlers
-
command incrementRealm 
   put 0 into sViewState
   show grp "quoteControl"
   if sCurrentRealm = 3 then 
      put 1 into sCurrentRealm
   else 
      add 1 to sCurrentRealm
   end if   
   setCardTitle
end incrementRealm

on checkRealm
   put sCurrentRealm
end checkRealm

--command toggleReadContext pState
--   local tURL, pData
--   switch pState
--      case "true"
--         if connectivity_PingServer() is "true" then
--            put the uSourceURL of the target into tURL
--            set the url of widget "readContext" to tURL
--            browser_SetLastURL tURL
--            hide the target
--            hide button "goNextRealm" # svg

--            --            ## GEOMETRY

--            --            ## we will later refactor this to an UpDateUI OI(or something) responsive Geometry  handler
--            --            # for not it is based on fixed rect as per:
--            --            # mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,736"

--            --            set rect of  widget "readContext" to (10,the bottom of btn "cancel"+ 6,404,680)

--            --            ## 

--            show    widget "readContext" # a browser
--            # log for journal, we are using a widget in Gems, but we woudl resume in the browser stack
--            # and not actually go back to gem in this case
--            show button "cancel"
--            put fld "title" into pData["currentRealm"]
--            tracking_RecordActivity "Gems", "read/quoteContext", pData
--         else
--            dialog_CustomMsg "Offline or Low Bandwidth"
--         end if
--         break
--      case "false"

--         set the url of widget "readContext" to empty
--         hide widget "readContext"
--         hide button "cancel"
--         show button "goNextRealm"
--   end switch
--end toggleReadContext

on addJournalEntry pContext
   local tRealm, pDataA, pData, tTitle
   switch pContext
      case "pReadQuote"
         put  item sCurrentRealm of ("God,Soul,Life") into  tRealm
         put "images-quotes" into pDataA["card"]
         put tRealm into sConfigA["currentRealm"]
         put tRealm into pDataA["realm"]
         put getLastImagePath() into pDataA["lastImage"]
         put getLastQuoteID() into pDataA["lastQuote"]
         Journal_RecordEntry "gems", sTruncFirstLine, pDataA
         break
         --      case "pBookPage"        
         --         put browser_GetLastURL() into pData["weburl"]
         --         put  browser_GetLastPageTitle() into tTitle
         --         Journal_RecordEntry "view_SivaSivaBrowser",tTitle,pData   
   end switch
   dialog_CustomMsg "Saved to Journal"
end addJournalEntry

command switchViewState 
   switch sViewState
      case 0          # img is full size and quote is showing    
         hide group "quoteControl"
         put 1 into sViewState
         break          
      case 1  # quote is hidden but image is full size
         toggleImgSize (the long id of img "gems-image"),,(the width of this card) 
         put 2 into sViewState
         break
      case  2 # quote is hidden, image is small need to restore complete view
         toggleImgSize (the long id of img "gems-image"),,(the formattedwidth of img "gems-image") 
         show group "quoteControl"
         put 0 into sViewState     
   end switch
end switchViewState

command share_Items
   local tShareItemsA
   put  sCurrentSourceURL into tShareItemsA["url"]  
   # if url is empty should default to home page for the app
   put fld "gems-quote" into tShareItemsA["text"]
   put "Gems of Wisdom from SivaSiva.App" into tShareItemsA["subject"]
   return tShareItemsA
end share_Items

--command resetUI
--   set the uSourceURL of button "loadContext" to empty
--   put empty into sCurrentSourceURL
--   toggleReadContext "false"
--end resetUI
