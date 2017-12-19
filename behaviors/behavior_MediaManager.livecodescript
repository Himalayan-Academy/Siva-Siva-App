script "behavior_MediaManager"
/**
behavior_MediaManager.livecodescript

Set as the behavior for card "disk_data_overview" of the settings.livecode stack

"me" refers to the card script

author: Brahmanathaswami from Key Ray's directory walker + andre alves garzia (andre@andregarzia.com) byte sum function

This library helps with media management in mobile apps.

testing this stuff, I think it might be working now.
*/

constant kMediaFolder= "/Users/Brahmanathaswami/Documents/SivaSivaApp/media"  # use for dev outside SivaSivaApp.
local sMediaFolder,sTopFolder,sTopFolderList,sSpaceTotal,sResultA,sTargetFile,sTargetLine,sDetailedTarget

on libraryStack
   if the short name of this stack is among the lines of the stacksinuse then
      pass libraryStack
   end if  
   mmSetRootFolder (path_Documents() & "media/")
end libraryStack

on openCard
   mmSetRootFolder (path_Documents() & "media/")
   mmGetTopSums
end openCard


--> recursive directory walk/digger and storing data handlers and functions

# we get sums for separate top level folders, 
# but we since we have to do the dig we save all files to the array
# we can use this later to present files with their sizes and allow the user to delete 
# without digging again. 

command mmGetTopSums
   show btn "load-spinner"
   show grp "diskDataOverview"
   dispatch "graphResets"  to group "diskDataOverview" with "zeroOut"
   put empty into sResultA
   get mmGetSizesBySubFolders("audio")
   get mmGetSizesBySubFolders("books")
   get  mmGetSizesBySubFolders("art")
   insertTopResults sResultA # see display section below
   show grp "goSettings"
end mmGetTopSums

command mmSetRootFolder pFolder
   if there is a folder pFolder then
      put pFolder into sMediaFolder
   end if
end mmSetRootFolder

function mmGetSizesBySubfolders pPathComplement
   put 0 into tTopSum
   
   put the defaultFolder into dF
   put sMediaFolder & pPathComplement into sTopFolder
   set the directory to sTopFolder
   put folders(sTopFolder) into sTopFolderList
   filter sTopFolderList without ".*"
   
   repeat for each line tF in sTopFolderList
      mmComputeSpaceUsedByFolder (sTopFolder & "/" & tF)
      if tF is not ".." then
         add sSpaceTotal to tTopSum
         put round (sSpaceTotal,2) into sResultA[pPathComplement][tF]
      end if
      put 0 into sSpaceTotal
   end repeat
   set the defaultFolder to dF
   put round (tTopSum,2) into sResultA[pPathComplement]["categorySum"]
   return sResultA
end mmGetSizesBySubfolders

command  mmComputeSpaceUsedByFolder tF
   set the itemDel to "/"
   set the directory to tF
   -------------
   # extract file sizes now before moving to next folder
   put the detailed files into tFilesList
   filter tFilesList without ".*"
   if tFilesList is not empty then
      set the itemdel to ","
      repeat for each line tFile in tFilesList
         put item 2 of tFile into tBytesCount
         put tBytesCount / 1024/1000 into tMBytes
         add tMBytes to sSpaceTotal
         put tF & "/" & tFile & cr after  sResultA["files"]
      end repeat
      set the itemdel to "/"
   end if
   ---------------
   
   #Moving down thru folders:
   
   put the folders into tDirList
   filter tDirList without ".*"
   sort tDirList
   
   repeat for each line x in tDirList
      if x = ".."  then next repeat
      mmComputeSpaceUsedByFolder (tF & "/" & x)
      delete line 1 of tDirList
   end repeat
   
end  mmComputeSpaceUsedByFolder

Command __UXDisplayAndDelete
   ## Display and Delete functions
end __UXDisplayAndDelete


###### 
command mouseup  #UI Interactions are trapped here
   put the short name of the target into tTarget
   --put the keys of sResultA
   switch tTarget
      # the dataOverviewGroup has it's own mousup handler
      # except for the go settings one below
      case "go-Settings-label"
         break
         # all the following apply to the datafiles group
      case "goSettings"
         go to card "settings-home"
         break
      case "FilesOnDisk"
         put value(the clickline) into tFile
         put the clickline into sTargetLine
         put word 2 of sTargetLine into tLineNo
         put line tLineNo of the uFilesOnDisk of me into sDetailedTarget
         put item 1 sDetailedTarget into tPath
         setTargetFile tPath
         set the itemdel to tab
         put item 1 of tFile into fld "currentFilePick"
         setDeleteMode "on"
         break
      case "DoneDeletions"  # leave the file list and return to sums
         setDeleteMode "off"
         hide grp "displayFilesSizes" 
         mmSetRootFolder (path_Documents() & "media/")
         mmGetTopSums
         break
      case "deleteYes"
         set the textcolor of sTargetLine to gray
         set the textstyle of sTargetLine to strikeout
         put item 2 of sDetailedTarget into tFileSize
         put tFileSize/1024/1000 into tMB
         put fld "currentTotal" - round (tMB,2) into fld "CurrentTotal"
         deleteFileOnDisk 
         setDeleteMode "Yes"
         break
      case "deleteNo"
         setDeleteMode "off"
         break
      case "deleteFile"
         put "Cannot be undone. Crossed out files have been deleted. Download them again later." \
               into pMsg
         doAnswer pMsg,"OK"
         break
   end switch
end mouseup

command setDeleteMode pOnOff
   if pOnOff="off" then 
      put empty into fld "currentFilePick"
      hide grc "deleteYes"
      hide grc "deleteNo"
      put "Delete File" into fld "deleteFile"
      set the opaque of  fld "deleteFile" to false
      set the backgroundColor of fld "deleteFile" to empty
   else # move to line and slide in
      set the opaque of  fld "deleteFile" to true
      set the backgroundColor of fld "deleteFile" to red
      show grc "deleteYes"
      show grc "deleteNo"
      put "Delete?" into fld "deleteFile"
   end if
end setDeleteMode

private command insertTopresults sResultA
   dispatch "updateUsageOverview" to grp "diskDataOverview" with sResultA
end insertTopResults
  
command displayTargetFiles pDataType
   put empty into fld "FilesOnDisk" 
   put sResultA["files"] into tDetailedFiles
   put  ("*media/"&pDataType&"/*") into tFilter
   filter lines of tDetailedFiles with tFilter
   set the uFilesOnDisk of this card to tDetailedFiles
   repeat for each line x in tDetailedFiles
      put item 1 of x into tPath
      put item 2 of x into tSize
      put round ( (tSize/1024/1000),2) into tSize
      set the itemdel to "/"
      put item -1 of tPath into tFile
      put tFile & tab & tSize & cr after tFileList 
      set the itemdel to comma
   end repeat
   put tFileList into fld "FilesOnDisk"
   hide grp "GoSettings"
   hide grp "diskDataOverview" with dissolve very fast
   put sResultA[pDataType][categorySum] into fld "currentTotal"
   show grp "displayFilesSizes" with dissolve very fast
end displayTargetFiles


# deletion routines

command setTargetfile pTargetFile
   put pTargetFile into sTargetFile
end setTargetfile

function getTargetFile
   return sTargetFile
end getTargetFile

command deleteFileOnDisk 
   delete file ( getTargetFile() )
end deleteFileOnDisk


on mouseDoubleDown pButtonNumber
   
end mouseDoubleDown
