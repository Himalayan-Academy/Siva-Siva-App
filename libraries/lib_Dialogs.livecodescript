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
local sShowTime,  tImagePath, tTextPath, someURL
on displayInfo pVis, pSubject, pBackground
   if pVis = "1" then   # We are showing the control
      --lock screen
      
      # set up background image first, if no param 
      # then use landscapes as default
      
      if pBackground is empty then 
         put  "bkgnds/nature/landscape/"  into pBackground
      end if
      put fetchRandomImageAsset(pBackground) into tImagePath  # see lib_SivaSivaMedia
      set the filename of img "info-bkgnd-img" to tImagePath
      show image "info-bkgnd-img"
      wait 400 milliseconds
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
      
      send "resizeControl" to grp "display-info" # just in case we need to get the geometry updated.
      
      # but for Android we had to take the field out!  It's on it's own layer on top of the card
      
      
      show group "info-container" with visual "effect" dissolve very fast
      show widget "fontResize"
      show  fld "info-text" with visual scroll down very fast
      send "CreateScroller info-text" to fld "info-text"
      
   else 
      hide widget "fontResize" 
      hide  fld "info-text"
      hide group "info-container" with visual effect "dissolve" very fast
      hide image "info-bkgnd-img"
      deleteMobileControl "info-text" 
   end if
   
end displayInfo

on sendFeedBack
   local tRecipient,tSubject,tBody
   put "sivasiva@hindu.org" into tRecipient
   put "SivaSiva App Feedback" into tSubject
   put ("Bug reports: " & cr & cr & "Describe what you did: " & cr &cr \
         & "What happened: " & cr &cr & "What you expected to happen: " & cr &cr &cr \
         & "Feature requests: Describe your idea in as much detail as possible." &cr &"Thank you.")  into tBody
   if isMobile() then
      mobileComposeMail tSubject, tRecipient,,,tBody 
   else
      revMail tRecipient,,tSubject,tBody
   end if
end sendFeedBack

on fieldLinkClicked pLink
   --hide fld "info-text" # otherwise we get new page right away with no bkgnd
   switch pLink
      case "User-Manual"
         portal_GoURL "https://www.himalayanacademy.com/looklisten/apps/sivasiva/sivasiva_user-guide"
   end switch
end fieldLinkClicked

---------------------------------------
## Bottom Toast notification "snackbar" in android Material-UI



command dialog_CustomMsg pMsg,pBtn,pHandleAffirm
   if isMobile() then
      mobileClearTouches
   end if
   local tDialogControl, tLocalToast,tCdWidth,tCdHeight,tmsgLines
   local tBtnHeight, tDialogHeight
   # short notification at bottom of screen goes away of itself
   # use the DoAnswer option for more interactions.
   
   # first instantiate the group to the local context
   put sConfigA["bottomToast"] into tDialogControl
   if (exists(group "bottomToast" of this card) ) then 
      #  do nothing... assume vis of the group is off...
   else
      lock screen
      copy tDialogControl to this card
   end if
   put the long id  grp "bottomToast" of this card into tLocalToast
   # we are noti using buttons here.. but could inthe future, 
   # the guideline is to only offer a single choice, no icons
   # for now we keep the button Hidden
   
   if pBtn is empty then
      hide btn "DIALOGAFFIRM" of tLocalToast --of grp "botton"
      set the textalign of fld "lbl-dialogPrompt" of tLocalToast  to "center"
      set the textalign of line 1 of fld "lbl-dialogPrompt"  of tLocalToast  to "center"
   else
      set the label of btn "DIALOGAFFIRM" of tLocalToast  to pBtn
      set the textalign of fld "lbl-dialogPrompt"   of tLocalToast  to left
      set the textalign of line 1 of fld "lbl-dialogPrompt"   of tLocalToast  to left
   end if
   
   -- put "This is a one liner. message to the user. " into tMsg
   # resize dynamically to card width
   # relative to the bottom
   put the width of this card into tCdWidth
   put the height of this card into tCdHeight
   put pMsg into fld "lbl-dialogPrompt" of tLocalToast 
   put the number of lines of the formattedText of fld "lbl-dialogPrompt"  of tLocalToast  into tmsgLines
   set the width of fld "lbl-dialogPrompt"   of tLocalToast to tCdWidth
   set the left of fld "lbl-dialogPrompt"  of tLocalToast  to 0
   set the textcolor fld "lbl-dialogPrompt"  of tLocalToast   to 0,0,0
   # if the button is required just add height
   if the vis of  btn "DIALOGAFFIRM"  of tLocalToast   then
      put 24 into tBtnHeight
   end if 
   
   put ((the formattedHeight of fld "lbl-dialogPrompt"  of tLocalToast ) + tBtnHeight) into tDialogHeight
   set the height of fld "lbl-dialogPrompt"  of tLocalToast  to tDialogHeight
   set the bottom of fld "lbl-dialogPrompt"   of tLocalToast  to tCdHeight
   set the bottomright of btn "DIALOGAFFIRM"   of tLocalToast to tCdwidth-24,tCdheight-15
   set the top of  group "bottomToast"  to tCdHeight+400  # make sure it off screen
   
   if there is a widget "body" of this cd and CardWidth()>CardHeight() then
      set the top of widget "body" of this cd to -tDialogHeight+safeBottomMargin()
   end if
   
   unlock screen
   if isMobile() then
      mobileClearTouches
   end if
   show group "bottomToast"   
   move grp "BottomToast" relative 0,-(tDialogHeight+400) in 800 milliseconds
   set the layer of grp "BottomToast" to top 
   wait 1second
   if isMobile() then
      mobileClearTouches
   end if
   move grp "BottomToast" relative 0,tDialogHeight+400 in 400 milliseconds
   hide grp "BottomToast"
   delete grp "BottomToast"
   
   if there is a widget "body" of this cd and CardWidth()>CardHeight() then
      set the top of widget "body" of this cd to safeTopMargin()
   end if
