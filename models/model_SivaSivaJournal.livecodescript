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
on librarystack,journalDB
   -- best not to place this here as it will get called every time
   if the long id of the target is not the long id of me then
      pass librarystack
   end if
   
   if sLoaded is not true then
      _setupDatabase
   end if
   
end librarystack



function Journal_GetCompressedFilePath
   local JournalCompressedFilePath
   put Journal_GetModelFolder() & "journal.sqlite.gz" into JournalCompressedFilePath
   return JournalCompressedFilePath
end Journal_GetCompressedFilePath

function Journal_GetModelFolder
   local JournalModelFolder,modelName
   set the itemdelimiter to slash
   put the filename of me into JournalModelFolder
   put the short name of me into modelName
   put modelName into item -1 of JournalModelFolder
   put slash after JournalModelFolder
   return JournalModelFolder
end Journal_GetModelFolder

function journal_convertDate pDateTime
   local tCurr12HrTime,tHasTime,tDate,tTime,tYear,tMonth,tDay
   -- YYYY-MM-DD HH:MM
   -- pDateTime could be a date only, or a date and time, so check first
   -- from: https://sonsothunder.com/devres/livecode/tips/data005.htm
   put the twelvehourtime into tCurr12HrTime
   set the twelvehourtime to false
   if ":" is not in pDateTime then
      put false into tHasTime
      put pDateTime into tDate
      convert tDate to long date
   else
      put true into tHasTime
      put word 1 of pDateTime into tDate
      convert tDate to long date
      put word 2 to 3 of pDateTime into tTime
      convert tTime to long time
      set the itemDel to ":" 
      if  length(item 1 of tTime)=1 then
         put "0" before tTime
      end if
   end if
   put last word of tDate into tYear
   convert tDate to short date
   set the itemDel to "/"
   put item 1 of tDate into tMonth
   put item 2 of tDate into tDay
   if tMonth < 10 then put 0 before tMonth
   if tDay < 10 then put 0 before tDay
   set the twelvehourtime to tCurr12HrTime
   put tYear & "-" & tMonth & "-" & tDay into tDate
   if tHasTime then
      return (tDate && tTime)
   else
      return tDate
   end if
end journal_convertDate

function Journal_GetDatabasePath
      return path_Documents() & "journal.sqlite"
end Journal_GetDatabasePath

--> Journal | Activities

---------------------------------------------------------------------------------------
-- Journal_RecordEntry
-- DESCRIPTION
--         add a journal entry to the journal.sqlite dbase
-- PARAMETERS
--  required:
--         pModule:  must be the short name of a livecode binary stack
--         pLabel: This appears as the main entry string in the journal, In large bold type
--                          use a short phrase that indicates
--                          what the activity is.
--         pData this an array   -- You must pass this, even if empty
-- Some important pData array key conventions
-- "weburl" is used to pass the URL that is based back on resume to the view_SivaSivaBrowser
--    optional:  pTags - any string, but comma separated single words of phrase by convention. see some examples.
--                        pImage- not yet implements TBD   BR: What does this do?    what value? path to file on disk?
--CHANGES
--         2017-04-01: Andre - Created
---------------------------------------------------------------------------------------


command Journal_RecordEntry pModule, pLabel, pData, pTags, pImage
   local tTempA,tResult,tDataA
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
   
   -- fix encodings
   put textEncode(tDataA["label"], "UTF8") into tDataA["label"]
   put textEncode(tDataA["data"], "UTF8") into tDataA["data"]
   put textEncode(tDataA["tags"], "UTF8") into tDataA["tags"]
   
   
   put journal_convertDate(the date && the time) into tDataA["date"]
   
   put dbInsert("journal", tDataA, JournalDB()) into tResult
   --ntInfo "saving journal entry for" && pModule
   return tResult
end Journal_RecordEntry

command Journal_SetFavoriteFlag pEntryID, pValue
   local tResult,tDataA
   if pValue is not a number then
      if pValue then
         put 1 into tDataA["is_favorite"]
      else
         put 0 into tDataA["is_favorite"]
      end if
   else
      put pValue into tDataA["is_favorite"]
   end if
   
   dbWhere "journal_id", pEntryID
   put dbUpdate("journal", tDataA, journalDB()) into tResult
   return tResult
end Journal_SetFavoriteFlag

command Journal_DeleteEntry pEntryID
   local tResult
   if pEntryID is not a number then
      return "error, id not a number"
   end if
   dbWhere "journal_id", pEntryID
   put dbDelete("journal", journalDB()) into tResult
   return tResult
