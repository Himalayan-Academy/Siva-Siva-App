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


local sCurrentPlayListA,sTargetPlayList,sListType,sPlaylistQueryA,sShareURL,sOnLIne
local sNowPlayingTitle, sNowPlayingArtist,sNowPlayingDetails,sStartTimer,sEndTimer


on preopenstack
   # may be fixed in recent versions Android crashed on stack swaps
   # this little wait helped 
   wait 100 milliseconds with messages 
   set the fullscreenmode of this stack to "showAll"
   mobile_SetAllowedOrientation "portrait"
end preopenstack
 
on openstack 
   # for V1 we know we are always coming from the Listen Portal
   # and these are basically playlists like on Spotify, though
   # some might qualify as albums, but we don't have enough to 
   # make a differentiation. So treat all as playlists  
   # if this stack is opened from a closed state
   # we can safely assume the portal link is the target playlist
   # be sure to never save the stack with any text in the audio list
   # test assumes if the fld id blank then we have some loading to do.

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
# Must be an exact match for the item in the portal dictionary: 
# see /models/model_SivaSiva/model_SivaSiva.json 
# CHANGES: Created 2017-06-22 Brahmanathaswami
------------------------------------------------------

on playlist_SetCurrent pList  
   put pList into sTargetPlayList
end playlist_SetCurrent

function playlist_GetCurrent
   return sCurrentPlayListA["playListTitle"]
end playlist_GetCurrent

function playlist_GetRecords  # use this to fetch data later for card behavior
   if sCurrentPlayListA["audioFiles"] is empty then
      put "No records Fetched!"
   else
      return sCurrentPlaylistA
   end if
end playlist_GetRecords


-----------------------------------------------------------------------
# playlist_QuerySetUp
# DESCRIPTION
# we have three classes of lists based on data storage/CMS
# each requires a different query
# 1. Remote list: send JSON to server we send JSON for remote list
# 2.  Audiobook: build a path string and download index. json for audio books
# 3. query the local dbase for already cached metadata in the Local Jnanam dbase

# we need max six criteria to search our metadata, not all playlists require all strings, 
# but our query array will still have all these keys; use elements as needed
# we will model that array into a json string or dbase query later
# media_type, author, artist, record-type [latest | cached | audiobook], num-of-records,year, file_id
# see /system/applications/ha/controllers/API3.lc  on the server for details on the remote call
#  structure of remote query, for reference:
# Note we use "recordType" here instead of "playlistClass" because the API is agnostic about the type
# of records we are fetching... it could be artwork quotes, books anything... not only audio playLists.
#   put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'recordType':'latest','recordCount':'30'}" into tJSON
# We have to do this "by hand"  in a switch case by case statemnt
# hard wiring the query data in this script is
# bad practice... later we should externalize to a playlists.json file 
# Audio books are simpler, all we need is a path to the remote server directory, fetch the audio JSON file therein.
# 
# PARAMS: pass the current play list string
# CHANGES: 2017-06-22 - BR Created
-----------------------------------------------------------------------


