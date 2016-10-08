script "model_SivaSivaFiles"
--> MetaData
-
license: GPLv3
name: model_SivaSivaFiles
type: model
version: 0.1


--> Working on
-
function sivasiva_GetModuleConfigurationArray pModule
   put sivasiva_GetModuleJson (pModule) into someJSON
   if someJSON is empty then return empty
   put jsonImport (someJSON) into someArray
   return someArray
end sivasiva_GetModuleConfigurationArray


--> SivaSiva | Paths
-
function sivasiva_AssetFolder
   put sivasiva_ProjectFolder() & "assets/" into sharedAssetFolder
   return sharedAssetFolder
   
   constant kSHARED_ASSETS_FOLDER = "assets/" -- was "shared/assets/"
   return (getPathToLoaderStack() & "/" & kSHARED_ASSETS_FOLDER)
end sivasiva_AssetFolder


--> SivaSiva | Paths | Modules
-
function sivasiva_GetModuleJson pModule
   put sivasiva_GetModuleJsonFile (pModule) into tModuleConfigurationFile
   put url ("binfile:" & tModuleConfigurationFile) into someJSON
   return someJSON
end sivasiva_GetModuleJson

function sivasiva_GetModuleJsonFile pModule
   if pModule is empty then put the short name of me into pModule
   
   put sivasiva_GetModuleFolder (pModule) into sivasivaModuleFolder
   put sivasivaModuleFolder & pModule & ".json" into tModuleConfigurationFile
   return tModuleConfigurationFile
end sivasiva_GetModuleJsonFile

function sivasiva_GetModuleStackPath pModule
   put sivasiva_GetModuleFolder (pModule) into moduleFolder
   put moduleFolder & pModule & ".livecode" into tModuleToLoad
   return tModuleToLoad
end sivasiva_GetModuleStackPath

function sivasiva_GetModuleFolder pModule
   put sivasiva_GetModuleRootFolder() & pModule & "/" into sivasivaModuleRootFolder
   return sivasivaModuleRootFolder
end sivasiva_GetModuleFolder

function sivasiva_GetModuleRootFolder
   put sivasiva_ProjectFolder() & "modules/" into moduleRootFolder
   return moduleRootFolder
   
   -- was "getPathToModulesFolder"
   constant kMODULES_FOLDER = "modules/"
   return (getPathToLoaderStack() & "/" & kMODULES_FOLDER)
end sivasiva_GetModuleRootFolder
