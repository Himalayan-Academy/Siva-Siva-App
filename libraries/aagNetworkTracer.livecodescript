script "aagNetworkTracer"
/*
aagNetworkTracer
by: Andre Garzia <andre@andregarzia.com>
version: 2.0

- Changes v2.0:
* Adding ADB support
*/
constant kDefaultPort = 8001
local sConfigA
local sMessagesA

on libraryStack
   if the target is not me then
      pass libraryStack
   end if
   
   set the lockErrorDialogs to true
   
   put kDefaultPort into sConfigA["port"]
   put true into sConfigA["enabled"]
end libraryStack

command ntEnableNetworkTracer
   put true into sConfigA["enabled"]
end ntEnableNetworkTracer


command ntDisableNetworkTracer
   put false into sConfigA["enabled"]
end ntDisableNetworkTracer


private function _ntBroadcastPort
   return sConfigA["port"]
end _ntBroadcastPort

private function _ntListeningSocket
   return "255.255.255.255:" & _ntBroadcastPort()
end _ntListeningSocket


command ntBroadcast pDataA, pContextA
   if sConfigA["enabled"] then
      set the allowDatagramBroadcasts to true
      put the short date && the long time into pDataA["time"]
      if the keys of pContextA is empty then
         put _parsedContext(line -3 of the executionContexts) into tContextA
         repeat for each key k in tContextA
            put tContextA[k] into pDataA[k]
         end repeat
      else
         repeat for each key k in pContextA
            put pContextA[k] into pDataA[k]
         end repeat
      end if
      
      --
      try
         set the itemdel to "of "
         get item -1 of pDataA["object"]
         get the short name of it
         put "stack" && quote & it & quote into item -1 of  pDataA["object"]
         --
         if pDataA["behavior"] is not empty then
            set the itemdel to "of "
            get item -1 of pDataA["behavior"]
            get the short name of it
            put "stack" && quote & it & quote into item -1 of  pDataA["behavior"]
         end if
      catch n
      end try
      --
      put jsonexport(pDataA) into tData
      open datagram socket to _ntListeningSocket()
      write tData to socket _ntListeningSocket() --with message "_ntUDPFinishedBroadcasting"
      close socket _ntListeningSocket()
      if the environment is not "development" then
         put tData
      end if
   end if
end ntBroadcast

command ntInfo pContent
   put "info" into pDataA["type"]
   put pContent into pDataA["content"]
   
   ntBroadcast pDataA
end ntInfo

private on _ntUDPFinishedBroadcasting pSocketID
   close socket pSocketID
end _ntUDPFinishedBroadcasting

command ntReceiveNetworkTracerBroadcasts pMessage, pLongID
   accept datagram connections on port _ntBroadcastPort() with message "_ntBroadcastCallback"
   if pMessage is empty then
      put "networkTracerMessage" into pMessage
   end if
   
   if pLongID is empty then
      put the long id of the target into pLongID
   end if
   
   put pMessage into sConfigA["trace message"]
   put pLongID into sConfigA["trace target"]
end ntReceiveNetworkTracerBroadcasts

on _ntBroadcastCallback pSocketID, pData
   try
      put jsonimport(pData) into tA
      _ntProcessMessage tA
   catch m
   end try
   
end _ntBroadcastCallback

private command _pushToArray pItemA, pDestinationA
   put pItemA into pDestinationA[the number of lines in the keys of pDestinationA + 1]
end _pushToArray


private command _ntProcessMessage pMessageA
   _pushToArray pMessageA, sMessagesA
   dispatch sConfigA["trace message"] to sConfigA["trace target"] with pMessageA
end _ntProcessMessage

function ntGetMessages
   return sMessagesA
end ntGetMessages

on errorDialog p1
   try
      local tContextArray
      local tHandler, tLineNumber, tObject
      
      --      put _parsedContext(line 3 of p1) into tContextArray
      put item 2 of line 1 of p1 into tContextArray["line"]
      set the itemdel to comma
      repeat  with k = 1 to the number of lines in p1
         if item 1 of line k of p1 is 353 and tContextArray["object"] is empty then
            put item -1 of line k of p1 into tContextArray["object"]
         end if
         if item 1 of line k of p1 is 241 and tContextArray["handler"] is empty then
            put item -1 of line k of p1 into tContextArray["handler"]
         end if
      end repeat
      
      
      put line 1 of p1 into tDataA["content"]
      put "error" into tDataA["type"]
      
      --   answer error p1
      ntBroadcast tDataA, tContextArray
   catch n
      answer n
   end try
end errorDialog

private function _parsedContext pContextLine
   local tKey = "object", tContextA
   
   repeat for each item tItem in pContextLine
      if tContextA[tKey] is not empty then
         put comma after tContextA[tKey]
      end if
      put tItem after tContextA[tKey]
      
      switch tKey
         case "object"
            if exists(tContextA[tKey]) then
               put "handler" into tKey
            end if
            break
         case "handler"
            put "line" into tKey
            break
         case "line"
            put "behavior" into tKey
            break
      end switch
   end repeat
   return tContextA
end _parsedContext
