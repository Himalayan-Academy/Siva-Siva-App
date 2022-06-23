script "behavior_PathToSiva"
global sConfigA

local sLastActivityA,sStackPendingMessagesA
local sCard

local sCurrentLesson, tText,tHTML, pLessonNumber
--BWM: this is a bad variable name... p is the prefix for a parameter
local pTrackdata


constant kLongPressMS = 400 -- google says 300 but seems too short
local sMouseLoc,sStartLoc,sStartMS


on preOpenStack
   if isMobile() then
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preOpenStack

--on preOpenCard
--   updateUI
--end preOpenCard

on openStack
   set the acceleratedRendering of this stack to "true"
   if getPhoneModel() is "iPhoneX" then
      mobileShowStatusBar
   end if
end openStack

on opencard
   
   updateUI
   
   put the short name of this card into sCard
   
   switch sCard
      
      case  "Photo Index"
         hide widget "photo index"
         hide widget "SVG Journal"
         hide btn "SVG Menu"
         hide btn "nextLesson"
         createScroller "indexGrp"
         break
         
   end switch
   
   audioIsRunning  
   --pass opencard
end opencard

--on mousedown
--   local tTargetOwner, tTarget
--   put the short name of the owner of the target into tTargetOwner
--   put short name of the target into tTarget
--   --put the short name of this card into sCard
--   put tTarget
--end mousedown

on mouseup
   
   local tTarget, tTargetOwner, tExpander
   local pHeaderMessage
   
   put the short name of the owner of the target into tTargetOwner
   put short name of the target into tTarget
   put the short name of this card into sCard
   
   switch tTarget
      # Cases of group "headerGrp"
      
      case "Photo Index" 
         hide widget "photo index"
         hide widget "SVG Journal"
         hide btn "SVG Menu"
         hide btn "nextLesson"
         go to card "Photo Index"
         break
         
      case "bodytext"
         switch
            case the milliseconds - sStartMS > kLongPressMS -- long press
               send "doGlossaryLookup the mouseText" to me in 0
               break
               
         end switch
         break
         
      case "prevLesson"
         switch sCard
            case "Photo Index"
               doAnswer "Want to go Home - SivaSiva Portal?", "Yes,Cancel","downloadAffirmed"
               exit to top
               break
               
            case "lessonView"
               if (sCurrentLesson = 0)  OR  (sCurrentLesson =  -1) then
                  
                  --put "It is the last" &cr& "messageI" into fld "message"
                  
                  --deployHeaders pHeaderMessage, "photo index", 68, 5
                  wait 100 milliseconds
                  doAnswer "Want to go Home - SivaSiva Portal?", "Yes,Cancel","downloadAffirmed"
                  
                  exit mouseup
                  break
               end if
               break
            case "glossary"
            case "about"
               go to card "lessonView"
               break
         end switch
         
         turnPage "prev", sCurrentLesson
         break
         
      case "nextLesson"
         
         switch sCard
            case  "photo index"
               
               lock screen
               go card "lessonView"
               loadLesson sCurrentLesson
               exit mouseup
               break
               
            case "glossary"
            case "about"
               goCd sCurrentLesson 
               exit mouseup
               break
         end switch
         
         turnPage "next", sCurrentLesson
         break 
         
      case "SVG Journal"
         hide fld "glossaryDef"
         if sCard is "photo index" then
            put "No Journal" & CR & "Was Made." into pHeaderMessage
         else
            Journal_AddEntry
            --put "Journal Entry" & CR & "Was Made." into pHeaderMessage
         end if
         
         --deployHeaders pHeaderMessage, "SVG Journal", 175,8
         doAnswer "Do you want to exit Path to Siva?", "Yes,Cancel","downloadAffirmed"
         break
         
      case "SVG Menu"
         toggleMenu
         break
         
      case "theExpander"
         switch sCard
            case "lessonView"
               
               switch tTarget
                  case "heroImg"
                  case "theExpander"
                     if ( ( the bottom of fld "caption" ) -  (the bottom of img "heroImg") ) <  50 then -- expanded
                        slideCaption true 
                     else
                        slideCaption false
                     end if
                     break
                     
               end switch
         end switch
         break
   end switch
end mouseup

