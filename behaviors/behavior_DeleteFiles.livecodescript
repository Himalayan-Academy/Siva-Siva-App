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
      case "deleteOn"
            # we inform user 
            show fld "status"
            wait 200 milliseconds
            hide fld "status" with visual effect "dissolve" very slowly
            
            hide grp "search-filter"
            hide fld "collections-label"
         break 
   end switch
   
end mouseup
