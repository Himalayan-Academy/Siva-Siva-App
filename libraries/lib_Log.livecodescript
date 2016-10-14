script "lib_Log"
--> MetaData
-
license: GPLv3
name: lib_Log
type: library
version: 0.2

/*
This library is designed for simple logging on mobile and desktop platforms.
This library implements system wide loggin functionality to track things like navigation history, and progress through a module / chapter / game.

== Important ==
We need to start logging before any libraries are loaded.
We must ensure this stack is the first to be used loaded first.

== Future ==
Early discussions considered the idea of using a general purpose logging library to track progress through the various SivaSiva modules.
Bookmarking, coverage of content for games and feedback could also use such a facility.
I defer to Andre on this for now? Should it be in the database, or an array based NoSQL model.
Anyway here is the place to develop a general purpose model for logging of progress through the app.
*/

--> Variables
-
/*
Rather than rely on an arbitary global variable - we should wrap all access to this library in public functions (an API)
and move to using other local forms of storage internally.
*/

global sConfigA


--> Workign on
-
command jgAndroidLog  --jg: temporary for testing; sent from Home btn in Home stack  --### REMOVE
   if (the platform = "android") and _androidIsLogging() then 
      put mobile_GetLogFile() into logFile
      answer "Clear or view log:" with "Cancel" or "Clear" or "View"
      if it = "view" then
         answer url ("file:" & logFile)
      else if it = "clear" then
         log_Clear
      end if
   end if
end jgAndroidLog

private function _androidIsLogging
   put the hilite of btn "jg android log" of cd 1 of stack "Siva-Siva-App" into isLogging
   return isLogging
end _androidIsLogging


--> Log | Utils
-
function log_GetLevelList
   put sConfigA ["log_level"] into logLevelList
   return logLevelList
end log_GetLevelList


--> Log
-
command log_Info pMessage
   log_Raw "info", pMessage
end log_Info

command log_Error pMessage
   log_Raw "error", pMessage
end log_Error

command log_Fatal pMessage
   log_Raw "fatal", pMessage
end log_Fatal

command log_Clear
   put log_GetFile() into logFile
   delete file logFile
end log_Clear

command log_Raw pLevel, pMessage
   put log_GetFile() into logFile
   put log_GetLevelList() into logLevelList
   
   -- simple logging for Android ?
   if the environment is not "development" and _androidIsLogging() is true then
      open file logFile for append
      write pMessage & CR to file logFile
      close file logFile
      return logFile
   end if
   
   -- general logging
   put item -2 of line -3 of the executioncontexts into tCalledHandler
   put item -1 of line -3 of the executioncontexts into tLineNumber
   put the short name of (item 1 of line -3 of the executioncontexts) into tObjectReference
   if char 1 of tCalledHandler is "_" then
      put " (PRIVATE)" into tPrivateFlag
   else
      put empty into tPrivateFlag
   end if
   
   if pLevel is among the items of logLevelList then
      put the short date && the short time && "[" & pLevel & "]" && tObjectReference & "#" & tLineNumber into logLine
      put space & ">>>" && tCalledHandler  & tPrivateFlag && ":" && pMessage after logLine
      
      put CR & logLine after url ("binfile:" & logFile)
      return logFile
   else
      return empty
   end if
end log_Raw


--> Log | Files
-
function log_GetFile
   if the environment is not "development" then
      return mobile_GetLogFile()
   else
      return desktop_GetLogFile()
   end if
end log_GetFile


--> Private
-
private function desktop_GetLogFile
   -- sivasiva.log
   put sConfigA ["log_file"] into logFile
   return logFile
end desktop_GetLogFile

private function mobile_GetLogFile
   put specialFolderPath ("documents") & "/mobilelog.txt" into logFile
   return logFile
end mobile_GetLogFile