command deployHeaders pHeaderMessage, pHeaderControl, x, y
   put long id of widget "SVG Journal" into pHeaderControl
   put pHeaderMessage into fld "message"
   hide pHeaderControl with visual effect "dissolve" fast
   wait 100 milliseconds
   topLeftMe pHeaderControl,x,y
   show fld "message"
   wait 750 milliseconds
   hide  fld "message" with visual effect "dissolve" slow
   wait 100 milliseconds
   topLeftMe pHeaderControl,x,y
   show pHeaderControl with visual effect "dissolve" fast
   wait 200 millisecond
end deployHeaders

command goCd pCdName --,pEffect -- optional effect param
   --breakpoint
   local tIslesson
   ntInfo pCdName && pEffect
   
   if (sCard is "glossary") OR (sCard is "about")  then
      put "lesson " before pCdName
   end if
   
   if pCdName is empty then
      ntInfo "tried going to empty card"
      exit goCd
   end if
   if the short name of this cd = pCdName then exit goCd
   
   --if pEffect = "" then put "plain" into pEffect
   
   put (pCdName begins with "lesson") into tIslesson
   
   lock screen  
   if there is a cd pCdName then
      go cd pCdName
      
   else if tIslesson then
      
      go cd "lessonView"
      
      send "loadLesson (word 2 of pCdName)" to this cd
      --send "loadLesson pCdName" to this cd
      
   else if pCdName = "GO HOME - SIVASIVA PORTAL" then -- return to project
      put "push right" into pEffect
      portal_GoStack "Siva-Siva-Portal"
      unlock screen with visual effect pEffect fast
      exit goCd
   end if
   
   if (sCard is "about") OR (sCard is "glossary") then
      hide btn "SVG menu"
   end if
   
   unlock screen --  with visual effect pEffect fast
   
end goCd

command loadLesson pLessonNum -- lesson pages, dynamically loaded html
   --breakpoint
   show widget "photo index"
   show widget "SVG Journal"
   show btn "SVG Menu"
   show btn "nextLesson"
   
   if pLessonNum = "pLessonNum" then
      exit loadLesson
   end if
   --put  pLessonNum & cr & sCurrentLesson
   
   if pLessonNum   <> 0 then
      put pLessonNum  into sCurrentLesson
      if pLessonNum > 68 then
         doAnswer "Want to go Home - SivaSiva Portal?", "Yes,Cancel","downloadAffirmed"
      end if
   else
      if pLessonNum   = 0 then
         put pLessonNum  into  pLessonNum
         put 0 into sCurrentLesson
      end if
   end if
   
   --put  pLessonNum & cr & sCurrentLesson
   
   setLastactivity "lessonView", pLessonNum  
   lock screen
   
   if there is a  fld "glossaryDef" then
      hide fld "glossaryDef"
   end if
   put the chapterContent[plessonNum] of this cd into tText
   if tText = "" then -- out of range
      exit loadLesson
   end if
   set the filename of img "heroImg" to (pathToImgs() & tText["image"]) -- load photo; will resize
   resizeToWidth "heroImg"
   set the vScroll of grp "bodytextGrp" to 0
   topCenterMe the long id of img "heroImg"
   put tText["caption"] & cr & space into fld "caption" -- overhang by one line
   resetCaption
   
   -- bodytext:  -- CH. 17 and 47: list/instructions come after quote 
   put "" into tHTML
   put tText["headingHTML"] into tHTML
   put tText["body"] & "<p></p>" after tHTML
   
   
   put tText["quote"] after tHTML
   put tText["addendum"] after tHTML -- only in lessons 17 and 47
   
   
   set the textstyle  of fld "bodytext"  to "plain"
   
   set the htmltext of fld "bodytext" to tHTML
   
   
   set the height of fld "bodytext" to the formattedheight of fld "bodytext"
   set the top of fld "bodytext" to the bottom of fld "caption"
   put pLessonNum into sConfigA["pathToSivaLastActivity"]
   
   unlock screen
   
   if the hilited of widget "showTerms" then
      flagGlossaryTerms true -- flag all glossary terms in the text
   end if
   
      createScroller "bodytextGrp" -- replaces any existing
   
   put "Lesson" && pLessonNumber into pTrackdata["targetContent"]
   tracking_RecordActivity "Path To Siva", "navigation/goLesson", pTrackdata
   
   
   
end loadLesson

