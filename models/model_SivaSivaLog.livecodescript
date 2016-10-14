script "model_SivaSivaLog"
--> MetaData
-
license: GPLv3
name: model_SivaSivaLog
type: model
version: 0.2

/*
This library is designed for simple logging on mobile and desktop platforms.
This library implements system wide loggin functionality to track things like navigation history, and progress through a module / chapter / game.

== Important ==
We need to start logging before any libraries are loaded.
We must ensure this stack is the first to be used / loaded.

== Future ==
For now this is a specific library for the Siva-Siva-App.
We look to creating a general purpose "logging module" which works on mobile, server and desktop.
This module would be it's own project but can be included in any application as an npm style dependeny.

== Consierations ==
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
local LocalArray


--> Log | Files
-
function log_GetFile
   if the environment is "mobile" then
      put the documents folder & slash & "model_SivaSivaLog.txt" into logFile
      return logFile
   else
      -- put the model_DataFile ["model_SivaSivaLog.txt"] of stack "model_SivaSivaLog" into logFile
      put sivasiva_ProjectFolder ("models/model_SivaSivaLog/") & "model_SivaSivaLog.txt" into logFile
      return logFile
      
      put LocalArray ["logFile"] into logFile
      if logFile is empty then
         put the tempname & ".txt" into logFile
         put logFile into LocalArray ["logFile"]
      end if
      return logFile
   end if
end log_GetFile


--> Workign on
-
--> Log | Model
-
command log_AddLine pMessage, pLevel
   put item -2 of line -3 of the executioncontexts into tCalledHandler
   put item -1 of line -3 of the executioncontexts into tLineNumber
   put the short name of (item 1 of line -3 of the executioncontexts) into tObjectReference
   if char 1 of tCalledHandler is "_" then
      put " (PRIVATE)" into tPrivateFlag
   else
      put empty into tPrivateFlag
   end if
   put the short date && the short time && "[" & pLevel & "]" && tObjectReference & "#" & tLineNumber into logLine
   put space & ">>>" && tCalledHandler  & tPrivateFlag && ":" && pMessage after logLine
   
   log_Append logLine
   return the result
end log_AddLine

command log_Append logLines
   put log_GetFile() into logFile
   
   open file logFile for append
   write logLines & CR to file logFile
   close file logFile
   return the result
end log_Append

function log_Fetch
   put log_GetFile() into logFile
   
   -- put url ("binfile:" & logFile) into logLines
   open file logFile for read
   read from file logFile until EOF
   put it into logLines
   put the result into readResult
   close file logFile
   
   put readResult & CR & logFile & CR & CR & word 1 to -1 of logLines into logText
   return logText
end log_Fetch

command log_Store logLines
   put log_GetFile() into logFile
   -- put logLines into url ("binfile:" & logFile)
   open file logFile for write
   write logLines to file logFile
   close file logFile
   return logFile
end log_Store

command log_Clear
   put log_GetFile() into logFile
   put "Cleared log:" && the seconds into clearText
   
   -- put clearText into url ("binfile:" & logFile) -- does not work if file does not exist ???
   -- delete file logFile
   log_Store clearText
end log_Clear

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

command display_Log
   put the long id of cd "Log" of stack "Siva-Siva-App" into cardObject
   put log_Fetch() into fld "Result" of cardObject
   go to cd "Log" of stack "Siva-Siva-App"
end display_Log

function log_GetLevelList
   put sConfigA ["log_level"] into logLevelList
   return logLevelList
end log_GetLevelList

command  log_SetLevelList logLevelList
   if logLevelList = "all" then
      put "info,error,fatal" into logLevelList
   end if
   put logLevelList into sConfigA ["log_level"]
end log_SetLevelList

private function _androidIsLogging
   put the hilite of btn "jg android log" of cd 1 of stack "Siva-Siva-App" into isLogging
   return isLogging
end _androidIsLogging


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

command log_Raw pLevel, pMessage
   put log_GetLevelList() into logLevelList
   switch
      case the environment is not "development" and _androidIsLogging() is true
         log_Append pMessage
         put the result into logFile
         return logFile
      case pLevel is among the items of logLevelList
         log_AddLine pMessage, pLevel
         put the result into logFile
         return logFile
      default
         return empty
   end switch
end log_Raw
