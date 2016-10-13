script "model_SivaSivaFiles"
--> MetaData
-
license: GPLv3
name: model_SivaSivaFiles
type: model
version: 0.2

/*
This model contains all the handlers we require to access any files and folders.
*/



--> Portal | Paths
-
/*
In this section we refer to images and files with their portal (module) names, and portal-link names.
This requires a look up in the siva-siva-app portal model.
*/

function portal_GetRowImageFile rowName, pSivasivaData
   if pSivaSivaData is not an array then put sivasiva_FetchData() into pSivaSivaData
   
   put pSivaSivaData ["portalRowDictionary"][rowName]["shortImagefile"] into shortFile
   put sivasiva_PortalImageFile (shortFile) into rowImageFile
   return rowImageFile
end portal_GetRowImageFile

function portal_GetHeaderImageFile moduleName, pSivasivaData
   if pSivasivaData is not an array then put sivasiva_FetchData() into pSivasivaData
   put pSivasivaData ["portalData"][moduleName] into moduleArray
   
   put moduleArray ["headerImage"] into shortFile  
   put sivasiva_PortalImageFile (shortFile) into headerImageFile
   
   if there is not a file headerImageFile then debug_MissingPortalImage headerImageFile, moduleName   -- debugging. Remove later
   return headerImageFile
end portal_GetHeaderImageFile


--> SivaSiva | Paths | Assets
-
function sivasiva_PortalImageFile shortFile
   put sivasiva_PortalImageFolder() & shortFile into portalImageFile
   return portalImageFile
end sivasiva_PortalImageFile

function sivasiva_PortalImageFolder
   put sivasiva_ProjectFolder() & "assets/img/portal-screens/" into portalImageFolder
   return portalImageFolder
end sivasiva_PortalImageFolder

function sivasiva_AssetFolder
   put sivasiva_ProjectFolder() & "assets/" into sharedAssetFolder
   return sharedAssetFolder
end sivasiva_AssetFolder


--> SivaSiva | Paths | Modules
-
function sivasiva_ListModuleFolders
   put sivasiva_GetModuleRootFolder() into modulesFolder  
   put folder_ListShort (modulesFolder) into moduleNames
   return moduleNames
end sivasiva_ListModuleFolders

function sivasiva_GetModuleStackPath moduleName
   put sivasiva_GetModuleFolder (moduleName) into moduleFolder
   put moduleFolder & pModule & ".livecode" into tModuleToLoad
   return tModuleToLoad
end sivasiva_GetModuleStackPath

function sivasiva_GetModuleFolder pModuleName
   if pModuleName is empty or pModuleName = "Siva-Siva-App" then
      -- this allows us to use the same code for modules and return the Siva-Siva-Apps config json
      return sivasiva_ProjectFolder()
   end if
   
   put sivasiva_GetModuleRootFolder() & pModuleName & "/" into sivasivaModuleRootFolder
   return sivasivaModuleRootFolder
end sivasiva_GetModuleFolder

function sivasiva_GetModuleRootFolder
   -- was "getPathToModulesFolder"
   put sivasiva_ProjectFolder() & "modules/" into moduleRootFolder
   return moduleRootFolder
end sivasiva_GetModuleRootFolder


--> Deps
-
function folder_ListShort rootFolder
   if there is not a folder rootFolder then return empty
   
   put the defaultfolder into oDefault
   set the defaultfolder to rootFolder
   put the folders into shortFolders
   set the defaultfolder to oDefault
   
   filter shortFolders without ".*"
   return shortFolders
end folder_ListShort


--> Private
-
private command debug_MissingPortalImage headerImageFile, homeModueName
   if there is not a file headerImageFile then
      put headerImageFile
      breakpoint
      put portal_GetHeaderImageFile (homeModueName) into imageFile
      set the itemdelimiter to slash
      put item 1 to -2 of headerImageFile & slash into imageFolder
      finder_Reveal imageFolder
      exit to top
   end if
end debug_MissingPortalImage
