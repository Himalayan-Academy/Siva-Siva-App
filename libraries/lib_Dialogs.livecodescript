script "lib_Dialogs"
--> MetaData
-
license: GPLv3
name: lib_Dialogs
type: library
version: 0.1

/*
This library is for handlers dealing with generic Siva-Siva-App popups messages, modal dialogs, status, UI feedback etc.

Adapted by Jacque Gay based on Scott Rossie's custom Messages script.

We should get all the params for setting the template field into an
array that we can change dynamically depending on tne context requirments.

*/


on closeMsg
   dialog_CustomMsg "false"
end closeMsg

on dialog_CustomMsg   pShow,pMsg
   -- pShow = boolean, show or hide msg grp
   
   -- pMsg = text to display, defaults to "Please wait..."; 
   -- height of msg displaychanges based on length
  
   if pShow <> false then -- show it
      if pMsg = "" then put "Please wait..." into pMsg 
      # assume some generic process; normally not advised to send empty
      put "350" into pWidth # locked to this width
         put the height of this cd into tV
         put tV - (tV div 4) into tV
         put (item 1 of the loc of this cd),tV into pLoc
         buildMsgDisplay pLoc,pMsg,pWidth  
         # we do not pass height; it is determined later based on formatted height of msg
   else -- clear all
      set the defaultstack to the topstack
      if there is a fld "alphaDisplayFld" then
         repeat until there is no fld "alphaDisplayFld"
            delete fld "alphaDisplayFld"
         end repeat
      end if
      if there is a grc "alphabkgnd" then
         repeat until there is no grc "alphabkgnd"
            delete grc "alphabkgnd"
         end repeat
      end if
   end if
end dialog_CustomMsg

on buildMsgDisplay pLoc,pMsg,pWidth-- revised from open source by Scott Rossi

   try 
      set the name of the templateGraphic to "alphabkgnd"
      set the backColor of the templateGraphic to black
      set the lineSize of the templateGraphic to 0
      set the style of the templateGraphic to roundrect
      set the opaque of the templateGraphic to true
      set the width of the templateGraphic to 400 
      set the blendLevel of the templateGraphic to 50
      set the loc of the templateGraphic to pLoc
      set the vis of the templateGraphic to false
      create grc
      
      reset the templateGraphic
      
      set the name of the templateField to "alphaDisplayFld"
      set the vis of the templateField to false # show later after resizeing backgroun d
      set the borderWidth of the templateField to 0
      set the opaque of the templateField to false
      set the traversalOn of the templateField to false
      set the locktext of the templateField to true
      set the autohilite of the templateField to false
      set the textFont of the templateField to "verdana"
      set the textSize of the templateField to 24
      set the textheight of the templateField to 36
      set the textColor of the templateField to white
      set the textAlign of the templateField to center
      set the text of the templateField to pMsg
      set the width of the templateField to 400
      set the loc of the templateField to pLoc
      create fld
      
      put the formattedHeight of fld "alphaDisplayFld"  into pHeight 
      set the height of fld "alphaDisplayFld"  to pHeight
      reset the templateField
      
      # adjust background and show
      set the height of grc "alphabkgnd" to (pHeight + 16)
      show grc "alphabkgnd"
      show fld "alphaDisplayFld"
      
   catch tErr
      put "Result:" && the result && "Error:" && tErr
      -- log tErr
   end try
   send  closeMsg to me in 1500 milliseconds
end buildMsgDisplay
  
