Script "stack_surprise_"

/*
# Name: stack "surprise"
# ID: stack "surprise"
*/


local tCurrentCardOrientation, sMediaURL,sQuoteData, tTargets,sOnline,sCurrentCard
local sFromJournalA,sCollection


on preopenstack
   set the fullscreenmode of this stack to "showAll" -- better for wider screens
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preopenstack

on openstack
   set the acceleratedRendering of this stack to true
end openstack

on opencard
   audioIsRunning
end opencard

# go to random media type
# if the user is not connected to the network
# take him to verses.
# check the script if each card you know what happens

command setUpSurprise
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
   put the uRandomQuoteBySubjectQuery of this stack into tSQL
   replace ":1" with pSubject in tSQL
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet("quote", tConnectionID) into aSelectedQuotes
   put textDecode ( aSelectedQuotes[1]["content"], UTF8)  into tQuote
   replace "\n" with cr in tQuote
   put tQuote into  sQuoteData["content"]
   put textDecode ( aSelectedQuotes[1]["citation"], UTF8)  into sQuoteData["citation"]
   put textDecode ( aSelectedQuotes[1]["subject"], UTF8)  into sQuoteData["subject"]
   put textDecode ( aSelectedQuotes[1]["author"], UTF8)  into sQuoteData["author"]
   
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


on insertRandomVerse
   fetchRandomQuote (sCollection)
   # get it over there first
   send "setUpQuote" to card "surprise_verse"
   go to card "surprise_verse"
end insertRandomVerse

on mediaUrl_Set pURL # used by all card except verses
   put pURL into sMediaURL 
end mediaUrl_Set

function mediaUrl_Get
   return sMediaURL
end mediaUrl_Get

on getNextItem
   put the short name of this card into tCard
   switch tCard
      case "surprise_verse"
         insertRandomVerse # handled here in the stack script
         break
      case "surprise_art"
         dispatch  "getAnImage" to this card
         break
      case "surprise_darshan"
         dispatch  "getAnImage" to this card
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

on closeStack
   portal_SetLastStack "Surprise"
end closeStack