end dialog_CustomMsg


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
   local tDialogControl,  tDoAnswer, tWidth, tHeight
   put pHandleAffirm into sHandleAffirm
   
   # copy the control
   
   # first instantiate the group to the local context
   put sConfigA["answerDialog"] into tDialogControl
   if (exists(group "answerDlgGrp" of this card) ) then 
      #  do nothing... assume vis of the group is off...
   else
      copy tDialogControl to this card
   end if
   
   put the id of grp "answerDlgGrp" of this card into tDoAnswer
   #  case there is some problem, exit without hanging
   if there is no grp "answerDlgGrp" then
      exit doAnswer
   end if
   
   # set  up text and buttons
   put pMsg into fld "lbl-dialogPrompt" of grp "answerDlgGrp"
   set the dialogData to empty -- init
   set the label of btn "dialogAffirm" of grp "answerDlgGrp" to toUpper(item 1 of pBtns)
   get item 2 of pBtns 
   # you leave out "Cancel"
   set the vis of btn "dialogCancel" of grp "answerDlgGrp" to (it <> "")
   set the label of btn "dialogCancel" of grp "answerDlgGrp" to toUpper(it)
   
   #geometry
   --breakpoint
   put CardWidth() into  tWidth
   put CardHeight() into tHeight
   set the rect of grc "cover" to 0,0,tWidth+25,tHeight+25
   set the loc of grc "cover" to CardLoc()
   set height fld "lbl-dialogPrompt" of grp "answerDlgGrp"  to (the formattedHeight of fld "lbl-dialogPrompt"  of grp "answerDlgGrp"+20)
   set the bottom of btn "dialogAffirm"  of grp "answerDlgGrp" to bottom of fld "lbl-dialogPrompt" of grp "answerDlgGrp"
   set the bottom of btn "dialogCancel"  of grp "answerDlgGrp" to bottom of fld "lbl-dialogPrompt" of grp "answerDlgGrp"
   set the loc of grp "promptGroup"  of grp "answerDlgGrp" to CardLoc()
   # show it
   --   put the long id of grp "answerDlgGrp" into pControl
   --   centerMe pControl
   set the vis of grc "cover" to true
   show grp "answerDlgGrp"
   show btn "dialogAffirm" of grp "answerDlgGrp"
   
   # cd must have a "[pHandleAffirm]" (eg.) handler to read dialogData and respond
   # it can be any name as it passed through param "pHandleAffirm" to 
   # via local sHandleAffirm
end doAnswer


-- To manage the response, use a [doAnswerResponse] { it can have any name) is passed by 
-- mouseup on the group "answerDigGrp"
--  It triggers either "cancel" or does whatever the handler passed  to the "pHandleAffirm"
-- which must in the card script or stack up that all the dialong.

command doAnswerResponse 
   # send by the buttons of   "answerDigGrp"
   get the dialogData
   if it contains "cancel" then
      exit to top
   else
     dispatch sHandleAffirm to this card
   end if
end doAnswerResponse


