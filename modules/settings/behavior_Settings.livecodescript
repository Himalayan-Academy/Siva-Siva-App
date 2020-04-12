script "behavior_Settings"

on preopenstack
   
   if isMobile() then  
      --set the fullscreenMode of this stack to "showAll"  
      --mobileSetFullScreenRectForOrientations "landscape left,landscape right","0,0,414,736"
      mobileSetAllowedOrientations "portrait,portrait upside down"
      mobileShowStatusBar
   end if
   setCardCoords "portrait"
   # Livecode is terrible running animation 
   # Or I have yet to figure out the method, but Gif animation does not well.
   --runFishAnimation
end preopenstack


----------------------------------------------
--> displayInfo
-- DESCRIPTION: 
-- 2017-06-19: that control is only in the /module/settings/settings.livecode stack at the moment
-- PARAMETERS
-- pVis : 1 ="true" and we turn on the vis of the control after setting it up.
-- pSubject... use as a case in the switch to determine what info is placed in the display-text field
-- can call some html file like from /assets/info/*.html 
-- or could come from a specific module folder to a specific module "how to" info 
-- CHANGES:
-- 2017-06-12, Brahmanatahswami: created
------------------------------------------------
global sConfigA
local sShowTime,  tImagePath, tTextPath, someURL

on opencard
   audioIsRunning
end opencard



on mouseUp
   local tTarget, tCard, tGroupTarget
   put the short name of this card into tCard
   put the short name of the target into tTarget
   put the short name of the owner of the target into tGroupTarget
   
   if tTarget is "Close App" then
      doAnswer "Closing SivaSiva. Goodbye!","OK,Cancel","quitApp"
      exit mouseup
end if
   
   switch tCard
      case "settings-home"
         switch tGroupTarget
            case "footerNavigation"
               portal_GoStack ("Siva-Siva-Portal")
               break
               
         end switch
         break
         
      case "info"
         local tInfoText
         
         switch tGroupTarget
            case "footerNavigation"
               hideMe
               go to card "settings-home"
               break
               
            case "fontResizer"
               if the vis of fld "info-text" is true then
                  put the long id fld "info-text" into tInfoText
                  if the textSize of  tInfoText  = 28 then
                     set the textSize of tInfoText to 18
                  else
                     set the textsize of tInfoText  to (the textsize of tInfoText  + 2)
                  end if
               end if
               break
         end switch
         
         break      
   end switch
end mouseUp


on hideMe
   put empty into fld "info-text"
   set the textsize of fld "info-text" to 18
   deleteMobileControl "info-text" 
end hideMe





on displayInfo pVis, pSubject
   if pVis = "1" then   # We are showing the control
      lock screen
      
      # set up background image first, if no param 
      # then use landscapes as default
      
    
      
      # next insert the text we need, either stored on the app somewhere or from a web URL
      switch pSubject
         case "App News"
            put path_Documents() & "assets/info/siva-app-news.html" into tTextPath
            break
         case "About"
            put path_Assets()&"info/about-siva-siva-app.html" into tTextPath
            break
         case "tos-privacy-eula"
            put path_Assets()&"info/privacy-tos-eula.html" into tTextPath
            break
         case "release-notes"
            put path_Assets()&"info/release-notes.html" into tTextPath
            break
         case "credits"
            put path_Assets()&"info/credits.html" into tTextPath
            break
         case "User Guide"
            put path_Assets()&"info/user-guide.html" into tTextPath
            break
      end switch
      set the htmltext of  fld "info-text" to url ("file:" &tTextPath)
      
      # but for Android we had to take the field out!  It's on it's own layer on top of the card
      send "CreateScroller info-text" to fld "info-text"
      
      unlock screen
   else 
     put empty into fld "info-text"
      deleteMobileControl "info-text" 
   end if
   
end displayInfo


on closeStack
   portal_SetLastStack "settings"
   set the fullscreenmode of this stack to empty
   
end closeStack

command HandleToastDialog
   quit
end HandleToastDialog


on resizeStack x,y,ox,oy
   lock screen
   -- When coming from a landscape stack, card rect is not updated correctly
   -- and the resizeStack is called with a landscape rect.  If an answer is
   -- inserted here, a second resizeStack gets sent with the correct rect.
   setCardCoords "portrait"
   updateUISettings
   unlock screen
end resizeStack


#  UI responsive

on updateUISettings
   local tControl,  tBottomMargin, tMenuBkgnd, tTop, tBottom, tRect
 
   if safeBottomMargin() > 0 then
      put 0 into tBottomMargin
   else
      put 8 into tBottomMargin
   end if
   
   # graphic do not have a formatted width/height
   # so we can't use setImageToFullCardLoc
   
   put the long id of grc "settings-bkgnd"into tControl
   centerMe tControl
   
   put the long id of widget"turnOffAudio" into tControl
   topRightMe tControl,40,20
   
   
   
   switch (the short name of this card)
      
      case "settings-home"
         if isMobile() then
            mobileHideStatusBar
         end if
         
         put the long id of grp"settings-options-1" of me into tControl
         topLeftMe tControl,90,60
         
         put the long id of img "Logo" of me into tControl
         topLeftMe tControl,0,0
         
         put the long id of button "Close App" of me into tControl
         bottomLeftMe tControl,0,100
         
         put the long id of grp "footerNavigation" into tControl
         bottomLeftMe tControl,0,0
         break
         
      case "info"
         put the long id of grc "info-field-bkgnd" into tControl
         centerMe tControl
         
         # Brian: needs help/refactor to safe margins:
         
         put (15,30,CardWidth()-15,CardHeight()-70) into tRect
         put the long id of fld "info-text" of me into tControl
         set the rect of tControl to tRect
  
         
         put the long id of grp "fontResizer" into tControl
         bottomRightMe tControl,0,0
         
         break
         
   end switch
   
   
end updateUISettings





