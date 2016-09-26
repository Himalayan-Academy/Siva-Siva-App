script "jnanam"
/**
* jnanam library
*
* Provides high level functions to deal with local jnanam database
*/

local sID
local sLoaded

on librarystack
   if sLoaded is not true then
      _setupDatabase
   end if
end librarystack

function pathToJnanamDatabase
   if the environment is "development" then
      -- use temp?
      return specialfolderpath("temporary") & "/jnanam.sqlite"
   else
      return specialfolderpath("documents") & "/jnanam.sqlite"
   end if
end pathToJnanamDatabase

private command _setupDatabase
   if there is not a file pathToJnanamDatabase() or the environment is "development" then
      _copyAndDecompress
   end if
   
   if sID is not a number then
      _loadDatabase
   end if
   put true into sLoaded
end _setupDatabase

private command _copyAndDecompress
   put the defaultfolder into tDF
   set the itemdel to "/"
   set the defaultfolder to item 1 to -2 of the effective filename of this stack
   get url ("binfile:jnanam.sqlite.gz")
   put decompress(it) into url ("binfile:" & pathToJnanamDatabase())
   set the defaultfolder to tDF
end _copyAndDecompress

private command _loadDatabase
   get revOpenDatabase("sqlite", pathToJnanamDatabase())
   if it is not a number then
      throw it
      exit to top
   else
      put it into sID
   end if
end _loadDatabase

function jnanamDB
   return sID
end jnanamDB

command updatePhotoCache
   ## This command will cycle the photos on disk and update the 
   ## cached_on_disk field on the SQLite database for all photos
   ## that are present.
   updateCache "art/photography"
end updatePhotoCache

function pathForItem pItemA
   switch pItemA["media_type"]
      case "art/photography"
         put "shared/img/photography/" & pItemA["file_id"] & "/" & pItemA["file_id"] & "_med.jpg" into tPath
         break
   end switch
   return tPath
end pathForItem

command updateCache pMediaType
   set itemdel to "/"
   put the defaultfolder into tDF
   set the defaultfolder to item 1 to -2 of the effective filename of stack "loader"
   
   dbWhere "media_type", pMediaType
   put dbGet("item") into tItemsA
   put the number of lines in the keys of tItemsA into tTotal
   repeat with x = 1 to tTotal
      put pathForItem(tItemsA[x]) into tFilePath
      if there is a file tFilePath then
         put true into tNewDataA["email"] 
         dbWhere "file_id", tItemsA[x]["file_id"]
         put dbUpdate("item", tNewDataA) into tResult
         answer tResult
         breakpoint
      end if
   end repeat
   set the defaultfolder to tDF
end updateCache


