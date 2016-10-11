script "lib_SivaSiva"
--> MetaData
-
license: GPLv3
name: lib_SivaSiva
type: library
version: 0.1

local LocalArray


--> Working On
-
--> Display
-
command sivasiva_DisplayHomePortalLink portalLinkName, pSivaSectionArray
   sivasiva_DisplayPortalLink portalLinkName, moduleName, pSivaSectionArray
   return the result
   
   if pSivaSivaData is not an array then put sivasiva_FetchData() into pSivaSivaData
   
   sivasiva_SetPortalLinkInfo portalLinkName, "home", pSivaSivaData, iconText, relativeImagefile, moduleFolder
   put moduleFolder & relativeImagefile into imageFile
   
   put view_GetTemplateObject ("View|SivaSiva|Contents|Row") into rowTemplate
   set the image_File of rowTemplate to imageFile
   set the title_Text of rowTemplate to iconText
   
   object_GoTo rowTemplate
end sivasiva_DisplayHomePortalLink

command sivasiva_DisplayPortalLink portalLinkName, moduleName, pSivaSectionArray
   if pSivaSivaData is not an array then put sivasiva_FetchData() into pSivaSivaData
   
   sivasiva_SetPortalLinkInfo portalLinkName, moduleName, pSivaSivaData, iconText, relativeImagefile, moduleFolder
   put moduleFolder & relativeImagefile into imageFile
   
   put view_GetTemplateObject ("View|SivaSiva|Contents|Row") into rowTemplate
   set the image_File of rowTemplate to imageFile
   set the title_Text of rowTemplate to iconText
   object_GoTo rowTemplate
   
   return pSivaSivaData
end sivasiva_DisplayPortalLink

command sivasiva_DisplayPortalHeader homeModueName, pHeaderView
   put sivasiva_GetPortalImage (homeModueName) into headerImageFile
   debug_MissingPortalImage headerImageFile, homeModueName
   
   if exists (pHeaderView) is false then
      put view_GetTemplateObject ("View|SivaSiva|Image|Header") into pHeaderView
      object_GoTo pHeaderView
   end if
   set the image_File of pHeaderView to headerImageFile
end sivasiva_DisplayPortalHeader

private command debug_MissingPortalImage headerImageFile, homeModueName
   if there is not a file headerImageFile then
      put headerImageFile
      breakpoint
      put sivasiva_GetPortalImage (homeModueName) into imageFile
      set the itemdelimiter to slash
      put item 1 to -2 of headerImageFile & slash into imageFolder
      finder_Reveal imageFolder
      exit to top
   end if
end debug_MissingPortalImage


--> SivaSiva | Files | Find
-
function sivasiva_FindPortalThumbImages
   put sivasiva_FindPortalScreenImages() into portalImages
   filter portalImages with "*/thumb_*"
   return portalImages
end sivasiva_FindPortalThumbImages

function sivasiva_FindPortalScreenImages
   put sivasiva_FindPortalScreenFolders () into portalScreenFolders
   repeat for each line portalScreenFolder in portalScreenFolders
      put folder_ListFiles (portalScreenFolder) & CR after portalScreenFiles
   end repeat
   delete char -1 of portalScreenFiles
   -- filter portalScreenFiles without "*/lcw_Metadata/*"
   return portalScreenFiles
end sivasiva_FindPortalScreenImages

function sivasiva_FindPortalScreenFolders
   put spotlight_FindFolders ("portal-screen") into portalScreenFolders
   return portalScreenFolders
end sivasiva_FindPortalScreenFolders


--> SivaSiva | Names
-
function sivasiva_ConstructGroupName moduleName
   -- original way of naming groups in home display
   -- hack:  the groups are not consistently named -- "suprise_links" etc
   
   switch moduleName
      case "home"
         return "portal-links"  -- hack
      case "surprise"
         return "surprise_links" 
      default
         put word 1 of moduleName & "-links" into groupName
         return groupName
   end switch
end sivasiva_ConstructGroupName

function sivasiva_RowNameToPortalLink rowName
   set the itemdelimiter to "_"
   delete item 1 of rowName
   return rowName
end sivasiva_RowNameToPortalLink

function sivasiva_PortalLinkToRowName portalLinkName, moduleName
   put word 1 of moduleName & "_" & portalLinkName into rowName
   return rowName
end sivasiva_PortalLinkToRowName


--> Hack
-
/*
Original module config way of doing things.
Moving over to better json array structure
*/

function hack_FindPortalImage moduleName, pReturnRelative
   -- hack for now due to lack of structure in json
   -- in case we have not created new json array structure
   
   put sivasiva_GetModuleFolderFromArray (moduleName) into sivasivaModuleFolder
   put sivasiva_GetModuleCongifArray (moduleName) into configurationArray
   put configurationArray ["portal-links"] into portalLinkArray
   repeat for each key portalLinkName in portalLinkArray
      put portalLinkArray [portalLinkName]["image"] into relativeImagefile
      set the itemdelimiter to slash
      put item -1 of relativeImagefile into shortFile
      set the itemdelimiter to "_"
      if item 1 of shortFile = "thumb" then next repeat
      
      if pReturnRelative is true then
         return relativeImagefile
      else
         put sivasivaModuleFolder & relativeImagefile into imageFile
      end if
      return imageFile
   end repeat
   return empty
end hack_FindPortalImage

function hack_ListPortalLinks moduleName
   put sivasiva_GetModuleCongifArray (moduleName) into configurationArray
   put configurationArray ["portal-links"] into portalLinkArray
   repeat for each key portalLinkName in portalLinkArray
      put portalLinkArray [portalLinkName]["image"] into relativeImageFile
      
      -- this should not be needed (we use here to check for bugs)
      -- remove in production
      put sivasiva_GetModuleFolderFromArray (moduleName) into moduleFolder
      put moduleFolder & relativeImageFile into imageFile
      if there is not a file imageFile then
         breakpoint
         next repeat -- lets skip liks without images
      end if
      
      set the itemdelimiter to slash
      put item -1 of relativeImageFile into shortFile
      set the itemdelimiter to "_"
      if item 1 of shortFile is not "thumb" then next repeat
      
      put portalLinkName & CR after portalLinks
   end repeat
   delete char -1 of portalLinks
   sort portalLinks
   return portalLinks
end hack_ListPortalLinks

function hack_GetPortalLinkImage portalLinkName, moduleName, pReturnRelative
   put sivasiva_GetModuleCongifArray (moduleName) into configurationArray
   put configurationArray ["portal-links"] into portalLinkArray
   put portalLinkArray [portalLinkName]["image"] into relativeImagefile
   put sivasiva_GetModuleFolderFromArray (moduleName) into sivasivaModuleFolder
   
   if pReturnRelative is true then
      return relativeImagefile
   else
      put sivasivaModuleFolder & relativeImagefile into imageFile
      return imageFile
   end if
end hack_GetPortalLinkImage
