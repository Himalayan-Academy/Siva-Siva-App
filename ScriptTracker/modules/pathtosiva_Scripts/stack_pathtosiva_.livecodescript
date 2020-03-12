Script "stack_pathtosiva_"

/*
# Name: stack "pathtosiva"
# ID: stack "pathtosiva"
# Behavior: button id 1251 of stack "pathToSiva"
*/


local sLastActivityA,sStackPendingMessagesA

on setLastactivity pCdName, pLessonNum   
   # never set this if moving to cards: cover, photo index, choose your path
   # for about and glossary we don't pass a lesson number.
   put pCdName into sLastActivityA["CdName"]
   put pLessonNum into sLastActivityA["LessonNum"]
end setLastactivity

on preOpenStack
   if isMobile() then
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preOpenStack

on preOpenCard
   updateUI
end preOpenCard

on openStack
   set the acceleratedRendering of this stack to "true"
   if getPhoneModel() is "iPhoneX" then
      mobileShowStatusBar
   end if
end openStack

on opencard
   audioIsRunning  
end opencard

on resizeStack
   setCardCoords
   updateUI
end resizeStack

on closestack
   portal_SetLastStack "pathtosiva"
   ntinfo "Closing PtS, Lockscreen is: " & the lockscreen
end closestack

on closeCard
   deleteCardMobileControls
end closeCard

--command addJournalEntry -- save a bookmark to db
--   local tTitle, pData
--   put "photo index" into pData["card"]
--      put toUpper(char 1 of tTitle) into char 1 of tTitle -- cap first letter
--   Journal_RecordEntry "pathtosiva","Path to Siva - Photo Index",pData -- send to journal
--end addJournalEntry


--on journalResume pData -- sent from journal stack
--   local tCd
--   put pData["card"] into tCd
--   goCd tCd
--end journalResume

command addJournalEntry -- save a bookmark to db
   local tCdName,pData,tLessonNum,tTitle
   put sLastActivityA["CdName"] into tCdName
   put tCdName into pData["card"] -- store the last user cd   
   if tCdName = "lessonView" then -- store the lesson number
      put sLastActivityA["LessonNum"] into tLessonNum
      --- if tLessonNum is not an integer then put 0 into tLessonNum -- intro cd
      put tLessonNum into pData["lessonNum"]
      put "Lesson " & tLessonNum into tTitle -- "lesson x"
      if tLessonNum = 0 then
         put "Introduction" into tTitle
      end if
   else
      put tCdName into tTitle
      put toUpper(char 1 of tTitle) into char 1 of tTitle -- cap first letter
   end if
   Journal_RecordEntry "pathtosiva",tTitle,pData -- send to journal
   dialog_CustomMsg "Saved to Journal"
end addJournalEntry

on journalResume pData,pEntryA -- sent from journal stack
   local tCd,tNum
   close stack "journal"
   put pData["card"] into tCd
   if tCd begins with "lesson" then
      put pData["lessonNum"] into tNum
      put tCd && tNum into tCd
   end if
   goCd tCd
end journalResume


command goCd pCdName,pEffect -- optional effect param
   local tIslesson
   ntInfo pCdName && pEffect
   if pCdName is empty then
      ntInfo "tried going to empty card"
      exit goCd
   end if
   if the short name of this cd = pCdName then exit goCd
   if pEffect = "" then put "plain" into pEffect
   put (pCdName begins with "lesson") into tIslesson
   lock screen for visual effect
   if there is a cd pCdName then
      go cd pCdName
   else if tIslesson then
      go cd "lessonView"
      send "loadLesson (word 2 of pCdName)" to this cd
   else if pCdName = "home" then -- return to project
      put "push right" into pEffect
      portal_GoStack "Siva-Siva-Portal"
      unlock screen with visual effect pEffect fast
      exit goCd
   end if
   toggleHeader not tIslesson and (the number of cd pCdName > 2)
   unlock screen with visual effect pEffect fast
end goCd


local sMenuLine = 0 -- current cd's TOC line, tracked for text hiliting

command toggleMenu
   local tMenu,tRect,tLineNum,tName
   
   put the long id of grp "menuGrp" into tMenu
   put the rect of tMenu into tRect
   subtract 7 from item 1 of tRect -- for shadow
   lock screen for visual effect in rect tRect
   set the textcolor of line sMenuLine of fld "toc" to empty
   if tocVisible() then -- onscreen
      deleteMobileControl (the short name of tMenu)
      hide tMenu -- avoid shadow artifacts
      unlock screen with visual effect "reveal right" fast-- need different effects depending on direction
      put the hilitedline of fld "toc" into tLineNum
      set the backcolor of line tLineNum of fld "toc" to the metadata of line tLineNum of fld "toc" -- restore
      set the textcolor of line tLineNum of fld "toc" to empty
   else -- offscreen
      set the layer of tMenu to top
      set the hilitedline of fld "toc" to 0
      get the short name of this cd
      if it begins with "lesson" then get line 1 of fld "bodytext"
      put lineoffset(it, fld "toc") into tLineNum
      set the textcolor of line tLineNum of fld "toc" to "black"
      put tLineNum into sMenuLine
      show tMenu
      if isMobile() then
         put the short name of tMenu into tName
         createScroller tName
      end if
      unlock screen with visual effect scroll left fast -- for left direction
   end if
