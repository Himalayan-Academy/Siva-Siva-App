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
function project_ListFolderStacks shortFolder
   put sivasiva_ConstructFolder (shortFolder) into standardFolder
   put sivasiva_ListStackPaths (standardFolder) into stackPaths
   return stackPaths
end project_ListFolderStacks

function sivasiva_ConstructFolder shortFolder
   put sivasiva_ProjectFolder() into projectFolder
   put projectFolder & shortFolder & slash into standardFolder
   return standardFolder
end sivasiva_ConstructFolder

function sivasiva_ListStackPaths someFolder  
   put mobile_ListShortFiles (someFolder) into shortFiles
   put stack_PathsFromShortFiles (shortFiles, someFolder) into stackFilePaths
   return stackFilePaths
end sivasiva_ListStackPaths

function stack_PathsFromShortFiles shortFiles, someFolder
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   return stackFilePaths
end stack_PathsFromShortFiles

function mobile_ListShortFiles someFolder
   -- bug: does not work on Android, despite fix Livecode bug on Android by setting the defaultstack on 8.1.2 rc2
   -- requires Livecode 8.1 or greater
   
   if there is not a folder someFolder then return empty
   put the defaultstack into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   set the defaultfolder to oFolder
   
   return shortFiles
   
   -- no longer working on Android with LC 8.2 rc@
   put the defaultstack into oStack
   set the defaultstack to homeStackName
   -- put files (someFolder) into shortFiles
   put the files into shortFiles
   set the defaultstack to oStack
   return shortFiles
end mobile_ListShortFiles

function mobile_ListLongFiles someFolder, homeStackName
   put mobile_ListShortFiles (someFolder, homeStackName) into shortFiles
   repeat for each line shortFile in shortFiles
      if char 1 of shortFiles is "." then next repeat
      put someFolder & shortFile & CR after longFiles
   end repeat
   delete char -1 of longFiles
   return longFiles
end mobile_ListLongFiles

function folder_ListShort rootFolder
   if there is not a folder rootFolder then return empty
   
   put the defaultfolder into oDefault
   set the defaultfolder to rootFolder
   put the folders into shortFolders
   set the defaultfolder to oDefault
   
   filter shortFolders without ".*"
   return shortFolders
end folder_ListShort


--> SivaSiva | Project | Files
-
function sivasiva_ProjectStackPath
   -- project home stacks are given a different short file name "mainstack" during standlaone building
   if the environment is "mobile" then
      put sivasiva_ProjectFolder() & "mainstack" into projectStackPath
   else
      put sivasiva_ProjectFolder() & "Siva-Siva-App.livecode" into projectStackPath
   end if
   return projectStackPath
end sivasiva_ProjectStackPath

function sivasiva_ProjectFolder pRelativeFolderPath
   if there is a stack "Siva-Siva-App" then 
      put project_HomeFolder ("Siva-Siva-App") into projectFolder
   else
      put project_HomeFolder ("lib_SivaSivaRoot") into projectFolder
   end if
   if pRelativeFolderPath is not empty then
      put pRelativeFolderPath after projectFolder
      if char -1 of projectFolder is not slash then put slash after projectFolder
   end if
   return projectFolder
end sivasiva_ProjectFolder

function project_HomeFolder
   if the environment = "mobile" then
      put specialFolderPath ("resources") into projectHomeFolder -- jg: works on desktop & mobile
      put slash after projectHomeFolder
   else
      set the itemdelimiter to slash
      put the filename of stack "Siva-Siva-App" into projectHomeFolder
      put empty into item -1 of projectHomeFolder
   end if
   return projectHomeFolder
end project_HomeFolder


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


--> Working on | Ensure writeable on mobile
-
function sivasiva_UserSettingsFile
   put sivasiva_UserSettingsFolder() & "model_SivaSivaPrefs.json" into userSettingsFile
   if there is not a file userSettingsFile then return empty
   return userSettingsFile
end sivasiva_UserSettingsFile

function sivasiva_UserSettingsFolder
   put sivasiva_ProjectFolder ("models/model_SivaSivaPrefs/") into userSettingsFolder
   return userSettingsFolder
end sivasiva_UserSettingsFolder


--> SivaSiva | Paths | Assets
-
function sivasiva_PortalImageFile shortFile, pReturnRelative
   return "assets/img/portal-screens/" & shortFile
   
   if pReturnRelative is true then
      -- ../../assets/img/portal-screens/thumb_surprise_boy-suitcase.jpg
      -- hard wired to the location of sivasivahome and the shared assets folder
      -- rather than working out the relative file with a script (for now)
      return "../../assets/img/portal-screens/" & shortFile
   else
      put sivasiva_PortalImageFolder() & shortFile into portalImageFile
   end if
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


--> SivaSiva | Asset | Folders
-
function sivasiva_AssetFolder  pRelativeFolderPath
   put sivasiva_ProjectFolder() & "assets/" into sharedAssetFolder
   if pRelativeFolderPath is not empty then put pRelativeFolderPath after sharedAssetFolder
   return sharedAssetFolder
end sivasiva_AssetFolder

function sivasiva_AssetFolder
   put sivasiva_GetProjectFolder() into projectFolder
   put asset_GetFolder (projectFolder) into sivasivaAssetFolder
   return sivasivaAssetFolder
end sivasiva_AssetFolder

function asset_GetFolder projectFolder, pShortAssetFolder
   put "assets/" into subFolderPath
   if pShortAssetFolder is not empty then
      text_AddTrailing pShortAssetFolder, slash
      put pShortAssetFolder after subFolderPath
   end if
   put projectFolder & subFolderPath into assetFolder
   folder_CreateNested assetFolder
   return assetFolder
end asset_GetFolder


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

function sivasiva_ListAssetsFolders
   put specialFolderPath("resources") & "/assets" into tAppAssetsFolder
   put folders(tAppAssetsFolder) into assetsFolders
   filter assetsFolders without ".."
   return assetsFolders
end sivasiva_ListAssetsFolders

function sivasiva_ListModuleFolders
   put specialFolderPath("resources") & "/modules" into tAppPkgModules
   put folders(tAppPkgModules) into moduleNames
   filter moduleNames without ".."
   return moduleNames
end sivasiva_ListModuleFolders

command check_CreateFolder pTargetFolder
   if there is a folder (pTargetFolder) then 
       # do nothing
      else
        create folder pTargetFolder
      end if   
   end check_CreateFolder
   


command checkFilesModelIsInUse
   answer "Yes File Model here!" with "OK"
end checkFilesModelIsInUse
