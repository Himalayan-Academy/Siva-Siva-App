Script "stack_settings_card_id_1002"

/*
# Name: card "settings-home" of stack "settings"
# ID: card id 1002 of stack "settings"
*/


on backKey -- jg: limit this or the app will exit
   if there is a grp "display-info" and the vis of grp "display-info" then
      hideMe
      go to card "setting-home"
   end if
end backKey


on quitApp
   quit
end quitApp

