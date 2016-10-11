script "model_SivaSivaFiles"
--> MetaData
-
license: GPLv3
name: model_SivaSivaFiles
type: model
version: 0.1


--> Config
-
function sivasiva_GetProjectConfigurationArray pModule
   put sivasiva_GetProjectJson (pModule) into someJSON
   if someJSON is empty then return empty
   put jsonImport (someJSON) into someArray
   return someArray
end sivasiva_GetProjectConfigurationArray

function sivasiva_GetProjectJson
   put sivasiva_ProjectFolder() & "config.json" into projectConfigurationFile
   put url ("binfile:" & projectConfigurationFile) into someJSON
   return someJSON
end sivasiva_GetProjectJson

function sivasiva_GetModuleConfigurationArray pModule
   put sivasiva_GetModuleJson (pModule) into someJSON
   if someJSON is empty then return empty
   put jsonImport (someJSON) into someArray
   return someArray
end sivasiva_GetModuleConfigurationArray


--> SivaSiva | Paths
-
function sivasiva_ProjectFolder
   -- renamed from "getPathToLoaderStack"
   -- it differs from old code below in that it uses the filename of this stack
   -- and adds a trailing slash for consistency
   
   put the stack_Folder of me into projectFolder
   return projectFolder
   
   -- chekc to see if this fails, or only fails due to reference to stack "loader"
   
   --  return item 1 to -2 of the effective filename of stack "loader" -- jg: fails on mobile
   put the defaultstack into tOrigStack
   set the defaultstack to me
   put specialFolderPath ("resources") into tSourcePath -- jg: works on desktop & mobile
   set the defaultstack to tOrigStack
   return tSourcePath
end sivasiva_ProjectFolder

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


--> Deps | Project | Files
-
getprop stack_Folder
   put the effective filename of the defaultstack into stackFolder
   set the itemdelimiter to slash
   put empty into item -1 of stackFolder
   return stackFolder
end stack_Folder

function folder_ListStackPaths someFolder
   -- new version: version 8.1
   if there is not a folder someFolder then return empty
   
   put files (someFolder) into shortFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   return stackFilePaths
end folder_ListStackPaths
