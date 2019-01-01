script "model_SivaSiva"
--> MetaData
-
license: GPLv3
name: model_SivaSiva
type: model
version: 0.2

/*
The SivaSiva model is an enhanced version of the older config.json model structure.
The array is stored in a file "Siva-Siva-App/models/model_SivaSiva/model_SivaSiva.array"
or later the equivalent "model_SivaSiva.json" file

Currently working on standardising the model handlers used here in "model_Library"
*/

--> Variables
-
local LocalArray,sSQLQueriesA


--> Working on


--> SivaSiva | Model




####################################
-- the following David "too complex" models, 
--above are much simpler model to the save the same information.

on libraryStack

# instead of stories SQL queries as custom Props of various stack or card.
#  a single text file stores on SQL queries we need in app.
# the way we can easily on them, create more and use them
# They are loaded into an array on startup sSQLQueriesA

   loadSQLQueries  
end libraryStack

function sivasiva_FetchData
   put "model_SivaSiva" into stackName
   put stackName & ".json" into shortFile-- could use ".array"
   put the model_Array [shortFile] of stack stackName into sivasivaData
   return sivasivaData
end sivasiva_FetchData

command sivasiva_StoreData sivasivaData
   sivasiva_SetCached sivasivaData -- to keep cache in sync

   put "model_SivaSiva" into stackName
   put stackName & ".json" into shortFile -- could use ".array"
   set the model_Array [shortFile] of stack stackName to sivasivaData
   return the result
end sivasiva_StoreData

function sivasiva_DataFile
   put "model_SivaSiva" into stackName
   put stackName & ".json" into shortFile -- could use ".array"
   put the model_DataFile [shortFile] of stack stackName into modelDataFile
   return modelDataFile
end sivasiva_DataFile


--> SivaSiva | Model | Cache
-
getprop use_SivaSivaCache
   return LocalArray ["useSivaSivaCache"] is not false  
   # BR Apr 9, 2017 never use cached data for now
end use_SivaSivaCache

setprop use_SivaSivaCache someBooelan
   put someBooelan into LocalArray ["useSivaSivaCache"]
end use_SivaSivaCache

command sivasiva_FetchOrGetCached @sivasivaData
   put the use_SivaSivaCache of me into useCache
   if useCache is false then return sivasiva_FetchData() -- useful in development

   if sivasivaData is not an array then
      put LocalArray ["sivasivaData"] into sivasivaData
      if sivasivaData is not an array then
         sivasiva_LoadCachedData
         put the result into sivasivaData
      end if
   end if
end sivasiva_FetchOrGetCached

command sivasiva_SetCached sivasivaData
   put sivasivaData into LocalArray ["sivasivaData"]
end sivasiva_SetCached

command sivasiva_LoadCachedData
   put sivasiva_FetchData() into sivasivaData
   sivasiva_SetCached sivasivaData
   return sivasivaData
end sivasiva_LoadCachedData

command sivasiva_ClearCachedData
   delete variable LocalArray ["sivasivaData"]
end sivasiva_ClearCachedData

function getTargetOwnerSegs
   # expects the long ID of a control
   put the long owner of the target into tOwner
   split tOwner with " of "
   put the keys of tOwner into tKeys
   sort tKeys ascending numeric
   repeat for each line x in tKeys
      put the short name of tOwner[x] & comma after tSegs
   end repeat
   delete char -1 of tSegs
   return tSegs
   # item 1 will be  the name of the target control
   # item -1 =  the stack name
   # item -2- the card name
   # Other keys in between will be group names.   
end getTargetOwnerSegs

########### Models 

command loadSQLQueries
   put path_Models() & "sqlQueries.txt" into tURL
   put URL ("file:/"&tURL) into tSqlQueries
   set the itemdelimiter to "|"
   put 0 into y
   repeat for each item x in tSqlQueries
      add 1 to y
      put line 2 of x into sSQLQueriesA[y][queryName]
      put line 4 to  -1 of x into  sSQLQueriesA[y][sqlQuery]
   end repeat
end loadSQLQueries

function getSQLQueries
   return sSQLQueriesA
end getSQLQueries




--> Model | Library
-
/*
Handlers below from "model_Library"
Not all required (so prune before release).
*/

getprop model_Names
   put the stack_Name of the target into modelStackName
   put the project_Folder of the target into projectFolder
   put model_ListNames (modelStackName, projectFolder) into shortFiles
   return shortFiles
end model_Names

