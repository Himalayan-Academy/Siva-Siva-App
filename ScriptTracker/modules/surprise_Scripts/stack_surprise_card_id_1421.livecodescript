Script "stack_surprise_card_id_1421"

/*
# Name: card "surprise_video" of stack "surprise"
# ID: card id 1421 of stack "surprise"
*/


on opencard
   
   setDefaultCard(the short name of this card)
   
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Connection required. Going to Verses"
      go to card "surprise_verses"
   else
      send getRandomVideo  to me in 200 milliseconds
   end if
end opencard


