Script "stack_pathtosiva_card_id_1083"

/*
# Name: card "lessonView" of stack "pathtosiva"
# ID: card id 1083 of stack "pathtosiva"
*/


global sConfigA

on openCard
   show button "svg Menu"
end openCard

local sCurrentLesson, tText,tHTML, pLessonNumber
local pTrackdata

command loadLesson pLessonNum -- lesson pages, dynamically loaded html
   put pLessonNum into sCurrentLesson # for sharing
   setLastactivity "lessonView", pLessonNum  
   lock screen
   hide fld "glossaryDef"
   put the chapterContent[plessonNum] of this cd into tText
   if tText = "" then -- out of range
      exit loadLesson
   end if
   set the filename of img "heroImg" to (pathToImgs() & tText["image"]) -- load photo; will resize
   resizeToWidth "heroImg"
   set the vScroll of grp "bodytextGrp" to 0
   set the top of img "heroImg" to 0
   put tText["caption"] & cr & space into fld "caption" -- overhang by one line
   --   set the height of fld "caption" to (the formattedheight of fld "caption") + 4 -- extra underhang
   --   set the bottom of fld "caption" to the bottom of img "heroImg" + \
   --         (the textheight of fld "caption") + (the bottomMargin of fld "caption") -- visible bottom edge
   --   set the bottom of button "expander" to (the bottom of fld "caption")-8
   resetCaption
   
   -- bodytext:  -- CH. 17 and 47: list/instructions come after quote 
   put "" into tHTML
   put tText["headingHTML"] into tHTML
   put tText["body"] & "<p></p>" after tHTML
   put tText["quote"] after tHTML
   put tText["addendum"] after tHTML -- only in lessons 17 and 47
   set the htmltext of fld "bodytext" to tHTML
   set the height of fld "bodytext" to the formattedheight of fld "bodytext"
   set the top of fld "bodytext" to the bottom of fld "caption"
   set the top of grp "lessonNav" to the bottom of fld "caption" + 14
   put pLessonNum into sConfigA["pathToSivaLastActivity"]
   unlock screen
   if the hilited of widget "showTerms" then flagGlossaryTerms true -- flag all glossary terms in the text
   createScroller "bodytextGrp" -- replaces any existing
   put "Lesson" && pLessonNumber into pTrackdata["targetContent"]
   tracking_RecordActivity "Path To Siva", "navigation/goLesson", pTrackdata
end loadLesson

command resetCaption
   set the height of fld "caption" to (the formattedheight of fld "caption") + 4 -- extra underhang
   set the bottom of fld "caption" to the bottom of img "heroImg" + \
         (the textheight of fld "caption") + (the bottomMargin of fld "caption") -- visible bottom edge
 set the flipped of widget "expander" to false
   set the bottom of widget "expander" to (the bottom of fld "caption")-6
end resetCaption

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

command flagGlossaryTerms pBool -- underline all glossary words in body text
   local tList,tColor, tSkip,tOffset
  -- Toggled from TOC selection.
  -- pBool = boolean
  put the cGlossaryTerms of cd "glossary" into tList
  put the text of fld "bodytext" into tText
  if pBool then put "240,238,143" into tcolor -- or try: lightyellow, beige, cornsilk
  else put "" into tColor
  lock screen
  repeat for each line l in tList
    put 0 into tSkip
    if l is among the trueWords of tText then
      repeat
        put trueWordOffset(l,tText,tSkip) into tOffset
        if tOffset = 0 then exit repeat
        --         set the flagged of trueword (tOffset + tSkip) of fld "bodytext" to pBool -- enable to use underlines
        set the backcolor of trueword (tOffset + tSkip) of fld "bodytext" to tColor -- enable to use color
        add tOffset to tSkip
      end repeat
    end if
  end repeat
  unlock screen
     put "Hilite Glossary Words" into pTrackdata["userAction"]
   tracking_RecordActivity "Path To Siva", "options/choose", pTrackdata
end flagGlossaryTerms

on linkClicked pLink
   switch pLink
      case "dws-sloka-1-video"
         portal_GoURL "https://www.youtube.com/embed/Mu752lmJHrY?rel=0"
         break
   end switch
end linkClicked


