script "model_Stories"

-----------------------------------------------------
# model_Stories
#
# DESCRIPTION
# used a behavior but called in model because it gets for disk what is needed
# is meant to serve as the code behind any  grp "story"
# which contains one or more images, fields, browser and audio that will be called
# to a story/narrative, story/teaching, story/reference
# the idea is to call an XML file to server story folders
# then "informs" the user with story.

# CHANGES  10-08-2019 Added a command to call a class of story (future use case, current a slideshow from the app) and random function 
# CHANGES: 10-20-2018 CREATED Brahmanathaswami

local  sStoriesMetaArray, sStoryTitle


function loadStoriesMetadata 
   local tStoryData
   put url ("binfile:" & path_Documents()& "modules/stories/stories.json") into tStoryData
   if tStoryData is empty then
      put url ("binfile:" & path_Modules()& "stories/stories.json") into tStoryData
   end if
   put JSONToArray(tStoryData) into sStoriesMetaArray 
   return sStoriesMetaArray
end loadStoriesMetadata

#### GETCONTENT 
## BR: 09-03-2019
-- getContent
-- currently use for slide shows using app package
-- photos and quote
-- eventually: "classes" TBD, like vidoe, XML presention
-- slideshow from the web etc.
############

# TO DO: BR why am I just "random" These are just list of caches photos?
# Legacy code. I use and SQL query model and probably removed the randon clause

on makeStoryFromDisk
   local sImageList, sQuoteList, sAttribution, sTotalSceneCount, slidesLimit
   local imageList, Quotes, Attribution, SceneCount, storyIsCachedFlag, storyTitle
   local sStoryImage
   
   put the long id of img "slideImage" into sStoryImage
   
   # just for development
   put  loadStoriesMetadata() into sStoriesMetaArray
   put "Vedas" into sStoryTitle
   
   # clean up the current content
   lock screen
   repeat with x = 2 to (the number of cards in this stack)
      delete card x of this stack
   end repeat
   
   unlock screen
   
   
   put randomPhotos(sStoriesMetaArray["Stories"][sStoryTitle]["imageTags"]) into sImageList 
   put FetchQuotesCollection(sStoriesMetaArray["Stories"][sStoryTitle]["quotesCollection"]) into sQuoteList
   
   if sStoriesMetaArray["Stories"][sStoryTitle][slidesLimit] = "quotes" then
      put the number of lines of  sQuoteList into sTotalSceneCount
   else
      put the number of lines of  sImageList into sTotalSceneCount
   end if
   
   # Make the stack cards 
   
   put "" into fld "mainText"
   repeat with x = 2 to sTotalSceneCount
      clone this card
      set the cantDelete of this card to false 
   end repeat
   
   # go card 1. Enter what you want in the title v
   go to card 1
   
   put sStoriesMetaArray["Stories"][sStoryTitle]["attribution"] into sAttribution
   put sStoryTitle & cr& "By" & cr & sAttribution into fld "mainText"
   
   
   ---------------
   # for development
   repeat with x = 2 to sTotalSceneCount
      go card x of this stack
      delete card x 
      set the filename of sStoryImage to line x of sImageList
      put line x of sQuoteList into fld "mainText"
      
   end repeat
   
end makeStoryFromDisk


on dataLocalStack pPassTitle
   put loadStoriesMetadata() into sStoriesMetaArray
   send "makeStoryLocal pPassTitle" to stack "makeStoryLocal" --in 0 seconds
end dataLocalStack