command turnPage pDir,  sCurrentLesson -- pLesson -- navigate to another lesson
   
   --breakpoint
   
   local tEffect
   switch pDir
      case "next"
         add 1 to sCurrentLesson
         put "reveal left" into tEffect
         break
      case "prev"
         ## on continue as the very beginning
         
         if "sCurrentLesson = -1" then
            add 2 to sCurrentLesson
         end if
         if "sCurrentLesson = 0" then
            add 1 to sCurrentLesson
         end if
         if "sCurrentLesson = 1" then
            add 0  to sCurrentLesson
         end if
         
         subtract 1 from sCurrentLesson
         put "reveal right" into tEffect
         break
      default
   end switch
   
   lock screen for visual effect
   loadLesson sCurrentLesson
   unlock screen with visual effect tEffect
end turnPage

command doScrollerTap
   local tLine,tcd,tCdNum,tEffect
   put the clickline into tLine
   
   # We set the glossary terms by hilite to "Show Defined Words"
   # but the doScrollerTap doesn't do any be besides 
   # hilite or not hilited the widget "showTerms"
   if tLine = "" or word 2 of tLine < 2 then
      exit doScrollerTap -- empty or "show glossary terms"
   end if
   set the hilitedline of fld "toc" to word 2 of tLine
   wait 100 millisecs -- to see it
   put the text of tLine into tCd
   
   if tCd = "About / Usage Guide" then 
      put "About" into tCd
   end if
   
   if tCd = "Glossary" then 
      put "Glossary" into tCd
   end if
   
   # Next we go to the lesson 1-68 or
   # Cover, Choose your Path, About, Glossary, Home, Introduction
   if word 1 of tCd = "lesson" and word 2 of tCd is an integer then
      put word 1 to 2 of tCd into tCd
   else if tCd contains "introduction" then
      put "lesson 0" into tCd
   end if
   if tCd = the short name of this cd or \
         (the short name of this cd = "lessonView" and line 1 of fld "bodytext" = tCd) then
      toggleMenu
      exit doScrollerTap
   end if
   if tocVisible() then toggleMenu
   if tCd begins with "lesson" then
      put the number of cd "lessonview" into tCdNum
   else if there is a cd tCd then
      put the number of cd tCd into tCdNum
   end if
   put item itemoffset(the number of this cd > tCdNum,"false,true") of "push left,push right" into tEffect
   # here we to Lesson or card "glossary" or "about"
   goCd tCd,tEffect
   
   # we have set have to set the lesson we wish go to 
   
   if sCurrentLesson <> 0 then
      put sCurrentLesson into sCurrentLesson
   end if
end doScrollerTap

on resizeStack
   setCardCoords
   updateUI
end resizeStack

command resetCaption
   set the height of fld "caption" to (the formattedheight of fld "caption") + 4 -- extra underhang
   set the bottom of fld "caption" to the bottom of img "heroImg" + \
         (the textheight of fld "caption") + (the bottomMargin of fld "caption") -- visible bottom edge
   set the flipped of widget "theExpander" to false
   set the bottom of grp "expander" to (the bottom of fld "caption")  -4
end resetCaption

command slideCaption pBool -- animate the caption view
   local tCaptionFld, tGap, tDistance
   --   pBool = true to show, false to hide
   put the long id of fld "caption" into tCaptionFld
   put the textheight of tCaptionFld + the bottomMargin of tCaptionFld into tGap
   
   set the textstyle  of tCaptionFld to "plain"
   
   put the height of tCaptionFld - tGap into tDistance
   if not pBool then put tDistance * -1 into tDistance
   set the bottom of grp "expander" to (the bottom of fld "caption") -4
   
   -- LC BUG: DOES NOT RECALC NEW GRP HEIGHT WHEN USING "MOVE" [bug 18965]
   lock moves
   move tCaptionFld relative 0,tDistance without waiting
   move fld "bodytext" relative 0,tDistance without waiting
   move group "expander" relative 0,tDistance without waiting
   unlock moves
   
   if pBool then set the top of tCaptionFld to the bottom of img "heroImg" -- adjust in case
   set the flipped of widget"theExpander" to pBool --not pBool
   createScroller  "bodytextGrp" -- adjust for new height
end slideCaption

