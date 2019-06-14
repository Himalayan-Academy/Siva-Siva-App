Script "stack_wordpuzzles_widget_id_4164"

/*
# Name: widget "context" of card "word-puzzle" of stack "wordpuzzles"
# ID: widget id 4164 of card id 1028 of stack "wordpuzzles"
# Widget Kind: com.livecode.widget.svgpath
*/


--on mouseUp
--   if connectivity_PingServer() is "true" then
--      set the url of widget "readContext" to the uSourceURL of me     
--   else
--      dialog_CustomMsg "Offline or Low Bandwidth"
--      exit mouseup
--   end if
--    set the vis of widget "readContext" to (not the vis of widget "readContext")
--end mouseUp
