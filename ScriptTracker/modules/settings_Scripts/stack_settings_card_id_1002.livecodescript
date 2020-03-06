Script "stack_settings_card_id_1002"

/*
# Name: card "settings-home" of stack "settings"
# ID: card id 1002 of stack "settings"
*/


--> Variables

local sOnline
--> Events



on openCard
   News_Fetch
   
   set the acceleratedRendering of this stack to true
   audioIsRunning  
   send "showNewNews" to me in 500 milliseconds
end opencard


command showNewNews
   set the vis of widget "newNews" to news_Check()
end showNewNews


on backKey -- jg: limit this or the app will exit
  if there is a grp "display-info" and the vis of grp "display-info" then
    displayInfo 2 -- hide it
  end if
end backKey

command fetchInfo pInfo
   if isMobile() then
      
      # there is no way to dynamically fetch the new formatted height if the
      # info text is longer than the last one. Our only option is to delete
      # and recreate the mobilescroller on the fly      
      send "deleteMobileControl info-text" to fld "info-text"
      # recreate:
      if the formattedheight of fld "info-text" > the height of fld "info-text" then
         send "CreateScroller info-text"  to fld "info-text"
      end if      
   end if
end fetchInfo

on quitApp
   quit
end quitApp