on dataServerStack pStoryTitle
   put loadStoriesMetadata() into sStoriesMetaArray
   
   local tHttpsServerRoot, tLocalDocumentsStories
   local tFilePath, tServerPath, tFiles, tLocation
   local tItems, tCompressionMethod,tItem,tZipItem
   
   put "https://dev.himalayanacademy.com/media/stories/" into tHttpsServerRoot
   put path_Documents()& "media/stories/" into tLocalDocumentsStories
   
   put (tHttpsServerRoot & pStoryTitle & "/" & pStoryTitle & ".zip") into tServerPath
   replace space with "%20" in tServerPath
   
   create folder tLocalDocumentsStories & pStoryTitle
   
   put tLocalDocumentsStories & pStoryTitle & "/" & pStoryTitle & ".zip" into tFilePath
   put URL (tServerPath) into  URL ("binfile:" & tFilePath)
   
   ------ # open the database
   
   set the itemDel to "/"
   put item 1 to -2 of tFilePath into tLocation
   --put "/" & char 1 to -5 of item -1 of tFilePath after tLocation
   ensureFolder tLocation
   
   revZipOpenArchive tFilePath, "read"
   local tZipContents
   --   put revZipEnumerateItems(tFilePath) into tZipContents
   put revZipEnumerateItems(tFilePath) into tFiles
   
   repeat for each line tZipItem in tFiles
      set the itemDel to comma
      put item 6 of revZipDescribeItem(tFilePath,tItem) into tCompressionMethod
      set the itemDel to "/"
      if item 1 of tZipItem is pStoryTitle then
         -- some zip files include an extra folder level
         put item 2 to -1 of tZipItem into tItem
      else
         put tZipItem into tItem
      end if
      
      if char -1 of tZipItem is "/" then
         -- we ignore extraction of folders, as libzip doesnt handle folders
      else if item -1 of tZipItem is ".DS_Store" then
         // Check for ".DS_Store"
         ensureFolder tLocation & "/" & item 1 to -2 of tItem
      else if tCompressionMethod is "deflate" then
         -- first make sure that the folder exists
         ensureFolder tLocation & "/" & item 1 to -2 of tItem
         revZipExtractItemToFile tFilePath, tZipItem, tLocation & "/" & tItem
      else
         -- ignore this item, possibly displaying a message to the user, that this file cannot be extracted
         -- because its compression type is not supported by this program
      end if
   end repeat
   
   revZipCloseArchive tFilePath
   
   delete file tFilePath
end dataServerStack

on ensureFolder pFolder
   set the itemDel to "/"
   repeat with x = 1 to the number of items in pFolder
      if there is not a folder (item 1 to x of pFolder) then
         create folder (item 1 to x of pFolder)
      end if
   end repeat
end ensureFolder



command  getContent sStoryTitle # keys of the stories.json 
   
   local sImageList, sQuoteList, sAttribution, sTotalSceneCount, slidesLimit
   local imageList, Quotes, Attribution, SceneCount, storyIsCachedFlag, storyTitle
   
   put sStoriesMetaArray["Stories"][sStoryTitle]["attribution"] into sAttribution
   put randomPhotos(sStoriesMetaArray["Stories"][sStoryTitle]["imageTags"]) into sImageList 
   put FetchQuotesCollection(sStoriesMetaArray["Stories"][sStoryTitle]["quotesCollection"]) into sQuoteList
   
   if sStoriesMetaArray["Stories"][sStoryTitle][slidesLimit] = "quotes" then
      put the number of lines of  sQuoteList into sTotalSceneCount
   else
      put the number of lines of  sImageList into sTotalSceneCount
   end if
   
   setCache "imageList", sImageList
   setCache "Quotes", sQuoteList
   setCache "Attribution", sAttribution
   setCache "SceneCount", sTotalSceneCount
   setCache "storyIsCachedFlag", 1
   setCache "storyTitle", sStoryTitle
   --   if not isMobile() then
   --      displayCache
   --   end if
end getContent

--command showStory pStoryA
--   dispatch "showStory" to stack "story" with pStoryA
--end showStory

