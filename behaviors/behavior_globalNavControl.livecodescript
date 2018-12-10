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

local sRowName, sMa

on mouseup
   
   put the short name of the target into tTarget
   if tTarget is among the items of "gem,surprise,listen,look,practice,read,websites,fun,journal,my home,settings-gear" then
      put getNavigationMap() into sMap 
      switch tTarget
         # Cases where we to a stake with no secondary navigation
         case "Gems"
         case "Surprise"
         case "listen"
         case "Journal"
         case "Settings-Gear"
            portal_GoStack tTarget
            break
            
            # Cases  where we access to toolbar
         default
            setControlUI "level1"
            put sMap[portalData][tTarget][rowdata] into tRowdataA
            reSizeDataGrid (item 2 of extents(tRowdataA) )
            set dgData of grp "navMap"  to tRowdataA
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
         set the blendlevel of grp "globalNavTopLayer" to 0
         hide me
         hide grp "navMap"
         break
      case "baseLevel"
         hide grp "navMap"
         set the blendlevel of grp "globalNavTopLayer" to 0
         show grp "globalNavTopLayer"
         break
      case "level1"
         set the blendlevel of grp "globalNavTopLayer" to 80
         show grp "navMap"
         break
   end switch
end setControlUI

command reSizeDataGrid pNumOfRows
   set the height of group "navMap" of me to (45*pNumOfRows)
   set top of group "navMap" of me to 200
end reSizeDataGrid

--         # case which have a 1st level navigation
--         --put the dgHilitedLines of group "navMap" into theLine
--         --put the dgDataOfLine[theLine] of group "navMap" into theDataA

--         put pMap[portalData][sRowname][rowdata] into pRowdata
--         put extents(pRowData) 
--         set dgData of grp "navMap"  to pRowdata

--dispatch "ResetList" to group "navMap" 


--on mouseUp -- pBtnNum
--   --if pBtnNum is 1 then
--      put the dgHilitedLines of group "navMap" into theLine
--      put the dgDataOfLine[theLine] of group "navMap" into theDataA
--      ## theDataA is now an array variable.
--      ## In the case of the Data Grid pictured above the keys of the array are id, FirstName, LastName and Title.

--      ## This answer dialog will display: Dusty Bottoms
--      answer theDataA["rowName"] with "OK"

--end mouseUp







on savingMobileStandalone pTargetType, pAppBundle
   
end savingMobileStandalone
