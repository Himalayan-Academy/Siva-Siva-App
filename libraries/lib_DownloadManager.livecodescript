script "Lib_DownloadManager"
constant kAssetsManifestURL = "https://dev.himalayanacademy.com/media/apps/sivasiva/assets.txt"
constant kAssetsZipURL = "https://dev.himalayanacademy.com/media/apps/sivasiva/assets.zip"
constant kConnectionID = "assets.zip"

local sConfigA

function didDownloadAssets
   if there is a file (the documents folder & "/assets.txt") then
      return true
   else
      return false
   end if
end didDownloadAssets

function getLocalAssetsChecksum
   if there is a file (the documents folder & "/assets.txt") then
      get url ("binfile:" & the documents folder & "/assets.txt")
      get word -1 of it
      return it
   else
      return false
   end if
end getLocalAssetsChecksum

function getRemoteAssetsChecksum
   get url kAssetsManifestURL
   if the result is not empty then
      return false
   end if
   get word -1 of it
   return it
end getRemoteAssetsChecksum

function shouldDownloadNewAssets
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
   tsNetInit
   put tsNetGetFile(kConnectionID, (the documents folder & "/assets.zip"), \
         kAssetsZipURL, tHeaders, "_transferComplete") into tResult
   send "_checkProgress" to me in 1 second
end downloadAssets

on _checkProgress
   put tsNetGetStatus(kConnectionID) into tStatus
   put tStatus
   if word 1 of tStatus is not "downloaded" then
      send "_checkProgress" to me in 2 seconds
   end if
end _checkProgress

on _transferComplete pID, pResult, pBytes, pCurlCode
   local tData, tHeaders
   if pCurlCode is not 0 then
      answer tsNetRetrError(pID)
   else
      answer "File has been downloaded"
   end if
   tsNetCloseConn pID
end _transferComplete
