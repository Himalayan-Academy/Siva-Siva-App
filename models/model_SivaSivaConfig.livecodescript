script "model_SivaSivaConfig"
--> MetaData
-
license: GPLv3
name: model_SivaSivaConfig
type: model
version: 0.2

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
   put sivasiva_GetModuleConfigArray ("Siva-Siva-App") into sConfigA
   put true into sConfigA ["initialized"]
end init_LoadJsonConfig


--> SivaSiva | Module | Config
-
function sivasiva_GetModuleConfigArray pModule
   put sivasiva_GetModuleJson (pModule) into someJSON
   if someJSON is empty then return empty
   put jsonImport (someJSON) into someArray   
   return someArray
end sivasiva_GetModuleConfigArray


--> SivaSiva | Paths | Modules
-
function sivasiva_GetModuleJson moduleName
   put sivasiva_GetModuleJsonFile (moduleName) into jsonFile
   if there is not a file jsonFile then
      log_Info "File does not exist"
      return empty
   end if
   
   put url ("binfile:" & jsonFile) into someJSON
   return someJSON
end sivasiva_GetModuleJson

function sivasiva_GetModuleJsonFile moduleName
   put sivasiva_GetModuleFolder (moduleName) into sivasivaModuleFolder
   put sivasivaModuleFolder & moduleName & ".json" into jsonFile
   return jsonFile
end sivasiva_GetModuleJsonFile
