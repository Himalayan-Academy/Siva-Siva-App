script "lib_SivaSivaMedia"
--> MetaData
license: GPLv3
name: lib_SivaSivaMedia
type: library
version: 0.2

--> Variables

local sMediaMetaA,aQuoteData,sCurrentGraphicRect,tMediaMeta,aSelectedItemFormats
local  sLastQuoteID, sLastImagePath

on ___LOCAL_Dbase
end ___LOCAL_Dbase


local tConnectionID, selectedItemsA, tRetValA, pCollection, tPath, tFolderList
local tImageID, tImageList, pMediaType, pServerPath, pURL, tSQL, 
local tLyricsA, tViewData, tTitle, tSubTitle, tArtists, tAuthor
local tDescription, tDateCreated, tTranscript, tLyricsFields, tFields, tCard
local tAssetpath, pImageList, GotIt, sURL, tQueryString, tServerPath
local tYear, tArtDirectory, tFileName,

##################### 
--> FETCH MEDIA ITEMS METADATA
-- the local "sMediaMetaA"
-- will always have the last record 
-- will check in data base for
-- This handler depending to param
--  PARAMETERS
-- users are double pair such as "media_type,audio,artist,Manivelu"
-- assume the pair match columns the dbase

############################
--> FETCHMEDIAITEM
-- all record the match a query

function fetchMediaItems tSearchA
   
   #Typically we are no passing and explicitlist
   # but a pre-set array   
   
   put  JnanamDB() into tConnectionID
   repeat for each key x in tSearchA
      if tSearchA[x]is not empty then
         dbLike x,tSearchA[x]
      end if
   end repeat
   put dbGet("item", tConnectionID) into selectedItemsA
   # often used to query a single item, 
   # set the sMetaDataA to the first  (and only) record
   metadata_SetRecord selectedItemsA[1]
   return selectedItemsA
end fetchMediaItems


function fetchRandomMediaItem
  
   if the paramcount mod 2 is not 0 then
      return "err: param count needs to be even"
   end if
   
   put  JnanamDB() into tConnectionID
   repeat with x = 1 to the paramcount step 2
      if param(x) is not empty then
         dbLike param(x), param(x+1)
      end if
   end repeat
   
   dbOrderBy "RANDOM()"
   dbLimit 1
   put dbGet("item", tConnectionID) into selectedItemsA
   put selectedItemsA[1] into tRetValA
   repeat for each key k in tRetValA
      put textDecode ( tRetValA[k], "UTF8")  into tRetValA[k]
   end repeat
   put tRetValA into sMediaMetaA
end fetchRandomMediaItem


-----------------------------------------------------------
-- fetchRandomImageAsset
--
-- DESCRIPTION
--  Sometimes we want to fetch images without reference to the database.
-- this is faster, where there is no metadata like category we need to think about
-- we just want the user to see something different
--
-- PARAMETERS
-- We assume the images are in /assets/img
-- you must pass the rest of the path to a folder therein
-- pass a slash 
-- like "/bkgnd/nature/landscape/"
-- the path to a random image is returned.
-- his handler has no knowledge of the size or how the image is to be display
-- the calling context must do the right thing
-- typically we must center the image; where most are sized to fill both portrait and landscape
-- if you need to adjust size then use the resize handlers 
--
-- CHANGES:  2017-06-12 Brahmanathaswami-- created
--------------------------------------------------------------

function fetchRandomImageAsset pCollection
   # if it in photography, each image has a folder
   
   put   (path_Assets()&"img/")  & pCollection into tPath
   If pCollection="photography" then
      put folders(tPath) into tFolderList
      put line(random (the number of lines of tFolderList))of tFolderList into tImageID
      put "/"& tImageID & "/"  & tImageID &"_med.jpg" after tPath
   else   
      put files(tPath) into tImageList
      put "/"&line (random (the number of lines of tImageList)) of tImageList after tPath
   end if
   return tPath
end fetchRandomImageAsset

function getMediaMeta
   return sMediaMetaA
end getMediaMeta

#############
--> GETMEDIAURL
-- assume we have the sMediaMetaA set
-- this function fetch to remote base on our CMS
-- if it audio book, we will go the folder
-- the case local URL, we just use specialPathDocuments()
-- the replaces the absolute URL
-- AS of April 20 with had only audio, art, vidoe
-- eventually need to do books.
-- the URL targets  the item.formats table
-- these function call the CMS folder functions beow.

