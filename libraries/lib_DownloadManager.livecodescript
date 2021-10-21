script "Lib_DownloadManager"
constant kAssetsManifestURL = "https://www.himalayanacademy.com/media/apps/sivasiva/assets.txt"
constant kAssetsZipURL = "https://www.himalayanacademy.com/media/apps/sivasiva/assets.zip"
constant kConnectionID = "assets.zip"

local sConfigA
local sCheckStatusMsgID   


function didDownloadAssets
   if there is a file (path_Documents() & "assets.txt") then
      return true
   else
      return false
   end if
end didDownloadAssets

function getLocalAssetsChecksum
   if there is a file (path_Documents() & "assets.txt") then
      get url ("binfile:" & path_Documents() & "assets.txt")
      get word -1 of it
      return it
   else
      return false
   end if
end getLocalAssetsChecksum

command saveAssetsChecksum
   put url kAssetsManifestURL into url ("binfile:" & path_Documents() & "assets.txt")
end saveAssetsChecksum

function getRemoteAssetsChecksum
   get url kAssetsManifestURL
   if the result is not empty then
      return false
   end if
   get word -1 of it
   return it
end getRemoteAssetsChecksum

function shouldDownloadNewAssets
   local tLocalAssetsChecksum, tRemoteAssetsChecksum
   
   put getLocalAssetsChecksum() into tLocalAssetsChecksum
   put getRemoteAssetsChecksum() into tRemoteAssetsChecksum
   
   if tLocalAssetsChecksum is false then
      -- no local assets, download
      return true
   end if
   
   if tRemoteAssetsChecksum is false then
      -- something wrong with the server, do not attempt to download
      return false
   end if
   
   if tLocalAssetsChecksum is not tRemoteAssetsChecksum then
      return true
   end if
   
   return false
end shouldDownloadNewAssets

command setDownloadStatusCallback pHandler, pTarget
   if pTarget is empty then
      put the target into pTarget
   end if
   
   put pHandler into sConfigA["handler"]
   put pTarget into sConfigA["target"]
end setDownloadStatusCallback

command downloadAssets
   local tHeaders, tResult

   put tsNetGetFile(kConnectionID, (path_Documents() & "assets.zip"), \
         kAssetsZipURL, tHeaders, "_transferComplete") into tResult
   if tResult is empty then
      send "_checkProgress" to me in 1 second
      put the result into sCheckStatusMsgID
   else 
      dispatch sConfigA["handler"] to sConfigA["target"] with ("error," & tResult)
   end if
end downloadAssets

command verifyAndExpandAssets
   local tZipPath, tZipManifest, tFileList, tFile, tDestinationFile
   
   cancel sCheckStatusMsgID
   
   saveAssetsChecksum
   
   put path_Documents() & "assets.zip" into tZipPath
   put path_Documents() & "assets.txt" into tZipManifest
   
   if there is a file tZipPath then
      revZipOpenArchive tZipPath, "read"
      if the result is not empty then
         dispatch sConfigA["handler"] to sConfigA["target"] with ("expanderr," & the result)
      end if
      
      if there is not a folder (path_Documents() & "assets") then
         create folder (path_Documents() & "assets")
      end if
      
      put revZipEnumerateItems(tZipPath) into tFileList
      dispatch sConfigA["handler"] to sConfigA["target"] with ("expanding 0" && the number of lines in tFileList )
      repeat with x = 1 to the number of lines in tFileList
         put line x of tFileList into tFile
         put (path_Assets() & tFile) into tDestinationFile
         replace "./" with empty in tDestinationFile
         
         createFolders tDestinationFile
         
         revZipExtractItemToFile tZipPath, tFile, tDestinationFile
         if the result is not empty then
            dispatch sConfigA["handler"] to sConfigA["target"] with the result
            exit repeat
         else
            dispatch sConfigA["handler"] to sConfigA["target"] with ("expanding" && x && the number of lines in tFileList )
         end if
         wait 50 millisecs with messages
      end repeat
      jnanam_UpdatePhotoCache
      dispatch sConfigA["handler"] to sConfigA["target"] with ("expanded" && x && the number of lines in tFileList )
   else
      dispatch sConfigA["handler"] to sConfigA["target"] with ("expanderr,no assets.zip")
   end if
end verifyAndExpandAssets

command createFolders pPath
   local tCurrPath
   
   set the itemdel to slash
   put "" into tCurrPath
   repeat with x = 1 to (the number of items in pPath - 1)
      put "/" & item x of pPath after tCurrPath
      if there is not a folder tCurrPath then
         create folder tCurrPath
      end if
   end repeat
end createFolders


on _checkProgress
   local tStatus
   
   put tsNetGetStatus(kConnectionID) into tStatus
   
   if tStatus contains "tsneterr" then
      log "error fetching connection information"
      log tStatus
      exit _checkProgress
   end if
   
   dispatch sConfigA["handler"] to sConfigA["target"] with tStatus
   
   switch word 1 of tStatus 
      case "downloaded"
         // strange error
         dispatch sConfigA["handler"] to sConfigA["target"] with "downloaded"
         break
      case "timeout"
         // try again...
         tsNetCloseConn kConnectionID
         send "downloadAssets" to me in 50 millisecs
         exit _checkProgress
         break
      case "tsneterr"
      case "error"
         if the environment is "development" then
            put tsNetRetrError(kConnectionID)
         end if
         
         dispatch sConfigA["handler"] to sConfigA["target"] with ("error," & tsNetRetrError(kConnectionID))
         tsNetCloseConn kConnectionID
         exit _checkProgress
         break
      default
         send "_checkProgress" to me in 3 seconds
         put the result into sCheckStatusMsgID
         break
   end switch 
   
end _checkProgress

on _transferComplete pID, pResult, pBytes, pCurlCode
   local tData, tHeaders
   if pCurlCode is not 0 then
      dispatch sConfigA["handler"] to sConfigA["target"] with tsNetRetrError(pID)
   else
      cancel sCheckStatusMsgID
      dispatch sConfigA["handler"] to sConfigA["target"] with "downloaded"
      tsNetCloseConn pID
   end if
end _transferComplete
