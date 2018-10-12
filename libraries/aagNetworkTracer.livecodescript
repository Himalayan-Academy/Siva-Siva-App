script "aagNetworkTracer"

constant kDefaultPort = 8001
local sConfigA
local sMessagesA

on libraryStack
   if the target is not me then
      pass libraryStack
   end if
   
   put kDefaultPort into sConfigA["port"]
   put true into sConfigA["enabled"]
end libraryStack

on errodialog p1, p2
   ntInfo "error" && p1 && p2
end errodialog

command ntEnableNetworkTracker
   put true into sConfigA["enabled"]
end ntEnableNetworkTracker


command ntDisableNetworkTracker
   put false into sConfigA["enabled"]
end ntDisableNetworkTracker


private function _ntBroadcastPort
    return sConfigA["port"]
end _ntBroadcastPort

private function _ntListeningSocket
    return "255.255.255.255:" & _ntBroadcastPort()
end _ntListeningSocket


command ntBroadcast pData
   if sConfigA["enabled"] then
      set the allowDatagramBroadcasts to true
      open datagram socket to _ntListeningSocket()
      write pData to socket _ntListeningSocket() --with message "_ntUDPFinishedBroadcasting"
      close socket _ntListeningSocket()
   end if
end ntBroadcast

command ntInfo pContent
   put "info" into pDataA["type"]
   put pContent into pDataA["content"]
   ntBroadcast arrayToJson(pDataA)
   put pDataA["type"] &":" && pDataA["content"]
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
      put jsontoarray(pData) into tA
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
