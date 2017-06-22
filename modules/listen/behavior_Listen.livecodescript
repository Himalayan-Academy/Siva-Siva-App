script "behavior_Listen"
local sCurrentPlayListA,sTargetPlayList,sListType,sPlaylistQueryA

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
   # if this stack is opened from a closed state
   # we can safely assume the portal link is the target playlist
   
   put portal_GetLastLinkTitle() into sTargetPlayList   
   playlist_SetCurrent sTargetPlayList
   
   # if stack is already open, then other playlist can be called
   # using the playlist_SetCurrent command.
   # now we have our play list we set up the query next
   playlist_QuerySetUp
   
end openstack

-----------------------------------------------------
# playlist_Set|GetCurrent
# DESCRIPTION:  the primary known variable is a string 
# which is the list name, which is usually it's title
# in V1 we are just picking this up from the portal link
# as the Audio UI develops we can create more in this module space
# we don't know later how this will develop, But regardless 
# in any scenario we will want to be able to set and get this variable:
# PARAMS: pass the playlist string, which should also serve as it's title (at least in V1)
# CHANGES: Created 2017-06-22 Brahmanathaswami
------------------------------------------------------

on playlist_SetCurrent pList
   put pList into sCurrentPlayListA["playlistTitle"]
end playlist_SetCurrent

function playlist_GetCurrent
   return sCurrentPlayListA["playlistTitle"]
end playlist_GetCurrent


-----------------------------------------------------------------------
# playlist_QuerySetUp
# DESCRIPTION
# we have three types of lists based on data storage/CMS
# each requires a different query
# Remote list: send JSON to serverwe send JSON for remote list
# Audiobook: build a path string and download index. json for audio books
# query the local dbase for already cached metadata in the Local Jnanam dbase
# we need max six criteria to search our metadata, not all playlists require all string, 
   # but our query array will still have all these keys; use elements as needed
   # we will model that array into a json string or dbase query later
   # media_type, author, artist, record-type [latest | cached | audiobook], num-of-records,year, file_id
   # see /system/applications/ha/controllers/API3.lc  on the server for details on the remote call
   #  structure of remote query, for reference:
   #   put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'recordType':'latest','recordCount':'30'}" into tJSON
# We have to do this "by hand"  in a switch case by case statemnt
# hard wiring the query data in this script is
# bad practice... later we should externalize to a playlists.json file 
# but for now:
# PARAMS: pass the current play list string
# CHANGES: 2017-06-22 - BR Created
-----------------------------------------------------------------------


on playlist_QuerySetUp sTargetPlayList   
   # Note: we are inserting queries strings... these are not the values of the records
   # the entire play list
   # aagDBLib uses "LIKE" so we only need to pass partial string for our searches
   # again: we should store these values in modules/listen/playlists.json
   
   switch sTargetPlayList
      case "Bodhinatha's Latest Talks" # Remote look up
         put "inspiredtalk" into sPlaylistQueryA["media_type"]
         put "Bodhinatha" into sPlaylistQueryA["author"]
         put "cached" into sPlaylistQueryA["recordType"]
         put 30 into sPlaylistQueryA["recordCount"]
         break
      case " Gurudeva's 1970 Master Course"
           put "inspiredtalk" into sPlaylistQueryA["media_type"]
         put "Subramuniyaswami" into sPlaylistQueryA["author"]
         put "cached" into sPlaylistQueryA["recordType"]
         put "1970" into sPlaylistQueryA["year"]
         put "master-course" into sPlaylistQueryA["file_id"]
         break
      case "The Guru Chronicles" # Audio book
         # for audio books; we need to know the file ID, which is the folder name
         # after that it is a simple path set up.
         put "the-guru-chronicles-audiobook" into sPlaylistQueryA["file_id"]
         put "Swamis of Kauai's Hindu Monastery" into sPlaylistQueryA["getAuthor"]
         put "audiobook" into sPlaylistQueryA["recordType"]
         break
      case "Gujarati Dancing with Siva Audiobook" # Audio book
         # for audio books; we need to know the file ID, which is the folder name
         # after that it is a simple path set up.
         put "dancing-with-siva-audiobook-gujarati" into sPlaylistQueryA["file_id"]
         put "Satguru Sivaya Subramuninyaswami" into sPlaylistQueryA["author"]
         put "audiobook" into sPlaylistQueryA["recordType"]
         break         
   end switch
   
   playList_FetchData 
   
end playlist_QuerySetUp

-----------------------------------------------------------------------
# playList_FetchData
# DESCRIPTION: 
# We use the values in sCurrentPlayListA  to get what we need to put on the card
# Later when users select info on the card we will have two known values
# the line number and the string, which will be the title of the record
# Sorting differs by recordType: latest|descending by date, audiobook | per json index, cached | alpha by title or file_ID
# usually trigger on arrival to this stack-card
# but also from action on UI (Home card later)
# PARAMS: everything is taken from the sCurrentPlaylistA array
-----------------------------------------------------------------------

on playList_FetchData
   
   put sPlaylistQueryA["recordType"] into tRecordType
   
   switch tRecordType
      case "latest"
            put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'record-type':'latest','num-of-records':'30'}" into tJSON
         break
      case "audiobook"
         break
      case "cached"
         break
   end switch
   
end playList_FetchData

on playlist_Instantiate sTargetPlayList
   
   ## Title and thumbnail:
   put sCurrentPlayListA["playlist-title"] into tTitle
   put tTitle into fld "title"
   
   # using: model_SivaSiva, which has functions to get json info we need:
   put sivasiva_FetchData() into tPortalInfoA
   put tPortalInfoA["portalRowDictionary"][tTitle][shortImageFile] into tThumbPath
   put path_Assets() & "img/portal-screens/" & tThumbPath into tPosterPath
   set the filename of img "playlistPoster" to tPosterPath
   
   playlist_SetType sTargetPlayList
end playlist_Instantiate


--> Audio book scenario
on audiobook_FetchFiles
   # uses json stored in a location on the serve and not in the dbase
   # the following snippet from site.lc on our server will help build this.
   --    case "audio/book"
   --     rigLoadLibrary "fastjson"
   --       put url ("file:" & $_SERVER["DOCUMENT_ROOT"] & "/media/audio/books/" & gData["record"]["file_id"] & "/audiobook.json") into tJSON
   --        put jsonToArray(tJSON) into gData["record"]["audiobook"]
end audiobook_FetchFiles


command fetch_GetLatest pJSON
   --put the seconds into sStartTimer
   set the httpheaders to "content-type: application/json"
   replace "'" with quote in pJSON
   POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"
   if the result is not empty then 
      put the result into fld "audioList"
      # reveal field using the function after it is built later      
   else 
      put it into tRecords
      put jsonToArray (tRecords) into sCurrentPlayListA
      put the keys of sCurrentPlayListA into tKeys
      sort lines of tKeys ascending numeric
   end if
   repeat for each line x in tKeys
      put tLatestTalks[x]["Title"] & cr after tTitles
   end repeat
   put tTitles into fld "audioList"
end fetch_GetLatest


-----------------------------------------------------------------------
# UI Interactions | card, group, list, detail display change ups
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

---------------------------------------------
# Select, Play, Listen, Stop UI interactions
---------------------------------------------
local sNowPlayingTitle, sNowPlayingArtist,sNowPlayingDetails,sStartTimer,sEndTimer

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

