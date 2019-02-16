script "model_Narratives"

-----------------------------------------------------
#  behavior_Narrative
#
# DESCRIPTION
# this behavior is meant to serve as the code behind any  grp "narrative" 
# which contains one or more images, fields, browser and audio that will be called
# to a narrative/story, narrative/teaching, narrative/reference
# the idea is to all an XML file to server narrative folders
# then "informs" the user with story.
# CHANGES: 2018-20-2018 CREATED Brahmanathaswami
-----

command showNarrative pNarrativeA
   dispatch "showNarrative" to stack "narrative" with pNarrativeA
end showNarrative

function loadNarrativeFromDisk pID 
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











# for now this a proof of conceptI have just a little kale left to last me 5 days. 
# starting by building it locally in the stack
# to see how it flows.

function randomDeityPhotos
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
   put dbGet(,tConnectionID) into pDeityPhotoFileIDA
   repeat for each key x in pDeityPhotoFileIDA
      put returnAssetPath("photography",pDeityPhotoFileIDA[x]["file_id"]) & cr after pImageList
   end repeat
   --ntinfo ("put line 10: " & (line 10 of pImageList))
   return pImageList
   
end randomDeityPhotos 

function fetchQuotesCollection pCollection
   put getSQLQueries() into tQueriesA
   repeat for each key x in tQueriesA
      if tQueriesA[x]["queryName"] = "selectQuotesCollection" then
         put tQueriesA[x]["sqlQuery"] into tSQL
         exit repeat
      end if
   end repeat
   
   replace "#####" with pCollection in tSQL
   
   put  JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet(,tConnectionID) into pQuotesDataA
   repeat for each key x in pQuotesDataA
      put pQuotesDataA[x]["content"] &cr & "|" after pQuotes
   end repeat
   return pQuotes
end fetchQuotesCollection 


function returnAssetPath pAssets,pFileID
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