command resizeToWidth pImgName
   local tW,tOrigW,tOrigH,tRatio
   try -- in case img doesn't load
      put the width of this cd into tW
      put the formattedWidth of img pImgName into tOrigW
      put the formattedHeight of img pImgName into tOrigH
      put tW/tOrigW into tRatio
      set the width of img pImgName to (tOrigW * tRatio)
      set the height of img pImgName to (tOrigH * tRatio)
   catch tErr
      put tErr
   end try
end resizeToWidth

command downloadAffirmed   
   portal_GoStack "Siva-Siva-Portal"
end downloadAffirmed



command flagGlossaryTerms pBool -- underline all glossary words in body text
   
   local tList,tColor, tSkip,tOffset
   
   if (sCard is "glossary") OR  (sCard is "about") then --OR  (sCard is "about") t
      exit flagGlossaryTerms 
   end if
   
   put the text of fld "bodytext" into tText
   
   put the cGlossaryTerms of cd "glossary" into tList
   
   if pBool then put "240,238,143" into tcolor -- or try: lightyellow, beige, cornsilk
   else put "" into tColor
   lock screen
   set wholematches to true
   repeat for each line l in tList
      put 0 into tSkip
      if l is among the trueWords of tText then
         repeat
            put trueWordOffset(l,tText,tSkip) into tOffset
            if tOffset = 0 then exit repeat
            
            set the flagged of trueword (tOffset + tSkip) of fld "bodytext" to pBool -- enable to use underlines
            
            set the backcolor of trueword (tOffset + tSkip) of fld "bodytext" to tColor -- enable to use colo
            
            add tOffset to tSkip
         end repeat
      end if
   end repeat
   unlock screen
   put "Hilite Glossary Words" into pTrackdata["userAction"]
   tracking_RecordActivity "Path To Siva", "options/choose", pTrackdata
end flagGlossaryTerms

command doGlossaryLookup pTerm -- display term with definition
   local tDef, tGlossaryDefFld
   
   if pTerm = "" then exit doGlossaryLookup
   
   lock screen
   
   dispatch function "getGlossaryDef" to cd "glossary" with pTerm
   put the result into tDef
   if tDef = "" then
      exit doGlossaryLookup
   else
      set the itemdel to colon
      put item 1 of tDef &cr& word 1 to -1 of item 2 to -1 of tDef into fld "glossaryDef"
      set the textstyle of line 1 of fld "glossaryDef" to "bold"
   end if
   set the spacebelow of line -1 of fld "glossaryDef" to 8
   set the height of fld "glossaryDef" to the formattedheight of fld "glossaryDef" 
   
   put the long id of fld "glossaryDef" into tGlossaryDefFld
   topCenterMe tGlossaryDefFld, 207
   
   show fld "glossaryDef"
   unlock screen
   put removeQuotes(pTerm) into pTrackdata["targetContent"]
   tracking_RecordActivity "Path To Siva", "options/glossarylookup", pTrackdata
end doGlossaryLookup


on checkGlossary pChunk -- flag a word if it's in the glossary; used for brief flag on touch; replaced by TOC lookups
   -- Note: "is among the lines of" fails on 2-word strings or in white space;
   -- using offset incorrectly matches partials (i.e. "the" matches "theism".)
   -- Using moustext, there are less errors.
   local tWordChunk
   get the mousetext
   if it = "" then exit checkGlossary
   if it is among the lines of the cGlossaryTerms of cd "glossary" then -- show a temp flag
      put the mouseChunk into tWordChunk
      setGlossaryIndicator tWordChunk,true
      send "setGlossaryIndicator tWordChunk,false" to me in 60 -- remove flag
   end if
end checkGlossary

command setGlossaryIndicator pChunk,pBool -- turn glossary indicator on/off; for manual word flagging
   set the flagged of pChunk to pBool
end setGlossaryIndicator


on linkClicked pLink
   switch pLink
      case "dws-sloka-1-video"
         portal_GoURL "https://www.youtube.com/embed/Mu752lmJHrY?rel=0"
         break
   end switch
end linkClicked
on closestack
   portal_SetLastStack "pathtosiva"
   ntinfo "Closing PtS, Lockscreen is: " & the lockscreen
end closestack

on closeCard
   deleteCardMobileControls
end closeCard

on setLastactivity pCdName, pLessonNum   
   # never set this if moving to cards: cover, photo index, choose your path
   # for about and glossary we don't pass a lesson number.
   put pCdName into sLastActivityA["CdName"]
   put pLessonNum into sLastActivityA["LessonNum"]
