script "model_Narratives"

-----------------------------------------------------
# model_Narrative
#
# DESCRIPTION
# used a behavior but called in model because it gets for disk what is needed
# is meant to serve as the code behind any  grp "narrative" which contains one or more images, fields, browser and audio that will be called
# to a narrative/story, narrative/teaching, narrative/reference
# the idea is to all an XML file to server narrative folders
# then "informs" the user with story.
# CHANGES: 2018-20-2019 Added a command to call a class of narrative (future use case, current a slideshow from the app) and random function 
# CHANGES: 2018-20-2018 CREATED Brahmanathaswami
-----
--command foundNarrativeScript
--   answer "Yes, I am model_narrative and I am in the message Path!" with "OK"
--end foundNarrativeScript

command showNarrative pNarrativeA
   dispatch "showNarrative" to stack "narrative" with pNarrativeA
end showNarrative

function loadNarrativeFromDisk pID
   local tPath, tXML, tNarrativeA, tFirstChild, i, tNextSibling
   put sivasiva_AssetFolder() & "narratives/" & pID & ".xml" into tPath 
   
   if there is not a file tPath then 
      return "xmlerr: file doesn't exist"
   end if 

   put revXMLCreateTreeFromFile(tPath, false, true, false) into tXML
   
   if tXML is not a number then 
      return tXML
   end if 
   
   put tXML into tNarrativeA["xml document id"]
   put revXMLRootNode(tXML) into tNarrativeA["xml root node"]
   put revXMLNumberOfChildren(tXML,tNarrativeA["xml root node"],,0) into tNarrativeA["number of scenes"]
   put revxmlfirstchild(tXML, tNarrativeA["xml root node"]) into tFirstChild
   put 1 into i
   put narrativeExtractScene(tXML, tFirstChild) into tNarrativeA["scenes"][i]
   put tFirstChild into tNextSibling
   
   repeat while tNextSibling is not empty
      put revXMLNextSibling(tXML,tNextSibling) into tNextSibling
      if "xmlerr" is in tNextSibling or tNextSibling is empty then
         exit repeat
      end if
      add 1 to i 
      put narrativeExtractScene(tXML, tNextSibling) into tNarrativeA["scenes"][i]
   end repeat
   
   return tNarrativeA
end loadNarrativeFromDisk

function narrativeExtractScene pXML, pPath
   local tFirstItem, i, tSceneA, tNextItem
   put revxmlfirstchild(pXML, pPath) into tFirstItem
   put 1 into i
   put narrativeExtractItem(pXML, tFirstItem) into tSceneA[i]
   put tFirstItem into tNextItem
   
   repeat while tNextItem is not empty
      put revXMLNextSibling(pXML,tNextItem) into tNextItem
      if "xmlerr" is in tNextItem or tNextItem is empty then
         exit repeat
      end if
      add 1 to i 
      put narrativeExtractItem(pXML, tNextItem) into tSceneA[i]
   end repeat
   
   return tSceneA
end narrativeExtractScene


function narrativeExtractItem pXML, pPath 
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
         narrativeItemLoadImage tR
         break
      case "text"
         break
   end switch
   
   return tR
end narrativeExtractItem

on narrativeItemLoadImage @pItemA
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

end narrativeItemLoadImage



-------------------------
# we should optimize these two functions for any slides show

function randomDeityPhotos
   local tQueriesA, tSQL, tConnectionID, tImageList
   --ntInfo ("getting RandomImage")
   put getSQLQueries() into tQueriesA
   repeat for each key x in tQueriesA
      if tQueriesA[x]["queryName"] = "selectCachedDeityPhotos" then
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
   
end randomDeityPhotos 

function randomLifePhotos
   local tQueriesA, tSQL, tConnectionID, tImageList
   --ntInfo ("getting RandomImage")
   put getSQLQueries() into tQueriesA
   repeat for each key x in tQueriesA
      if tQueriesA[x]["queryName"] = "selectCachedLifePhotos" then
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
   
end randomLifePhotos 


function fetchQuotesCollection pCollection
   local tQueriesA, tSQL, tConnectionID, tQuotesDataA, tQuotes
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
      put tQuotesDataA[x]["content"] &cr & "|" after tQuotes
   end repeat
   return tQuotes
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