function model_ListNames modelStackName, projectFolder
   put projectFolder & "models/" & modelStackName & slash into modelDataFolder
   put folder_ListShortFiles (modelDataFolder) into shortFiles
   return shortFiles
end model_ListNames

function model_ListModelFiles pListShort
   put lcw_ArrayFolder() into libraryArrayFolder
   put files (libraryArrayFolder) into shortFiles
   filter shortFiles with "*.array"
   if pListShort is true then
      return shortFiles
   else
      put file_AddFolderToPaths (shortFiles, libraryArrayFolder) into filePaths
      return filePaths
   end if
end model_ListModelFiles


--> Model | Array | Props
-
getprop model_Array [pShortFile]
   -- assumes the target is a model stack
   put the model_DataFile [pShortFile] of the target into modelDataFile
   put array_FetchModel (modelDataFile) into modelArray
   return modelArray
end model_Array

setprop model_Array [pShortFile] dataArray
   -- assumes the target is a model stack
   put the model_DataFile [pShortFile] of the target into modelDataFile
   array_SaveModel modelDataFile, dataArray
   return modelDataFile
end model_Array


--> Model | Array
-
function model_FetchArray modelStackName, projectFolder, pShortFile
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelArrayFile
   put array_FetchModel (modelArrayFile) into modelArray
   return modelArray
end model_FetchArray

command model_StoreArray modelStackName, projectFolder, modelArray, pShortFile
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelArrayFile
   array_SaveModel modelArrayFile, modelArray
   return modelArrayFile
end model_StoreArray


--> Model | Data Folder
-
function model_GetDataFolder modelStackName, projectFolder
   put project_ConstructFolder ("models", projectFolder) into rootModelsFolder
   put rootModelsFolder & modelStackName & slash into modelDataFolder
   return modelDataFolder
end model_GetDataFolder

getprop model_DataFolder [modelStackName]
   if modelStackName is empty then
      -- we assume the target is a model stack in the "models/" folder
      -- simple utitlity that looks for a sister folder to any stack
      put the stack_Name of the target into modelName
      put the stack_Folder of the target into stackFolder
      put stackFolder & modelName & slash into modelDataFolder
   else
      -- will search for the model data folder in the "models/" folder of the project the target stack is in
      put the project_Folder of the target into projectFolder
      put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   end if
   return modelDataFolder
end model_DataFolder


--> Model | Data File
-
getprop model_DataFile [pShortFile]
   -- assumes the target is a model stack
   put the stack_Name of the target into modelStackName
   put the stack_Folder of the target into stackFolder
   put stackFolder & modelStackName & slash into modelDataFolder

   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_DataFile

function model_GetDataFile modelStackName, projectFolder, pShortFile
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_GetDataFile


--> Array | Model
-
/*
Modified versions of "array_Fetch" and "array_Save"
Allows storing mmodels as json or other formats based on their file extensions.

The aim is to standarize different ways in which arrays can be stored and fetched,
in order to make it easier to switch models from simple text files, json files, encoded arrays or databases.
*/

function array_FetchModel someFile
   -- allows for simple switching of models
   put url ("binfile:" & someFile) into someData
   if someData is empty then return empty
   set the itemdelimiter to "."
   switch item -1 of someFile
      case "json"
         put jsonImport (someData) into modelArray
         break
      case "array"
         put arraydecode (someData) into modelArray
         break
      default
         -- here we can return an array from a database
         -- someFile could contain items used in a query
         -- or even an sql query
   end switch
   return modelArray
end array_FetchModel

command array_SaveModel someFile, modelArray
   if modelArray is not an array then delete file someFile
   set the itemdelimiter to "."
   switch item -1 of someFile
      case "json"
         put jsonExport (modelArray) into encodedData
         break
      default -- case "array"
         put arrayencode (modelArray) into encodedData
         break
   end switch
   put encodedData into url ("binfile:" & someFile)
end array_SaveModel


--> Private
-
private function dataFolder_GetFile modelDataFolder, pShortFile
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of modelDataFolder into modelName
      put modelName & ".array" into pShortFile
   end if
   put modelDataFolder & pShortFile into modelDataFile
   return modelDataFile
end dataFolder_GetFile


--> Deps
-
getprop stack_Name
   return the short name of the defaultstack
end stack_Name

getprop stack_Object
   return the defaultstack
end stack_Object

getprop stack_Folder
   put the effective filename of the defaultstack into stackFolder
   set the itemdelimiter to slash
   put empty into item -1 of stackFolder
   return stackFolder
end stack_Folder