end Journal_DeleteEntry

function Journal_GetEntriesForModule pModule, pOffset
   local tEntriesA
   if pOffset is empty then
      dbLimit 100
   else
      dbLimit 100, pOffset
   end if
   
   dbLike "module", pModule
   put dbGet("journal", JournalDB()) into tEntriesA
   return tEntriesA
end Journal_GetEntriesForModule

function Journal_GetEntriesForDate pStartDate, pEndDate, pOffset
   local tEntriesA
   if pOffset is empty then
      dbLimit 100
   else
      dbLimit 100, pOffset
   end if
   //todo: dbwhere for the dates
   put dbGet("journal", JournalDB()) into tEntriesA
   return tEntriesA
end Journal_GetEntriesForDate

function Journal_GetEntries pOffset
   local  tEntriesA
   if pOffset is empty then
      dbLimit 100
   else
      dbLimit 100, pOffset
   end if
   dbOrderBy "journal_id DESC"
   --dbOrderBy "date DESC"
   put dbGet("journal", JournalDB()) into tEntriesA
   return tEntriesA
end Journal_GetEntries

-------------------------------------------
-- Journal_LaunchEntry
-- created 2017-04-15: Andre Garzia
-- Mod: 2017-05-15 Brahmanathaswami (added these comments)
-- DESCRIPTION:
-- This command fetches data from the joural.sqlite dbase.
-- tEntriesA arracy contains the values of all columns, 1 per key
-- These are: 1: journal_id; 2:module;3:data (a json object contain whatever the developer wants  to pass;
-- 4:date [2017-05-15 04:44:00]; 5:tags (text string); 6 :image (not implemented yet);
-- 7: is_favorite: integer (usage TBD); 8:comments (aka "notes")
-- 9:label (appears on journal list)
-- tDataA contains the name value pairs pass by the developer of the module
-- to be used as needed on journalResume.
-- use any value in tEntryA or tDataA  to trigger custom actions when resuming the module
----------------------------------------------


command Journal_LaunchEntry pEntryID,pModule,pData
   local tEntriesA,tEntryA,tDataA
   # if we need to get the data from the data base, pEntryID has value
   # pModule and pData are empty
   # if you already have data, the pEntryID is empty
   # and we have last to param, pModule and pData already.
   
   if pEntryID <> empty then
      dbWhere "journal_id", pEntryID
      put dbGet("journal", JournalDB()) into tEntriesA
      if the keys of tEntriesA[1] is empty then
         return "journalerr, no such entry"
      end if
      put tEntriesA[1] into tEntryA
   else
      put pModule into tEntryA["module"]
      put pData into tEntryA["data"]
   end if
   
   try
      put jsonimport(tEntryA["data"]) into tDataA
   catch n
      return "journalerr, data is corrupted"
   end try
   put tEntryA["module"] into pData["returnTo"]
   tracking_RecordActivity "Journal","resume/activity", pData
   
   --ntInfo "resuming journal activity for" && tEntryA["module"]
   portal_GoStack tEntryA["module"]
   dispatch "journalresume" to stack tEntryA["module"] with tDataA, tEntryA
   if it is among the items of "unhandled,passed" then
      return "journalerr, no module could handle this activity"
   end if
   
end Journal_LaunchEntry

on journalresume pDataA, pEntryA
   put "Error: no one could handle journalresume, going for the default behavior"
   --put "Launching" && pEntryA["module"]
   portal_GoStack pEntryA["module"]
end journalresume


function Journal_makeInlineArray
   local tTempA
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
   local JournalDatabasePath
   put Journal_GetDatabasePath() into JournalDatabasePath
   if there is not a file JournalDatabasePath then  --or the environment is "development" then
      _copyAndDecompress
   end if
   
   if sID is not a number then
      _loadDatabase
   end if
   put true into sLoaded
end _setupDatabase

private command _copyAndDecompress
   local  compressedFile,tDF
   put Journal_GetCompressedFilePath() into compressedFile
   
   put the defaultfolder into tDF
   set the itemdel to "/"
   set the defaultfolder to item 1 to -2 of the effective filename of this stack
   get url ("binfile:" & compressedFile)
   put decompress(it) into url ("binfile:" & Journal_GetDatabasePath())
   set the defaultfolder to tDF
end _copyAndDecompress

private command _loadDatabase
   local sqliteFile
   put Journal_GetDatabasePath() into sqliteFile
   
   get revOpenDatabase("sqlite", sqliteFile)
   if it is not a number then
      throw it
      exit to top
   else
      put it into sID
   end if
end _loadDatabase
