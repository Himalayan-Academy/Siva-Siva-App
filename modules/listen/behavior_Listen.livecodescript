script "behavior_Listen"

-----------------------------------------------------
#  behavior_Listen
#
# DESCRIPTION
# this behavior is the /modules/listen/listen.livecode stack script
# It's primary function is to handle high level calls to get play lists
# UI consist of 3 main cards
# listen-collections - shows a catalog of songs built up on a 
# collection.json for: it in be built from a development stack tools
# listen-browse - Later for show in play list
# listen-my-music  # for music that is no loaded
#
# So as not to over load this script the handlers whose scope deals with
# user interaction with a single play list/ indivdtual songs are in a separate behavior 
#
# behavior_ListenSelectPlay
# assigned to the listen-browse card
#
# PARAMS: Main variable sent to this script is a string JSONl list 
#  which is the name/title of all the collections
#
# CHANGES: 2017-06-22 CREATED Brahmanathaswami
-----

local sCollectionA,sCollectionChoice
local sCurrentPlayListA,sTargetPlayList,sListType,sPlaylistQueryA,sShareURL,sOnLIne
local sNowPlayingTitle, sNowPlayingArtist,sNowPlayingDetails,sStartTimer,sEndTimer
local sCached, sBrowseHeader

on preopenstack
  -- put empty into sCurrentPlayListA
   # may be fixed in recent versions Android crashed on stack swaps
   # this little wait helped 
   wait 100 milliseconds with messages 
   set the fullscreenmode of this stack to "showAll"
   mobile_SetAllowedOrientation "portrait"
end preopenstack

on openstack 
   #V2 April 8, 2018
   # 
   # and these are basically playlists like on Spotify, though
   # some might qualify as albums, but we don't have enough to 
   # make a differentiation. So treat all as playlists 
   # we get playlist from the json file, that is attached
   # to the mouse down one the group number
   #
   # first, load the json
   
   set the acceleratedRendering of this stack to true
   
   -- put empty into fld "log"
   
   put url ("binfile:" & path_Modules()& "listen/collection.json") into tContainer
   put JSONToArray(tContainer) into sCollectionA   
 
end openstack

# return JSON for other handlers as needed
function getCollectionsJson
   return sCollectionA
end getCollectionsJson


command selectPlaylist pSelection
   
   # use has  made choice from card 
   
   
   
   # get extract JSON from sCollectionA 
   # which is an array that contain all collections
   # the data we need to 
   # the title and path to img file.
   # you can rebuild the UI from the SivaSivaDec Tool.livecode stacks
   
   
   put the short name of pSelection into tPlayTarget
   
   # first - card navigition
   
   if tPlaytarget contains "my-audio" then
      go to card "listen-my-audio"
      exit selectPlayList
   end if
   
   # other wise we are select a collection:
   
   if not (tPlayTarget contains "-playlist-") then
      exit to top
   else
      set the itemDelimiter to "-"
      put item 1 of tPlayTarget into tColl
      put item 2 of tPlayTarget into tPlay
   end if
   
   # Link each separate process to a 
   # specific handler
   playList_FetchData tColl,tPlay
end selectPlaylist

-----------------------------------------------------
# playlist_SetGetCurrent
# DESCRIPTION:  the primary known variable is a string 
# which taken from the json list on mouseup (see selectPlayList above
#
# PARAMS: pass the playlist string, which should also serve as it's title 
# See the JSON for more detail on what is on the aray
# see /models/model_SivaSiva/model_SivaSiva.json 
# CHANGES: Created 2017-06-22 Brahmanathaswami
------------------------------------------------------

# more need to set the playListLater
# and other playListClass
# what we have a setter/getter here
on playlist_GetClass
   return sCurrentPlayListA["playlistClass"]
end playlist_GetClass

on playlist_SetCurrent pList  
   put pList into sTargetPlayList
end playlist_SetCurrent

function playlist_GetCurrent
   return sCurrentPlayListA["playListTitle"]
end playlist_GetCurrent

# we may need to fetch files later
# so another function return the key listen to build everything
# includes the metadata from the date base, the lyrics and the URL
# use this to fetch data later for card behavior

