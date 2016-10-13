script "lib_SivaSivaDevelopment"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaDevelopment
type: library
version: 0.2

/*
Place your development handlers here!
Treat this as a sort of scrap book for handlers you like to use as a convenience in development,
but are not intended to be used in production (you can move them to another stack later if they prove needed).

This library will eventually be moved into a separate authoring project.
These handlers that are useful in development but are not to be used in the final deployed mobile app. 
They should be in "tool" projects outside of a production project.
*/


--> Working on
-
command testMessagePath pMessage -- is this needed?
   answer pMessage with "OK"
end testMessagePath


--> From API
-
command scaleStackIfNeeded
   if the environment is "development" and (item 4 of the effective working screenRect < 800 )  then
      set the scalefactor of this stack to .75
      set the height of this stack to 736
   end if
end scaleStackIfNeeded

command errorDialog pExecutionError
   if not isMobile() then
      --put pExecutionError
      put item 4 of line 1 of pExecutionError into tBrokenStatement
      put item 2 of line 1 of pExecutionError into tLineNumber
      put line (item 1 of line 1 of pExecutionError) of the scriptExecutionErrors  into tErrorDescription 
      # scriptExecutionErrors  seems to be a global prop in the IDE, no longer the cErrorList custom property of a binary stack
      log_Error tErrorDescription & ":" && tBrokenStatement && "on line" && tLineNumber
   end if
end errorDialog


--> SivaSiva | Files
-
/*
These handler list files in the directories.
*/

function portal_ListThumbImages
   -- a thumb image is not guaranteed to be named beginning with "thumb_"
   put portal_ListImages() into portalImages
   filter portalImages with "*/thumb_*"
   return portalImages
end portal_ListThumbImages

function portal_ListImages
   -- lists all images (it is possible that some may not be used is actua app)
   put sivasiva_PortalImageFolder() into portalImageFolder
   put folder_ListFiles (portalImageFolder) into portalImageFiles
   return portalImageFiles
end portal_ListImages
   

--> Hack
-
/*
Original module config way of doing things.
Moving over to better json array structure
*/

function hack_GetModuleFolderFromArray moduleName, pSivaSivaData
   -- no longer stroing in an array
   if pSivasivaData is not an array then put sivasiva_FetchData() into pSivasivaData
   put pSivasivaData ["module"][moduleName] into moduleArray
   put moduleArray ["moduleFolder"] into moduleFolder
end hack_GetModuleFolderFromArray

function hack_FindPortalImage moduleName, pReturnRelative
   -- hack for now due to lack of structure in json
   -- in case we have not created new json array structure
   
   put hack_GetModuleFolderFromArray (moduleName) into sivasivaModuleFolder
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
      put hack_GetModuleFolderFromArray (moduleName) into moduleFolder
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
   put hack_GetModuleFolderFromArray (moduleName) into sivasivaModuleFolder
   
   if pReturnRelative is true then
      return relativeImagefile
   else
      put sivasivaModuleFolder & relativeImagefile into imageFile
      return imageFile
   end if
end hack_GetPortalLinkImage


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

function sivasiva_PortalLinkToRowName rowName, moduleName
   put word 1 of moduleName & "_" & rowName into rowName
   return rowName
end sivasiva_PortalLinkToRowName


--> SivaSiva | Files | Old
-
function old_FindPortalThumbImages
   put sivasiva_FindPortalScreenImages() into portalImages
   filter portalImages with "*/thumb_*"
   return portalImages
end old_FindPortalThumbImages

function old_FindPortalScreenImages
   put sivasiva_FindPortalScreenFolders () into portalScreenFolders
   repeat for each line portalScreenFolder in portalScreenFolders
      put folder_ListFiles (portalScreenFolder) & CR after portalScreenFiles
   end repeat
   delete char -1 of portalScreenFiles
   -- filter portalScreenFiles without "*/lcw_Metadata/*"
   return portalScreenFiles
end old_FindPortalScreenImages

function old_FindPortalScreenFolders
   put spotlight_FindFolders ("portal-screen") into portalScreenFolders
   return portalScreenFolders
end old_FindPortalScreenFolders
