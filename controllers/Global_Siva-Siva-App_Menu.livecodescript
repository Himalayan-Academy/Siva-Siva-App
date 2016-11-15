script "Global_Siva-Siva-App_Menu"
--> MetaData
-
license: GPLv3
name: Global_Siva-Siva-App_Menu
type: controller
version: 0.2


--> Global | Siva-Siva-App | Menu
-
on menu_DisplayBookMarks
   portal_DisplayBookmarks
end menu_DisplayBookMarks

on menu_DisplayRowNames projectName, portalName
   put portal_GetHomeView() into layoutView
   put portal_ListRowNames (portalName) into rowNames
   set the portal_RowNames [portalName] of layoutView to rowNames
end menu_DisplayRowNames

on menu_SetPortalName projectName, portalName
   put portal_GetHomeView() into layoutView
   set the portal_Name of layoutView to portalName
end menu_SetPortalName

on menu_EditBehavior projectName, whichBehavior
   put portal_GetHomeView() into layoutView
   
   switch whichBehavior
      case "layout"
         put layoutView into someView
         break
      case "scrolling"
         -- put view_GetTemplateObject ("View|SivaSiva|Scrolling") into someView
         put the scrolling_View of layoutView into someView
         break
      case "bottom navigation"
         -- put view_GetTemplateObject ("View|SivaSiva|Navigation|Bottom") into someView
         put the navigation_View of layoutView into someView
         break
      case "header image"
         -- put view_GetTemplateObject ("View|SivaSiva|Image|header") into someView
         put the scrolling_View of layoutView into scrollingView
         put the header_View of scrollingView into someView
         break
      case "scrolling row"
         -- put view_GetTemplateObject ("View|SivaSiva|Navigation|Bottom") into someView
         put the scrolling_View of layoutView into scrollingView
         put the row_View [1] of scrollingView into someView
         break
   end switch
   edit the script of the behavior of someView
end menu_EditBehavior

on _
end _

on menu_SetPortalHeaderImage projectName, portalName
   put sivasiva_PortalImageFolder() into someFolder
   answer file "Select header image" with someFolder
   if it is empty then exit to top 
   put it into headerImageFile
   set the itemdelimiter to slash
   put item -1 of headerImageFile into shortHeaderImageFile
   
   portal_SetHeaderImage portalName, shortHeaderImageFile
   
   put portal_GetHomeView() into layoutView
   set the portal_Name of layoutView to portalName
end menu_SetPortalHeaderImage

on menu_SetPortalColour projectName, portalName
   answer color
   if it is empty then exit to top 
   put it into portalColour
   
   portal_SetBackgroundColour portalName, portalColour
   
   put portal_GetHomeView() into layoutView
   set the portal_Name of layoutView to portalName
end menu_SetPortalColour

on _
end _

on menu_EditPortalModelJson
   put sivasiva_DataFile() into jsonFile
   launch_Atom jsonFile
end menu_EditPortalModelJson

on _
end _

on menu_EditHomeModuleJson whoCares, portalName
   put sivasiva_GetModuleJsonFile (portalName) into jsonFile
   if there is not a file jsonFile then
      breakpoint
      set the itemdelimiter to slash
      put item 1 to -2 of jsonFile into jsonFolder
      finder_Reveal jsonFolder
   end if
   
   launch_Atom jsonFile
end menu_EditHomeModuleJson

on menu_DisplayModuleConfig whoCares, portalName
   put sivasiva_GetModuleCongifArray (portalName) into configArray
   display_Array configArray
end menu_DisplayModuleConfig

on _
end _

on menu_DisplayPortalJson
   put sivasiva_FetchData() into sivasivaData
   display_Array sivasivaData, "sivasiva_FetchData(),SivaSiva Portal JSON"
end menu_DisplayPortalJson

on menu_DisplayTraitsBookArray
   put traits_FetchBookArray() into bookArray
   display_Array bookArray, "traits_FetchBookArray(),Charachter Traits Array"
end menu_DisplayTraitsBookArray

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplaySivasivaData
   put sivasiva_FetchData() into sivasivaData
   display_Array sivasivaData, "sivasiva_FetchData()", "Global | Siva-Siva-App | Menu"
   put the result into whoCares
end menu_DisplaySivasivaData

-- on menu_RestoreSivasivaData
   put "model_SivaSiva" into stackName
   put stackName & ".array" into shortFile-- could use ".array"
   put the model_Array [shortFile] of stack stackName into sivasivaData
   
   sivasiva_StoreData sivasivaData
   menu_DisplaySivasivaData
end menu_RestoreSivasivaData

on _
end _

on menu_RestoreSivasivaData
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
end menu_RestoreSivasivaData

on menu_DisplayOldData
   put sivasiva_FetchOldData() into sivasivaData
   display_Array sivasivaData
end menu_DisplayOldData


--> Global | Siva-Siva-App | Menu | Props
-
getprop portal_Name
   put portal_GetHomeView() into portalView
   put the portal_Name of portalView into portalName
   return portalName
end portal_Name

getprop portal_Names
   put portal_ListNames() into moduleNames
   return moduleNames
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
