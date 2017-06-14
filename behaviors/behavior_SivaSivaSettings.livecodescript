script "behavior_SivaSivaSettings"
/* 
June 12, 2017
Brahmanathaswami
This is the  behavior assigned to  the /modules/settings/settings.livecode stack
As such it can serve as the stack script
For mobile controls, set the behavior of the card with scrolling groups or other controls

This is a attempt to separate code from the UI as completely as possible.
Therefore create all logic here in this script and only use triggers in objects in the binary stack
*/

------------------------------------------------------------
-- displayInfo
--
-- DESCRIPTION
-- invoke the generic display-info group control
-- consists of: 
--    i) background image
--    ii) translucent field background
--    iii) field for text
--  All logic for the display is here  
-- We require a mobile scroller to applied also
-- The control is responsive, and that code is in the group script itself
--
-- PARAMETERS
-- pVis  1  or 0 for the visibility of the control; pass 0 to hide and exit
-- pSubject: main switch e.g. "About" "Policy"  "Sharing"
-- pBackground: path to image assets to be randomly selected
--  e.g. "bkgnds/nature/landscape/" (always pass a final slash)
--
-- CHANGES
-- 2017-06-12 Brahmanathaswami, created
--
------------------------------------------------------------------------

on displayInfo pVis, pSubject, pBackground
   
   
   if pVis = "1" then   # We are showing the control
      
      # set up bacckground image first, if no param then use landscapes as default
      
      if pBackground is empty then 
         put  "/bkgnds/nature/landscape/"  into pBackground
      end if
      
      put fetchRandomImageAsset (pBackground) into tImagePath  # see lib_SivaSivaMedia
      set the filename of img "info-bkgnd-img" to tImagePath
      
      # next insert the text we need, either stored on the app somewhere or from a web URL
      switch pSubject
         case "About"
            --test
            put "About" into fld "info-text"
            break
      end switch
      
      send "updateMyRect" to grp "display-info" # just in case we need to get the geometry updated.
      show grp "display-info" with visual effect dissolve very fast
      if the formattedheight of fld "info-text" > the height of fld "info-text" then
         send "CreateScroller info-text to fld "info-text"
      end if
   else
      hide grp "display-info" with visual effect dissolve very fast
      put empty into fld "info-text"
      deleteMobileControl "info-text" 
   end if
   
   
end displayInfo





