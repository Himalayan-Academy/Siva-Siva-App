script "lib_SivaSivaLegacy"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaLegacy
type: library
version: 0.1


--> Variables
-
global sConfigA


--> Legacy | Paths
-
function getPathToModulesFolder
   -- legacy shim in case any scripts are still using this   
   return sivasiva_GetModuleRootFolder()
end getPathToModulesFolder

function getPathToLoaderStack
   -- legacy shim in case any scripts are still using this
   breakpoint
   
   put sivasiva_ProjectFolder() into tSourcePath
   delete char -1 of tSourcePath -- slash
   return tSourcePath
end getPathToLoaderStack

function getPathToSharedAssetsFolder
   -- legacy shim in case any scripts are still using this
   breakpoint
   return sivasiva_AssetFolder()
end getPathToSharedAssetsFolder

function project_DocumentsFolder
   -- works cross platform
   -- put specialFolderPath ("documents") into docFolder
   put the documents folder into docFolder
   put "/" after docFolder
   return docFolder
end project_DocumentsFolder

function project_HomeFolder
   
end project_HomeFolder

function mobile_HomeFolder
   --###jg: will fail on desktop if loader stack isn't the defaultstack; ok on mobile
   put specialFolderPath ("resources") into tPath
   put "/" after tPath
   return tPath
end mobile_HomeFolder

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

command loadModuleConfiguration pModule pData
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
