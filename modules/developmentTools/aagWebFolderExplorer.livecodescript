script "aagWebFolderExplorer"
local sPort = "8081"

command startFolderExplorer pPort
   put "starting web server"
   try
      httpdStart "_connectionHandler", pPort, "AAG Web Folder Explorer"
      if the result is not empty then
         throw "webexplorererr," & the result
         exit startFolderExplorer
      else
         put it into sPort
         log "started web folder explorer in port" && sPort
         launch url "http://localhost:" & sPort
      end if
   catch n
      repeat for each line t in n
         put t
      end repeat
   end try
end startFolderExplorer

command stopFolderExplorer
   httpdStop sPort
end stopFolderExplorer

on _connectionHandler pSocketID, pRequestA
   -- file flow
   if there is a file pRequestA["resource"] then
      get url ("binfile:" & pRequestA["resource"])
      httpdResponse pSocketID, 200, it
      exit _connectionHandler
   end if
   
   
   -- folder flow
   put pRequestA["resource"] into tFolder
   if tFolder is "/" then
      put the documents folder into tFolder
   end if
   if char -1 of tFolder is not "/" then
      put "/" after tFolder
   end if
   httpdResponse pSocketID, 200, _folderToHTML(tFolder)
end _connectionHandler

function _folderToHTML pFolder
 
   put folders(pFolder) into tFolderList
   put files(pFolder) into tFileList
   
   sort tFolderList
   sort tFileList
   
   put "<h2>Folders in <code>" &pFolder& "</code></h2>" into tBuf
   put "<ul>" after tBuf 
   repeat for each line tFolder in tFolderList
      put the merge of "<li><a href='[[pFolder]][[tFolder]]'>[[tFolder]]</a></li>" & CRLF after tBuf
   end repeat 
   put "</ul>" & crlf after tBuf
   
   put "<h2>Files in <code>" &pFolder& "</code></h2>" after tBuf
   put "<ul>" after tBuf 
   repeat for each line tFile in tFileList
      put the merge of "<li><a href='[[pFolder]][[tFile]]'>[[tFile]]</a></li>" & CRLF after tBuf
   end repeat 
   put "</ul>" & crlf after tBuf
   return tBuf
end _folderToHTML
