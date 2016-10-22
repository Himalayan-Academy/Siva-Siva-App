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


--> Working on
-
function sivasiva_ProjectStackPath
   if the environment is "mobile" then
      put sivasiva_ProjectFolder() & "mainstack" into projectStackPath
   else
      put sivasiva_ProjectFolder() & "Siva-Siva-App.livecode" into projectStackPath
   end if
   return projectStackPath
end sivasiva_ProjectStackPath

function sivasiva_UserSettingsFile
   put sivasiva_UserSettingsFolder() & "model_SivaSivaPrefs.json" into userSettingsFile
   if there is not a file userSettingsFile then return empty
   return userSettingsFile
end sivasiva_UserSettingsFile

function sivasiva_UserSettingsFolder
   put sivasiva_ProjectFolder ("models/model_SivaSivaPrefs/") into userSettingsFolder
   return userSettingsFolder
end sivasiva_UserSettingsFolder


--> WordPuzzle | Files
-
function wordpuzzle_ListLongImageFiles
   put wordpuzzle_ImageFolder() into imageFolder
   put mobile_ListLongFiles (imageFolder, "Siva-Siva-App") into longImageFiles
   return longImageFiles
end wordpuzzle_ListLongImageFiles

function wordpuzzle_ListShortImageFiles
   put wordpuzzle_ImageFolder() into imageFolder
   -- put files (imageFolder) into shortImageFiles
   put mobile_ListShortFiles (imageFolder, "Siva-Siva-App") into shortImageFiles
   return shortImageFiles
end wordpuzzle_ListShortImageFiles

function wordpuzzle_ImageFolder -- source may change later
   -- was "getPathToImgs" -- "shared/img/bkgnds/nature/landscape/"
   put sivasiva_AssetFolder ("img/bkgnds/nature/landscape/") into imageFolder
   return imageFolder
 end wordpuzzle_ImageFolder


--> SivaSiva | Folder
-
function sivasiva_ProjectFolder pRelativeFolderPath
   put project_HomeFolder ("Siva-Siva-App") into projectFolder
   if pRelativeFolderPath is not empty then
      put pRelativeFolderPath after projectFolder
      if char -1 of projectFolder is not slash then put slash after projectFolder
   end if
   return projectFolder
end sivasiva_ProjectFolder

function project_HomeFolder homeStackName
   if the environment = "mobile" then
      put specialFolderPath ("resources") into projectHomeFolder -- jg: works on desktop & mobile
      put slash after projectHomeFolder
   else
      -- the commented out lines make the code below work on mobile
      -- put the defaultstack into oStack
      -- set the defaultstack to homeStackName
      set the itemdelimiter to slash
      put the filename of stack homeStackName into projectHomeFolder
      put empty into item -1 of projectHomeFolder
      -- set the defaultstack to oStack
   end if
   return projectHomeFolder
end project_HomeFolder

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
   
   return headerImageFile
end portal_GetHeaderImageFile


--> SivaSiva | Paths | Modules
-
function sivasiva_GetModuleStackPath moduleName
   put sivasiva_GetModuleFolder (moduleName) into moduleFolder
   put moduleFolder & moduleName & ".livecode" into tModuleToLoad
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


--> SivaSiva | Paths | Assets
-
function sivasiva_PortalImageFile shortFile
   put sivasiva_PortalImageFolder() & shortFile into portalImageFile
   return portalImageFile
end sivasiva_PortalImageFile

function sivasiva_PortalImageFolder
   put sivasiva_AssetFolder ("img/portal-screens/") into portalImageFolder
   return portalImageFolder
end sivasiva_PortalImageFolder

function sivasiva_PhotosFolder
   put sivasiva_AssetFolder ("img/photography/") into photosFolder
   return photosFolder
end sivasiva_PhotosFolder

function sivasiva_AssetFolder pRelativeFolderPath
   put sivasiva_ProjectFolder() & "assets/" into sharedAssetFolder
   if pRelativeFolderPath is not empty then put pRelativeFolderPath after sharedAssetFolder
   return sharedAssetFolder
end sivasiva_AssetFolder


--> SivaSiva | Paths | List
-
function sivasiva_ListModelShortFiles
   put sivasiva_ProjectFolder ("models/") into modelsFolder
   put mobile_ListShortFiles (modelsFolder, "Siva-Siva-App") into modelShortFiles
   return modelShortFiles
end sivasiva_ListModelShortFiles

function sivasiva_ListPhotoFolders
   put sivasiva_PhotosFolder() into photosFolder  
   put folder_ListShort (photosFolder) into photoFolderNames
   return photoFolderNames
end sivasiva_ListPhotoFolders

function sivasiva_ListModuleFolders
   put sivasiva_GetModuleRootFolder() into modulesFolder  
   put folder_ListShort (modulesFolder) into moduleNames
   return moduleNames
end sivasiva_ListModuleFolders

function sivasiva_ListStackPaths someFolder  
   put mobile_ListShortFiles (someFolder, "Siva-Siva-App") into shortFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   return stackFilePaths
end sivasiva_ListStackPaths


--> Deps
-
function mobile_ListLongFiles someFolder, homeStackName
   put mobile_ListShortFiles (someFolder, homeStackName) into shortFiles
   repeat for each line shortFile in shortFiles
      if char 1 of shortFiles is "." then next repeat
      put someFolder & shortFile & CR after longFiles
   end repeat
   delete char -1 of longFiles
   return longFiles
end mobile_ListLongFiles

function mobile_ListShortFiles someFolder, homeStackName
   -- bug: this function includes hack to fix Livecode bug on Android by setting the defaultstack
   -- requires Livecode 8.1 or greater
   if there is not a folder someFolder then return empty
   
   put the defaultstack into oStack
   set the defaultstack to homeStackName
   put files (someFolder) into shortFiles
   set the defaultstack to oStack
   return shortFiles
end mobile_ListShortFiles

function folder_ListShort rootFolder
   if there is not a folder rootFolder then return empty
   
   put the defaultfolder into oDefault
   set the defaultfolder to rootFolder
   put the folders into shortFolders
   set the defaultfolder to oDefault
   
   filter shortFolders without ".*"
   return shortFolders
end folder_ListShort

-- getprop stack_Folder
   put the effective filename of the defaultstack into stackFolder
   set the itemdelimiter to slash
   put empty into item -1 of stackFolder
   return stackFolder
end stack_Folder
