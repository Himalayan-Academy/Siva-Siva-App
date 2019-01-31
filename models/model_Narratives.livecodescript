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






