script "lib_SivaSivaMedia"
--> MetaData
license: GPLv3
name: lib_SivaSivaMedia
type: library
version: 0.2

/*
Moved from frontscript
*/

--> Variables
-
local sMediaMetaA,aQuoteData,sCurrentGraphicRect,tMediaMeta,aSelectedItemFormats

command checkThisScriptIsInMsgPath
   answer "Yes, I'm here. You found me" with "OK"
end checkThisScriptIsInMsgPath
 
 
 --> FETCH RANDOM
 -
 # MODEL FOR CALL TO API
 
 #the httpheaders to "content-type: application/json"
 #POST "{'data': {'media_type': 'art/photography','tags':'Bodhinatha'}}" to URL #\"http://dev.himalayanacademy.com/api3/getrandomitem/json"
 
 
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
   put textDecode ( aSelectedItem[1]["item_id"], UTF8)  into sMediaMetaA["item_id"]
   put textDecode ( aSelectedItem[1]["approved_for_public"], UTF8)  into sMediaMetaA["approved_for_public"] 
   put textDecode ( aSelectedItem[1]["file_id"], UTF8)  into sMediaMetaA["file_id"]
   put textDecode ( aSelectedItem[1]["media_type"], UTF8)  into sMediaMetaA["media_type"]
   put textDecode ( aSelectedItem[1]["date_created"], UTF8)  into sMediaMetaA["date_created"]
   put textDecode ( aSelectedItem[1]["genre"], UTF8)  into sMediaMetaA["genre"]
   put textDecode ( aSelectedItem[1]["deity"], UTF8)  into sMediaMetaA["deity"]
   put textDecode ( aSelectedItem[1]["title"], UTF8)  into sMediaMetaA["title"]
   put textDecode ( aSelectedItem[1]["sub_title"], UTF8)  into sMediaMetaA["sub_title"] 
   put textDecode ( aSelectedItem[1]["artists"], UTF8)  into sMediaMetaA["artists"]
   put textDecode ( aSelectedItem[1]["author"], UTF8)  into sMediaMetaA["author"]
   put textDecode ( aSelectedItem[1]["description"], UTF8)  into sMediaMetaA["description"]
   
  getformatData (sMediaMetaA["item_id"])
end _old_fetchRandomMediaItem

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
      put textDecode ( tRetValA[k], UTF8)  into tRetValA[k]
   end repeat
   put tRetValA into sMediaMetaA
end fetchRandomMediaItem

----------------------------------------------------------------------------------
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
   put pRecordArray into sMediaMetaA
end metadata_SetRecord

--> FETCH ALL RECORDS THAT MATCH
# 
function fetchMediaItems
   if the paramcount mod 2 is not 0 then
      return "err: param count needs to be even"
   end if
   
   put  JnanamDB() into tConnectionID
   repeat with x = 1 to the paramcount step 2
      if param(x) is not empty then
         dbLike param(x), param(x+1)
      end if
   end repeat
   put dbGet("item", tConnectionID) into selectedItemsA
  -- put selectedItemsA[1] into tRetValA
   --    repeat for each key k in tRetValA
   --       put textDecode ( tRetValA[k], UTF8)  into tRetValA[k]
   --    end repeat
   --    put tRetValA into sMediaMetaA
   --  return sMediaMetaA
  return selectedItemsA
end fetchMediaItems



function fetchRemoteMediaItems
   if the paramcount mod 2 is not 0 then
      return "err: param count needs to be even"
   end if
   
   # we need to pass params to the API on the server to look up 
   # a record that we know has  not have yet been bundled with the app in the Jnanam dbase
   # mostly this is for most recent additions of audio and video, or book additions
   # for major collections we should be updating the app with a fresh dump of the dbase
   
   # need a function to check latest date in local Jnanam sqlLite dbase.
   
   
   
   #the httpheaders to "content-type: application/json"
   #POST "{'data': {'media_type': 'art/photography','tags':'Bodhinatha'}}" to URL #\"http://dev.himalayanacademy.com/api3/getrandomitem/json"
   
   
end fetchRemoteMediaItems

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
   put   (path_Assets()&"img/")  & pCollection into tPath
   put files (tPath) into tImageList
   put line (random (the number of lines of tImageList)) of tImageList after tPath
   return tPath
end fetchRandomImageAsset

function getMediaURL pFormat # usually 1... but extract as item to in case more are passed
   
   put sMediaMetaA["media_type"] into pMediaType
   getformatData (sMediaMetaA["item_id"])
   # each media type will entail a different path on the /media directory 
   switch 
      case pMediaType contains "audio/"
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

