script "lib_SivaSivaLegacy"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaLegacy
type: library
version: 0.1

/*
I believe non of these handlers are being used any more after refactoring?
*/


--> Variables
-
global sConfigA


--> Legacy | Paths
-
function getPathToModulesFolder
   -- legacy shim in case any scripts are still using this   
   put sivasiva_GetModuleRootFolder() into moduleRootFolder
   delete char -1 of moduleRootFolder
   return moduleRootFolder
end getPathToModulesFolder

function getPathToLoaderStack
   -- legacy shim in case any scripts are still using this
   put sivasiva_ProjectFolder() into tSourcePath
   delete char -1 of tSourcePath -- slash
   return tSourcePath
end getPathToLoaderStack

function getPathToSharedAssetsFolder
   -- legacy shim in case any scripts are still using this
   return sivasiva_AssetFolder()
end getPathToSharedAssetsFolder

function project_DocumentsFolder
   -- works cross platform
   -- put specialFolderPath ("documents") into docFolder
   put the documents folder into docFolder
   put "/" after docFolder
   return docFolder
end project_DocumentsFolder

function localPath  --###jg: will fail on desktop if loader stack isn't the defaultstack; ok on mobile
   -- legacy shim in case any scripts are still using this
   breakpoint
   return mobile_HomeFolder()
end localPath

function documentsPath
   -- legacy shim in case any scripts are still using this
   breakpoint
   return project_DocumentsFolder()
end documentsPath

function getPathForSharedLibraries
   -- not used by anything   
   breakpoint
   
   constant kSHARED_LIBS_FOLDER = "libraries/" -- was "shared/libs/"
   return sivasiva_ProjectFolder() & kSHARED_LIBS_FOLDER
   
   -- return (getPathToLoaderStack() & "/" & kSHARED_LIBS_FOLDER)
end getPathForSharedLibraries


--> Legacy | Config
-
/*
These utility handlers are not required in the "loading script" of the projects home stack.
Consider moving them to a project library.

Also consider renaming them to give them a unique prefix to avaoid any possible clash with any other libraries or developer tools.
*/

function getConfiguration pKey
   -- not used ???
   return sConfigA [pKey]
end getConfiguration

function getModuleConfiguration pModule
   return sConfigA ["modules"][pModule]
end getModuleConfiguration

command loadModuleConfiguration pModule, pData
   put pData into sConfigA ["modules"][pModule]
end loadModuleConfiguration


--> Legacy | Utils
-
function dev -- Thanks to Jacqueline Landman Gay @ HyperActive Software for this one.
  return the environment is "development"
end dev

function isMobile -- jg, for convenience
  return the environment is "mobile"
end isMobile

command setBasePath
   set the defaultfolder to sivasiva_ProjectFolder()
end setBasePath


--> Legacy | API 
-
command goHome
   -- log_Info _goLaunchModule ..."
   put getConfiguration ("launch_module") into homeModule
   portal_Link "home"
end goHome

command loadModule pModule
   log_Info "Loading module:" && pModule
   module_LoadConfiguration pModule
   portal_Link pModule
end loadModule

command module_LoadConfiguration pModule
   -- put (getPathToModulesFolder() & pModule & "/" & pModule & ".json") into moduleJsonFile
   put sivasiva_GetModuleJsonFile (pModule) into moduleJsonFile
   
   // check and load configuration
   if there is a file moduleJsonFile then
      get url ("binfile:" & moduleJsonFile)
      loadModuleConfiguration pModule, jsonImport(it)
      log_Info "loadModuleConfiguration"
   end if
end module_LoadConfiguration

command initializeInterfaceDefaults pOrientation -- mobile orientation setup
   /*
   Currently sent in viewer preOpenStack and currenlty by all "portal" stack cards and the hap media viewers (browser) stacks.
   Possibly better to initialisations scripts at the card layer (as a behavior)
   */
   sivasiva_InitOrientation pOrientation
end initializeInterfaceDefaults


--> Legacy | DTB
-
command sivasiva_DisplayHomePortalLink rowName, pSivaSectionArray
   sivasiva_DisplayPortalLink rowName, moduleName, pSivaSectionArray
   return the result
end sivasiva_DisplayHomePortalLink

command sivasiva_DisplayPortalLink rowName, moduleName, pSivaSivaData
   if pSivaSivaData is not an array then put sivasiva_FetchData() into pSivaSivaData
   put view_GetTemplateObject ("View|SivaSiva|Contents|Row") into rowTemplate
   
   sivasiva_SetPortalLinkInfo rowName, moduleName, pSivaSivaData, iconText, relativeImagefile, moduleFolder
  
   -- put moduleFolder & relativeImagefile into imageFile
   set the itemdelimiter to slash
   put item -1 of relativeImagefile into shortFile
   put sivasiva_PortalImageFile (shortFile) into imageFile
   
   if there is a file imageFile then
      set the image_File of rowTemplate to imageFile
   else
      put imageFile
      breakpoint
   end if
   set the title_Text of rowTemplate to iconText
   object_GoTo rowTemplate
   
   return pSivaSivaData
end sivasiva_DisplayPortalLink

command sivasiva_SetPortalLinkInfo rowName, sivaSivaData, @imageText, @shortImagefile
   put sivaSivaData ["portalRowDictionary"] into portalRowDictionary   
   put portalRowDictionary [rowName]["shortImagefile"] into shortImagefile
   put portalRowDictionary [rowName]["imageText"] into imageText
end sivasiva_SetPortalLinkInfo

command sivasiva_DisplayPortalHeader homeModueName, pHeaderView
   put portal_GetHeaderImageFile (homeModueName) into headerImageFile
   
   if exists (pHeaderView) is false then
      put view_GetTemplateObject ("View|SivaSiva|Image|Header") into pHeaderView
      object_GoTo pHeaderView
   end if
   set the image_File of pHeaderView to headerImageFile
end sivasiva_DisplayPortalHeader


--> Legacy | sivasiva
-
-- command loadPortalImages sConfigA
-- was "loadPortalImages" of card 1 of stack "sivasivahome"
setBasePath
// load hero image
loadImage sConfigA["portal-links"]["hero"]["image"], the long id of image "home-hero"

loadImage sConfigA["portal-links"]["gems"]["image"], the long id of image "portal-link-image" of group "home_gems"
loadImage sConfigA["portal-links"]["surprise"]["image"], the long id of image "portal-link-image" of group "home_surprise"
loadImage sConfigA["portal-links"]["listen"]["image"], the long id of image "portal-link-image" of group "home_listen"
loadImage sConfigA["portal-links"]["look"]["image"], the long id of image "portal-link-image" of group "home_look"
loadImage sConfigA["portal-links"]["practice"]["image"], the long id of image "portal-link-image" of group "home_practice"
loadImage sConfigA["portal-links"]["read"]["image"], the long id of image "portal-link-image" of group "home_read"
loadImage sConfigA["portal-links"]["website"]["image"], the long id of image "portal-link-image" of group "home_website"
loadImage sConfigA["portal-links"]["games"]["image"], the long id of image "portal-link-image" of group "home_games"
end loadPortalImages