on playlist_QuerySetUp
   
   # Note: we are inserting queries strings... these are not the values of the records
   # the entire play list
   # aagDBLib uses "LIKE" so we only need to pass partial string for our searches
   # again: we should store these values in modules/listen/playlists.json
   # Add all your new playlists here in V1... assume match to a portal link for V1
   
   switch sTargetPlayList
      
      # Go to the web server for these latest playlists
      case "Bodhinatha's Latest inspired Talks" 
         # Remote look up based on search criteria... 
         # this model could fetch any kid of collection, songs, curated by category or tag... 
         # again we should be using a JSON for this data, and hold the query on disk and not hard
         # code this here.  Later... V2
         put "latest" into sPlaylistQueryA["playlistClass"]  # gets metadata from remote server
         put "inspiredtalk" into sPlaylistQueryA["media_type"]         
         put "Satguru Bodhinatha Veylanswami" into sPlaylistQueryA["author"]
         put "latest" into sPlaylistQueryA["recordType"]        
         put 30 into sPlaylistQueryA["recordCount"]
         break
      case "All Recent Additions"
         put "latest" into sPlaylistQueryA["playlistClass"]  # gets metadata from remote server
         put "audio" into sPlaylistQueryA["media_type"]       
         put "latest" into sPlaylistQueryA["recordType"]   
         put 50 into sPlaylistQueryA["recordCount"]
         break  
         
         # fetch all these form the local Jnanam dbase
      case "Gurudeva's 1970 Audio Course"
         put "cached" into sPlaylistQueryA["playlistClass"] # get metadata from local Jnanam
         put "inspiredtalk" into sPlaylistQueryA["media_type"]
         put "Satguru Sivaya Subramuniyaswami" into sPlaylistQueryA["author"]
         put "1970" into sPlaylistQueryA["date_created"]
         put "master-course" into sPlaylistQueryA["file_id"]
         break
      case "Songs" # fetches everything for now.. but nothing new
         put "cached" into sPlaylistQueryA["playlistClass"] # get metadata from local Jnanam
         put "audio/song" into sPlaylistQueryA["media_type"]
         put "YES" into sPlaylistQueryA["approved_for_public"]
         break
      case "All Gurudeva Talks" # fetches everything for now.. but nothing new
         put "cached" into sPlaylistQueryA["playlistClass"] # get metadata from local Jnanam
         put "inspiredtalk" into sPlaylistQueryA["media_type"]
         put "Satguru Sivaya Subramuniyaswami" into sPlaylistQueryA["author"]
         put "YES" into sPlaylistQueryA["approved_for_public"]
         break
      case "All Bodhinatha Talks" # fetches everything for now.. but nothing new
         put "cached" into sPlaylistQueryA["playlistClass"] # get metadata from local Jnanam
         put "inspiredtalk" into sPlaylistQueryA["media_type"]
         put "Satguru Bodhinatha Veylanswami" into sPlaylistQueryA["author"]
         put "YES" into sPlaylistQueryA["approved_for_public"]
         break
      case "Sanskrit Chanting"
         put "cached" into sPlaylistQueryA["playlistClass"] # get metadata from local Jnanam
         put "audio/chant" into sPlaylistQueryA["media_type"]
         put "YES" into sPlaylistQueryA["approved_for_public"]
         break
         
         ## Audio books:
         # for audio books; all we need to know the file ID, which is the folder name
         # after that it is a simple path set up.
      case "The Guru Chronicles" # Audio book
         put "audiobook" into sPlaylistQueryA["playlistClass"] # from remote server
         put "the-guru-chronicles-audiobook" into sPlaylistQueryA["file_id"]
         break
      case "Gujarati Dancing with Siva" # Audio book
         put "audiobook" into sPlaylistQueryA["playlistClass"]
         put "dancing-with-siva-audiobook-gujarati" into sPlaylistQueryA["file_id"] 
         break   
      case "Gujarati Living with Siva" # Audio book
         put "audiobook" into sPlaylistQueryA["playlistClass"]
         put "living-with-siva-audiobook-gujarati" into sPlaylistQueryA["file_id"] 
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
# Sorting differs by playlistClass: latest|descending by date, audiobook | per json index, cached | alpha by title or file_ID
# usually trigger on arrival to this stack-card
# but also from action on UI (Home card later)
# PARAMS: everything is taken from the sCurrentPlaylistA array
-----------------------------------------------------------------------

