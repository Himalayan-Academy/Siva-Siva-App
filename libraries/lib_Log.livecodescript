script "lib_Log"
--> MetaData
-
license: GPLv3
name: lib_Log
type: library
version: 0.1

/*
This library is designed for simple logging on mobile and desktop platforms.
*/


--> Working on
-
function mobile_LogFile
   if the environment is not "development" then
      put specialFolderPath ("documents") & "/mobilelog.txt" into logFile
   else
      put sConfigA ["log_file"] into logFile
   end if
   return logFile
end mobile_LogFile


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
   put the params
   
   if the environment is not "development" then
      // for now, lets not log stuff in Mobile -- jg needs to see these
      if (the hilite of btn "jg android log" of cd 1 of stack "loader") then
         put specialFolderPath ("documents") & "/mobilelog.txt" into tFile
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
