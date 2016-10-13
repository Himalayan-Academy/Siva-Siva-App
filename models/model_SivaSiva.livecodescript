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
*/


--> Working on
-
function portal_ListRowNames portalName, pSivaSectionArray
   put portal_GetArray (portalName, pSivasivaData) into   moduleArray
   put moduleArray ["rowData"] into rowData
   put item 2 of the extents of rowData into maxNum
   repeat with keyNum = 1 to maxNum
      put rowData [keyNum]["rowName"] into portalLinkName
      put portalLinkName & CR after orderedPortalLinkNames
   end repeat
   delete char -1 of orderedPortalLinkNames
   return orderedPortalLinkNames
end portal_ListRowNames

function portal_GetArray portalName, pSivasivaData
   if pSivasivaData is not an array then put sivasiva_FetchData() into pSivasivaData
   put pSivasivaData ["portalData"][portalName] into portalArray
   return portalArray
end portal_GetArray

function portal_GetRowData rowName, pSivasivaData
   if pSivasivaData is not an array then put sivasiva_FetchData() into pSivasivaData
   put pSivasivaData ["portalRowDictionary"] into portalRowDictionary
   put portalRowDictionary [rowName] into rowData
   return rowData
end portal_GetRowData


--> SivaSiva | Model
-
function sivasiva_FetchData
   put "model_SivaSiva" into stackName
   put stackName & ".json" into shortFile-- could use ".array"
   put the model_Array [shortFile] of stack stackName into sivasivaData
   return sivasivaData
end sivasiva_FetchData

command sivasiva_StoreData sivasivaData
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


--> SivaSiva | Module | List
-
function sivasiva_ListHomeLinks
   return portal_ListRowNames ("home")
end sivasiva_ListHomeLinks

function sivasiva_ListPortals pListHow
   switch pListHow
      case "folders"
         -- will not return portal names if we have other types of "module" in the "modules" folder
         put sivasiva_ListModuleFolders() into moduleNames
         break
      default
         put sivasiva_FetchData() into sivasivaData
         put sivasivaData ["portalData"] into portalData
         put keys (portalData) into moduleNames
         sort moduleNames
   end switch
   return moduleNames
end sivasiva_ListPortals


--> Project | Model | Array
-
/*
These handlers can be in a separate model library.

Convenience handlers that uses a simple naming convention.
in which a folder placed at the same level of a stack and named the smae as the short name of a stack 
contains any number of named data files.

The default model_DataFile of a stack "model_SivaSiva" in a path of the form /path/to/model_SivaSiva.livecode
for instance would be a /path/to/model_SivaSiva/model_SivaSiva.array

You can give alternative names by passing the param pShortFile. So
- the model_Array ["test.array"] of stack "model_SivaSiva" would get or store an array in the file "/path/to/model_SivaSiva/test.array"
*/

getprop model_Array [pShortFile]
   put the model_DataFile [pShortFile] of the target into modelDataFile
   put array_Fetch (modelDataFile) into modelArray
   return modelArray
end model_Array

setprop model_Array [pShortFile] dataArray
   put the model_DataFile [pShortFile] of the target into modelDataFile
   array_Save modelDataFile, dataArray
   return modelDataFile
end model_Array

getprop model_DataFile [pShortFile]
   put the stack_Name of the target into modelName
   put the stack_Folder of the target into stackFolder
   put stackFolder & modelName & slash into modelDataFolder
   
   if pShortFile is empty then put modelName & ".array" into pShortFile
   put modelDataFolder & pShortFile into modelDataFile
   return modelDataFile
end model_DataFile

getprop model_DataFolder
   put the stack_Name of the target into modelName
   put the stack_Folder of the target into stackFolder
   put stackFolder & modelName & slash into modelDataFolder
   return modelDataFolder
end model_DataFolder

function array_Fetch someFile
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
end array_Fetch

command array_Save someFile, modelArray
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
end array_Save