on playList_FetchData pQueryArray
   
   if pQueryArray is not empty then # we are passing a query from the search behavior
      put pQueryArray into sPlaylistQueryA
   end if
   
   # we can put in the title and image right away
   
   # we may have the stack already open 
   # and switching play list so clear the card first:
   
   dispatch "cleanUpGui" to card "listen-playlist"
   
   ## Title and thumbnail:
   put sTargetPlayList into tTitle 
   put tTitle into fld "title"   
   
   put sivasiva_FetchData() into tPortalInfoA
   put tPortalInfoA["portalRowDictionary"][tTitle][shortImageFile] into tThumbPath
   put path_Assets() & "img/portal-screens/" & tThumbPath into tPosterPath
   set the filename of img "playlistPoster" to tPosterPath
   
   put sPlaylistQueryA["playlistClass"] into tPlaylistClass
   
   switch tPlaylistClass
      case "latest" 
         # we do a JSON Call  Hard wiring as a test for now. but we should later 
         # use the a function in lib_SivaSivaMedia to model this array sPlaylistQueryA into the pJSON
         # we need because we can then use for different play lists on demand.. 
         
         # the sPlayListQueryA  has the values needed for the API... 
         # API requires odd construct data: set the query;  recordtype/Count set up how many to return which are 
         # different function in the API, SQL
         # e.g. required format need single quotes to go thru the API
         #  "{'data': {'media_type': 'inspiredtalk','author':'Satguru Bodhinatha Veylanswami'},'recordType':'latest','recordCount':'30'}"
         #  API is agnostic about query strings... if you just pass media type "song" with author or artist you get all the latest songs.
         # It just set the WHERE clause in the query with what ever you request. then sorts on date sends bak the request number
         # of records.
         
         put sPlayListQueryA["media_type"] into queryData["data"]["media_type"]
         put sPlayListQueryA["author"] into queryData["data"]["author"] 
         put sPlayListQueryA["recordType"] into queryData["recordType"]
         put sPlayListQueryA["recordCount"] into queryData["recordcount"]
         
         put arrayToJson(queryData) into pJSON
         
         put the ticks into sStartTimer
         set the httpheaders to "content-type: application/json"
         POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"
         if the result is not empty then 
            put "Check your network Connections" into  fld "audioList"
            dialog_CustomMsg "Offline or Low Bandwidth"
            portal_Link "Listen"
            exit to top
         else 
            put it into tRecords
            put jsonToArray (tRecords) into sCurrentPlayListA["audioFiles"]
         end if
         # add list type for other operations
         put tPlaylistClass into sCurrentPlayListA["playlistClass"]
         break
      case "cached"
         put sPlaylistQueryA into tSearchA
         delete variable tSearchA["playlistClass"]  # don't pass this to the query
         put fetchMediaItems(tSearchA) into sCurrentPlayListA["audioFiles"]
         put tPlaylistClass into sCurrentPlayListA["playlistClass"] 
         break
      case "audiobook"
         # a simple call to the server to get the TOC
         # can chose different books base on file_id
         put sPlaylistQueryA["file_id"] into tFileID
         
         # CMS is straightforward, path is consistent, no magic code required
         put "https://www.himalayanacademy.com/media/audio/books/" & tfileID & "/audiobook.json"   into tTocURL
         put URL tTocURL into tBookToc
         if the result is not empty then 
            put "Check your network Connections" into  fld "audioList"
            dialog_CustomMsg "Offline or Low Bandwidth"
            portal_Link "Listen"
            exit to top
         else 
            put jsonToArray(tBookToc) into sCurrentPlayListA["audioFiles"]
         end if
         # this should come from the local dBase,
         # but as of June 29, the local dBase is obsolete
         
         --put sPlaylistQueryA into tSearchA
         -- delete variable tSearchA["playlistClass"]  # don't pass this to the query
         --  put fetchMediaItems(tSearchA) into sCurrentPlayListA
         -- put tPlaylistClass into sCurrentPlayList["playlistClass"] 
         
         # so we have to fetch info from the server 
         
         put "{'data': {'media_type': 'audio/book','file_id':'" & tFileID&"'}}" into pJSON 
         set the httpheaders to "content-type: application/json"
         replace "'" with quote in pJSON
         POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"         
         if the result is not empty then 
            put "Check your network Connections" into  fld "audioList"
            dialog_CustomMsg "Offline or Low Bandwidth"
            -- close this stack
            portal_Link "Listen"
            exit to top
         else 
            put it into tRecords 
            # But the model is different for audio books. We now have metadata for the whole book
            # this is not a series of records for individual files
            # We need this later:
            put jsonToArray (tRecords) into sCurrentPlayListA["audioBookMetadata"]
         end if
         
         # add list type for other operations
         put tPlaylistClass into sCurrentPlayListA["playlistClass"]
         break
         
   end switch
   
   -- put (the ticks - sStartTimer)  early tests: as long as 3 minutes to get data from the server...
   # we have the data for our records in the array now.
   # need know two things from the beginning
   put tPlaylistClass into sCurrentPlaylistA["playlistClass"]
   put sTargetPlayList into sCurrentPlayListA["playListTitle"]
   
   if sCurrentPlayListA["audioFiles"] is empty then 
      put "No records for that search. Try again" into fld "audioList"
      wait 1500 milliseconds with messages
      put empty ito fld "audioList"
      dispatch "revealMoreActions" to this card with "true"
      exit to top
   end if
   
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

   if (sTargetPlayList ="Songs" OR sTargetPlayList contains "Talks") AND  (sPlaylistQueryA["playListClass"] = "cached" ) then
      set the vis of widget "revealMoreActions" to true
   else
       set the vis of widget "revealMoreActions" to false # just in case it's hanginh around visible
    end if    
   
   # using: model_SivaSiva, which has functions to get json info we need:
   
   
   switch sPlaylistQueryA["playlistClass"] 
      case "audiobook"
         put the keys of sCurrentPlayListA["audioFiles"]["toc"] into tKeys
         sort lines of tKeys ascending numeric
         repeat for each line x in tKeys
            put sCurrentPlayListA["audioFiles"]["toc"][x]["label"] & cr after tTitles
         end repeat
         break
      default
         put the keys of sCurrentPlayListA["audioFiles"] into tKeys
         sort lines of tKeys ascending numeric
         repeat for each line x in tKeys
            put sCurrentPlayListA["audioFiles"] [x]["Title"] after tTitles
            if sCurrentPlayListA["audioFiles"] [x]["media_type"] ="audio/song" then
               put ", " &sCurrentPlayListA["audioFiles"] [x]["artists"] after tTitles
            end if
            put cr after tTitles
         end repeat
   end switch
   
   put tTitles into fld "audioList"  
   
 
   put the number of lines of tTitles into pLineCount
   addSpaceBelowListLines (the long id of fld "audioList"), pLineCount, 10
   
   # here is where we have to check to see if any files are stored locally or not
   
   markCachedItems tKeys
   if the formattedHeight fld "audioList" > the height of fld "AudioList" then
      send "CreateScroller audioList" to fld "audioList" of card "listen-playlist"
   end if
   put  sTargetPlayList into pData["audio_playlist"]
   tracking_RecordActivity "Listen", "navigation/playlist", pData
