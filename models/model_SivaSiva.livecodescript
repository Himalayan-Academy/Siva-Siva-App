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
