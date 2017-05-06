script "model_SivaSivaJournal"
--> Metadata
-
/*
* Journal Model
*
* Provides high level functions to store and retrieve activity log usage inside the app.
*
* This model is inspired by OLPC Journal and Web Browser History.
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
   end if
   
end librarystack


--> Journal | Files
-
function Journal_GetCompressedFilePath
   put Journal_GetModelFolder() & "journal.sqlite.gz" into JournalCompressedFilePath
   return JournalCompressedFilePath
end Journal_GetCompressedFilePath

function Journal_GetModelFolder
   set the itemdelimiter to slash
   put the filename of me into JournalModelFolder
   put the short name of me into modelName
   put modelName into item -1 of JournalModelFolder
   put slash after JournalModelFolder
   return JournalModelFolder
end Journal_GetModelFolder


function Journal_GetDatabasePath
   if the environment is "development" then
      -- use temp?
      return specialfolderpath("temporary") & "/journal.sqlite"
   else
      return specialfolderpath("documents") & "/journal.sqlite"
   end if
end Journal_GetDatabasePath

--> Journal | Activities

command Journal_RecordEntry pModule, pLabel, pData, pTags, pImage
   put pModule into tDataA["module"]
   
   if the keys of pData is empty then
      if pData is not empty then
         put pData into tTempA["data"]
         put jsonexport(tTempA) into tDataA["data"]
      end if
   else
      put jsonexport(pData) into tDataA["data"]
   end if
   
   if pTags is not empty then
      put pTags into tDataA["tags"]
   end if
   
   if pImage is not empty then
      put pImage into tDataA["image"]
   end if
   
   if pLabel is not empty then
      put pLabel into tDataA["label"]
   else
      put pModule into tDataA["label"]
   end if
   
   put dbInsert("journal", tDataA, JournalDB()) into tResult
   return tResult
end Journal_RecordEntry

command Journal_SetFavoriteFlag pEntryID, pValue
   if pValue then
      put 1 into tDataA["is_favorite"]
   else
      put 0 into tDataA["is_favorite"]
   end if
   
   dbWhere "journal_id", pEntryID
   put dbUpdate("journal", tDataA, journalDB()) into tResult
   return tResult
end Journal_SetFavoriteFlag

function Journal_GetEntriesForModule pModule
   dbLimit 50
   dbLike "module", pModule
   put dbGet("journal", JournalDB()) into tEntriesA
   return tEntriesA
end Journal_GetEntriesForModule

function Journal_GetEntries
   dbLimit 50
   dbOrderBy "date"
   put dbGet("journal", JournalDB()) into tEntriesA
   return tEntriesA
end Journal_GetEntries

command Journal_LaunchEntry pEntryID
   dbWhere "journal_id", pEntryID
   put dbGet("journal", JournalDB()) into tEntriesA
   if the keys of tEntriesA[1] is empty then
      return "journalerr, no such entry"
   end if
   put tEntriesA[1] into tEntryA
   try
      put jsonimport(tEntryA["data"]) into tDataA
   catch n
      return "journalerr, data is corrupted"
   end try
   dispatch "journalresume" to stack tEntryA["module"] with tDataA, tEntryA
   if it is among the items of "unhandled,passed" then
      return "journalerr, no module could handle this activity"
   end if
end Journal_LaunchEntry

on journalresume pDataA, pEntryA
   put "Error: no one could handle journalresume, going for the default behavior"
   put "Launching" && pEntryA["module"]
   portal_GoStack pEntryA["module"]
end journalresume
   
   
   function Journal_makeInlineArray
   repeat with x = 1 to the paramcount step 2
      put param(x+1) into tTempA[param(x)]
   end repeat
   return tTempA
end Journal_makeInlineArray




--> Journal
-
function JournalDB
   if sID is not a number then
      _loadDatabase
   end if
   return sID
end JournalDB


--> Private
-
private command _setupDatabase
   put Journal_GetDatabasePath() into JournalDatabasePath
   if there is not a file JournalDatabasePath or the environment is "development" then
      _copyAndDecompress
   end if
   
   if sID is not a number then
      _loadDatabase
   end if
   put true into sLoaded
end _setupDatabase

private command _copyAndDecompress
   put Journal_GetCompressedFilePath() into compressedFile
   
   put the defaultfolder into tDF
   set the itemdel to "/"
   set the defaultfolder to item 1 to -2 of the effective filename of this stack
   get url ("binfile:" & compressedFile)
   put decompress(it) into url ("binfile:" & Journal_GetDatabasePath())
   set the defaultfolder to tDF
end _copyAndDecompress

private command _loadDatabase
   put Journal_GetDatabasePath() into sqliteFile
   
   get revOpenDatabase("sqlite", sqliteFile)
   if it is not a number then
      throw it
      exit to top
   else
      put it into sID
   end if
end _loadDatabase