end playlist_Instantiate

command markCachedItems pKeys
   repeat for each line x in pKeys
      # this as good a place as any to check for the existence of files  
      # and get the URL for every one in the play list... so we only do this once.
      put getItemURL(x) into pURL
     # Check and create folders here
      put path_isFileOnDisk(pURL) into tLocalStatus
      put item 1 of tLocalStatus into tIsCached
      put tIsCached into sCurrentPlayListA["audioFiles"][x]["cached"]
      if tIsCached then  # need to colored cached files on theUI
         # store line numbers
         put x & cr after tCachedFiles
         put item 2 of tLocalStatus into  sCurrentPlayListA["audioFiles"][x]["myURL"]
      else
         put pURL into sCurrentPlayListA["audioFiles"][x]["myURL"]
      end if
   end repeat
   repeat for each line y in tCachedFiles
      set the foregroundcolor of line y of fld "audioList" to green
   end repeat
end markCachedItems

function getItemURL pRecordNum
   # send of to lib_SivaSivaMedia, which knows all about our media CMS
   # but Audio books are completely different CMS: they have no item records for their audio files
   
   if ( sCurrentPlayListA["playlistClass"] = "latest")  OR ( sCurrentPlayListA["playlistClass"] ="cached") then
      # everything happens via Jnanam table structure record array
      put  sCurrentPlayListA["audioFiles"][pRecordNum] into sSelectedItemA
      metadata_SetRecord sSelectedItemA
      put getMediaURL (sSelectedItemA["item_id"]) into sSelectedURL
      
      # but lib_SivaSivaMedia won't have string for the latest item
      # fortunately there is easily solution for audio:
      if char -1 of sSelectedURL = "/" then
         put  sCurrentPlayListA["audioFiles"][pRecordNum]["file_id"] & ".mp3" after sSelectedURL
      end if      
   else
      # its an audio book
      put getMediaURL("audioBook") into sSelectedURL
      put  sCurrentPlayListA["audioBookMetadata"][1]["file_id"] & "/" after sSelectedURL
      put  sCurrentPlayListA["audioFiles"]["toc"][pRecordNum]["file"] after sSelectedURL
   end if
   return sSelectedURL
end getItemURL


on journalResume  pDataA, pEntryA
   deleteMobileControl "audioPlayer"
   put "card " & quote &  pDataA["card"] & quote &   " of stack " && quote & pEntryA["module"] & quote into pDestination
   put pDataA["playList"] into sTargetPlayList
   portal_SetLastLinkTitle sTargetPlayList  
   portal_GoStack pDestination 
   put pDataA["playSelection"] into pSelectedLine
   dispatch "playlist_Reset" to card "listen-playlist"
   dispatch "select_Play" to card "listen-playlist" with pDataA["item_id"]
end journalResume


on closeStack
   --   if isMobile() then 
   --      deleteMobileControl "audioList"
   --   end if
end closeStack
