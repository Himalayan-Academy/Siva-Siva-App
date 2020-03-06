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
      set the fullscreenMode of this stack to "showAll"
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preOpenStack

on openStack
   set the acceleratedRendering of this stack to "true"
end openStack


on opencard
   audioIsRunning  
end opencard

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
   goCd tCd
   if tCd begins with "lesson" then
      put pData["lessonNum"] into tNum
      send "loadLesson tNum" to this cd
   end if
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
      send "portal_Link read" to me in 0
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


-- utility --

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