function loadStoryFromDisk pID
   local tPath, tXML, tStoryA, tFirstChild, i, tNextSibling
   put sivasiva_AssetFolder() & "storys/" & pID & ".xml" into tPath 
   
   if there is not a file tPath then 
      return "xmlerr: file doesn't exist"
   end if 
   
   put revXMLCreateTreeFromFile(tPath, false, true, false) into tXML
   
   if tXML is not a number then 
      return tXML
   end if 
   
   put tXML into tStoryA["xml document id"]
   put revXMLRootNode(tXML) into tStoryA["xml root node"]
   put revXMLNumberOfChildren(tXML,tStoryA["xml root node"],,0) into tStoryA["number of scenes"]
   put revxmlfirstchild(tXML, tStoryA["xml root node"]) into tFirstChild
   put 1 into i
   put storyExtractScene(tXML, tFirstChild) into tStoryA["scenes"][i]
   put tFirstChild into tNextSibling
   
   repeat while tNextSibling is not empty
      put revXMLNextSibling(tXML,tNextSibling) into tNextSibling
      if "xmlerr" is in tNextSibling or tNextSibling is empty then
         exit repeat
      end if
      add 1 to i 
      put storyExtractScene(tXML, tNextSibling) into tStoryA["scenes"][i]
   end repeat
   
   return tStoryA
end loadStoryFromDisk

function storyExtractScene pXML, pPath
   local tFirstItem, i, tSceneA, tNextItem
   put revxmlfirstchild(pXML, pPath) into tFirstItem
   put 1 into i
   put storyExtractItem(pXML, tFirstItem) into tSceneA[i]
   put tFirstItem into tNextItem
   
   repeat while tNextItem is not empty
      put revXMLNextSibling(pXML,tNextItem) into tNextItem
      if "xmlerr" is in tNextItem or tNextItem is empty then
         exit repeat
      end if
      add 1 to i 
      put storyExtractItem(pXML, tNextItem) into tSceneA[i]
   end repeat
   
   return tSceneA
end storyExtractScene


function storyExtractItem pXML, pPath 
   local tAttributesA, tContents, tNodeName, tR
   put pPath
   put revXMLAttributes(pXML, pPath, tab, cr) into tAttributesA
   split tAttributesA by cr and tab 
   put revxmlnodecontents(pXML, pPath) into tContents
   set the itemdel to "/"
   put item -1 of pPath into tNodeName
   set the itemdel to "["
   put item 1 of tNodeName into tNodeName
   if the keys of tAttributesA is not empty then
      put tAttributesA into tR["attributes"]
   end if
   if tContents is not empty then 
      put tContents into tR["contents"]
   end if
   put tNodeName into tR["type"]
   
   switch tNodeName
      case "image"
         storyItemLoadImage tR
         break
      case "text"
         break
   end switch
   
   return tR
end storyExtractItem

on storyItemLoadImage @pItemA
   local tRecordA, tPath
   if pItemA["attributes"]["file-id"] is not empty then
      put jnanamGetItem(pItemA["attributes"]["file-id"]) into tRecordA 
      # AAG: BROKEN! Files on disk doesn't match media folder on hap. 
   end if
   
   if pItemA["attributes"]["path"] is not empty then
      put sivasiva_AssetFolder() & "img/" & pItemA["attributes"]["path"] into tPath
      if there is a file tPath then 
         put tPath into pItemA["path"]
      end if
   end if
   
end storyItemLoadImage



-------------------------
# we should optimize these two functions for any slides show
# 

function randomPhotos pClass
   local tQueriesA, tSQL, tConnectionID, tImageList, tSelectionQuery
   Local tPhotoFileIDA
   put "selectCached" & pClass & "Photos"  into tSelectionQuery
   # see /models/sqlQueries.txt  which is a library or queries
   # turn into an array by lib_SivaSiva
   
   --ntInfo ("getting RandomImage")
   put getSQLQueries() into tQueriesA
   repeat for each key x in tQueriesA
      if tQueriesA[x]["queryName"] = tSelectionQuery then
         put tQueriesA[x]["sqlQuery"] into tSQL
         exit repeat
      end if
   end repeat
   --ntinfo tSQL
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet(,tConnectionID) into tPhotoFileIDA
   repeat for each key x in tPhotoFileIDA
      put returnAssetPath("photography",tPhotoFileIDA[x]["file_id"]) & cr after tImageList
   end repeat
   --ntinfo ("put line 10: " & (line 10 of pImageList))
   return tImageList
   
