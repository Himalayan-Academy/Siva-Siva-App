script "model_SivaSivaConfig"
--> MetaData
-
license: GPLv3
name: model_SivaSivaConfig
type: model
version: 0.1

/*
This model handles project and modue configuration.

Project cofiguration uses the same structure, and handlers, as individual modules.
*/


--> Variables
-
global sConfigA


--> SivaSiva | Project | Config
-
command init_LoadJsonConfig
   put sivasiva_GetModuleCongifArray ("Siva-Siva-App") into sConfigA
   put true into sConfigA ["initialized"]
end init_LoadJsonConfig


--> SivaSiva | Module | Config
-
function sivasiva_GetModuleCongifArray pModule
   put sivasiva_GetModuleJson (pModule) into someJSON
   if someJSON is empty then return empty
   put jsonImport (someJSON) into someArray
   return someArray
end sivasiva_GetModuleCongifArray


--> SivaSiva | Paths | Modules
-
function sivasiva_GetModuleJson moduleName
   put sivasiva_GetModuleJsonFile (moduleName) into tModuleConfigurationFile
   put url ("binfile:" & tModuleConfigurationFile) into someJSON
   return someJSON
end sivasiva_GetModuleJson

function sivasiva_GetModuleJsonFile moduleName   
   put sivasiva_GetModuleFolder (moduleName) into sivasivaModuleFolder
   put sivasivaModuleFolder & moduleName & ".json" into tModuleConfigurationFile
   return tModuleConfigurationFile
end sivasiva_GetModuleJsonFile