end setLastactivity

command Journal_AddEntry -- save a bookmark to db
   local tCdName,pData,tLessonNum,tTitle
   put sLastActivityA["CdName"] into tCdName
   put tCdName into pData["card"] -- store the last user cd   
   if tCdName = "lessonView" then -- store the lesson number
      put sLastActivityA["LessonNum"] into tLessonNum
      if tLessonNum is not an integer then put 0 into tLessonNum -- intro cd
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
end Journal_AddEntry

on journalResume pData,pEntryA -- sent from journal stack
  --breakpoint
   local tCd,tNum
   close stack "journal"
   put pData["card"] into tCd
   if tCd begins with "lesson" then
      put pData["lessonNum"] into tNum
      put tCd && tNum into tCd
   end if
   goCd tCd
end journalResume



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
      --set the textcolor of line tLineNum of fld "toc" to "black"
      set the foregroundcolor of line tLineNum of fld "toc" to "green"
      put tLineNum into sMenuLine
      show tMenu
      if isMobile() then
         put the short name of tMenu into tName
         createScroller tName
      end if
      unlock screen with visual effect scroll left fast -- for left direction
   end if
end toggleMenu


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
   return the vis of grp "menuGrp"
end tocVisible

function pathToImgs  -- path to lesson imgs
   return sivasiva_GetModuleFolder(the short name of me) & "img/lesson/"
end pathToImgs

function isMobile
   return the environment is "mobile"
end isMobile



local sShareItemsA
command share_Items 
   
   put "Path to Siva Lessons " & sLastActivityA["LessonNum"]  into sShareItemsA["subject"]
   put "From the SivaSiva app. Coming out soon!"  & cr & cr & (fld "bodytext" of card "lessonView")  into sShareItemsA["text"] 
   return sShareItemsA
end share_Items

private command __GEOMETRY__
end __GEOMETRY__

on updateUI
   
   local tCard, tHeaderGrp, tHeaderBgFld, tPrevLesson, tPhotoIndex, tSVGJournal, tMessage
   local tControl, tSVGMenu, tNextLesson, tTurnOffAudio
   
   put the short name of this card into tCard
   
    if the cLayoutRect of this card is CardRect() then exit updateUI
   set the cLayoutRect of this card to CardRect()
   
   switch tCard
      
      case "photo index"
      case "lessonview"
      case "about"
      case "glossary"
         
         put the long id of grc "headerBkgGrc" into tHeaderBkgGrc
         centerMe tHeaderBkgGrc, 0, 0
         
         ## we do the grp "headerGrp"
         put the long id of grp "headerGrp" into tHeaderGrp
         topCenterMe tHeaderGrp, 0
         
         put the long id of btn "prevLesson" into tPrevLesson
         topLeftMe tPrevLesson, 0, 2
         
         put the long id of widget "photo index" into tPhotoIndex
         topLeftMe tPhotoIndex, 75, 8
         
         put the long id of widget "SVG Journal" into tSVGJournal
         topCenterMe tSVGJournal, 5
         
         put the long id of fld "message" into tMessage
         topCenterMe tMessage, 3
         
         put the long id of btn "SVG Menu" into tSVGMenu
         topRightMe tSVGMenu, 80, 0
         
         put the long id of btn "nextLesson" into tNextLesson
         topRightMe tNextLesson, 0, 3
         
         put the long id of widget "turnOffAudio" of grp "audioGlobalControl" into tTurnOffAudio
         topRightMe tTurnOffAudio, 18, 74
         break
         
   end switch
   
   switch tCard
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
   
   updateMenuGrpUI
   
end updateUI

private command updateCoverUI
   local tControl, tLoc, tTopSpace
   
   put the long id of img "01-cover_YS-Walking-Siva-_366w_opt.jpg" into tControl
   bottomCenterMe tControl
   put max(the top of tControl - safeTopMargin(), 200) into tTopSpace
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



private command updateExploreRealmsUI
   local tControl, tRect, tRight
   centerMe the long id of img "map.jpg"
end updateExploreRealmsUI

