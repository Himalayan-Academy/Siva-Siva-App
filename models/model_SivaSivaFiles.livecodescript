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



--> SivaSiva | Paths | Assets
-
function sivasiva_AssetFolder
   put sivasiva_ProjectFolder() & "assets/" into sharedAssetFolder
   return sharedAssetFolder
end sivasiva_AssetFolder


--> SivaSiva | Paths | Modules
-
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