end toggleMenu

command toggleHeader pBool -- show/hide header
   if there is no grp "headergrp" of this cd then exit toggleHeader
   if pBool = "" then put not the vis of grp "headerGrp" into pBool
   get (the short name of this cd = "lessonView" and pBool = true)
   set the blendlevel of grp "headerGrp" to item itemOffset(it,"true,false") of "40,0"
   set the vis of grp "headerGrp" to pBool
end toggleHeader

local sPrefsArray

command setPref pType,pVal -- using script local, later link into project?
   put pVal into sPrefsArray[pType]
end setPref

function getPref pPref  -- using script local; only one pref so far
   get sPrefsArray[pPref]
   if it = "" and pPref = "index" then get "photo index" -- default
   return it
end getPref


private command __UTILITY__
end __UTILITY__

on backKey
   if there is a widget "SVG Back" then
      send "mouseUp" to widget "SVG Back"
   end if
end backKey

function tocVisible
   --   put the long id of grp "menuGrp" into tMenu
   --   return the right of tMenu <= the right of this cd
   return the vis of grp "menuGrp"
end tocVisible

function pathToImgs  -- path to lesson imgs
   return sivasiva_GetModuleFolder(the short name of me) & "img/lesson/"
end pathToImgs

function isMobile
   return the environment is "mobile"
end isMobile

command doScrollerTap
   -- trap
end doScrollerTap

local sShareItemsA
command share_Items 
   
   put "Path to Siva Lessons " & sLastActivityA["LessonNum"]  into sShareItemsA["subject"]
   put "From the SivaSiva app. Coming out soon!"  & cr & cr & (fld "bodytext" of card "lessonView")  into sShareItemsA["text"] 
   return sShareItemsA
end share_Items

private command __GEOMETRY__
end __GEOMETRY__

on updateUI
   if the cLayoutRect of this card is CardRect() then exit updateUI
   switch the short name of this card
      case "cover"
         updateCoverUI
         break
      case "choose your path"
         updateChooseYourPathUI
         break
      case "photo index"
         updatePhotoIndexUI
         break
      case "explore realms"
         updateExploreRealmsUI
         break
      case "lessonview"
         updateLessonViewUI
         break
      case "about"
         updateAboutUI
         break
      case "glossary"
         updateGlossaryUI
         break
   end switch
   set the cLayoutRect of this card to CardRect()
end updateUI

private command updateCoverUI
   local tControl, tLoc, tTopSpace
   
   put the long id of img "01-cover_YS-Walking-Siva-_366w_opt.jpg" into tControl
   bottomCenterMe tControl
   put the top of tControl - safeTopMargin() into tTopSpace
   put the loc of tControl into tLoc
   subtract 12 from item 1 of tLoc
   subtract 58 from item 2 of tLoc
   set the loc of img "Fire1.gif" to tLoc
   bottomCenterMe the long id of img "Tiger", 1
   topCenterMe the long id of widget "SVG title", tTopSpace*.09
   topCenterMe the long id of widget "SVG subtitle", tTopSpace*.23
   topCenterMe the long id of widget "SVG author", tTopSpace*.52
   updateMenuGrpUI
end updateCoverUI

private command updateChooseYourPathUI
   local tControl, tFooterTop, tOldLoc, tNewLoc, tDeltaX, tDeltaY
   
   # footerNavigation needs to be a "background" so that the "preOpenControl" message
   # is received before "preOpenCard" is sent otherwise "updateUI" will crash with div by 0
   put the long id of grp "footerNavigation" into tControl
   send "updateUI" to tControl
   put the top of tControl into tFooterTop
   
   put the long id of img "app-img_dsc_0209_736h-landscape_med.jpg" into tControl
   put the loc of tControl into tOldLoc
   set the bottom of tControl to tFooterTop
   put the loc of tControl into tNewLoc
   
   # adjust everything left for narrower screens
   if CardWidth() < 414 then
      subtract 414-CardWidth() from item 1 of tNewLoc
      set the loc of tControl to tNewLoc
   end if
   
   # calculate offsets to use for icons, label, and background
   put item 1 of tNewLoc - item 1 of tOldLoc into tDeltaX
   put item 2 of tNewLoc - item 2 of tOldLoc into tDeltaY
   
   adjustLoc the long id of grc "iconBkgnd", tDeltaX, tDeltaY
   
   # move label and icons down for shorter screens
   if CardHeight() < 736 then
      subtract CardHeight()-736 from tDeltaY
   end if
   
   adjustLoc the long id of fld "lbl-choose your path", tDeltaX, tDeltaY
   adjustLoc the long id of widget "Lesson 0", tDeltaX, tDeltaY
   adjustLoc the long id of widget "photo index", tDeltaX, tDeltaY
   adjustLoc the long id of widget "explore realms", tDeltaX, tDeltaY
   adjustLoc the long id of widget "about", tDeltaX, tDeltaY
