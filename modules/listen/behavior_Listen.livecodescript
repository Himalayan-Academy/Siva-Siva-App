script "behavior_Listen"
local sCurrentPlayListA,sTargetPlayList


on preopenstack
   wait 100 milliseconds with messages
   set the fullscreenmode of this stack to "showAll"
   mobile_SetAllowedOrientation "portrait"
   set the acceleratedRendering of this stack to "true"
   cleanUpGui
end preopenstack

on openstack 
   # for V1 we know we are always coming from the Listen Portal
   # and these are basically playlists like on Spotify, though
   # some might qualify as albums, but we don't have enough to 
   # make a differentiation. So treat all as playlists
   
   # but we have different cards in this stack... 
   # let's decide where we are going first    
   # initialize interface
   # nothing here yet...
   
   # assume we are coming from a portal link for now
   # we need to refactor later
   
   put portal_GetLastLinkTitle() into sTargetPlayList   
   playlist_SetCurrent sTargetPlayList
   
   # if stack is already open we can set this PlayList to anything we want.
   # and override the initial play list from a portal.
   
  playlist_Instantiate 
   
end openstack

# we don't know later how this will develop, so let's keep more robust
# functions all here in the stack script and we can make this a behavior later
# when coming and going from home or catalogs of plays lists we will 
# use these to set and get 

on playlist_SetCurrent pList
   put pList into sCurrentPlayListA["playlist-title"]
end playlist_SetCurrent

function playlist_GetCurrent
   return sCurrentPlayListA["playlist-title"]
end playlist_GetCurrent

on closeStack
   set the acceleratedRendering of this stack to "false"
end closeStack


-----------------------------------------------------------------------
# SET UP THE UI
# Clean up and then:
# for now we just install the title and thumbnail 
-----------------------------------------------------------------------

on cleanUpGUI
   # more later but for now, so no flash of previous content 
   put empty into fld "title"
   set the filename of img "playlistPoster" to empty
   put empty into fld "audioList"
   put empty into fld currentTitleLabel
   set the filename of player "audioPlayer" to empty
   ## add other mobile stuff to clear out here later
end cleanUpGUI

on playlist_Instantiate sTargetPlayList
   
   ## Title and thumbnail:
   put sCurrentPlayListA["playlist-title"] into tTitle
   put tTitle into fld "title"
   
   # using: model_SivaSiva, which has functions to get json info we need:
   put sivasiva_FetchData() into tPortalInfoA
   put tPortalInfoA["portalRowDictionary"][tTitle][shortImageFile] into tThumbPath
   put path_Assets() & "img/portal-screens/" & tThumbPath into tPosterPath
   set the filename of img "playlistPoster" to tPosterPath
   
   playlist_FetchData sTargetPlayList
end playlist_Instantiate



-----------------------------------------------------------------------
# UI Interactions
-----------------------------------------------------------------------

on mouseup   
   put the target into pTarget
   put the short name of the Target  into tTarget
   # there are no scripts at all in any object of the UI.
   # all logic for user interaction with the GUI is handled here.
   # but this just a mouse event router. Encapsulate acttion to separate handlers.
   switch tTarget
      case "AudioList"
         put word 2 of the clickline into tSelectNum
         put tSelectNum
         break    
   end switch
end mouseup

-----------------------------------------------------------------------
# FETCH, SAVE, DISPLAY A SINGLE PLAY LIST
# usually trigger on arrival to this stack-card
# but also from action on UI (Home card later)
-----------------------------------------------------------------------


local sNowPlayingTitle, sNowPlayingArtist,sNowPlayingDetails,sStartTimer,sEndTimer

on playList_FetchData pTargetPlayList
   
   # here we want to just get the data and insert into the local array for the current playlist
   # if the word "Latest" is in the string, we go to the server
   # otherwise get it from the local Jnanam dbase, which will be much faster. 
   
   put "Bodhinatha's Latest Talks, The Guru Chronicles, Sanskrit Chanting, Gurudeva's Archives" into tLocalPlayLists
   # "Local playlist"  just means we are not sending anyone to a web page, but have a native UI 
   # for the songs here in the app
   
   if tTargetPlayList is among the items of tLocalPlayLists then
      # We set a play list 
      playlist_SetCurrent tTargetPlayList
      go to card "listen-playlists"  -- Behavior on card will handle the playlists.
      playList_FetchData tTargetPlayList
   else
      # for later... when we build a more robust ui for audio
      # a "Home" card will supplement and "supplant" the listen portal 
      # which does not scale easily.
      go to card "listen-home"  
 end if
   
   
