script "behavior_Surprise"
local sMediaURL, sQuoteData, sOnline
local sCollection, sTimeStamp, sCard
local sPlayerRect, sSelectHttp
local sCurrentPlayListA,  sSelectNum
put (20, the bottom of tNext + 30 ,CardWidth() - 20, the top of tPausePlay - 50) into tRect
on preOpenStack
   --breakpoint
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preOpenStack


on preOpenCard
   updateUI
end preOpenCard


on opencard
   audioIsRunning
   --copyLogControl
   put the short name of this card into sCard
end opencard


on closeStack
   portal_SetLastStack "Surprise"
end closeStack


on mouseup 
   
   local tTarget
   put the short name of this card into sCard
   put the short name of the target into tTarget
   
   if tTarget is "turnOffAudio" then turnOffAudio
   
   switch sCard
      case "surprise"
         if tTarget = "Surprise" then
            setUpSurprise
         end if
         break
         
      case "surprise_audio" 
         switch tTarget # START switch for audio card "surprise_audio"
            case "go-next"
               if not isMobile() then
                  stop player "audioPlayer"
                  set the filename of player "audioPlayer"  to empty
               else 
                  setMobileAudioPlayer "audioPlayer", false
                  deleteMobileControl "audioPlayer"
               end if
               
               getNextItem
               show grp "downloadSelection" 
               break
               
            case "pauseAudio"
               if not isMobile() then
                  put  the currentTime of player "audioPlayer" into sTimeStamp
               else
                  put mobileControlGet ( "audioPlayer", "currentTime" ) into sTimeStamp
               end if
               pausePlayer sTimeStamp
               break
               
            case "playAudio"
               if not isMobile() then
                  set  the currentTime of player "audioPlayer" to sTimeStamp
               end if
               playPausedAudio sTimeStamp
               break
               
            case "loading"
               setMobileAudioPlayer "audioPlayer","stop"
               deleteMobileControl "audioPlayer" 
               wait 20 milliseconds
               showBusyIndicator false
               put empty into fld "audioDetails"
               go to card "surprise_menu"
               break
               
            case "downloadSelection"
               
               if connectivity_PingServer() <> "true" then
                  dialog_CustomMsg "Offline or Low Bandwidth"
                  exit mouseup
               end if
               
               put mediaUrl_Get(sMediaURL) into sSelectHttp
               
               
               if sSelectHttp<> empty then  # we have a selection
                  doAnswer "Download this audio file?" &cr& "Journal entry requires a download.", "Download,Cancel","downloadAffirmed" 
               end if
               
               
               break
               
         end switch #END  switch for audio card "surprise_audio"
         break
         
      default 
         if checkIsLoading() is true then 
            exit mouseup
         else
            getNextItem
         end if
         
   end switch
   
end mouseup


# go to random media type
# if the user is not connected to the network
# take him to verses.
# check the script if each card you know what happens

command setUpSurprise
   
   local tTargets, tTarget, tCard
   if connectivity_PingServer() = "true" then 
      --put "video" into tTarget # for test one card only: comment out the following 2 lines
      --put "verses" into tTarget --,audio,darshan,art,video" into tTargets
      # for some reason, video will not send the
      # broader download complete or  hideLoader to the browser
      # from this context so we are taking in out
      put "verses,audio,darshan,art,video" into tTargets
      put item (random(5)) of tTargets into tTarget
      put "surprise_"&tTarget into tCard
   else
      put "surprise_verses" into tCard
   end if
   
   switch tCard
      
      case "surprise_verse" 
         pokeACollection
         insertRandomVerse # this take you to surprise_verse
         break
      case "surprise_video"
         getRandomVideo
      default
         go to card tCard
   end switch
   
end setUpSurprise


command fetchRandomQuote pSubject  # same as sCollection
   local tSQL, tConnectionID, aSelectedQuotes, tQuote
   put the uRandomQuoteBySubjectQuery of this stack into tSQL
   replace ":1" with pSubject in tSQL
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet("quote", tConnectionID) into aSelectedQuotes
   put textDecode ( aSelectedQuotes[1]["content"], "UTF8")  into tQuote
   replace "\n" with cr in tQuote
   put tQuote into  sQuoteData["content"]
   put textDecode ( aSelectedQuotes[1]["citation"], "UTF8")  into sQuoteData["citation"]
   put textDecode ( aSelectedQuotes[1]["subject"], "UTF8")  into sQuoteData["subject"]
   put textDecode ( aSelectedQuotes[1]["author"], "UTF8")  into sQuoteData["author"]
   
   # Later pass source to call browser to read source,
   # after we get internet connectivity thing more robust
   # put textDecode ( aSelectedQuotes[1]["source_url"], UTF8)  into sQuoteData["sourceURL"]
   