function playlist_GetRecords  
   if sCurrentPlayListA["audioFiles"] is empty then     
      --       if isMobile() is false then
      --          put "No records Fetched!"
      --       end if   
   else
      return sCurrentPlaylistA
   end if
end playlist_GetRecords

-----------------------------------------------------------------------
# playList_FetchData
# DESCRIPTION: 
-- # all the dataquery data it in to json file under "data-query"
-- # we have three classes of lists based on data storage/CMS
-- # each requires a different query
-- # 1. Remote list: send JSON to server we send JSON for remote list
-- # 2.  Audiobook: build a path string and download index. json for audio books
-- # 3. query the local dbase for already cached metadata in the Local Jnanam dbase
-- # These are merged into a sPlaylistQueryA   array the we use pass date to the 
-- # dbase handlers
-- # we need max six criteria to search our metadata, not all playlists require all strings, 
-- # but our query array will still have all these keys; use elements as needed
-- # we will model that array into a json string or dbase query later
-- # media_type, author, artist, record-type [latest | cached | audiobook], num-of-records,year, file_id
-- # see /system/applications/ha/controllers/API3.lc  on the server for details on the remote call
-- #  structure of remote query, for reference:
-- # Note we use "recordType" here instead of "playlistClass" because the API is agnostic about the type
-- # of records we are fetching... it could be artwork quotes, books anything... not only audio playLists.
-- #   put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'recordType':'latest','recordCount':'30'}" into tJSON
-- #
-- # We keep all the data in json file now.

-- # Audio books are simpler, all we need is a path to the remote server directory, fetch the audio JSON file therein.
-- # 
-- # Sorting differs by playlistClass: latest|descending by date, audiobook | per json index, cached | alpha by title or file_ID
-- # usually trigger on arrival to this stack-card
-- # but also from action on UI (Home card later)

-- # PARAMS: pass numeric collection and the playlist from json file
-- # CHANGES: 2018-04-09 - BR Created

# secondary params"
#  from json file: this is a sample. Not all playlists require all params
--          put "playListClass" into sPlaylistQueryA["playlistClass"]  # gets metadata from remote server
--          put "inspiredtalk" into sPlaylistQueryA["media_type"]         
--          put "Satguru Bodhinatha Veylanswami" into sPlaylistQueryA["author"]
--          put "latest" into sPlaylistQueryA["recordType"]        
--          put 30 into sPlaylistQueryA["recordCount"] 
--          put "master-course" into sPlaylistQueryA["file_id"]
--          put "1970" into sPlaylistQueryA["date_created"]
--          put "YES" into sPlaylistQueryA["approved_for_public"]
 
-----------------------------------------------------------------------

