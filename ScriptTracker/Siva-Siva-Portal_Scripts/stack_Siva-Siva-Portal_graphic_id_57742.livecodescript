Script "stack_Siva-Siva-Portal_graphic_id_57742"

/*
# Name: graphic "share" of bkgnd "SivaSiva Portal Navigation" of stack "Siva-Siva-Portal"
# ID: graphic id 57742 of bkgnd id 7279 of stack "Siva-Siva-Portal"
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

