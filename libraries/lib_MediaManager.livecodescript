script "lib_MediaManager"
/**
lib_MediaManager.livecodescript

author: andre alves garzia (andre@andregarzia.com)

This library helps with media management in mobile apps.

testing this stuff, I think it might be working now.
*/

local sMediaFolder

on libraryStack
   if the short name of me is among the lines of the stacksinuse then
      pass libraryStack
   end if
   
   mmSetRootFolder (path_Documents() & "media/")
end libraryStack

command mmSetRootFolder pFolder
   if there is a folder pFolder then
      put pFolder into sMediaFolder
   end if
end mmSetRootFolder

function mmGetSizesBySubfolders pPathComplement
   local tResultA
   put the defaultfolder into tDF
   set the defaultfolder to (sMediaFolder & pPathComplement)
   put the folders into tFolderList
   repeat for each line tF in tFolderList
      if tF is not ".." then
         put mmComputeSpaceUsedByFolder(tF) into tResultA[tF]
      end if
   end repeat
   set the defaultfolder to tDF
   return tResultA
end mmGetSizesBySubfolders

function mmComputeSpaceUsedByFolder pF
   local tResult
   put 0 into tResult
   put the defaultFolder into tDF
   set the defaultFolder to pF
   put the detailed files into tFilesList
   repeat for each line tF in tFilesList
      put item 2 of tF into tBytesCount
      put tBytesCount / 1024 into tMBytes
      add tMBytes to tResult
   end repeat
   put the folders into tFoldersList
   repeat for each line tF in tFoldersList
      if tF is not ".." then
         add mmComputeSpaceUsedByFolder(tF) to tResult
      end if
   end repeat
   set the defaultFolder to tDF
   return tResult
end mmComputeSpaceUsedByFolder
