script "jnanam"
/**
* jnanam library
*
* Provides high level functions to deal with local jnanam database
*/

local sID

on librarystack
   _setupDatabase
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
   if there is not a file pathToJnanamDatabase() then
      _copyAndDecompress
   end if
   if sID is not a number then
      _loadDatabase
   end if
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


