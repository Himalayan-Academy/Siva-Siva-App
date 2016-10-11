script "Global_Siva-Siva-App_Menu"
--> MetaData
-
license: GPLv3
name: Global_Siva-Siva-App_Menu
type: controller
version: 0.1


--> Global | Siva-Siva-App | Menu
-
on menu_DisplaySivasivaData
   put sivasiva_FetchData () into sivasivaData
   display_Array sivasivaData
end menu_DisplaySivasivaData

on menu_DisplayModuleConfig indexView, moduleName
   put sivasiva_GetModuleCongifArray (moduleName) into configArray
   display_Array configArray
end menu_DisplayModuleConfig


--> Global | Siva-Siva-App | Menu | Props
-
getprop module_Names
   put sivasiva_ListModules() into moduleNames
   put "Siva-Siva-App" & CR & "-" & CR into goodModuleNames
   repeat for each line moduleName in moduleNames
      put sivasiva_GetModuleJsonFile (moduleName) into jsonFile
      if there is a file jsonFile then
         put moduleName & CR after goodModuleNames
      else
         put "(" & moduleName & CR after goodModuleNames
      end if
   end repeat
   delete char -1 of goodModuleNames
   return goodModuleNames
end module_Names
