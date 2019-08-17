Script "stack_surprise_"

/*
# Name: stack "surprise"
# ID: stack "surprise"
*/


local sMediaURL,sQuoteData,sOnline
local sCollection
local sPlayerRect

on preOpenStack
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preOpenStack

on preOpenCard
   updateUI
end preOpenCard

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

on openstack
   set the acceleratedRendering of this stack to true
end openstack

on opencard
   audioIsRunning
end opencard

on closeStack
   portal_SetLastStack "Surprise"
end closeStack

on updateUI
   local tHeader, tFooter, tCard, tLoc, tNext, tBackground
   put the long id of grp "footerNavigation" into tFooter
   set the width of tFooter to CardWidth()
   bottomCenterMe tFooter
   
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
         put the long id of grp "go-next" into tNext
         break
      case "surprise_audio"
         put the long id img "headset_portrait_bkgnd_opt-50.jpg" into tBackground
         put the long id of grp "go-next" into tNext
         put (21, the top of tFooter - 53, CardWidth() - 21, the top of tFooter - 21) \
               into sPlayerRect
         set the rect of player "audioPlayer" to sPlayerRect
         break
      case "surprise_video"
         break
   end switch
   
   if there is a tBackground then
      setImageToFullCardLoc tBackground, "portrait"
      set the loc of tBackground to CardLoc()
   end if
   
   if there is a tNext then
      set the top of tNext to safeTopMargin() - 6
      set the right of tNext to CardWidth() + 9
   end if
   
   if there is a grp "audioGlobalControl" then
      set the top of grp "audioGlobalControl" to safeTopMargin() + 7
   end if
end updateUI

# go to random media type
# if the user is not connected to the network
# take him to verses.
# check the script if each card you know what happens

command setUpSurprise
   local tTargets, tTarget, tCard
   if connectivity_PingServer() = "true" then 
      put "verse,audio,darshan,art,video" into tTargets
      put item (random(5)) of tTargets into tTarget
      put "surprise_"&tTarget into tCard
   else
      ntInfo "no network"
      put "surprise_verse" into tCard
   end if
   ntInfo "surprise:" && tCard
   if tCard is "surprise_verse" then
      pokeACollection
      insertRandomVerse # this take you to surprise_verse
   else
      go to card tCard
   end if
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
   local tCard
   put the short name of this card into tCard
   switch tCard
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