function getMediaItemMetadata
    
   put empty into tViewData
   # create small HTML chunck from the data we want
   put sMediaMetaA["title"] into tTitle
   put sMediaMetaA["sub_title"] into tSubTitle
   put sMediaMetaA["artists"] into tArtists
   put sMediaMetaA["author"] into tAuthor
   put sMediaMetaA["description"] into tDescription
   put sMediaMetaA["date_created"] into tDateCreated
   # do not  display a non-date string as zeros
   if tDateCreated ="0000-00-00" then put "" into tDateCreated
   
# data has commas so we have to use a lines as a delimiter
   put (tTitle& cr &tSubTitle& cr &tArtists& cr &tAuthor& cr &tDateCreated& cr &tDescription) into tFields

   repeat for each line x in tFields
      if x <> empty then
         put x & cr & cr after tViewData
      end if
   end repeat
     return tViewData
 
  end getMediaItemMetadata
  
command getformatData pItemID
   put format ("SELECT  * FROM item_format WHERE item_id  = \"%s\"", pItemID) into tSQL
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet("item_format", tConnectionID) into aSelectedItemFormats   
end getformatData

   
   # the whole html text thing is breaking everything!
   
   --   repeat for each item x in tFields
   --      if x <> empty then
   --         switch 
   --            case x = tTitle
   --               put (htmlTagger (bold,tTitle) ) &"<br>" & cr after tViewData
   --               break
   --            case x = tSubTitle
   --               put (htmlTagger (bold,tSubTitle) ) &"<br>" & cr after tViewData
   --               break
   --            case x = tArtists
   --               put (htmlTagger (bold,tArtists) ) &"<br>" & cr after tViewData
   --               break
   --            case  x= tAuthor
   --               put (htmlTagger (bold,tAuthor) ) &"<br>" & cr after tViewData
   --               break
   --            case x = tDateCreated
   --               put (htmlTagger (bold,tDateCreated) ) &"<br><br >" & cr after tViewData
   --               break
   --            case  x= tDescription
   --               put tDescription  & cr after tViewData # plain text
   --         end switch
   --      end if
   --      end repeat
   --      put "</p>" & cr& cr after tViewData
   
function htmlTagger pStyle,  pText
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

## Need a better function here.. this method loses data
## we need to just target the tags and leave enclosed strings.

function stripHTML pText
   set the htmlText of the templateField to pText
   put the text of the  templateField into tPlainText
   reset the templateField
   return tPlainText
end stripHTML



---> ## ART PATHFINDER

## need a switch here for top level media type


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

command insertImageDimensions pImage
   put ( (the formattedwidth of pImage) & "x" & (the formattedheight of pImage) ) into sCurrentGraphicRect
end insertImageDimensions



function getRectOfCurrentGrc
  return sCurrentGraphicRect
end getRectOfCurrentGrc


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

##########################################################
## IMAGE PROCESSING METHODS
##########################################################
# Br: July 15th, 2016
# Images arriving from the server need to fit the screen
# the general use case will almost always be a portrait screen
# landscape orientation will be used in specific cases for games or graphic stories
# As of today (July 15) these handlers to do not addess landscape 
# but we will pass a landscape param anyway so that we can implement later
# "pOrientation"
# We copied some already good methods from the gurudeva app. and modified from there.
##########################################################

on manualTestFetch pimage
   # just fror development... 
   # use a temp button on the UI to check for image resolution behavior etc
     answer file "Chose an image"
   put it into sURL
   set the filename of pImage to sURL
        put the formattedWidth of  pImage into tFWd
     put the formattedHeight of  pImage into tFHt
     put (tFWd & "x" & tFHt) into sCurrentGraphicRect
   resizeToHeight pimage, 736
   set the loc of pimage to the loc of this card
   show control "quoteControl"
   put sCurrentGraphicRect
end manualTestFetch

## NOTE: for the following handlers to work you must pass
## the rect in the form of  width x height  this this form ("736x552")
## and the long ID of the target image to "pImage" 

on resizeToHeight pImage,pSize
   set the itemdel to "x"
   put item 1 of sCurrentGraphicRect into tOrigImgWidth
   put item 2 of sCurrentGraphicRect into tOrigImgHeight
   # it may not be necessary
   if pSize > tOrigImgHeight then exit resizeToHeight
   put (pSize)/tOrigImgHeight  into tRatio
  put (tOrigImgWidth * tRatio) into tNewWidth
  put (tOrigImgHeight * tRatio) into tNewHeight
  set the rect of pImage to 0,0,tNewWidth,tNewHeight  