function getMediaURL pFormat # usually 1... but extract as item to in case more are passed
   if pFormat = "audioBook" then
      return "https://www.himalayanacademy.com/media/audio/books/"
      exit getMediaURL
   end if
   
   put sMediaMetaA["media_type"] into pMediaType
   
   getformatData (sMediaMetaA["item_id"])
   # each media type will entail a different path on the /media directory 
   switch 
      case pMediaType contains "audio/"  
         # Be careful: conflates with "audio/book"  but CMS is different
         put FolderForAudio(pMediaType)  into pServerPath
         return ("https://www.himalayanacademy.com/"  & pServerPath)        
         break
      case pMediaType contains "art/"
         put FolderForArt(item 1 of pFormat) into pServerPath
         return ("https://www.himalayanacademy.com/"  & pServerPath)
         break
      case pMediaType contains "video"
         
         # there are not paths... we just need to get the URL from the video and
         # convert it to the proper embed form for use in a browser widget
         put aSelectedItemFormats[1]["url"] into pURL
         return  convertYouTubeURL (pURL)
   end switch
   
end getMediaURL

# the following function adds more data to the sMediaMetaA array

function getSongLyrics pItemID    
   local tLyrics
   put "SELECT song_lyrics.lyrics_id,song_lyrics.song_title,song_lyrics.original_script,song_lyrics.transliteration,song_lyrics.diacritical_transliteration,item.lyrics_id" \ 
         &  " FROM song_lyrics JOIN  item ON item.lyrics_id= song_lyrics.lyrics_id WHERE item.item_id = " & pItemID into tSQL
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet(,tConnectionID) into tLyricsA
   put "original_script,diacritical_transliteration,transliteration" into tLyrics
   repeat for each item x in tLyrics
      get textDecode (tLyricsA[1][x], "UTF8") 
      if it is not empty then put it into sMediaMetaA[x] 
   end repeat
end getSongLyrics


#########################
--> GETMEDIAITEMMETADATA
-- the local sMediaMetaA has all the data from the data base
-- here turn into individual varible to display
-- this is primarily used to the audio model
-- the return a string that has all data referring to the MP3
-- which we show when use to read of.

function getMediaItemMetadata pRecords
   local tLyrics
   if pRecords is not empty then
      put pRecords into sMediaMetaA
   end if
   
   put empty into tViewData
   # create small HTML chunck from the data we want
   put sMediaMetaA["title"] into tTitle
   put sMediaMetaA["sub_title"] into tSubTitle
   put sMediaMetaA["artists"] into tArtists
   if sMediaMetaA["artists"] <> empty then
      put "Artist: " & sMediaMetaA["artists"] into tArtists
   end if
   put sMediaMetaA["artists"] into tAuthor
   if sMediaMetaA["author"] <> empty then
      put "Author: " & cr &  sMediaMetaA["author"] into tAuthor
   end if
   put sMediaMetaA["description"] into tDescription
   replace "\n" with cr in tDescription  # hopefully fixes the EOL chars passed to SQLLIte
   put sMediaMetaA["date_created"] into tDateCreated
   put  sMediaMetaA["audio_file_transcript"] into tTranscript
   # do not  display a non-date string as zeros
   if tDateCreated ="0000-00-00" then put "" into tDateCreated
   if tTranscript is not empty then  
      put "Transcript: " & cr & cr before tTranscript
   end if
   
   # Lyrics
   put "original_script,diacritical_transliteration,transliteration" into tLyricsFields 
   repeat for each item x in tLyricsFields
      if sMediaMetaA[x] <> empty then 
         put cr & cr & sMediaMetaA[x] after tLyrics
      end if
   end repeat 
   
   
   # data has commas so we have to use a lines as a delimiter
   put (tTitle& cr &tSubTitle& cr &tArtists& cr &tAuthor& cr &tDateCreated& cr &tDescription& cr &cr & tTranscript & tLyrics) into tFields
   
   repeat for each line x in tFields
      if x <> empty then
         put x & cr & cr after tViewData
      end if
   end repeat
   replace "<p>" with "" in tViewData
   replace "</p>" with "" in tViewData
   replace (cr &cr &cr) with cr in tViewData
   replace (cr &cr &cr) with cr in tViewData
   
   replace "\n" with cr in tViewData
   replace "null" with "" in tViewData
   return tViewData
   
end getMediaItemMetadata

#############
# GetFormatData
## use this to get the format for records
## the format depend on media type: 
## Art:  you are dimensions
## Books: get you the different epubs
## audio: get the name of the audio file
## study the data base  design to find our more  

command getformatData pItemID
   put format ("SELECT  * FROM item_format WHERE item_id  = \"%s\"", pItemID) into tSQL
         put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet("item_format", tConnectionID) into aSelectedItemFormats   
   return aSelectedItemFormats