end fetchRandomQuote


function getQuoteData
   return sQuoteData
end getQuoteData

# sometime we need to get a collection if we should go to verses
# they are in to subject field of the data base jnanam.quotes table. 
# we use that column for name of collection 
# see card "surprise_verses" we have these as buttons.
# other wise it comes from the mouse on butttons of that card

command  pokeACollection
   local tCollection
   put "Tayumanvar,Vedas,Tirukural,Words of Our Master,Atti Chudi" into tCollection
   put item (random(5)) of tCollection into tCollection
   setCurrentCollection tCollection
end pokeACollection

command setCurrentCollection pCollection
   put pCollection into sCollection
end setCurrentCollection

function getCurrentCollection
   return sCollection
end getCurrentCollection

function getPlayerRect
   return sPlayerRect
end getPlayerRect

on insertRandomVerse
   lock screen
   fetchRandomQuote (sCollection)
   -- go to the card first to shorten object references in the card script
   go to card "surprise_verse"
   send "setUpQuote" to card "surprise_verse"
   send "positionQuote" to card "surprise_verse"
   unlock screen
end insertRandomVerse

on mediaUrl_Set pURL # used by all card except verses
   put pURL into sMediaURL 
end mediaUrl_Set

function mediaUrl_Get
   return sMediaURL
end mediaUrl_Get

on getNextItem
   
   switch sCard
      case "surprise_verse"
         insertRandomVerse # handled here in the stack script
         break
      case "surprise_art"
         dispatch "getAnImage" to this card
         break
      case "surprise_darshan"
         dispatch "getAnImage" to this card
         break
      case "surprise_audio"
         dispatch "getRandomAudio" to this card
         break
      case "surprise_video"
         # not implemented; we have to leave this stack
         # maybe in V2 if there is a demand
         break
   end switch
end getNextItem

##------------ audio

on pausePlayer sTimeStamp
   if not isMobile() then
      set the paused of  player "audioPlayer" to "true"
   else 
      wait 200 milliseconds
      setMobileAudioPlayer "audioPlayer", "pause",sTimeStamp
   end if
   togglePause true, false
end pausePlayer


on playPausedAudio sTimeStamp
   if not isMobile() then
      set the currenttime  of player "audioPlayer" to sTimeStamp
      start player "audioPlayer"
   else
      setMobileAudioPlayer "audioPlayer", "play", sTimeStamp
   end if
   togglePause true, true
end playPausedAudio

command downloadAffirmed   
   local tTitle, tNewRecordA, sLastTarget
   if  sCurrentPlayListA["playListClass"] ="audiobook" then
      put  sCurrentPlayListA["audioFiles"]["toc"][sSelectNum]["label"] into tTitle
   else
      put   sCurrentPlayListA["audioFiles"][sSelectNum]["title"]  into tTitle
   end if
   put sCurrentPlayListA["audioFiles"][sSelectNum] into tNewRecordA
   jnanam_SaveNewItem tNewRecordA
   show grp "downloadControls"
   wait 100 milliseconds with messages
   dispatch "downloadURL"  to group "downloadControls" with  tTitle, sSelectHttp, sSelectNum, sLastTarget
   # sLastTarget becomes params pRequest by to the download stack
end downloadAffirmed


on hideDownloadControls
   local tLastStack
   put empty into fld "ProgressTitle"
   put empty into fld "progressField"
   hide scrollbar "progressbar"
   hide grp "downloadSelection"
end hideDownloadControls


--command  journal_AddEntry -- save a bookmark to db
--   local tCdName, tData, tTitle
--   put sLastActivityA["CdName"] into tCdName

--   put tCdName into tData["card"] -- store the last user cd   

--   if tCdName = "daily-lesson" then -- store the lesson number
--      put "Master Course Daily Lesson"  into tTitle
--   end if

--   Journal_RecordEntry "daily-lesson",tTitle,tData -- send to journal
--   dialog_CustomMsg "Saved to Shortcuts"
--end  journal_AddEntry

