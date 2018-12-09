script "behavior_globalNavControl"
###################
-- BR: 2018-12-4
-- the model for the global nav control 
-- which is be place on all card
-- for now will use the common library of SivaSivaPortal
-- all this need to do is call 
--  portal_DoRowLink tRowName
--  where to tRowName is the string we previous use
-- on the portals labels. 
-- not the string does now have a space. 

local sRowName

on openControl
   show grp "globalNavTopLayer"
end openControl

on mouseup
   put the short name of the target into sRowName
 
   switch sRowname
      # Cases where we to a stake with no secondary navigation
      case "Gems"
      case "Surprise"
      case "listen"
         portal_GoStack sRowname
         break
      case "globalNavBack"
         Answer "Would to close SivaSiva?" with "Yes" or "No"
         break
      case "closeGlobalNav"
         hide me
         show widget "openGlobalNav"
         break
      default
         portal_DoRowLink RowName
   end switch
end mouseup





