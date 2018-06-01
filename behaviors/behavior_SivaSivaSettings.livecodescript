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
      
      # set up background image first, if no param 
      # then use landscapes as default
      
      if pBackground is empty then 
         put  "bkgnds/nature/landscape/"  into pBackground
      end if
      put fetchRandomImageAsset(pBackground) into tImagePath  # see lib_SivaSivaMedia
      set the filename of img "info-bkgnd-img" to tImagePath
      
      # next insert the text we need, either stored on the app somewhere or from a web URL
      switch pSubject
         case "About"
            put path_Assets()&"info/about-siva-siva-app.html" into tTextPath
            set the htmltext of  fld "info-text" to url ("file:/" &tTextPath)
            break
         case "tos-privacy-eula"
            put path_Assets()&"info/privacy-tos-eula.html" into tTextPath
            set the htmltext of  fld "info-text" to url ("file:/" &tTextPath)
            break
         case "release-notes"
            put path_Assets()&"info/release-notes.html" into tTextPath
            set the htmltext of  fld "info-text" to url ("file:/" &tTextPath)
            break
         case "credits"
            put path_Assets()&"info/credits.html" into tTextPath
            set the htmltext of  fld "info-text" to url ("file:/" &tTextPath)
            break
         case "User Guide"
            portal_GoURL someURL ## youtube of mp4 later
            breadk
      end switch
      
      send "resizeControl" to grp "display-info" # just in case we need to get the geometry updated.
      show grp "display-info" with visual effect dissolve very fast
      if the formattedheight of fld "info-text" > the height of fld "info-text" then
         send "CreateScroller info-text" to fld "info-text"
      end if
   else
      hide grp "display-info" with visual effect dissolve very fast
      put empty into fld "info-text"
      deleteMobileControl "info-text" 
   end if
   
end displayInfo

on sendFeedBack
    revMail "studyhall@hindu.org",,"SivaSiva App Feedback",\
         ("Bug reports: Describe what happened and what you expected to happen. " & cr & "Feature requests: Describe your idea in as much detail as possible." &cr &"Thank you.") 
      end sendFeedBack
      
on fieldLinkClicked pLink
   switch pLink
      case "Terms of Service, Privacy Policy, EULA"
         displayInfo 1,"tos-privacy-eula"
         break
         # new link
      case "Release Notes"
         displayInfo 1,"release-notes"
         break
      case "Credits"
         displayInfo 1,"credits"
         break
      case "Send Feedback"
         sendFeedBack
         break
   end switch
end fieldLinkClicked





