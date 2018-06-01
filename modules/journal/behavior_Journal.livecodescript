script "behavior_Journal"
local sConfigA

on preopenstack
   set the fullscreenmode of this stack to "showAll"
   
end preopenstack

on openstack
   put sivasiva_GetModuleConfigArray("journal") into sConfigA
end openstack


on backkey
   send mouseup to btn "go back"
end backkey

function getConfigForLayout pScreenIdentifier, pKey
   return sConfigA["style"][pScreenIdentifier][pKey]
end getConfigForLayout
 
on journalresume pDataA
   if the keys of pDataA is not empty then
      put jsonexport(pDataA) into pDataA
   end if
  -- answer "launched from journal" && pDataA
end journalresume

function crlist
   repeat with x = 1 to the paramcount()
      put param(x) & cr after tRetVal
   end repeat
   delete char -1 of tRetVal
   return tRetVal
end crlist

function randomElement
   repeat with x = 1 to the paramcount()
      put param(x) & cr after tRetVal
   end repeat
   delete char -1 of tRetVal
   return any line of tRetVal
end randomElement
