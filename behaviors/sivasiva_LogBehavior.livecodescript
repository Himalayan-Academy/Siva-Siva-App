script "sivasiva_LogBehavior"
--> Metadata
-
/*
This is the Siva-Siva-App's home logging script.

We have also moved all logging handlers to this behavior and use before and after handlers for logging.
This improves legibility, forces us to write the code in a nice modular fashion, the and allows us to simply remove all logging when we deploy.
*/


--> Variables
-
global sConfigA


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
before _loadJsonConfig
   logInfo "About to load App configuration..."
end _loadJsonConfig

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
