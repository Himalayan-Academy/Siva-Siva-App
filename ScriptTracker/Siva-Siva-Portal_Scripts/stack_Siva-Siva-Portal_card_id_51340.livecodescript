Script "stack_Siva-Siva-Portal_card_id_51340"

/*
# Name: card "mainNav" of stack "Siva-Siva-Portal"
# ID: card id 51340 of stack "Siva-Siva-Portal"
# Behavior: stack "behavior_updateUIPortal"
*/


global sConfigA
local sStartLoc,sScreenRect

on preopenCard 
   hide button "goToMainNav" of group "footer" of me
   show button "goHome" of group "footer" of me
   news_Fetch
   audioIsRunning  
end preopenCard

command tellUserToGetFavorites 
   doAnswer "There are no Favorites in My Home yet. Go to the Journal." && \
         "Click the star by some of your Favorites. They will then appear in My Home", \
         "OK","downloadAffirmed"
end tellUserToGetFavorites

command downloadAffirmed   
   portal_GoStack "Journal"
end downloadAffirmed

