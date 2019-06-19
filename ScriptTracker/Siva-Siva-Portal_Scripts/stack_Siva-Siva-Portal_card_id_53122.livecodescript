Script "stack_Siva-Siva-Portal_card_id_53122"

/*
# Name: card "modulesList" of stack "Siva-Siva-Portal"
# ID: card id 53122 of stack "Siva-Siva-Portal"
# Behavior: stack "behavior_globalNavControl"
*/


global sConfigA

on preopenCard
   local pControl
   
   lock screen
   setcardCoords
   audioIsRunning  
   
   put the long id of grp "modulesList" into pControl
   topCenterMe pControl,100
   put the long id of grp "footer" into pControl
   bottomCenterMe pControl,8
   pass preopencard
   unlock screen
end preopenCard

command showStories
   hide grp "globalNav"
end showStories

command tellUserToGetFavorites 
   doAnswer "There is nothing in My Home yet. Go to the Journal. Click the Star by some of your favorites. They will then appear in My Home", "OK","downloadAffirmed"
end tellUserToGetFavorites

command downloadAffirmed   
   portal_GoStack "Journal"
end downloadAffirmed