end getformatData

# metadata_SetRecord
#
# DESCRIPTION: This library model data related to media
# It want primarily an array of records or an array for a single record
# from the item Table
# this could come froma function that fetches remote data
# it could come from the local dbase
# once we have it, then we can model it and return as needed from this library
#
# PARAMS: Pass an item record array here from another stack
# 
# CHANGES: CREATED, 2017-06-22. Brahmanathaswami

----------------------------------------------------------------------------------

on metadata_SetRecord pRecordArray
   # this only sets and array of from the item table
   # for formats and lyrics etc you have do use a different function.
   put pRecordArray into sMediaMetaA
end metadata_SetRecord

#################

on ___QUOTEMANAGEMENT
end ___QUOTEMANAGEMENT

########### Globable Management Quotes


# we save the quote it from Gem with img path, 
# the way we can go back to it if the user Saves it as a Favorites
# in Journal, we maybe able to use this elsewhere when crossing stack
# the library has the data 

command setLastQuoteID pQuoteID
   put pQuoteID into sLastQuoteID
end setLastQuoteID

function getLastQuoteID 
   return sLastQuoteID
end getLastQuoteID

command setLastImagePath pImagePath
   put pImagePath into sLastImagePath
end setLastImagePath

function getLastImagePath
   return sLastImagePath
end getLastImagePath


************************

####################
on ___IMAGEManipulation
end ___IMAGEManipulation

command imageDecompressAndCache pImageList
   repeat for each line x in pImageList
      prepare image x
   end repeat
end imageDecompressAndCache

command cacheGlobalNavImages
   local x, y
   --breakpoint
   # image are on card 4 of Siva-Siva-App
   # we want them in card 
   put the long id of card "Global Image Resource 1" of stack "Siva-Siva-App" into tCard
   put path_Assets() into tAssetPath
   repeat with x = 1 to (the number of images of tCard)
      put (tAssetPath& "img/nav-global-icons/" & the short Name  of img x of tCard) into y
      put y & cr after pImageList
      prepare image file  y
   end repeat
   
end cacheGlobalNavImages


#################

on ___VIDEO
end ___VIDEO

##########################################################
## VIDEO PRESENTATION UTILITIES
##########################################################

# this just get a video URL as passed it directly to the view stack

command getRandomVideo
   if isMobile() then
      deleteMobileControl "audioPlayer" # in case one is open already and playing
   end if
   put fetchRandomMediaItem ("media_type","video") into GotIt
   # the above just fetches a record from the item table 
   # to get the path or URL we have to query the format table:
   put getMediaURL ("url") into sURL
   portal_GoUrl sURL
end getRandomVideo


# convert incoming URL from the formats table in the Jnanam database
# URL are stored in this form:
# "http://www.youtube.com/watch?v=T6mwoO9sXPI&feature=youtube_gdata_player"

function convertYouTubeURL pURL
   set the itemdel to "?"
   put item 2 of pURL into tQueryString
   split tQueryString with "&" and "="
   return "https://www.youtube.com/embed/" & tQueryString["v"]&"?playsinline=1"
end convertYouTubeURL


####################
on ___UTILITIES
end ___UTILITIES

----------------------------------------------------------------------------------
## Here are handlers which know our CMS
## and can return for proper folder with media lives

---> AUDIO PATHFINDER

function folderForAudio pMediaType
   put "media/audio/" into tServerPath
   
   switch 
      case pMediaType = "audio/chant"
         put "chants/" after tServerPath
         break
      case pMediaType = "audio/shum"
         put "shum/" after tServerPath
         break
      case pMediaType = "audio/song"
         put "songs/" after tServerPath
         put sMediaMetaA["genre"] &"/" after tServerPath
         
         if (sMediaMetaA["genre"] = "bhajan") OR (sMediaMetaA["genre"] = "bhakti-gitam")  then
            # only these two genres have sub folders on disk
            # other Genres may have "diety" assignments, but not stored on disk in separate folders
            put (toLower(sMediaMetaA["deity"])) & "/" after tServerPath
         end if
         break
      case pMediaType="audio/inspiredtalk"
         put "inspired-talks/" after tServerPath
         put sMediaMetaA["author"] into tAuthor
         put line 1 of tAuthor into tAuthor # handle extra EOL in some records
         put sMediaMetaA["date_created"] into tDateCreated
         set the itemdel to "-"
         put item 1 of tDateCreated into tYear
         switch tAuthor
            case "Satguru Sivaya Subramuniyaswami" 
               put "gurudeva/" after tServerPath
               break
            case "Satguru Bodhinatha Veylanswami" 
               put "bodhinatha/" after tServerPath
               break
         end switch
         put tYear & "/" after tServerPath	
         break	
         
   end switch
   put sMediaMetaA["file_id"] & "/" after tServerPath
   put aSelectedItemFormats["1"]["filename"] after tServerPath
   return tServerPath
