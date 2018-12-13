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

local sRowName, sMap

on preopencontrol
   setControlUI "baseLevel"
end preopencontrol

on mouseup
   
   put the short name of the target into tTarget
   if tTarget is among the items of "gems,surprise,listen,look,practice,read,websites,fun,journal,my home,settings-gear" then
      put getNavigationMap() into sMap 
      switch tTarget
         # Cases where we to a stake with no secondary navigation
         case "Gems"
         case "Surprise"
         case "listen"
         case "look"
         case "Journal"
         case "Settings-Gear"
            portal_GoStack tTarget
            break
            
            # Cases  where we access to toolbar
         default
            
            put sMap[portalData][tTarget][rowdata] into tRowdataA
            set dgData of grp "navMap" of me to tRowdataA
            reSizeDataGrid 
            setControlUI "level1"
      end switch
      
   else #toolbar items
      
      switch tTarget
         case "globalNavBack"
            if (the vis of grp "navMap" is true)then
               setControlUI "baseLevel"
            else
               if the short name of this card = "home" then
                  Answer "Would to close SivaSiva?" with "Yes" or "No"
               end if
            end if
            break
         case "closeGlobalNav"
            setControlUI "close"
            break
      end switch
   end if
   
end mouseup

command setControlUI pState
   switch pState
      case "close"
         set the blendlevel of grp "globalNavTopLayer" of me to 0
         hide me
         hide grp "navMap" of me
         break
      case "baseLevel"
         hide grp "navMap" of me
         set the blendlevel of grp "globalNavTopLayer"  of me to 0
         show grp "globalNavTopLayer" of me
         break
      case "level1"
         set the blendlevel of grp "globalNavTopLayer"  of me to 80
         show grp "navMap" of me
         break
   end switch
end setControlUI

command reSizeDataGrid pNumOfRows
   put the dgNumberOfRecords of group "navMap" of me into tNumberOfRecords
   put the dgProp ["row height"] of group "navMap" of me into tRowHeight
   Set the height of group "navMap" of me to min(12, tNumberOfRecords) * (tRowHeight) + 36 -- account for header and scrollbar
   --set the height of group "navMap" of me to ( (67*pNumOfRows) )
   --set top of group "navMap" of me to 100
end reSizeDataGrid

command firstLevelNavigation 
   put the dgHilitedLines of group "navMap" into theLine
   put the dgDataOfLine[theLine] of group "navMap" into theDataA
   portal_DoRowLink theDataA["rowName"]
end firstLevelNavigation
