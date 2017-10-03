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
----------------------------------------------
--> displayInfo
-- DESCRIPTION: 
-- used by the group control "display-info"  for showing text on top of any card in any stack
-- 2017-06-19: that control is only in the /module/settings/settings.livecode stack at the moment
-- some time we may move it to a generic location and copy on demand when needed.
-- for now if you need it, make a copy to your stack, It is normally hidden and is responsive.
-- PARAMETERS
-- pVis : 1 ="true" and we turn on the vis of the control after setting it up.
-- pSubject... use as a case in the switch to determine what info is placed in the display-text field
-- can call some html file like from /assets/info/*.html 
-- or could come from a specific module folder to a specific module "how to" info 
-- CHANGES:
-- 2017-06-12, Brahmanatahswami: created
------------------------------------------------
global sConfigA
local sShowTime
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
            set the htmltext of  fld "info-text" to url ("file:" &tTextPath)
            break
         case "tos-privacy-eula"
            put path_Assets()&"info/privacy-tos-eula.html" into tTextPath
            set the htmltext of  fld "info-text" to url ("file:" &tTextPath)
            break
         case "release-notes"
            put path_Assets()&"info/release-notes.html" into tTextPath
            set the htmltext of  fld "info-text" to url ("file:" &tTextPath)
            break
         case "credits"
            put path_Assets()&"info/credits.html" into tTextPath
            set the htmltext of  fld "info-text" to url ("file:" &tTextPath)
            break
         case "User Guide"
            portal_GoURL someURL ## youtube of mp4 later
            breadk
      end switch
      
      send "resizeControl" to grp "display-info" # just in case we need to get the geometry updated.
      # but for Android we had to take the field out!  It's on it's own layer on top of the card
      show grp "display-info" with visual effect  dissolve very fast
      show  fld "info-text" with visual scroll down very fast
      if the formattedheight of fld "info-text" > the height of fld "info-text" then
         set the layerMode of grp "info-container" to "scrolling" -- jg
         send "CreateScroller info-text" to fld "info-text"
      end if
   else
      put empty into fld "info-text"
      hide grp "display-info" with visual effect dissolve very fast
      hide  fld "info-text"
      deleteMobileControl "info-text" 
   end if
   
end displayInfo

on sendFeedBack
   revMail "sivasiva@hindu.org",,"SivaSiva App Feedback",\
   ("Bug reports: " & cr & cr & "Describe what you did: " & cr &cr & "What happened: " & cr &cr & "What you expected to happen: " & cr &cr &cr & "Feature requests: Describe your idea in as much detail as possible." &cr &"Thank you.") 
end sendFeedBack

on fieldLinkClicked pLink
   hide fld "info-text" # otherwise we get new page right away with no bkgnd
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
      case "About"
         displayInfo 1,"about"
         break
      case "Send Feedback"
         sendFeedBack
         break
   end switch
end fieldLinkClicked

---------------------------------------
## Bottom Toast notification "snackbar" in android Material-UI



command dialog_CustomMsg pMsg,pBtn,pHandleAffirm
   
   # first instantiate the group to the local context
   put sConfigA["bottomToast"] into tDialogControl
   if (exists(group "bottomToast" of this card) ) then 
      #  do nothing... assume vis of the group is off...
   else
      copy tDialogControl to this card
   end if
   
   # we are not using buttons here.. but could inthe future, 
   # the guideline is to only offer a single choice, no icons
   # for now we keep the button Hidden
   
   --    put the long id of group "bottomToast" of card "dialog_CustomMsg" of stack "lib_CustomControls" into sConfigA["bottomToast   put "This is a message to the user. You have some really marvelous news!" into tMsg
   if pBtn is empty then
      hide btn "DIALOGAFFIRM"  
      set the textalign of fld "lbl-dialogPrompt" to center
      set the textalign of line 1 of fld "lbl-dialogPrompt" to center
   else
      set the label of btn "DIALOGAFFIRM" to pBtn
      set the textalign of fld "lbl-dialogPrompt" to left
      set the textalign of line 1 of fld "lbl-dialogPrompt" to left
   end if
   
   -- put "This is a one liner. message to the user. " into tMsg
   # resize dynamically to card width
   # relative to the bottom
   put the width of this card into tCdWidth
   put the height of this card into tCdHeight
   put pMsg into fld "lbl-dialogPrompt"
   put the number of lines of the formattedText of fld "lbl-dialogPrompt" into tmsgLines
   
   if tMsgLines > 1 then
      set the margins of fld "lbl-dialogPrompt" to 24,20,24,24
   else
      set the margins of fld "lbl-dialogPrompt" to 24,19,24,27
   end if
   set the width of fld "lbl-dialogPrompt" to tCdWidth
   set the left of fld "lbl-dialogPrompt" to 0
   
   # if the button is required just add height
   if the vis of  btn "DIALOGAFFIRM" then
      put 24 into tBtnHeight
   end if 
   
   put ((the formattedHeight of fld "lbl-dialogPrompt") + tBtnHeight) into tDialogHeight
   set the height of fld "lbl-dialogPrompt" to tDialogHeight
   set the bottomright of btn "DIALOGAFFIRM" to tCdwidth-24,tCdheight-8
   set the top of  group "bottomToast" to tCdHeight
   -- set the bottom of fld "lbl-dialogPrompt"  to tCdHeight
   show group "bottomToast"
   move grp "BottomToast" relative 0,-tDialogHeight in 200 milliseconds
   wait 1 seconds
   move grp "BottomToast" relative 0,tDialogHeight in 200 milliseconds
   hide grp "BottomToast"
   delete grp "BottomToast"
end dialog_CustomMsg


on closeMsg pControl

end closeMsg


#Scott Rossi older option, deprecated...
-- on dialog_CustomMsg   pShow,pMsg,pShowtime
--    if pShowtime is not empty then
--       put pShowtime into sShowtime
--    else
--       put 1500 into sShowTime
--    end if

--    -- pShow = boolean, show or hide msg grp

--    -- pMsg = text to display, defaults to "Please wait..."; 
--    -- height of msg displaychanges based on length

--    if pShow <> "false" then -- show it
--       if pMsg = "" then put "Please wait..." into pMsg 
--       # assume some generic process; normally not advised to send empty
--       put "350" into pWidth # locked to this width
--       put the height of this cd into tV
--       put tV - (tV div 4) into tV
--       put (item 1 of the loc of this cd),tV into pLoc
--       buildMsgDisplay pLoc,pMsg,pWidth  
--       # we do not pass height; it is determined later based on formatted height of msg
--    else -- clear all
--       set the defaultstack to the topstack
--       if there is a fld "alphaDisplayFld" then
--          repeat until there is no fld "alphaDisplayFld"
--             delete fld "alphaDisplayFld"
--          end repeat
--       end if
--       if there is a grc "alphabkgnd" then
--          repeat until there is no grc "alphabkgnd"
--             delete grc "alphabkgnd"
--          end repeat
--       end if
--    end if
-- end dialog_CustomMsg

-- on buildMsgDisplay pLoc,pMsg,pWidth-- revised from open source by Scott Rossi
--    try 
--       set the name of the templateGraphic to "alphabkgnd"
--       set the backColor of the templateGraphic to black
--       set the lineSize of the templateGraphic to 0
--       set the style of the templateGraphic to roundrect
--       set the opaque of the templateGraphic to true
--       set the width of the templateGraphic to 400 
--       set the blendLevel of the templateGraphic to 50
--       set the loc of the templateGraphic to pLoc
--       set the vis of the templateGraphic to false
--       create grc

--       reset the templateGraphic

--       set the name of the templateField to "alphaDisplayFld"
--       set the vis of the templateField to false # show later after resizeing backgroun d
--       set the borderWidth of the templateField to 0
--       set the opaque of the templateField to false
--       set the traversalOn of the templateField to false
--       set the locktext of the templateField to true
--       set the autohilite of the templateField to false
--       set the textFont of the templateField to "verdana"
--       set the textSize of the templateField to 24
--       set the textheight of the templateField to 36
--       set the textColor of the templateField to white
--       set the textAlign of the templateField to center
--       set the text of the templateField to pMsg
--       set the width of the templateField to 400
--       set the loc of the templateField to pLoc
--       create fld

--       put the formattedHeight of fld "alphaDisplayFld"  into pHeight 
--       set the height of fld "alphaDisplayFld"  to pHeight
--       reset the templateField

--       # adjust background and show
--       set the height of grc "alphabkgnd" to (pHeight + 16)
--       show grc "alphabkgnd"
--       show fld "alphaDisplayFld"

--    catch tErr
--       put "Result:" && the result && "Error:" && tErr
--       -- log tErr
--    end try
--    send "closeMsg" to this stack in sShowTime milliseconds 
-- end buildMsgDisplay

-----------------------------------
# BY Jacqueline Landman Gay
# updated by Brahmanathaswamit Aug 2017
/*

Note that Android usually disables and dims the screen while a dialog is up. There is 
a graphic named "cover" on the "Show a dialog" stack that handles this, which you
should copy to the card. The dialog group should be layered above all other visible controls
and the cover graphic should be one layer below the dialog group.

Note that the order of the button names is reversed from the LC convention.
PARAMS:
pMsg: max two lines  90Chars is enough...
pBtns
JQ: Note that the order of the button names is reversed from the LC convention.
pHandleAffirm
BR: instead of putting the doAnswerResponse into every stack or card that uses this grp
We pass the handler to be used when invoking the dialog, save in local and dispatch back
In the calling handlers the old method was to trap for "it" and proceed with the script if it was "Yes" 
But now you break out your response script to its own handler, which is better coding anyway.
e.g. in the audio playlis card we do this

doAnswer "Download this audio file?", "Download,Cancel","downloadAffirmed"
end downloadSelection

on downloadAffirmed
   go stack "view_Download"
   dispatch "downloadURL"  to stack "view_Download" with  pTitle,sSelectedURL,sSelectNum,sLastTarget
end downloadAffirmed

This library dispatches that back to the calling handler.

*/
local sHandleAffirm