end randomPhotos 

--function randomLifePhotos
--   local tQueriesA, tSQL, tConnectionID, tImageList
--   ntInfo ("getting RandomImage")
--   put getSQLQueries() into tQueriesA
--   repeat for each key x in tQueriesA
--      if tQueriesA[x]["queryName"] = "selectCachedLifePhotos" then
--         put tQueriesA[x]["sqlQuery"] into tSQL
--         exit repeat
--      end if
--   end repeat
--   ntinfo tSQL
--   put  JnanamDB() into tConnectionID
--   dbSetSQL tSQL
--   put dbGet(,tConnectionID) into tPhotoFileIDA
--   repeat for each key x in tPhotoFileIDA
--      put returnAssetPath("photography",tPhotoFileIDA[x]["file_id"]) & cr after tImageList
--   end repeat
--   ntinfo ("put line 10: " & (line 10 of pImageList))
--   return tImageList

--end randomLifePhotos 


function fetchQuotesCollection pCollection
   local tQueriesA, tSQL, tConnectionID, tQuotesDataA, tQuote, tQuotes
   local aSelectedQuotes
   
   put getSQLQueries() into tQueriesA
   repeat for each key x in tQueriesA
      if tQueriesA[x]["queryName"] = "selectQuotesCollection" then
         put tQueriesA[x]["sqlQuery"] into tSQL
         exit repeat
      end if
   end repeat
   
   ## It is taken from the "subject" column of the quote table
   ## where use the book title in many cases
   
   replace "#####" with pCollection in tSQL
   
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet(,tConnectionID) into tQuotesDataA
   repeat for each key x in tQuotesDataA
      put textDecode (tQuotesDataA[x]["content"] , "UTF8")  into tQuote
      put tQuote &cr & "|" after tQuotes
      --put tQuotesDataA[x]["content"] &cr & "|" after tQuotes
   end repeat
   return tQuotes
   
   setLastQuoteID (aSelectedQuotes[1]["quote_id"])
   replace "\n" with cr in tQuote
end fetchQuotesCollection 


function returnAssetPath pAssets,pFileID
   local tPath
   switch pAssets
      case "photography"
         --ntinfo ("Accessingphotography folder")
         # photographs are always in a folder which is same same as the fileID
         # from the data base.
         --ntinfo (path_Assets())
         put (path_Assets()&"img/photography/")  &  \
               pFileID & "/"  & pFileID &"_med.jpg" after tPath
         break
   end switch
   -- ("the Path: " & tPath)
   return tPath
end returnAssetPath

-- put the long id img "randomPhoto" into tBkgndPhoto
--   put fetchRandomImageAsset("photography") into tImagePath
--   set the filename of tBkgndPhoto to tImagePath
--   setRectOfCurrentGrc tBkgndPhoto
--   resizeToHeight tBkgndPhoto,736
--   set the loc of tBkgndPhoto to the loc of this card


--   function fetchRandomImageAsset pCollection
--   # if it in photography, each image has a folder

--   put   (path_Assets()&"img/")  & pCollection into tPath
--   If pCollection="photography" then
--      put folders(tPath) into tFolderList
--      put line(random (the number of lines of tFolderList))of tFolderList into tImageID
--      put "/"& tImageID & "/"  & tImageID &"_med.jpg" after tPath
--   else   
--      put files(tPath) into tImageList
--      put "/"&line (random (the number of lines of tImageList)) of tImageList after tPath
--   end if
--   return tPath
--end fetchRandomImageAsset

--set the filename of tBkgndPhoto to tImagePath
--setRectOfCurrentGrc tBkgndPhoto
--resizeToHeight tBkgndPhoto,736
--set the loc of tBkgndPhoto to the loc of this card


-----
command foundStoryModel
   answer "Yes, I am model_story and I am in the message Path!" with "OK"
end foundStoryModel
-----




