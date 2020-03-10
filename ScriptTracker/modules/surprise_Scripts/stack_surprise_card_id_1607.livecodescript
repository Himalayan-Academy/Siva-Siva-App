Script "stack_surprise_card_id_1607"

/*
# Name: card "surprise_video" of stack "surprise"
# ID: card id 1607 of stack "surprise"
*/


on opencard
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Connection required. Going to Verses"
      go to card "surprise_verses"
   else
      send "getRandomVideo"  to me in 200 milliseconds
   end if
end opencard


