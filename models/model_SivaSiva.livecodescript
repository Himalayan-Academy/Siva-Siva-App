script "model_SivaSiva"
--> MetaData
-
license: GPLv3
name: model_SivaSiva
type: model
version: 0.1


--> SivaSiva | Portal | Images
-
function sivasiva_GetPortalHomeLinkImage portalLinkName 
   put sivasiva_GetPortalLinkImage (portalLinkName, "home") into imageFile
   return imageFile
end sivasiva_GetPortalHomeLinkImage

function sivasiva_GetPortalImage moduleName, pReturnRelative
   put sivasiva_GetModuleArray (moduleName) into moduleArray
   if moduleArray is not an array then return hack_FindPortalImage (moduleName) -- legacy hack
   
   put moduleArray ["portalImage"] into relativeImage
   if pReturnRelative is true then return relativeImage
   
   put moduleArray ["moduleFolder"] into moduleFolder
   put moduleFolder & relativeImage into imageFile
   return imageFile
end sivasiva_GetPortalImage

function sivasiva_GetPortalLinkImage portalLinkName, moduleName, pReturnRelative, pSivaSivaData
   if pSivaSivaData is not an array then put sivasiva_FetchData() into pSivaSivaData
   if pSivaSivaData is not an array then return hack_GetPortalLinkImage (portalLinkName, moduleName, pReturnRelative) -- legacy hack
   
   sivasiva_SetPortalLinkInfo portalLinkName, moduleName, pSivaSivaData, iconText, relativeImagefile, moduleFolder
   if pReturnRelative is true then
      return relativeImagefile
   else
      put moduleFolder & relativeImagefile into imageFile
      return imageFile
   end if 
end sivasiva_GetPortalLinkImage

function sivasiva_GetModuleFolderFromArray moduleName, pSivaSivaData
   if pSivaSivaData is not an array then put sivasiva_FetchData() into pSivaSivaData
   put sivaSivaData ["module"][moduleName] into moduleArray
   put moduleArray ["moduleFolder"] into moduleFolder
end sivasiva_GetModuleFolderFromArray

command sivasiva_SetPortalLinkInfo portalLinkName, moduleName, sivaSivaData, @iconText, @relativeImagefile, @moduleFolder
   put sivaSivaData ["sectionDictionary"] into sectionDictionaryArray
   
   put sectionDictionaryArray [moduleName][portalLinkName] into portalLinkArray
   put portalLinkArray ["image"] into relativeImagefile
   put portalLinkArray ["text"] into iconText
   
   put sivaSivaData ["module"][moduleName] into moduleArray
   put moduleArray ["moduleFolder"] into moduleFolder
end sivasiva_SetPortalLinkInfo


--> SivaSiva | Module | List
-
function sivasiva_ListHomeLinks
   return sivasiva_ListPortalLinks ("home")
end sivasiva_ListHomeLinks

function sivasiva_ListPortalLinks moduleName
   put sivasiva_GetModuleArray (moduleName) into moduleArray
   if moduleArray is not an array then return hack_ListPortalLinks (moduleName) -- legacy hack
   
   put moduleArray ["rowData"] into rowData
   put item 2 of the extents of rowData into maxNum
   repeat with keyNum = 1 to maxNum
      put rowData [keyNum]["portalLinkName"] into portalLinkName
      put portalLinkName & CR after orderedPortalLinkNames
   end repeat
   delete char -1 of orderedPortalLinkNames
   return orderedPortalLinkNames
end sivasiva_ListPortalLinks

function sivasiva_ListModules pListHow
   switch pListHow
      case "folders"
         put getPathToModulesFolder() into modulesFolder
         put folder_ListShort (modulesFolder) into moduleNames
         break
      default
         put sivasiva_FetchData() into sivasivaData
         put sivasivaData ["module"] into sivasivaModuleData
         put keys (sivasivaModuleData) into moduleNames
         sort moduleNames
   end switch
   return moduleNames
end sivasiva_ListModules


--> SivaSiva | Model
-
function sivasiva_GetRowData rowName, pSivaSectionArray
   if pSivaSectionArray is not an array then put sivasiva_FetchData() into sivasivaData
   set the itemdelimiter to "_"
   put item 1 of rowName into moduleName
   put item 2 of rowName into portalLinkName
   
   put sivasivaData ["module"][moduleName]["moduleFolder"] into moduleFolder
   put sivasivaData ["sectionDictionary"][moduleName][portalLinkName] into rowData
   put moduleFolder into rowData ["moduleFolder"]
   
   return rowData
end sivasiva_GetRowData

function sivasiva_GetModuleArray moduleName, pSivaSectionArray
   if pSivaSectionArray is not an array then put sivasiva_FetchData() into sivasivaData
   put sivasivaData ["module"][moduleName] into moduleArray
   return moduleArray
end sivasiva_GetModuleArray

function sivasiva_GetSectionDictionary moduleName, pSivaSectionArray
   if pSivaSectionArray is not an array then put sivasiva_FetchData() into sivasivaData
   put sivasivaData ["sectionDictionary"] into sectionDictionaryArray
   return sectionDictionaryArray
end sivasiva_GetSectionDictionary


--> SivaSiva | Model
-
function sivasiva_FetchData
   -- "Enhanced Configuration,SivaSiva JSON"
   put the model_Array ["TraitsSection"] of stack "model_SivaSiva" into sivaSectionArray
   return sivaSectionArray
end sivasiva_FetchData

command sivasiva_StoreData sivaSectionArray
   set the model_Array ["TraitsSection"] of stack "model_SivaSiva" to sivaSectionArray
end sivasiva_StoreData
