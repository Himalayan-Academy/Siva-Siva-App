Script "stack_listen_widget_id_1973"

/*
# Name: widget "search" of bkgnd "search-filter" of stack "listen"
# ID: widget id 1973 of bkgnd id 1974 of stack "listen"
# Widget Kind: com.livecode.widget.svgpath
*/


global sConfigA

on mouseUp
   go to card "listen-search"
end mouseUp

-- put sConfigA["search"] into tSearchControl  

--    if (exists(group "searchControls" of this card) ) then 
--       revealSearchControls ("true")
--    else 
--       copy tSearchControl to this card 
--    end if 
