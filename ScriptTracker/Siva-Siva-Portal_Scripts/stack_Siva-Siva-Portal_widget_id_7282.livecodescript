Script "stack_Siva-Siva-Portal_widget_id_7282"

/*
# Name: widget "share" of bkgnd "SivaSiva Portal Navigation" of stack "Siva-Siva-Portal"
# ID: widget id 7282 of bkgnd id 7279 of stack "Siva-Siva-Portal"
# Widget Kind: com.livecode.widget.svgpath
*/


global sConfigA

on mouseUp
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

