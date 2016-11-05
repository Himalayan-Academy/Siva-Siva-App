script "jnanam"
--> Metadata
-
/*
* jnanam library
*
* Provides high level functions to deal with local jnanam database
*/

--> Variables
-
local sID
local sLoaded
local LocalArray


--> Working on
-

--> Events
-
on librarystack
   -- best not to place this here as it will get called every time
   if the long id of the target is not the long id of me then pass librarystack
     
   if sLoaded is not true then
      _setupDatabase
   end if
end librarystack


--> Jnanam | Photos
-
command jnanam_UpdatePhotoCache
   ## This command will cycle the photos on disk and update the 
   ## cached_on_disk field on the SQLite database for all photos
   ## that are present.
   updateCache "art/photography"
end jnanam_UpdatePhotoCache


--> Jnanam | Files
-
function jnanam_GetCompressedFilePath
   put jnanam_GetModelFolder() & "jnanam.sqlite.gz" into jnanamCompressedFilePath
   return jnanamCompressedFilePath
end jnanam_GetCompressedFilePath

function jnanam_GetModelFolder
   set the itemdelimiter to slash
   put the filename of me into jnanamModelFolder
   put the short name of me into modelName
   put modelName into item -1 of jnanamModelFolder
   put slash after jnanamModelFolder
   return jnanamModelFolder
end jnanam_GetModelFolder

private function asset_GetFileFromItemArray pItemA
   -- was "pathForItem"
   put sivasiva_AssetFolder() into assetFolder
   put pItemA ["file_id"] into fileID
   
   switch pItemA ["media_type"]
      case "art/photography"
         put assetFolder & "img/photography/" & fileID & "/" & fileID & "_med.jpg" into assetFile
         break
   end switch
   return assetFile
end asset_GetFileFromItemArray

function jnanam_GetDatabasePath
   -- was "pathToJnanamDatabase"
   if the environment is "development" then
      -- use temp?
      return specialfolderpath("temporary") & "/jnanam.sqlite"
   else
      return specialfolderpath("documents") & "/jnanam.sqlite"
   end if
end jnanam_GetDatabasePath


--> Jnanam
-
function jnanamDB
   return sID
end jnanamDB


--> Private
-
command _setupDatabase
   put jnanam_GetDatabasePath() into jnanamDatabasePath
   if there is not a file jnanamDatabasePath or the environment is "development" then
      _copyAndDecompress
   end if
   
   if sID is not a number then
      _loadDatabase
   end if
   put true into sLoaded
end _setupDatabase

private command _copyAndDecompress
   put jnanam_GetCompressedFilePath() into compressedFile
   
   put the defaultfolder into tDF
   set the itemdel to "/"
   set the defaultfolder to item 1 to -2 of the effective filename of this stack
   get url ("binfile:" & compressedFile)
   put decompress(it) into url ("binfile:" & jnanam_GetDatabasePath())
   set the defaultfolder to tDF
end _copyAndDecompress

private command _loadDatabase
   put jnanam_GetDatabasePath() into sqliteFile
   
   get revOpenDatabase("sqlite", sqliteFile)
   if it is not a number then
      throw it
      exit to top
   else
      put it into sID
   end if
end _loadDatabase

private command updateCache pMediaType   
   dbWhere "media_type", pMediaType
   put dbGet ("item") into tItemsA
   
   put the number of lines in the keys of tItemsA into tTotal
   repeat with x = 1 to tTotal
      put tItemsA [x] into itemArray
      put asset_GetFileFromItemArray (itemArray) into tFilePath
      
      if there is a file tFilePath then    
         put tItemsA [x]["file_id"] into fileID
         dbWhere "file_id", fileID
         
         put true into tNewDataA ["email"]
         put dbUpdate ("item", tNewDataA) into tResult
         answer tResult
         breakpoint
      end if
   end repeat
end updateCache
