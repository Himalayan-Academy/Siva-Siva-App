script "sivasiva_LogBehavior"
--> Metadata
-
/*
This is the Siva-Siva-App's home logging script.

We have also moved all logging handlers to this behavior and use before and after handlers for logging.
This improves legibility, forces us to write the code in a nice modular fashion, the and allows us to simply remove all logging when we deploy.
*/

--> Logging | Custom
-
command jgAndroidLog  --jg: temporary for testing; sent from Home btn in Home stack  --### REMOVE
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


--> Logging | before and After
-
after _loadJsonConfig
   logInfo "App configuration loaded..."
end _loadJsonConfig

before _loadLibrary tStackPath, sharedLibFolder
   logInfo "Loading library" && tStackPath
end _loadLibrary

before _loadLibrary tStackPath, sharedLibFolder
   logInfo "Loading library" && tLibrary
end _loadLibrary

before _loadFrontScript tStackPath, sharedLibFolder
   logInfo "Loading frontscript" && tStackPath
end _loadFrontScript

before _loadBackScript tStackPath, sharedLibFolder
   logInfo "Loading backscript" && tStackPath
end _loadBackScript


--> Logging
-
/*
Basic loggin handlers.
Consider moving to a general library "lib_Logging"?
*/

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
      put the short date && the short time && "[" & pLevel & "]" && tObjectReference & "#" & tLineNumber into logLine
      put space & ">>>" && tCalledHandler  & tPrivateFlag && ":" && pMessage after logLine
      put CR & logLine after url ("binfile:" & sConfigA["log_file"])
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
