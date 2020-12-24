script "behavior_DeleteFiles"
-----------------------------------------------------------------------
# UI Interactions | card, group, list, detail display change ups
-----------------------------------------------------------------------

on mouseup
   local pTarget, tTarget
   
   
   put long id of the target into pTarget
   put the short name of the Target  into tTarget   
   
   
   switch tTarget
      # card navigaton
      case "deleteOnOff"
         if (the hidden widget "deleteOff" is true) then
            turnOnDelete
         else
            turnOffDelete            
         end if
         break 
         
      case "deleteOff"
         turnOnDelete            
         break
         
   end switch
   
end mouseup

on turnOnDelete
   # we inform user 
   show fld "status"
   wait 200 milliseconds
   hide fld "status" with visual effect "dissolve" very slowly
   
   hide grp "search-filter"
   hide fld "collections-label"
   show widget "deleteOff" of me
end turnOnDelete

on turnOffDelete
   show grp "search-filter"
   show fld "collections-label"
   hide widget "deleteOff" of me
   
end turnOffDelete
