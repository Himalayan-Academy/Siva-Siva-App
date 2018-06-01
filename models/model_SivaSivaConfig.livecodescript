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


--> SivaSiva | Config
-
command init_LoadJsonConfig   
   put sivasiva_GetModuleConfigArray ("Siva-Siva-App") into sConfigA
   put true into sConfigA ["initialized"]
end init_LoadJsonConfig

function sivasiva_GetModuleConfigArray moduleName
   put sivasiva_GetModuleJson (moduleName) into someJSON
   if someJSON is empty then return empty
   put jsonImport (someJSON) into configArray   
   return configArray
end sivasiva_GetModuleConfigArray

command sivasiva_SetModuleConfigArray moduleName, configArray
   put jsonExport (configArray) into someJSON
   sivasiva_SetModuleJson moduleName, someJSON
end sivasiva_SetModuleConfigArray


--> SivaSiva | Paths | Modules
-
function sivasiva_GetModuleJson moduleName
   put sivasiva_GetModuleJsonFile (moduleName) into jsonFile
   put url ("binfile:" & jsonFile) into someJSON
   return someJSON
end sivasiva_GetModuleJson

command sivasiva_SetModuleJson moduleName, someJSON
   put sivasiva_GetModuleJsonFile (moduleName) into jsonFile   
   put someJSON into url ("binfile:" & jsonFile)
   return jsonFile
end sivasiva_SetModuleJson

function sivasiva_GetModuleJsonFile moduleName
   if moduleName = "home" then
      put sivasiva_ProjectFolder() & "Siva-Siva-App.json" into jsonFile
   else
      put sivasiva_GetModuleFolder (moduleName) into sivasivaModuleFolder
      put sivasivaModuleFolder & moduleName & ".json" into jsonFile
   end if
   return jsonFile
end sivasiva_GetModuleJsonFile
