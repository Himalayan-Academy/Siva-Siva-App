script "model_SivaSivaTracking"
--> Metadata
-
/*
* Activity Tracking Model
*
* Provides high level functions to track activity usage inside the app
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
   if the long id of the target is not the long id of me then 
      pass librarystack
   end if
   
   if sLoaded is not true then
      _setupDatabase
      _generateUUID
   end if
   
end librarystack


--> Tracking | Files
-
function tracking_GetCompressedFilePath
   put tracking_GetModelFolder() & "tracking.sqlite.gz" into trackingCompressedFilePath
   return trackingCompressedFilePath
end tracking_GetCompressedFilePath

function tracking_GetModelFolder
   set the itemdelimiter to slash
   put the filename of me into trackingModelFolder
   put the short name of me into modelName
   put modelName into item -1 of trackingModelFolder
   put slash after trackingModelFolder
   return trackingModelFolder
end tracking_GetModelFolder


function tracking_GetDatabasePath
   return path_Documents() & "tracking.sqlite"
end tracking_GetDatabasePath


function tracking_GetUUIDPath
   return path_Documents() & "uuid.txt"
end tracking_GetUUIDPath

function tracking_UUID
   get url ("binfile:" & tracking_GetUUIDPath())
   return it
end tracking_UUID

--> Tracking | Activities

command tracking_RecordActivity pModule, pType, pData
   put pModule into tDataA["module"]
   put pType into tDataA["type"]
   
   if the keys of pData is empty then
      if pData is not empty then
         put pData into tTempA["data"]
         put jsonexport(tTempA) into tDataA["data"]
      end if
   else
      put jsonexport(pData) into tDataA["data"]
   end if
   
   put dbInsert("activity", tDataA, trackingDB()) into tResult
   return tResult
end tracking_RecordActivity

command tracking_UploadData
   if _thereIsInternet() then
      _uploadData
   end if
end tracking_UploadData

private function _thereIsInternet
   get url "http://dev.himalayanacademy.com/ping.txt"
   if it is "true" then
      return true
   else
      return false
   end if
end _thereIsInternet

private command _uploadData
   put _assembleDataForUpload() into tDataJSON
   post tDataJSON to url ("http://dev.himalayanacademy.com/api/index.php/sivasiva/tracking/" & tracking_UUID())
   if the result is not empty then
      -- error
   else
      put jsonImport(it) into tResultA
      if tResultA["status"] is "uploaded" then
         _truncateData
      end if
   end if
end _uploadData

private function _assembleDataForUpload
   put dbGet("activity",trackingDB()) into tResultA
   return jsonExport(tResultA)
end _assembleDataForUpload

private command _truncateData
   get dbDelete("activity", trackingDB(), true)
end _truncateData
   
   function tracking_makeInlineArray
   repeat with x = 1 to the paramcount step 2
      put param(x+1) into tTempA[param(x)]
   end repeat
   return tTempA
end tracking_makeInlineArray




--> tracking
-
function trackingDB
   if sID is not a number then
      _loadDatabase
   end if
   return sID
end trackingDB


--> Private
-
private command _setupDatabase
   put tracking_GetDatabasePath() into trackingDatabasePath
   if there is not a file trackingDatabasePath or the environment is "development" then
      _copyAndDecompress
   end if
   
   if sID is not a number then
      _loadDatabase
   end if
   put true into sLoaded
end _setupDatabase

private command _copyAndDecompress
   put tracking_GetCompressedFilePath() into compressedFile
   
   put the defaultfolder into tDF
   set the itemdel to "/"
   set the defaultfolder to item 1 to -2 of the effective filename of this stack
   get url ("binfile:" & compressedFile)
   put decompress(it) into url ("binfile:" & tracking_GetDatabasePath())
   set the defaultfolder to tDF
end _copyAndDecompress

private command _generateUUID
   put the ticks & random(9999) & random(9999) into tUUID
   put tUUID into url ("binfile:" & tracking_GetUUIDPath())
end _generateUUID

private command _loadDatabase
   put tracking_GetDatabasePath() into sqliteFile
   
   get revOpenDatabase("sqlite", sqliteFile)
   if it is not a number then
      throw it
      exit to top
   else
      put it into sID
   end if
end _loadDatabase

