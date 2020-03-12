Script "stack_listen_bkgnd_id_2572"

/*
# Name: bkgnd "footerNavigation" of stack "listen"
# ID: bkgnd id 2572 of stack "listen"

# Background on card IDs: 1158, 1002, 2000, 2660, 2052
*/


global sConfigA

on mouseUp
   local tTarget, tShareControl, pControl, tMediaMetaData
   put the short name of the target into tTarget
   switch tTarget
      case "go-home-portal"
         
         switch (the short name of this card)
            case "listen-browse"   
            case "listen-my-audio"
               go  card "listen-collection"
               break
            case "listen-search"
               go  card "listen-browse" 
               break       
            default
               portal_GoStack ("Siva-Siva-Portal")
         end switch
         break
         
      Case "settings-gear"
         portal_GoStack "settings"
         break
         
      case "share"
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
         show group "share-ui" with visual "dissolve" very fast
         unlock screen
         break
         
      case "add-favorites"
         move control target relative 0,-100 in 200 milliseconds
         move control target relative 0,100 in 70 milliseconds
         addJournalEntry
         
         
         break
   end switch
end mouseup