command doAnswer pMsg,pBtns,pHandleAffirm
       put pHandleAffirm into sHandleAffirm
   # first instantiate the group to the local context
   put sConfigA["answerDialog"] into tDialogControl
   if (exists(group "answerDlgGrp" of this card) ) then 
      #  do nothing... assume vis of the group is off...
   else
      copy tDialogControl to this card
   end if
   -- pMsg = prompt
   -- pBtns = comma-delimited names of up to 2 btns to show;
   if there is no grp "answerDlgGrp" then
      exit doAnswer
   end if
   set the dialogData to empty -- init
   put pMsg into fld "lbl-dialogPrompt" of grp "answerDlgGrp"
   set the label of btn "dialogAffirm" of grp "answerDlgGrp" to toUpper(item 1 of pBtns)
   get item 2 of pBtns
   set the vis of btn "dialogCancel" of grp "answerDlgGrp" to (it <> "")
   set the label of btn "dialogCancel" of grp "answerDlgGrp" to toUpper(it)
   
   show grp "answerDlgGrp" -- cd must have a "doAnswerResponse" handler to read dialogData and respond
end doAnswer


-- To manage the response, use a "doAnswerResponse" handler like this in the card or stack script:


command doAnswerResponse -- sent from doAnswer dlg
   get the dialogData
   if it contains "cancel" then
      exit to top
   else
     dispatch sHandleAffirm to this card
   end if
end doAnswerResponse