end updateChooseYourPathUI

private command updatePhotoIndexUI
   local tControl, tRect, tRight, tTextSize
   
   updateHeaderGrpUI
   put the long id of grp "headerGrp" into tControl
   put the rect of tControl into tRect
   put item 4 of tRect into item 2 of tRect
   put CardHeight() into item 4 of tRect
   set the rect of grp "indexGrp" to tRect
   
   put min(CardWidth(),the right of grp "indexGrp")-4 into tRight
   repeat with tNum = 1 to 68 
      set the right of fld ("lbl-chapterText"&&tNum) of grp "indexGrp" to tRight
   end repeat
   if CardWidth() < 414 then
      put the textSize of grp "indexGrp" into tTextSize
      set the textSize of grp "indexGrp" to tTextSize-1
   end if
end updatePhotoIndexUI

private command updateExploreRealmsUI
   local tControl, tRect, tRight
   
   updateHeaderGrpUI
   centerMe the long id of img "map.jpg"
end updateExploreRealmsUI

private command updateLessonViewUI
   local tControl, tRect, tRight, tLoc
   
   updateHeaderGrpUI
   set the rect of grp "bodytextGrp" to safeRect()
   set the width of fld "bodytext" to CardWidth()-2*safeSideMargin()
   set the left of fld "bodytext" to safeSideMargin()
   topCenterMe the long id of img "heroImg"
   topCenterMe the long id of fld "caption", 163
   topCenterMe the long id of btn "expander", 432
   topCenterMe the long id of widget "expander", 267
   set the left of btn "prevLesson" of grp "lessonNav" to -14
   set the right of btn "nextLesson" of grp "lessonNav" to CardWidth()+14
   
   put the long id of fld "glossaryDef" into tControl
   put the loc of tControl into tLoc
   put item 1 of the loc of img "heroImg" into item 1 of tLoc
   set the loc of tControl to tLoc
end updateLessonViewUI

private command updateAboutUI
   local tControl, tRect
   
   updateHeaderGrpUI
   put the long id of img "C_Introduction_366w_opt.jpg" into tControl
   topCenterMe tControl, 67
   set the bottom of fld "aboutTitle" to the bottom of tControl
   set the right of fld "aboutTitle" to CardWidth()-max(safeSideMargin(),12)
   
   put the long id of grp "aboutTextGrp" into tControl
   put (max(safeSideMargin(),12), the bottom of fld "aboutTitle"+6, \
         the right of fld "aboutTitle", CardHeight()-max(safeBottomMargin(),12)) into tRect
   set the rect of tControl to tRect
   set the width of fld "aboutFld" to the width of tControl
   set the topLeft of fld "aboutFld" to the topLeft of tControl
end updateAboutUI

private command updateGlossaryUI
   local tControl, tRect
   
   updateHeaderGrpUI
   put the long id of img "C2_TOC-shutterstock-278201699_366w_opt.jpg" into tControl
   topCenterMe tControl, 67
   set the bottom of fld "glossaryTitle" to the bottom of tControl
   set the right of fld "glossaryTitle" to CardWidth()-max(safeSideMargin(),12)
   
   put the long id of grp "glossaryTextGrp" into tControl
   put (max(safeSideMargin(),12), the bottom of fld "glossaryTitle"+6, \
         the right of fld "glossaryTitle", CardHeight()-max(safeBottomMargin(),12)) into tRect
   set the rect of tControl to tRect
   set the width of fld "glossaryText" to the width of tControl
   set the topLeft of fld "glossaryText" to the topLeft of tControl
end updateGlossaryUI

private command updateHeaderGrpUI
   local tControl
   
   put the long id of grp "headerGrp" into tControl
   if the cLayoutRect of tControl is CardRect() then exit updateHeaderGrpUI
   
   topCenterMe tControl
   set the left of btn "SVG Back" of grp "headerGrp" to -11
   set the right of btn "SVG Menu" of grp "headerGrp" to CardWidth()+2
   
   topRightMe the long id of widget "turnOffAudio" of grp "audioGlobalControl", 18, 74
   
   updateMenuGrpUI
   
   set the cLayoutRect of tControl to CardRect()
end updateHeaderGrpUI

private command updateMenuGrpUI
   local tControl
   
   put the long id of grp "menuGrp" into tControl
   if the cLayoutRect of tControl is CardRect() then exit updateMenuGrpUI
   
   set the right of tControl to CardWidth()+91
   set the height of tControl to CardHeight()
   set the top of tControl to 0
   set the height of fld "TOC" to ((the formattedheight of fld "TOC")+safeBottomMargin()+24)
   set the top of fld "TOC" to safeTopMargin()
   set the top of widget "showTerms" to safeTopMargin()
   
   set the cLayoutRect of tControl to CardRect()
end updateMenuGrpUI
