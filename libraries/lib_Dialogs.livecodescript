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

on dialog_CustomMsg Show,Msg,pLoc,pWidth,pHeight
  -- pShow = boolean, show or hide msg grp
  -- pLoc = cd loc for display placement; defaults to 1/4 up from bottom center
   -- pMsg = text to display, defaults to "Getting files"; room for only a couple of words
   --BR: set other defaults in case you just have a short msg
   
  if Show <> false then -- show it
     if Msg = "" then put "Getting files..." into pMsg
     if pWidth = "" then put "350" into pWidth
       if pHeight = "" then put "50" into pHeight
    if pLoc = "" then
      put the height of this cd into tV
      put tV - (tV div 4) into tV
      put (item 1 of the loc of this cd),tV into pLoc
    end if
    buildMsgDisplay pLoc,Msg,pWidth,pHeight
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

on buildMsgDisplay pLoc,Msg,pWidth,pHeight -- revised from open source by Scott Rossi
   -- pLoc = loc for display
   -- Msg = text string to display
   try
      set the name of the templateGraphic to "alphabkgnd"
      set the backColor of the templateGraphic to black
      set the lineSize of the templateGraphic to 0
      set the style of the templateGraphic to roundrect
      set the opaque of the templateGraphic to true
      set the width of the templateGraphic to 400 
      set the height of the templateGraphic to pHeight +16
      set the blendLevel of the templateGraphic to 50
      set the loc of the templateGraphic to pLoc
      create grc
      reset the templateGraphic
      set the name of the templateField to "alphaDisplayFld"
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
      set the text of the templateField to Msg
      set the width of the templateField to 400
      set the height of the templateField to pHeight
      set the loc of the templateField to pLoc
      create fld
      reset the templateField
        catch tErr
          put "Result:" && the result && "Error:" && tErr
      log tErr
     end try
   end buildMsgDisplay