command journal_AddEntry tCard-- save a bookmark to db
   
   local tData,pDataA, tTitle, tURL --, tCard
   
   
   put getMediaMeta() into tData
   
   if tCard is "surprise_audio" then
      --put getMediaMeta() into tData
      put tData["item_id"] into pDataA["item_id"]
      put tData["title"] into pDataA["title"]
      put tData["title"] into tTitle
      put mediaUrl_Get() into pDataA["url"] 
      put sTimeStamp  into pDataA["timestamp"]
      put "listen-file" into pDataA["card"] 
      Journal_RecordEntry "listen",tTitle,pDataA
   else
      put tCard  into tTitle
      put tCard into tData["card"]
      Journal_RecordEntry "surprise",tTitle,tData
   end if
   
   dialog_CustomMsg "Saved to Shortcuts"
   
end journal_AddEntry 

on journalResume pData,pEntryA -- sent from journal stack
   lock screen
   local tCd
   put pData["card"] into tCd
   go to card tCd
   unlock screen
end journalResume

on _GEOMETRY
end _GEOMETRY

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack


on updateUI
   local tHeader, tFooter, tCard, tLoc, tNext, tBackground, tRect
   local tLoading, tPausePlay, tLoadingNotice,tTouchTrap
   local tAudioDetails, tDownloadSelection, tTitle
   
   
   put the long id of grp "footerNavigation" into tFooter
   send "updateUI" to tFooter
   
   if there is a grp "viewLogging" then
      set the bottom of btn "Hide" of grp "viewLogging" to the top of tFooter - 20
      set the bottom of btn "Clear" of grp "viewLogging" to the top of tFooter - 20
      put the rect of fld "log" of grp "viewLogging" into tRect
      put the top of btn "Hide" of grp "viewLogging" - 2 into item 4 of tRect
      set the rect of fld "log" of grp "viewLogging" to tRect
   end if
   
   put the long id of grc "touchTrap" of me into tTouchTrap
   put the long id of grc "loading" of me into tLoadingNotice
   set the rect of tTouchTrap to cardRect()
   bottomCenterMe tLoadingNotice,65
   
   put the long id of grp "header" into tHeader
   set the width of tHeader to CardWidth()
   topCenterMe tHeader, -12
   
   put the short name of this card into tCard
   switch tCard
      
      case "surprise"
         put the long id img "randomPhoto" into tBackground
         put the loc of tFooter into tLoc
         subtract 89 from item 2 of tLoc
         set the loc of btn "Surprise" to tLoc
         break
      case "surprise_verses"
         put the long id img "surprise-verses-bkgnd_opt-70.jpg" into tBackground
         set the right of grp "verse-collections" to CardWidth() - 10
         break
      case "surprise_verse"
         put the long id of img "parchment-portrait-bkgnd_opt-50.jpg" into tBackground
         put the long id of grp "go-next" into tNext
         break
      case "surprise_art"
         put the long id of img "fabric-lt-brown_portrait-bkgnd_opt-50.jpg" into tBackground
         put the long id of grp "go-next" into tNext
         
         break 
      case "surprise_darshan"
         put the long id of img "fabric-blue_portrait-bkgnd_opt-12.jpg" into tBackground
         put the long id of grp "go-next"into tNext
         
         break
      case "surprise_audio"
         put the long id img "headset_portrait_bkgnd_opt-50.jpg" into tBackground
         
         put the long id of grp "go-next" into tNext
         topRightMe tNext, 222, 220
         
         --ntinfo "switch card before going to audio before center in load/player"
         
         put the long id of grp "loadingGroup" into tLoading
         bottomCenterMe tLoading,120
         
         put the long id of grp "pause-play" into tPausePlay
         bottomCenterMe tPausePlay,65
         
         put the long id of fld "title" into tTitle
         topLeftMe tTitle, 20, 20
         
         put the long id of fld "audioDetails" into tAudioDetails
         put (20, 100,CardWidth() - 20, the top of tPausePlay - 15) into tRect
         set the rect of  tAudioDetails to tRect
         
         put (21, the top of tFooter - 53, CardWidth() - 21, the top of tFooter - 21) \
               into sPlayerRect
         set the rect of player "audioPlayer" to sPlayerRect
         
         put the long id of grp  "downloadSelection" into tDownloadSelection
         topRightMe tDownloadSelection, 35, 45
         show grp  "downloadSelection" 
         break
         
      case "surprise_video"
         break
   end switch
   
   
   if there is a tBackground then
      setImageToFullCardLoc tBackground, "portrait"
      set the loc of tBackground to CardLoc()
   end if
   
   if there is a tNext then
      set the top of tNext to safeTopMargin()
      set the right of tNext to CardWidth() + 9
   end if
   
   if there is a grp "audioGlobalControl" then
      set the top of grp "audioGlobalControl" to safeTopMargin() + 7
   end if
end updateUI


