script "behavior_Listen"

-----------------------------------------------------
#  behavior_Listen
#
# DESCRIPTION
# this behavior is the /modules/listen/listen.livecode stack script
# It's primary function is to handle high level calls to get play lists
# UI consist of 2 main cards
# listen-playlist - for show a single play list
# listen-catalog - later: for showing multiple lists like on Spotify # not in V1
# So as not to over load this script the handlers whose scope deals with
# user interaction with a single play list/ indivitual songs are in a separate behavior 
# behavior_ListenSelectPlay
# assigned to the listen-playlist card
#
# PARAMS: Main variable sent to this script is a string which is the name/title of a playlist
#
# CHANGES: 2017-06-22 CREATED Brahmanathaswami
-----


local sCurrentPlayListA,sTargetPlayList,sListType,sPlaylistQueryA
local sNowPlayingTitle, sNowPlayingArtist,sNowPlayingDetails,sStartTimer,sEndTimer
local sDownloadedFlag

on preopenstack
   # may be fixed in recent versions Android crashed on stack swaps
   # this little wait helped 
   wait 100 milliseconds with messages 
   set the fullscreenmode of this stack to "showAll"
   mobile_SetAllowedOrientation "portrait"
   set the acceleratedRendering of this stack to "true"
end preopenstack
 
on openstack 
   # for V1 we know we are always coming from the Listen Portal
   # and these are basically playlists like on Spotify, though
   # some might qualify as albums, but we don't have enough to 
   # make a differentiation. So treat all as playlists  
   # if this stack is opened from a closed state
   # we can safely assume the portal link is the target playlist
   
   put (fld "audioList" is empty)
   if fld "audioList" is empty then
     show widget "Downloading"
      #We are about to download or fetch a list
      put "false" into sDownloadedFlag
      showDownloadProgress
   end if
   
   put portal_GetLastLinkTitle() into sTargetPlayList   
   playlist_SetCurrent sTargetPlayList
   
   # if stack is already open, then other playlist can be called
   # using the playlist_SetCurrent command.
   # now we have our play list we set up the query next
   playlist_QuerySetUp sTargetPlayList
   
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
   put pList into sTargetPlayList
end playlist_SetCurrent

function playlist_GetCurrent
   return sCurrentPlayListA["playListTitle"]
end playlist_GetCurrent

function playlist_GetRecords  # use this to fetch data later for card behavior
   if sCurrentPlayListA is empty then
      put "No records Fetched!"
   else
      return sCurrentPlaylistA  
   end if
end playlist_GetRecords


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


on playlist_QuerySetUp
      
   # Note: we are inserting queries strings... these are not the values of the records
   # the entire play list
   # aagDBLib uses "LIKE" so we only need to pass partial string for our searches
   # again: we should store these values in modules/listen/playlists.json
   
   switch sTargetPlayList
      case "Bodhinatha's Latest Talks" # Remote look up
         put "inspiredtalk" into sPlaylistQueryA["media_type"]
         put "Bodhinatha" into sPlaylistQueryA["author"]
         put "latest" into sPlaylistQueryA["recordType"]
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
         # we do a JSON Call  Hard wiring as a test for now. but we should later 
         # use the a function in lib_SivaSivaMedia to model this array sPlaylistQueryA into the pJSON
         # we need because we can then use for different play lists on demand.. 
         put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'recordType':'latest','recordCount':'30'}" into pJSON
         put the ticks into sStartTimer
         set the httpheaders to "content-type: application/json"
         replace "'" with quote in pJSON
         POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"
         if the result is not empty then 
            put the result into fld "audioList"
            # reveal field using the function after it is built later      
         else 
            put it into tRecords
            put jsonToArray (tRecords) into sCurrentPlayListA
         end if
         # add list type for other operations
         put tRecordType into sCurrentPlayList["listType"]
         
         break
      case "audiobook"
         # uses json stored in a location on the serve and not in the dbase
         # the following snippet from site.lc on our server will help build this.
         --    case "audio/book"
         --     rigLoadLibrary "fastjson"
         --       put url ("file:" & $_SERVER["DOCUMENT_ROOT"] & "/media/audio/books/" & gData["record"]["file_id"] & "/audiobook.json") into tJSON
         --        put jsonToArray(tJSON) into gData["record"]["audiobook"]
         break
      case "cached"
         -- pass our sPlaylistQueryA to lib_SivaSivaMedia to fetch records from the local SQLlite dbase
         break
   end switch
   
   -- put (the ticks - sStartTimer)  early tests: as long as 3 minutes to get data from the server...
   # we have the data for our records in the array now.
   # need know two things from the beginning
   put tRecordType into sCurrentPlaylistA["listType"]
   put sTargetPlayList into sCurrentPlayListA["playListTitle"]
   
   playlist_Instantiate sTargetPlayList
   
end playList_FetchData


-----------------------------------------------------------------------
# playlist_Instantiate
#
# DESCRIPTION: 
# card 1 of this stack must always be card "listen-playlist" 
# as such, object references here refer to controls on that card
# this is where we fill in the play list 
#
# PARAMS: everything is taken from the sCurrentPlaylistA array
#
# CHANGES: 2017-06-22 created Brahmanathswami
-----------------------------------------------------------------------


on playlist_Instantiate sTargetPlayList   
   # we may have the stack already open 
   # and switching play list so clear the card first:
   
   dispatch "cleanUpGui" to card "listen-playlist"
   
   ## Title and thumbnail:
   put sTargetPlayList into tTitle 
   put tTitle into fld "title"   
   # using: model_SivaSiva, which has functions to get json info we need:
   put sivasiva_FetchData() into tPortalInfoA
   put tPortalInfoA["portalRowDictionary"][tTitle][shortImageFile] into tThumbPath
   put path_Assets() & "img/portal-screens/" & tThumbPath into tPosterPath
   set the filename of img "playlistPoster" to tPosterPath
   put the keys of sCurrentPlayListA into tKeys
   sort lines of tKeys ascending numeric

   repeat for each line x in tKeys
      # the array includes key/values info for theplaylist that are not  audio files
      # these are always strings, keys for files are always numeric index
      if isNumber(x) then 
         put sCurrentPlayListA[x]["Title"] & cr after tTitles
      end if
   end repeat
   put tTitles into fld "audioList"
      if the formattedHeight fld "audioList" > the height of fld "AudioList" then
      send "CreateScroller audioList" to fld "audioList" of card "listen-playlist"
   end if
   
end playlist_Instantiate

on showDownloadProgress
    
   if fld "audioList" is not empty then
      put "true" into sDownloadedFlag
   end if
   
   if sDownloadedFlag is "true" then 
      set the hightlight of widget "Downloading" to false
      hide widget "Downloading"
      exit showDownloadProgress
   end if
   put the highlight of widget "Downloading" into tState
   set the highlight of widget "downloading" to  not tState
   send showDownloadProgress to me in 200 milliseconds
end showDownloadProgress


on closeStack
   set the acceleratedRendering of this stack to "false"
end closeStack