on playList_FetchData tColl,tPlay,pFilterListQueryA,pBrowseHeader
   showBusyIndicator true,"Loading"
   put empty into fld "audioList" of card "listen-browse" of stack "listen"
   
   --  dispatch "cleanUpGui" to card "listen-browse"      
   
   put empty into sPlaylistQueryA 
   
   # if pFilterListQueryA is empty, it means we are coming in
   # the Search and Filter filter screen
   # if not, we coming of the main collection screen
   
   if pFilterListQueryA = empty then 
      
      put sCollectionA[tColl]["playlists"][tPlay]["playListClass"] into tPlaylistClass 
      put sCollectionA[tColl]["playlists"][tPlay]["playListTitle"]  into  sCurrentPlayListA["playListTitle"]
      
      
      put tPlaylistClass into sPlayListQueryA["PlaylistClass"]
      
      # decides is cached on device, or from server and audio book
      # this param is used here... not sent to the database. 
      # but use to determine how the query show go: the server, audio book, in the jnanam (local dbase_
      # get type of playlistL audio book, etc
      
      # first we need action the array from the json able 
      # everyhing in needs to create a query
      
      put "recordType,recordCount" into tRecordTypeCount
      
      # remember: tColl and tPlay are drawn from the mouseups
      # see the nomenclature for what the mouseup delivers on the objects
      # in the project browers
      
      repeat for each item RT in tRecordTypeCount
         if (sCollectionA[tColl]["playlists"][tPlay][RT] is not empty) then 
            put  sCollectionA[tColl]["playlists"][tPlay][RT] into sPlayListQueryA[RT]
         end if 
      end repeat
      # you must declare all columns you are searching in the data base.
      put "media_type,file_id,approved_for_public,author,genre,deity,tags" into tDbaseColumns
      
      repeat for each item DC in tDbaseColumns
         if ( sCollectionA[tColl]["playlists"][tPlay]["data_query"][DC] is not empty) then 
            put sCollectionA[tColl]["playlists"][tPlay]["data_query"][DC] into sPlayListQueryA[DC]
         end if
      end repeat
      put sCurrentPlayListA["playListTitle"] into sBrowseHeader
      replace cr with " " in sBrowseHeader
   else
      # use the queries from the Search Screen
      
      put "cached" into tPlayListClass
      put pFilterListQueryA into sPlaylistQueryA
      # the query is sent a param for the header
      put pBrowseHeader into sBrowseHeader
      
   end if
   
   
   # we get records now, from server, or local jnanam.
   # we are to each one based on where they come from
   
   switch tPlaylistClass
      case "latest" 
         # we do a JSON Call  to the server
         # use the a function in lib_SivaSivaMedia to model this array sPlaylistQueryA into the pJSON
         # we need because we can then use for different play lists on demand..          
         # the sPlayListQueryA  has the values needed for the API... 
         # API requires construct data: set the query;  recordtype/Count  (we have set an number if the return
         # set up how many to return which are 
         # different function in the API, SQL ; Note look at the API2.livecode ; getItemRecords handler
         # e.g. required format need single quotes to go thru the API
         #  "{'data': {'media_type': 'inspiredtalk','author':'Satguru Bodhinatha Veylanswami'},'recordType':'latest','recordCount':'30'}"
         #  API is agnostic about query strings... if you just pass media type "song" with author or artist you get all the latest songs.
         # It just set the WHERE clause in the query with what ever you request. then sorts on date sends bak the request number
         # of records.
         put "Contacting server... " into fld "audioList" of card "listen-browse"
         put sPlayListQueryA["media_type"] into queryData["data"]["media_type"]
         put sPlayListQueryA["author"] into queryData["data"]["author"] 
         put sPlayListQueryA["recordType"] into queryData["recordType"]
         put sPlayListQueryA["recordCount"] into queryData["recordcount"]
         
         put arrayToJson(queryData) into pJSON # from server
         
         put the ticks into sStartTimer
         set the httpheaders to "content-type: application/json"
         POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"
         if the result is not empty then 
            put "Check your network Connections" into  fld "audioList" of card "listen-browse" of stack "listen"
            dialog_CustomMsg "Offline or Low Bandwidth"
            portal_Link "Listen"
            exit to top
         else 
            put it into tRecords
        
            put jsonToArray (tRecords) into sCurrentPlayListA["audioFiles"]
         end if
         # add list type for other operations
         put tPlaylistClass into sCurrentPlayListA["playlistClass"]  #now we have our local array
         break
      case "cached"
         put sPlaylistQueryA into tSearchA
         delete variable tSearchA["playlistClass"]  # don't pass this to the query
         put fetchMediaItems(tSearchA) into sCurrentPlayListA["audioFiles"]
         put tPlaylistClass into sCurrentPlayListA["playlistClass"] 
         break
      case "audiobook"
         put "Contacting server... " into fld "audioList" of card "listen-browse"
         # a simple call to the server to get the TOC
         # can chose different books base on file_id
         put sPlaylistQueryA["file_id"] into tFileID
         
         # CMS is straightforward, path is consistent, no magic code required
         put "https://www.himalayanacademy.com/media/audio/books/" & tfileID & "/audiobook.json"   into tTocURL
         put URL tTocURL into tBookToc
         if the result is not empty then 
            put "Check your network Connections" into  fld "audioList" of card "listen-browse" of stack "listen"
            dialog_CustomMsg "Offline or Low Bandwidth"
            showBusyIndicator false
            exit to top
         else 
            put jsonToArray(tBookToc) into sCurrentPlayListA["audioFiles"]
         end if
         # this should come from the local dBase,
         # but as of June 29, the local dBase is obsolete
         
         # so we have to fetch info from the server 
         # this does not include a data base query other than the file id
         # which get the URL and pull to TOC.json for the audio book.
         
         put "{'data': {'media_type': 'audio/book','file_id':'" & tFileID&"'}}" into pJSON 
         set the httpheaders to "content-type: application/json"
         replace "'" with quote in pJSON
         POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"         
         if the result is not empty then 
            put "Check your network Connections" into  fld "audioList" of card "listen-browse" of stack "listen"
            dialog_CustomMsg "Offline or Low Bandwidth"
            showBusyIndicator false
            exit to top
         else 
            put it into tRecords 
            # But the model is different for audio books. We now have metadata for the whole book
            # this is not a series of records for individual files
            # We need this later:
            put jsonToArray (tRecords) into sCurrentPlayListA["audioBookMetadata"]
         end if
         
         break      
   end switch
   
   -- put (the ticks - sStartTimer)  early tests: as long as 3 minutes to get data from the server...
   # we have the data for our records in the array now.
   # need know two things from the beginning
   put tPlaylistClass into sCurrentPlaylistA["playlistClass"]
   
   if sCurrentPlayListA["audioFiles"] is empty then 
      doAnswer "No records for that search. Try again","Cancel"
      showBusyIndicator false
      put empty into fld "audioList" of card "listen-browse" of stack "listen"
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


