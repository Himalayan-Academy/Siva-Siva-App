script "Global_Siva-Siva-App_Menu"
--> MetaData
-
license: GPLv3
name: Global_Siva-Siva-App_Menu
type: controller
version: 0.2


--> Global | Siva-Siva-App | Menu
-
on menu_EditPortalModelJson
   put sivasiva_DataFile() into jsonFile
   launch_Atom jsonFile
end menu_EditPortalModelJson

on menu_EditHomeModuleJson indexView, portalName
   put sivasiva_GetModuleJsonFile (portalName) into jsonFile
   if there is not a file jsonFile then
      breakpoint
      set the itemdelimiter to slash
      put item 1 to -2 of jsonFile into jsonFolder
      finder_Reveal jsonFolder
   end if
   
   launch_Atom jsonFile
end menu_EditHomeModuleJson

on menu_DisplayModuleConfig indexView, portalName
   put sivasiva_GetModuleCongifArray (portalName) into configArray
   display_Array configArray
end menu_DisplayModuleConfig

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplaySivasivaData
   put sivasiva_FetchData () into sivasivaData
   display_Array sivasivaData
end menu_DisplaySivasivaData

on _
end _

on menu_TidySivasivaData
   put sivasiva_FetchOldData() into sivasivaData
   -- put sivasiva_FetchData () into sivasivaData
   
   put sivasivaData ["sectionDictionary"] into sectionDictionary
   set the itemdelimiter to slash
   repeat for each key portalName in sectionDictionary
      put sectionDictionary [portalName] into oldArray
      repeat for each key oldGroupName in oldArray
         put oldArray [oldGroupName]["text"] into imageText
         put oldArray [oldGroupName]["image"] into relativeFile
         put item -1 of relativeFile into shortImageFile
         
         put _constructNewTitle (imageText) into newTitle
         
         put shortImageFile into portalRowDictionary [newTitle]["shortImageFile"]
         put imageText into portalRowDictionary [newTitle]["imageText"] -- redundent ???
         -- put empty into portalRowDictionary [newTitle]["portalName"][portalName]["oldGroupName"][oldGroupName]-- redundent
         
         put newTitle into tempDictionary [oldGroupName]
      end repeat
   end repeat
   -- display_Array portalRowDictionary
   put portalRowDictionary into newSivaSivaData ["portalRowDictionary"]
   
   put sivasivaData ["module"] into moduleArray
   repeat for each key portalName in moduleArray
      put moduleArray [portalName] into oldArray
      
      put oldArray ["rowData"] into rowData
      repeat for each key rowNum in rowData
         put rowData [rowNum]["portalLinkName"] into oldGroupName
         put tempDictionary [oldGroupName] into newRowName
         put newRowName into rowArray [rowNum]["rowName"]
      end repeat
      put rowArray into newSivaSivaData ["portalData"][portalName]["rowData"]
      
      put oldArray ["portalImage"] into relativeFile
      put item -1 of relativeFile into shortFile
      
      put shortFile into newSivaSivaData ["portalData"][portalName]["headerImage"]
      put portalName into newSivaSivaData ["portalData"][portalName]["portalName"]
   end repeat
   
   display_Array newSivaSivaData
   breakpoint
   sivasiva_StoreData newSivaSivaData
end menu_TidySivasivaData

on menu_DisplayOldData
   put sivasiva_FetchOldData() into sivasivaData
   display_Array sivasivaData
end menu_DisplayOldData


--> Global | Siva-Siva-App | Menu | Props
-
getprop portal_Names
   -- put portal_ListRowNames ("home") into homeRowNames
   put sivasiva_ListPortals() into moduleNames
   put "Siva-Siva-App" & CR & "-" & CR into goodModuleNames
   repeat for each line portalName in moduleNames
      put sivasiva_GetModuleJsonFile (portalName) into jsonFile
      if there is a file jsonFile then
         put portalName & CR after goodModuleNames
      else
         put "(" & portalName & CR after goodModuleNames
      end if
   end repeat
   delete char -1 of goodModuleNames
   return goodModuleNames
end portal_Names


--> Private
-
function sivasiva_FetchOldData
   put "model_SivaSiva" into stackName
   put stackName & ".array" into shortFile
   -- put stackName & ".json" into shortFile
   
   put the model_Array [shortFile] of stack stackName into sivasivaData
   return sivasivaData
end sivasiva_FetchOldData

private function _constructNewTitle imageText
   repeat for each word someWord in imageText
      put someWord & space after newTitle
   end repeat
   delete char -1 of newTitle
   return newTitle
end _constructNewTitle