end folderForAudio


---> ## ART PATHFINDER

function folderForArt pBestFormat
   
   put "media/art/" into pServerPath
   
   # Art is divided into categories represented by sub-directories on the server
   # we need to parse the media_type to get the folder
   
   set the itemdel to "/" 
   put item 2 of sMediaMetaA["media_type"] into tArtDirectory
   put tArtDirectory & "/" after pServerPath
   
   # unlike audio, there are no further sub-directories so we can go directly to the fileID
   put  sMediaMetaA["file_id"]  &"/" after pServerPath
   
   # "pBestformat" species the size, typically we just want either med or large
   # pass this from your card script based on your view requirements
   # this script must be agnostic.
   # lots of the art varies 
   # and many use cases will use it very small
   # you need to know your collection to make the right choise
   # sml and thm have been cropped to a small horizontal format, even for native portrait orientation
   #sml is useful because the ratio is always the same: 
   
   
   repeat for each key x in aSelectedItemFormats
      put aSelectedItemFormats[x]["filename"] into tFilename
      if  tFilename contains ("_" & pBestFormat) then
         put tFilename after pServerPath
         exit repeat
      end if
   end repeat
   return pServerPath
end  folderForArt

########### LAYOUT ############

on layout_getCardRect
   --     put "stack: " & the width of this stack into tDims
   --     put "; card: " & the width of this card after tDims
   --     put "; screen: " & the screenRect after tDims
end layout_getCardREct

command checkThisScriptIsInMsgPath
   answer "Yes, I'm here. You found me" with "OK"
end checkThisScriptIsInMsgPath




on ___TYPESETTING
END ___TYPESETTING

########### TYPESETTING UTILITIES  #############
# We frequently need to apply formatting to type in fields.
# LC have nothing like "type styles" so we have to apply formatting to 
# to the lines of fields and lists by code.
# this section of the media library will allow us to make consistent views type
# across all modules...
#############################

-----------------------------------------------
# addSpaceBelowListLines
#
# DESCRIPTION: 
# Frequently titles or labels that are placed into a list may be long and have to wrap
# in order to keep the wrapped text close to the line above, we set the listheight of the field 
# appropriate to the text size.
# but then we need more space between the list items/lines
#
# PARAMS:
# Pass the long ID of the field,and an integer value for the space you want.
# 
# CREATED: BRAHManathswami
# just fishing for global means to set up type styles.
-----------------------------------------------
on addSpaceBelowListLines pField, pLineCount, pSpace
   lock screen
   repeat with x = 1 to pLineCount
      set the spacebelow of line x of pField to pSpace
   end repeat
   unlock screen
end addSpaceBelowListLines

function ReturnTitleCase pText
   local x
   
   # does not handle hyphentated words
   replace "-" with space in pText
   repeat with x = 1 to (the number of truewords in pText)
      put  toUpper(char 1 of trueword x of pText) into char 1 of trueword x of pText
   end repeat
   return pText
end ReturnTitleCase

function htmlTagger pStyle,  pText
   local tMarkedUp,tTag,
   put "<#S#>#T#</#S#>" into tMarkedUp
   switch pStyle
      case "bold"
         put "b" into tTag
         break
      case "italic"
         put "i" into tTag
         break
      case "h1"
         put "h1" into tTag
         break
      case "h2"
         put "h2" into tTag
         break
      case "h3"
         put "h3" into tTag
         break
   end switch
   replace "#S#" with tTag in tMarkedup
   replace "#T#" with pText in tMarkedUp
   return tMarkedUp
   
end htmlTagger

function normalizeFiletoTitle  pTitle
   set the itemdel to "."
   if the number items in pTitle > 1 then 
      delete item -1 of  pTitle
   end if
   replace "-" with space in  pTitle
   replace "_" with ", " in  pTitle
   repeat with i  = 1 to (the number of truewords in  pTitle)
      put toupper(char 1 of trueword i of pTitle) into char 1 of trueword  i of  pTitle
   end repeat
   return  pTitle
end normalizeFiletoTitle

## Need a better function here.. this method loses data
## we need to just target the tags and leave enclosed strings.