on  playlist_Instantiate sTargetPlayList    
   
   # using: model_SivaSiva, which has functions to get json info we need:
   
   switch sPlaylistQueryA["playlistClass"] 
      case "audiobook"
         put the keys of sCurrentPlayListA["audioFiles"]["toc"] into tKeys
         sort lines of tKeys ascending numeric
         repeat for each line x in tKeys
            put sCurrentPlayListA["audioFiles"]["toc"][x]["label"] & cr & cr after tTitles
         end repeat
         break
      default
         put the keys of sCurrentPlayListA["audioFiles"] into tKeys
         sort lines of tKeys ascending numeric
         repeat for each line x in tKeys
            put sCurrentPlayListA["audioFiles"] [x]["Title"] after tTitles
            
            if sCurrentPlayListA["audioFiles"] [x]["media_type"] ="audio/song" then
               put cr &sCurrentPlayListA["audioFiles"] [x]["artists"] after tTitles
            else
               put cr after tTitles
            end if
            put cr after tTitles
            
         end repeat
   end switch
   put empty into sCached
   
   getPlayListURLs tKeys
   
   --markCachedItems tKeys
   
      showBusyIndicator false
   
    # Now we switch cards, 
    
   go to card "listen-browse"
  
   hide fld "audioList"
   put tTitles into fld "audioList"  
   typesetAudioList
   -- put the number of lines of tTitles into pLineCount
   --  addSpaceBelowListLines (the long id of fld "audioList"), pLineCount, 10
 
    repeat for each line x in sCached
      set the foregroundcolor line (x*2-1) of fld "audioList" to 245,200,190
   end repeat
     replace cr with " " in sBrowseHeader
   put sBrowseHeader into fld "title-label" of card "listen-browse"

   show fld "audioList"
  
   
   # here is where we have to check to see if any files are stored locally or not
   
   
   if the formattedHeight fld "audioList" > the height of fld "AudioList" then
      send "CreateScroller audioList" to fld "audioList" of card "listen-browse"
   end if
   put  sTargetPlayList into pData["audio_playlist"]
   tracking_RecordActivity "Listen", "navigation/playlist", pData
end playlist_Instantiate

# V2 Link to transcript

command select_ShowDetails  pSelection, pRecord
   deleteMobileControl "audioList"
   
   switch
      case (sCurrentPlayListA["playlistClass"] = "latest")  OR (sCurrentPlayListA["playlistClass"] ="cached")
         put getMediaItemMetadata() into fld "audioDetails"
         break
         
         # its an audio book, lib media doesn't know anything, we have to pass the record here   
      case sCurrentPlayListA["playlistClass"]= "audioBook"
         put "Transcripts for audio books are available here." &cr & cr &  "Read the original book." into fld "audioDetails"
         break        
         
         # or its from a downloaded file in My Audio
      case (pSelection="downloaded")
         put  getMediaItemMetadata(pRecord) into  fld "audioDetails"   
         break   
   end switch
   
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   set the rect of fld "AudioDetails" to rect of fld "audioList" 
   
   show fld "audioDetails" with visual effect wipe up very fast
   send "CreateScroller audioDetails" to fld "audioDetails"
