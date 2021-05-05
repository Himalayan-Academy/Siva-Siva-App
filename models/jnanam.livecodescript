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
   
   # BR: assuming the set up does not fail then we need to updated the item table with
   # what is cached on disk, this could expand to include other media later.
   
   jnanam_UpdatePhotoCache
   
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
   local jnanamCompressedFilePath
   put jnanam_GetModelFolder() & "jnanam.sqlite.gz" into jnanamCompressedFilePath
   return jnanamCompressedFilePath
end jnanam_GetCompressedFilePath

function jnanam_GetModelFolder
   local jnanamModelFolder, modelName
   set the itemdelimiter to slash
   put the filename of me into jnanamModelFolder
   put the short name of me into modelName
   put modelName into item -1 of jnanamModelFolder
   put slash after jnanamModelFolder
   return jnanamModelFolder
end jnanam_GetModelFolder

private function asset_GetFileFromItemArray pItemA
   local assetFolder, fileID, assetFile
   put path_Assets() into assetFolder
   put pItemA ["file_id"] into fileID
   
   switch pItemA ["media_type"]
      case "art/photography"
         put assetFolder & "img/photography/" & fileID & "/" & fileID & "_med.jpg" into assetFile
         break
   end switch
   return assetFile
end asset_GetFileFromItemArray

function jnanam_GetDatabasePath
      return path_Documents() & "jnanam.sqlite"
end jnanam_GetDatabasePath


--> Jnanam
-
function jnanamDB
      if sID is not a number then
      _loadDatabase
   end if
   return sID
end jnanamDB


--> Private
-
command _setupDatabase
   local jnanamDatabasePath
   put jnanam_GetDatabasePath() into jnanamDatabasePath
   if there is not a file jnanamDatabasePath  or _CheckSumDoesntMatch(jnanamDatabasePath)  then
      _copyAndDecompress
   end if
   
   if sID is not a number then
      _loadDatabase
   end if
   put true into sLoaded
end _setupDatabase

function _CheckSumDoesntMatch jnanamDatabasePath
   local  tDbaseCheckPath, tCheckSum, tLatestCheckSum
   put jnanamDatabasePath into tDbaseCheckPath
   put ".txt" after tDbaseCheckPath
   put url ("binfile:" & tDbaseCheckPath) into tCheckSum
   put  the md5Digest of URL ("binfile:" & jnanam_GetCompressedFilePath()) into tLatestCheckSum
   return tCheckSum<>tLatestCheckSum
end _CheckSumDoesntMatch
   
private command _copyAndDecompress
   local compressedFile, tDF
   put jnanam_GetCompressedFilePath() into compressedFile
   put the defaultfolder into tDF
   set the itemdel to "/"
   set the defaultfolder to item 1 to -2 of the effective filename of this stack
   get url ("binfile:" & compressedFile)
   put decompress(it) into url ("binfile:" & jnanam_GetDatabasePath())
   put  the md5Digest of URL ("binfile:" & jnanam_GetCompressedFilePath()) into url ("binfile:" &jnanam_GetDatabasePath() & ".txt")
   set the defaultfolder to tDF
end _copyAndDecompress

private command _loadDatabase
   local  sqliteFile
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
   local tPathToPhotos, tFileIDs, pSQL, pDatabaseConnectionID,
   local tItemsA, tTotal, itemArray, tFilePath, fileID, tNewDataA, tResult
   switch pMediaType
      case "art/photography"
         put path_Assets() & "img/photography/" into tPathToPhotos
         put folders(tPathToPhotos) into tFileIDs
         delete line 1 of tFileIDs# .. listing
         replace cr with comma in tFileIDs
         put format ("UPDATE item SET cached_on_disk=\"true\" WHERE file_id IN" ) into pSQL
               put " (" & quoteValuesforSQLparam(tFileIDs) & ")" after pSQL
         put JnanamDB() into pDatabaseConnectionID
         dbExecuteSQL pSQL, pDatabaseConnectionID
         break
      default
         
         --##BR 2016-11-22: this doesn't work
         -- all items on disk should have their "cached_on_disk" updated to "true
         
         dbWhere "media_type", pMediaType
         put dbGet("item") into tItemsA
         
         put the number of lines in the keys of tItemsA into tTotal
         repeat with x = 1 to tTotal
            put tItemsA [x] into itemArray
            put asset_GetFileFromItemArray(itemArray) into tFilePath
            
            if there is a file tFilePath then    
               put tItemsA [x]["file_id"] into fileID
               dbWhere "file_id", fileID
               
               ## put true into tNewDataA["email"] --Br "email"?
               put "true" into tNewDataA["cached_on_disk"] -- BR still doesn't work
               
               put dbUpdate("item", tNewDataA) into tResult
               answer tResult
               breakpoint
            end if
         end repeat
         
   end switch
   
end updateCache

function quoteValuesforSQLparam pValueList
   local tQuotedList 
   # pass a list of items comma separated and return with quotes
   put empty into tQuotedList # just in case
   repeat for each item x in pValueList
      put quote & x & quote & comma after tQuotedList
   end repeat
   delete char -1 of tQuotedList
   return tQuotedList
end quoteValuesforSQLparam

function jnanam_GetItem pFileID 
   local tA 
   dbWhere "file_id", pFileID 
   put dbGet("item",jnanamDB()) into tA 
   return tA[1]
end jnanam_GetItem

command jnanam_SaveNewItem pItemA
   if pItemA["file_id"] is empty then 
      return "jnanamerr, can't save item with no file_id"
   end if
   
   put jnanam_GetItem(pItemA["file_id"]) into tA
   if tA["file_id"] is not empty then
      return "jnanamerr, record already exists for file_id:" && tA["file_id"]
   end if
   
   -- clean up for safety
   repeat for each item v in "filename,formats,myURL"
      delete variable pItemA[v]
   end repeat
   
   return dbInsert("item", pItemA, jnanamDB())
end jnanam_SaveNewItem
