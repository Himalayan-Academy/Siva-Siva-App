Script "stack_pathtosiva_widget_id_51281"

/*
# Name: widget "share" of bkgnd "homeScreensBottomNav" of stack "pathtosiva"
# ID: widget id 51281 of bkgnd id 51278 of stack "pathtosiva"
# Widget Kind: com.livecode.widget.svgpath
*/


global sConfigA

oon mouseUp
lock screen
put sConfigA["shareControl"] into tShareControl  

if (exists(group "share-ui" of this card) ) then 
   -- it has a preopencontrol which hides me
else
   copy tShareControl to this card 
end if
put the long id of group "share-ui" of this card into pControl
bottomCenterMe pControl

deleteMobileControl  "audioPlayer"
show group "share-ui" with visual dissolve very fast
unlock screen
end mouseUp