end select_ShowDetails

command typeSetAudioList
 put 0 into tX
   repeat with x =1 to the number lines  in fld "audioList"
      add 1 to tX
      if (tX mod 2) = 0 then
         set the leftIndent of line x of fld "audioList" to 10
         if  line x of fld "audioList" <> empty then
            set the spaceBelow of line x of fld "audioList" to 10
         end if   
         set the textSize of line x of fld "audioList" to 15
      else
               set the textSize of line x of fld "audioList" to 17
      end if
   end repeat 
 
end typeSetAudioList

command getPlayListURLs pKeys
   repeat for each line x in pKeys
    --  put getItemURL(x) into sSelectedURL
      put getItemURL(x) into sCurrentPlayListA["audioFiles"][x]["myURL"]
   end repeat   
end getPlayListURLs

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
         -- put  sCurrentPlayListA["audioFiles"][pRecordNum]["file_id"] & ".mp3" into sCurrentPlayListA["audioFiles"][pRecordNum]["myURL"]
      end if      
   else
      # its an audio book
      put getMediaURL("audioBook") into sSelectedURL
      put  sCurrentPlayListA["audioBookMetadata"][1]["file_id"] & "/" after sSelectedURL
      put  sCurrentPlayListA["audioFiles"]["toc"][pRecordNum]["file"] after sSelectedURL
   end if
   return sSelectedURL
end getItemURL

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
         put x & cr after sCached
         put item 2 of tLocalStatus into  sCurrentPlayListA["audioFiles"][x]["myURL"]
      else
         put pURL into sCurrentPlayListA["audioFiles"][x]["myURL"]
      end if
   end repeat
end markCachedItems

on journalResume  pDataA, pEntryA
   -- breakpoint
   deleteMobileControl "audioPlayer"
   put "card " & quote &  pDataA["card"] & quote &   " of stack " && quote & pEntryA["module"] & quote into pDestination
   put pDataA["playList"] into sTargetPlayList
   playlist_SetCurrent sTargetPlayList
   playlist_QuerySetUp sTargetPlayList 
   portal_SetLastLinkTitle sTargetPlayList  
end journalResume


on closeStack
   --   if isMobile() then 
   --      deleteMobileControl "audioList"
   --   end if
end closeStack

------------- 
on __ListenUtilities
end __ListenUtilities

command setAudioListColors pColor
   repeat with x=1 to (the number lines of fld "audioList")
      set the backgroundcolor of line x of fld "audioList" to pColor
   end repeat
end setAudioListColors

on preopencard
   # tweak the header for collections
   
   --deleteMobileControl "audioList"  
   
   -- set up the header 
   put the short name of this card into tMode
   switch tMode
      case "listen-collection" 
         
         put the location of fld "collections-label" into tLabelLoc
         put the width of fld "collections-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         hide fld "browse-label"
         put "Listen" into fld "title-label"
         # have nav bar
         show widget "share"
         show widget "add-favorites" 
         break
      case "listen-my-audio"
         setAudioListcolors
         put the location of fld "my-audio-label" into tLabelLoc
         put the width of fld "my-audio-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         show fld "browse-label"
         put "Downloaded Audio" into fld "title-label"
         put empty into fld "audioList"
          # have nav bar
         show widget "share"
         show widget "add-favorites" 
         break
      case "listen-browse"
         setAudioListcolors
         put the location of fld "browse-label" into tLabelLoc
         put the width of fld "browse-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         show fld "browse-label"
         put playlist_GetCurrent() into  tBrowseHeader
         replace cr with " " in tBrowseHeader
         put tBrowseHeader into fld "title-label"
          # have nav bar
         show widget "share"
         show widget "add-favorites" 
         break
      case "listen-search"
          put the location of fld "title-label" into tLabelLoc
         put the width of fld "title-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         put "Search" into fld "title-label"
         set the textsize of fld "title-label" to 18
          # have nav bar
         hide widget "share"
         hide widget "add-favorites" 
         break
   end switch   
end preopencard
   
  
