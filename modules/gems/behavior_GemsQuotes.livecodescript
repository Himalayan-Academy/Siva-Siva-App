script "behavior_GemsQuotes"
/* 
This script  is the behavior assigned to card 1 
"image-quotes"  of the gems stack

*/

--> Variables
# sCurrentRealm is an  integer 1, 2 or 3  not a string!

global sConfigA
local sOnLine,sCurrentRealm,sViewState,sCurrentSourceURL


--> Events
 
on preOpenCard
   # Make sure our photo cache is updated   
   --  jnanam_UpdatePhotoCache

   
   # Clean the card so we don't get a flash back to previous content
   hide image "gems-image"
   put empty into fld "gems-quote"
   
   # Fix image path from desktop when loading on Mobile
   
   if isMobile() then
      put the filename of image "gems-Image" into tImageFile
      set the itemdel to "/"  
      put   (sivasiva_AssetFolder()&"/img/photography/"  & (item -2 to -1 of tImageFile) ) \
            into tNextImagePath
      set the filename of img "gems-image" to tNextImagePath 
   end if 
   
   # ideally we only call this in start up   
   mobile_SetAllowedOrientation "portrait"
   
   put 0 into sViewState
   
   put connectivity_PingServer() into sOnline
   
   --play (localPath() &"shared/audio/aum.mp3")
   -- create vertical scroller on top of field after all other layout has 
   -- complete and the card is rendered
   
   put itemOffset(sConfigA["currentRealm"],"God,Soul,Life")  into sCurrentRealm
   if sCurrentRealm = 0 then 
      put random(3) into sCurrentRealm
   end if
   setCardTitle
   send "fetchQuoteAndImage sCurrentRealm" to me in 10 milliseconds  
end preOpenCard

on setCardTitle
   put "Realm of God,Realm of Soul,Realm of Life" into tTitles
   put item sCurrentRealm of tTitles into tRealm
   put tRealm into fld "title"     
   AddJournalEntry pReadQuote
   put tRealm into pData["switchRealm"]
   tracking_RecordActivity "Gems", "navigation/realms", pData
end setCardTitle

on closecard
   resetUI

end closecard

command fetchQuoteAndImage
   hide widget "loadContext"
   set the uSourceURL of widget "loadContext" to empty
   
   if sCurrentRealm is empty then
      put itemOffset(sConfigA["currentRealm"],"God,Soul,Life") into sCurrentRealm
   end if
   
   --toggleReadContext ("false")
   # show a picture first
   ## Fetch Images
   
   ## Fetch quote
   put line sCurrentRealm of the uRealmCats of this card into tCats
   put _getRandomSQL() into tQuoteSQL
   replace ":1" with tCats in tQuoteSQL
   put JnanamDB() into tConnectionID
   dbSetSQL tQuoteSQL
   put dbGet("quote", tConnectionID) into aSelectedQuotes
   put textDecode ( aSelectedQuotes[1]["content"], UTF8)  into tQuote
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
   
   put textDecode ( aSelectedQuotes[1]["source_url"], UTF8) into tSource
   
   # We need to use https, but if we change all the URL in the dbase on the server
   # then we need a little test/fork
   
   if (char 1 to 5 of tSource) <> "https" then
      replace "http" with "https" in tSource
   end if
   
   if sOnLine ="true" then
      if tSource <> empty then
         # some bogus data in this field so confirm 
         if char 1 to 5 of tSource ="https" then
            set the uSourceURL of widget "loadContext" to tSource
            put tSource into sCurrentSourceURL  # for sharing 
            show widget "loadContext"
         end if
      end if
   end if
   
   fetchImage sConfigA["currentRealm"]
   
end fetchQuoteAndImage

command fetchImage pRealm
   
   put _getRandomImageSQL() into tImgSQL
   replace ":1" with pRealm in tImgSQL
   put JnanamDB() into tConnectionID
   dbSetSQL tImgSQL
   put dbGet ("file_id", tConnectionID) into tImageFileID
   put textDecode ( tImageFileID[1]["file_id"], UTF8)  into tImageFileID     
   put   (sivasiva_AssetFolder()&"img/photography/")  & tImageFileID & "/" & tImageFileID & "_med.jpg" \
         into tNextImagePath
   set the filename of img "gems-image" to tNextImagePath   
   show image "gems-Image" 

end fetchImage

on updateImages
   jnanam_UpdatePhotoCache
end updateImages
 
private function _getRandomSQL
   put the uRandomSQLQuery of this card into tSQL
   return tSQL
end _getRandomSQL

private function _getRandomImageSQL
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
command toggleReadContext pState
   switch pState
      case "true"
         if connectivity_PingServer() is "true" then
            put the uSourceURL of the target into tURL
            set the url of widget "readContext" to  tURL
            browser_SetLastURL tURL
            hide the target
            hide widget "next-arrow" # svg
            show widget "readContext" # a browser
            # log for journal, we are using a widget in Gems, but we woudl resume in the browser stack
            # and not actually go back to gem in this case
            show widget "cancel"
            send  "AddJournalEntry pBookPage" to stack "behavior_GemsQuotes" in 1000 milliseconds
            put  fld "title" into pData["currentRealm"]
            tracking_RecordActivity "Gems", "read/quoteContext", pData
         else
            dialog_CustomMsg "Offline or Low Bandwidth"
         end if
         break
      case "false"
         
         set the url of widget "readContext" to empty
         hide widget "readContext"
         hide widget "cancel"
         show widget "next-arrow"
         --  show widget "loadContext"      # Only show if there is a URL from the verse  
   end switch
end toggleReadContext

on addJournalEntry pContext
   switch pContext
      case "pReadQuote"
         put  item sCurrentRealm of ("God,Soul,Life") into  tRealm
         put "images-quotes" into pDataA["card"]
         put tRealm into sConfigA["currentRealm"]
         put tRealm into pDataA["realm"]
         Journal_RecordEntry "gems", ("Reading" && tRealm && "Quotes" ), pDataA
         break
      case "pBookPage"        
         put browser_GetLastURL() into pData["weburl"]
         put  browser_GetLastPageTitle() into tTitle
         Journal_RecordEntry "view_SivaSivaBrowser",tTitle,pData   
   end switch
   
end addJournalEntry

command switchViewState 
   switch sViewState
      case 0          # img is full size and quote is showing    
         hide group quoteControl
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
   put  sCurrentSourceURL into sShareItemsA["url"]  
   # if url is empty should default to home page for the app
   put fld "gems-quote" into sShareItemsA["text"]
   put "Gems of Wisdom from SivaSiva.App" into sShareItemsA["subject"]
   return sShareItemsA
end share_Items

command resetUI
   set the uSourceURL of widget "loadContext" to empty
   put empty into sCurrentSourceURL
   if the vis of widget "readContext" then
      toggleReadContext "false"
   end if
end resetUI


on mainStackChanged
   
end mainStackChanged