end resizeToHeight

on resizeToWidth pImage,pSize 
      set the itemdel to "x"
   put item 1 of sCurrentGraphicRect into tOrigImgWidth
   put item 2 of sCurrentGraphicRect into tOrigImgHeight
   # it may not be necessary
      if pSize > tOrigImgWidth then exit resizeToWidth
  put pSize/tOrigImgWidth into tRatio 
  put (tOrigImgWidth * tRatio) into tNewWidth
  put (tOrigImgHeight * tRatio) into tNewHeight
  set the rect of  pImage to 0,0,tNewWidth,tNewHeight
end resizeToWidth

on toggleImgSize pImage, pFullSize, pTargetSize 
   # we may not always this rect of the images from  the metadata
   # May as well just find out what it is right here.
   # pImage is the long ID of the image
   # you do not use "img ## to refer to it... just "pImage"

   -- if second param is empty we toggle it; otherwise set it as specified;
   -- called from main img script when tapped and when main cd closes to reset
   
   if pFullSize = "" then -- calculate if it's already full size
      put (the width of  pImage > the width of this cd) into tFullSize
  end if
  put the formattedWidth of  pImage into tFWd
     put the formattedHeight of  pImage into tFHt

  if tFullSize then -- reduce to fit
    resizeToWidth pImage,pTargetSize
  else -- return to full size
    resizeToHeight pImage,tFHt
  end if
  set the loc of  pImage to the loc of this cd

end toggleImgSize

##########################################################
## VIDEO PRESENTATION UTILITIES
##########################################################

# convert incoming URL from the formats table in the Jnanam database
# URL are stored in this form:
# "http://www.youtube.com/watch?v=T6mwoO9sXPI&feature=youtube_gdata_player"

function convertYouTubeURL pURL
    set the itemdel to "?"
    put item 2 of pURL into tQueryString
    split tQueryString with "&" and "="
    return "https://www.youtube.com/embed/" & tQueryString["v"]&"?rel=0"
end convertYouTubeURL

command checkMetaBackScript pMsg
   answer "got it" with pMsg
end checkMetaBackScript

##########################################################
## VISUAL EFFECTS
##########################################################



--> GRADIENT SETTINGS

command setGradient pObject
   # Param "pObject" works locally with simple object reference like  graphic "header"
   # otherwise you should  pass the long ID of the object
   
   local tNewGradientArray
   
   # be careful when cutting and paste to and from email
   # tabs may get replace by spaces:
   
   put "from	208,-201|mirror	false|quality	good|ramp	0.13000,255,255,255,0" & return into tNewGradientArray
   put "0.62001,60,11,9,212|repeat	1|to	208,-304|type	linear|via	536,-201|wrap	true" after tNewGradientArray
   
   split tNewGradientArray by "|" and tab
   set the fillGradient of pObject to tNewGradientArray
   
end setGradient

--> FADE WITH BLENDLEVEL
-- Better to use dissolve.

   # BR note that hide and show with visual effect "dissolve" also works, 
   # tends to run very fast on mobile
   
command object_FadeIn  pEffectsTarget, newBlendLevel, someIncrement, someDelay
   set the blendLevel of  pEffectsTarget  to newBlendLevel
   if newBlendLevel > 0 then
      subtract someIncrement from newBlendLevel
      send "object_FadeIn pEffectsTarget, newBlendLevel,someIncrement,someDelay" to me in someDelay milliseconds
   else
      set the blendLevel of pEffectsTarget to 0
   end if
end object_FadeIn

command object_FadeOut  pEffectsTarget, newBlendLevel, someIncrement, someDelay
   set the blendLevel of  pEffectsTarget  to newBlendLevel
   if newBlendLevel <100 then
      add someIncrement to newBlendLevel
      send "object_FadeOut pEffectsTarget, newBlendLevel,someIncrement,someDelay" to me in someDelay milliseconds
   else
      set the blendLevel of pEffectsTarget to 100
   end if
end object_FadeOut


##########################################################
## ##########################################################
## RANDOM IMAGE FOR INIT STACK 
##  the following is uses to update the image on the home loader card which 
##  always stays open  our current methods are making this appear in between module transitions
##  so let's make it interesting.
##########################################################



