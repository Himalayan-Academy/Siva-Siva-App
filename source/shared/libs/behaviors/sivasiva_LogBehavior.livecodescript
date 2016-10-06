script "sivasiva_LogBehavior"
--> Logging | before and After
-
before _loadBehavior tStackPath, sharedLibFolder
   logInfo "Loading behavior is not needed" && tStackPath
end _loadBehavior
   
before _loadFrontScripts tStackPath, sharedLibFolder
   logInfo "Loading frontscript" && tStackPath
end _loadFrontScripts

before _loadBackScript tStackPath, sharedLibFolder
   logInfo "Loading backscript" && tStackPath
end _loadBackScript

before _loadLibrary tStackPath, sharedLibFolder
   logInfo "Loading library" && tStackPath
end _loadLibrary

before _loadLibrary tStackPath, sharedLibFolder
   logInfo "Loading library" && tLibrary
end _loadLibrary

after _loadJsonConfig
   logInfo "App configuration loaded..."
end _loadJsonConfig


--> Logging
-
command logInfo pMessage
   logRaw "info", pMessage
end logInfo

command logError pMessage
   logRaw "error", pMessage
end logError

command logFatal pMessage
   logRaw "fatal", pMessage
end logFatal

command logRaw pLevel, pMessage
   if the environment is not "development" then
      // for now, lets not log stuff in Mobile -- jg needs to see these
      if (the hilite of btn "jg android log" of cd 1 of stack "loader") then
         put specialFolderPath("documents") & "/mobilelog.txt" into tFile
         open file tFile for append
         write pMessage & cr to file tFile
         close file tFile
         exit logRaw
      end if
   end if
   
   put item -2 of line -3 of the executioncontexts into tCalledHandler
   put item -1 of line -3 of the executioncontexts into tLineNumber
   put the short name of (item 1 of line -3 of the executioncontexts) into tObjectReference
   
   if char 1 of tCalledHandler is "_" then
      put " (PRIVATE)" into tPrivateFlag
   else
      put empty into tPrivateFlag
   end if
   
   if pLevel is among the items of sConfigA["log_level"] then
      put (the short date && the short time && \
            "[" & pLevel & "]" && \
            tObjectReference & "#" &tLineNumber && ">>>" && tCalledHandler  & tPrivateFlag && \
            ":" && pMessage & cr) \
            after url ("binfile:" & sConfigA["log_file"])
  end if
end logRaw


--> Testing
-
command testMessagePath pMessage
   answer pMessage with "OK"
end testMessagePath


--> Android test builds (okay to remove later)
-
on savingStandalone -- pre-processss
  -- if not an Android app, turn off android logging
  put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
  set the hilite of btn "jg android log" of cd 1 of me to tIsAndroid
  set the vis of fld "logfld" of cd 1 of me to tIsAndroid
end savingStandalone

on standaloneSaved pFolder -- post-process
  -- increase build number for next time, turn logging back on
  -- Will be saved at next manual save, otherwise we don't want it anyway.
  put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
  if tIsAndroid then
    put the cRevStandaloneSettings["android,version code"] of me into tBuildNum
    add 1 to tBuildNum
    set the cRevStandaloneSettings["android,version code"] of me to tBuildNum
    
    set the hilite of btn "jg android log" of cd 1 of me to tIsAndroid
    set the vis of fld "logfld" of cd 1 of me to false
  end if
end standaloneSaved

on jgAndroidLog  --jg: temporary for testing; sent from Home btn in Home stack  --### REMOVE
  if (the platform = "android") and (the hilite of btn "jg android log" of me) then 
    put specialFolderPath("documents") & "/mobilelog.txt" into tFile
    answer "Clear or view log:" with "Cancel" or "Clear" or "View"
    if it = "view" then
      answer url ("file:" & tFile)
    else if it = "clear" then
      put empty into url ("file:" & tFile)
    end if
  end if
end jgAndroidLog


--> Junk
-
-- private command  _initializeDependencies
lock screen
set the itemdel to "/"
setBasePath -- jg
// load libraries
repeat for each key x in sConfigA["libraries"]
   put  sConfigA["libraries"][x] into tLibrary
   logInfo"Loading library" && tLibrary
   start using (getPathForSharedLibraries() & tLibrary)
end repeat

// load behavior stacks
// be aware that those stacks are just loaded but not applied.
repeat for each key x in sConfigA["behaviors"]
   put  sConfigA["behaviors"][x] into tStackPath
   put token -1 of tStackPath into tStackName
   replace ".livecode" with empty in tStackName
   
   logInfo"Loading behavior" && tStackPath
   --go stack (getPathForSharedLibraries() & tStackPath)
   get the short name of stack (getPathForSharedLibraries() & tStackPath)
   # still not available as a behavior in the ID  
   # later we will have to set stack files  
   # best practices TBD
end repeat

// load backscripts
repeat for each key x in sConfigA["backscripts"]
   put  sConfigA["backscripts"][x] into tStackPath
   put token -1 of tStackPath into tStackName
   replace ".livecode" with empty in tStackName
   
   logInfo"Loading backscript" && tStackPath
   --go stack (getPathForSharedLibraries() & tStackPath)
   --insert the script of stack tStackName into back
   insert the script of stack (getPathForSharedLibraries() & tStackPath) into back
end repeat

// load frontscripts
repeat for each key x in sConfigA["frontscripts"]
   put  sConfigA["frontscripts"][x] into tStackPath
   put token -1 of tStackPath into tStackName
   replace ".livecode" with empty in tStackName
   
   logInfo"Loading frontscript" && tStackPath
   --go stack (getPathForSharedLibraries() & tStackPath)
   --insert the script of stack tStackName into front
   insert the script of stack (getPathForSharedLibraries() & tStackPath) into front
end repeat
 _initializeDependencies

command loadAppConfiguration
   setBasePath -- jg
   
   if there is not a file "config.json" then
      answer  "Can't find configuration json file!!!" with "OK"
      exit to top
   end if
   
   get url "binfile:config.json"
   put jsonImport(it) into sConfigA
   
   -- logInfo "App configuration loaded..."
   
   put true into sConfigA ["initialized"]
   _initializeDependencies
   
   -- for testing a module we don't close or go anywhere
   -- if not dev() then close me
   -- goHome
end loadAppConfiguration