function stripHTML pText
   local tPlaintext
   set the htmlText of the templateField to pText
   put the text of the  templateField into tPlainText
   reset the templateField
   return tPlainText
end stripHTML

 
function truncateText pText,pNumChars,pEllipsisBool  # last parameter is "true" or "false"
   Local tTruncatedText
   put char 1 to  pNumChars of pText into tTruncatedText
   if pEllipsisBool then put "..." after tTruncatedText
   return tTruncatedText
end truncateText


 
#####################
on _____Deprecated
end _____Deprecated

 
command _old_fetchRandomMediaItem pSelectParams
   
   --   #The selection Params are passed down from the calling command as quoted strings 
   --   # each set of two = column + value
   --   # e.g. "media_type", "audio", "tags","Bodhinatha"  the API uses %LIKE% so partial strings work
   --   # assuming there is a match.. check HAPMAN for criteria you can use
   --   # TBD: categories?  how to pass one to the API?
   --   # the CURL call wants to pass this as JSON in a single "data" object like this:
   --   # "data": {"media_type": "art/photography","tags":"Bodhinatha"}
   --   # so we have to build that from incoming params
   
   --   repeat with x = 1 to the number of items of pSelectParams
   --     if (x mod 2) <> 0 then next repeat
   --     put  item (x -1) of pSelectParams into y
   --     put item x of pSelectParams  into pSelect["data"][y]
   --   end repeat
   --   put JsonExport(pSelect) into tJsonQuery # now properly formed for the POST
   --   set the httpheaders to "content-type: application/json"
   
   --   POST tJsonQuery to URL "http://dev.himalayanacademy.com/api3/getrandomitem/json"
   --   --put the result
   --   put it into tMediaMeta
   --   if (tMediaMeta is empty) OR (tMediaMeta contains "Internal Server Error") then
   --      put empty into sMediaMetaA
   --   end if
   
   --   # if you want to see what you are getting
   --   # uncomment this line:
   --   # put tMediaMeta
   
   --   try
   --     put jsonImport(tMediaMeta) into sMediaMetaA
   --   catch tErr
   --     logError tErr
   --   end try
   -- end fetchRandomMediaItem
   
   #### ABOVE CALLS THE API ON THE SERVER
   #### BELOW WE USE THE LOCAL DATABASE
   local tColumn, tValue,aSelectedItem
   
   put char 2 to -2 of word 2 of the params into tColumn
   
   put item 2 of params() into tValue
   put "%" after char 1 of tValue
   put "%" before char -1 of tValue
   
   # very bad form... need something better!
   # problem is I am hard wiring a single SQL query option here
   # with only as single column/value pair
   # model for SQL
   # this only takes one column/value pair... media type
   
   put format ("SELECT  * FROM item WHERE :1 LIKE :2  ORDER BY RANDOM() LIMIT 1") into tSQL
   replace ":1" with tColumn in tSQL
   replace ":2" with tValue in tSQL
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet("item", tConnectionID) into aSelectedItem
   put textDecode ( aSelectedItem[1]["item_id"], "UTF8")  into sMediaMetaA["item_id"]
   put textDecode ( aSelectedItem[1]["approved_for_public"], "UTF8")  into sMediaMetaA["approved_for_public"] 
   put textDecode ( aSelectedItem[1]["file_id"], "UTF8")  into sMediaMetaA["file_id"]
   put textDecode ( aSelectedItem[1]["media_type"], "UTF8")  into sMediaMetaA["media_type"]
   put textDecode ( aSelectedItem[1]["date_created"], "UTF8")  into sMediaMetaA["date_created"]
   put textDecode ( aSelectedItem[1]["genre"], "UTF8")  into sMediaMetaA["genre"]
   put textDecode ( aSelectedItem[1]["deity"], "UTF8")  into sMediaMetaA["deity"]
   put textDecode ( aSelectedItem[1]["title"], "UTF8")  into sMediaMetaA["title"]
   put textDecode ( aSelectedItem[1]["sub_title"], "UTF8")  into sMediaMetaA["sub_title"] 
   put textDecode ( aSelectedItem[1]["artists"], "UTF8")  into sMediaMetaA["artists"]
   put textDecode ( aSelectedItem[1]["author"], "UTF8")  into tAuthor
   # deal with extra cr in this field
   put line 1 of tAuthor into sMediaMetaA["author"]
   put textDecode ( aSelectedItem[1]["description"], "UTF8")  into sMediaMetaA["description"]
   
   getformatData (sMediaMetaA["item_id"])
end _old_fetchRandomMediaItem