end playList_FetchData

command getLatestBodhinathaTalks
   --put the seconds into sStartTimer
   set the httpheaders to "content-type: application/json"
   put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'record-type':'latest','num-of-records':'30'}" into tJSON
   replace "'" with quote in tJSON
   POST tJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"
   if the result is not empty then 
      put the result into fld "audioDetails"
      # reveal field using the function after it is built later
      
   else 
      put it into tRecords
      put jsonToArray (tRecords) into tLatestTalks
      put the keys of tLatestTalks into tKeys
      sort lines of tKeys ascending numeric
   end if
   repeat for each line x in tKeys
      put tLatestTalks[x]["Title"] & cr after tTitles
   end repeat
   put tTitles into fld "audioList"
   
end getLatestBodhinathaTalks


# Let's break out discreet function and stop overloading the open card handlers
# we can then move these out to library.
# so we should write generalized code that handles none localize param names
# so they can serve in other contexts.
# play audio talks/songs is pretty much the same everywhere.

on playChoice 
   put fetchRandomMediaItem ("media_type","audio") into gotIt
   put getMediaURL () into tURL
   if tURL = "" then -- jg: don't continue
      put "Media not found" into fld "audioDetails"
      set the height of fld "audioDetails" to the formattedHeight of fld "audioDetails"
      showBusyIndicator false
      exit to top
   end if
   
   
   if isMobile() then
      createMobileAudioPlayer tURL, "audioPlayer"
   else
      set the filename of player "audioPlayer" to tURL
   end if
   
   showPlayer "true", "audioPlayer"
   if not isMobile() then 
      start player "audioPlayer"
   else
      setMobileAudioPlayer "play"
   end if
   showBusyIndicator false
   send "showNowPlaying pMax" to me in 10 ticks
end playChoice

on closeCard
   hide fld "audioDetails"
   put empty into fld "audioDetails"
   showPlayer "false", "audioPlayer"
   if isMobile() then 
      deleteAllMobileControls
   end if
end closeCard


# We will expand or shrink the nowPlayingview
# by simply
# collapsing the audio detail field to hold only the title OR
# expand to show all details.
# pull down the chevron and to point up
# controller stays in a fixed location.

# V2 Link to transcript

command showNowPlaying pMaxMin
   switch pMaxMin
      case "pMax"
         break
      case "pMini"
         break
   end switch
   
   put textDecode (getMediaItemMetadata(),"UTF8") into  fld "audioDetails" 
   
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   
   # need to fix this because the height could be too tall
   # if too tall we need to set max height
   # and instantiate scrolling on desktop and mobile
   
   put the formattedHeight of fld "audioDetails" into tRequiredHeight
   
   If tRequiredHeight> 512 then
      # We need to constrain size and set scrolling
      # BR: I'm making an attempt here to see if we can accomodate Tablet
      # by working with the card size instead of setting a fixed pixel rect.
      
      set the rect of fld "AudioDetails" to (45,65,the width of this card-45,the height of this card -150) 
      set the vscrollbar of fld "AudioDetails" to not isMobile()
      
      set the mobile_VerticalScroller of fld "AudioDetails" to "AudioDetails"
      
   else  # it will fit
      set the height of fld "audioDetails" to tRequiredHeight
      if tRequiredHeight > 400 then # too tall to center. falls behind the player controller
         set the top of fld "AudioDetails" to 66
      else
         set the loc of fld "audioDetails" to the loc of this card
      end if
   end if
   
   show fld "audioDetails" with visual effect wipe up very fast
end showNowPlaying

--> Audio book scenario
on audiobook_FetchFiles
   # uses json stored in a location on the serve and not in the dbase
   # the following snippet from site.lc on our server will help build this.
   --    case "audio/book"
   --     rigLoadLibrary "fastjson"
   --       put url ("file:" & $_SERVER["DOCUMENT_ROOT"] & "/media/audio/books/" & gData["record"]["file_id"] & "/audiobook.json") into tJSON
   --        put jsonToArray(tJSON) into gData["record"]["audiobook"]
end audiobook_FetchFiles
