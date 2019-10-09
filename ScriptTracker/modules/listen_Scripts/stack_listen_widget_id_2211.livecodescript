Script "stack_listen_widget_id_2211"

/*
# Name: widget "search" of group "searchControls" of bkgnd "filterAudio" of stack "listen"
# ID: widget id 2211 of group id 2317 of bkgnd id 2176 of stack "listen"
# Widget Kind: com.livecode.widget.svgpath
*/


on mouseup
   focus on the mouseControl
   put the shortName of me into pTarget
   executeSearch pTarget
end mouseup