private command updateLessonViewUI
   local tControl, tRect, tRight, tLoc
   
   set the rect of grp "bodytextGrp" to safeRect()
   set the width of fld "bodytext" to CardWidth()-2*safeSideMargin()
   set the left of fld "bodytext" to safeSideMargin()
   topCenterMe the long id of img "heroImg"
   topCenterMe the long id of fld "caption", 163
   topCenterMe the long id of grp "expander", 371
   
   put the long id of fld "glossaryDef" into tControl
   put the loc of tControl into tLoc
   put item 1 of the loc of img "heroImg" into item 1 of tLoc
   set the loc of tControl to tLoc
end updateLessonViewUI

private command updatePhotoIndexUI
   local tControl, tRect, tRight, tTextSize
   
   --updateHeaderGrpUI
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

private command updateAboutUI
   local tControl, tRect
   
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
   
   --updateHeaderGrpUI
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



private command updateMenuGrpUI
   local tControl
   
   put the long id of grp "menuGrp" into tControl
   if the cLayoutRect of tControl is CardRect() then exit updateMenuGrpUI
   
   set the right of tControl to CardWidth()+5
   set the height of tControl to CardHeight()
   set the top of tControl to 0
   set the height of fld "TOC" to ((the formattedheight of fld "TOC")+safeBottomMargin()+24)
   set the top of fld "TOC" to safeTopMargin()
   set the top of widget "showTerms" to safeTopMargin()
   
   set the cLayoutRect of tControl to CardRect()
end updateMenuGrpUI

---------------


private command __MOBILESCROLLER__
end __MOBILESCROLLER__


-- creation and management of mobile scrollers --
-- behavior assigned to stack --
local sStartVScroll, sIsScrolling, sLastVScroll
constant kCheckScrollMS = 50

command createScroller pName
   local tRect
   put  (0,0,the formattedwidth of control pName,the formattedheight of control pName+ 60) into tRect
   if not isMobile() then exit createScroller
   deleteMobileControl pName -- delete any existing
   --   set the vScroll of control pName to 0 -- init for alignment
   mobileControlCreate "scroller", pName
   mobileControlSet pName, "rect", (the rect of control pName)
   
   
   mobileControlSet pName, "contentRect",tRect
   mobileControlSet pName, "hScroll",0
   wait 0 milliseconds -- workaround for mobile vscroll bug
   mobileControlSet pName, "vScroll", 0 
   mobileControlSet pName, "hIndicator",false
   mobileControlSet pName, "vIndicator",true
   mobileControlSet pName, "visible", true
   put 0 into sStartVScroll
   put false into sIsScrolling
end createScroller

on scrollerDidScroll hScrolled, vScrolled
   local tControlID
   put mobileControlTarget() into tControlID
   if  vScrolled < 20 then
      set the vscroll of control tControlID to vScrolled * 2
   else
      set the vscroll of control tControlID to vScrolled + 20
   end if
   if not sIsScrolling then
      put true into sIsScrolling
      put vScrolled into sStartVScroll
      put vScrolled into sLastVScroll
      send "checkScrollDirection tControlID" to me in kCheckScrollMS milliseconds
   end if
end scrollerDidScroll

on checkScrollDirection pControlID
   local tCurrentVScroll
   if not sIsScrolling then exit checkScrollDirection
   put the vscroll of control pControlID into tCurrentVScroll
   if tCurrentVScroll = sLastVScroll then
      put false into sIsScrolling
      exit checkScrollDirection
   end if
   put tCurrentVScroll into sLastVScroll
   if tCurrentVScroll > sStartVScroll+30 then
      dispatch "scrollingDown" to control pControlID
   else if tCurrentVScroll < sStartVScroll-30 then
      dispatch "scrollingUp" to control pControlID
   else
      send "checkScrollDirection pControlID" to me in kCheckScrollMS milliseconds
      exit checkScrollDirection
   end if
   put false into sIsScrolling
end checkScrollDirection

on deleteMobileControl pName -- deletes an existing mobile control
   if not isMobile() then exit deleteMobileControl -- do nothing on desktop
   put false into sIsScrolling
   repeat while pName is among the lines of mobileControls()
      mobileControlDelete pName
   end repeat
end deleteMobileControl

on deleteCardMobileControls -- delete all mobile controls of any type on current card only
   if not isMobile() then exit deleteCardMobileControls
   put false into sIsScrolling
   repeat for each line l in mobileControls()
      if there is a grp l then
         mobileControlDelete l
      end if
   end repeat
end deleteCardMobileControls

