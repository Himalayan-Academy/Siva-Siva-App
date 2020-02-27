Script "stack_pathtosiva_group_id_1093"

/*
# Name: group "bodytextGrp" of card "lessonView" of stack "pathtosiva"
# ID: group id 1093 of card id 1083 of stack "pathtosiva"
*/



-- scrolling specific to the lesson group,
-- handles taps, swipes, and glossary lookups

constant kLongPressMS = 400 -- google says 300 but seems too short
local sMouseLoc,sStartLoc,sStartMS

on mouseDown
  -- trick removes glossary definitionfld from view without hiding it. If hidden on mousedown,
  -- the next mouseUp will toggle the header. To avoid that, move it but leave it
  -- visible. The next lookup will reposition it correctly.
  set the bottom of fld "glossaryDef" to -100
  if (the bottom of img "heroImg") = the top of fld "caption"  then -- expanded
    slideCaption false -- reset the loc to work around LC bug where formattedHeight is not updated
  else
    put the mouseloc into sMouseLoc
    put sMouseLoc into sStartLoc
    put the milliseconds into sStartMS
    --     checkGlossary the mouseChunk -- for glossary flags per word on touch
  end if
end mouseDown

on mouseUp -- not sent on mobile when swiping, works on taps.
  put "" into sMouseLoc
  if tocVisible() then
    toggleMenu
    toggleHeader false
  else if the vis of fld "glossaryDef" then
    hide fld "glossaryDef"
  else
    put abs(the mouseH - item 1 of sStartLoc) into tHDist
    put abs(the mouseV - item 2 of sStartLoc) into tVDist
    switch
      case tHDist <= 10 and tVDist <= 10 -- a tap
        send "doScrollerTap" to the target in 0
        break
      case (item 1 of sStartLoc > the mouseH) and (tHDist > 50) and (tVDist < 100)  -- swipe left
        turnPage "next"
        break
      case (item 1 of sStartLoc < the mouseH) and (tHDist > 50) and (tVDist < 100)  -- swipe right
        turnPage "prev"
        break
      default
    end switch 
  end if
end  mouseup

on mouseRelease
  put "" into sMouseLoc
  put "" into sStartLoc
end mouseRelease

on mouseMove x,y -- desktop scrolling
  if isMobile() or sMouseLoc = "" then pass mouseMove -- to mobileScrollerBehavior
  put abs(y - item 2 of sMouseLoc) into tVDist
  if item 2 of sMouseLoc > y then -- pushing up
    set the vscroll of me to the vscroll of me + tVDist
  else if item 2 of sMouseLoc < y then -- pushing down
    set the vscroll of me to the vscroll of me - tVDist
  end if
  put x,y into sMouseLoc
end mouseMove

command doScrollerTap
  switch the short name of the target
    case "bodytext"
      switch
        case the milliseconds - sStartMS > kLongPressMS -- long press
          send "doGlossaryLookup the mouseText" to me in 0
          break
        case the mouseH > (the width of this cd) - 60 -- tap right side
          turnPage "next"
          break
        case the mouseH < 60 -- tap left side
          turnPage "prev"
          break
        default
          toggleHeader
      end switch
      break
   case "heroImg"
      toggleHeader
      break
    case "caption"
      put (the bottom of img "heroImg") > the top of fld "caption" into tShow
      slideCaption tShow
  end switch
end doScrollerTap

command turnPage pDir -- navigate to another lesson
  -- pDir = "next" or "prev"
  put last word of line 1 of fld "bodytext" into tLesson
  if tLesson is not an integer then put 0 into tLesson -- intro cd
  switch pDir
    case "next"
      add 1 to tLesson
      put "reveal left" into tEffect
      break
    case "prev"
      subtract 1 from tLesson
      put "reveal right" into tEffect
      break
    default
  end switch
  toggleHeader false
  lock screen for visual effect
  loadLesson tLesson
  unlock screen with visual effect tEffect
end turnPage

-- local sDistance

command slideCaption pBool -- animate the caption view
   --   pBool = true to show, false to hide
   put the long id of fld "caption" into tCaptionFld
   put the textheight of tCaptionFld + the bottomMargin of tCaptionFld into tGap
   put the height of tCaptionFld - tGap into tDistance
   if not pBool then put tDistance * -1 into tDistance
   set the bottom of button "expander" to (the bottom of fld "caption")+6
   -- LC BUG: DOES NOT RECALC NEW GRP HEIGHT WHEN USING "MOVE" [bug 18965]
   lock moves
   move tCaptionFld relative 0,tDistance without waiting
   move fld "bodytext" relative 0,tDistance without waiting
   move button "expander" relative 0,tDistance without waiting
   move group "lessonNav" relative 0,tDistance without waiting
   unlock moves

   
   if pBool then set the top of tCaptionFld to the bottom of img "heroImg" -- adjust in case
   --set the flipped of widget "expander" to not pBool
   createScroller the short name of me -- adjust for new height
end slideCaption


command doGlossaryLookup pTerm -- display term with definition
   if pTerm = "" then exit doGlossaryLookup
   dispatch function "getGlossaryDef" to cd "glossary" with pTerm
   put the result into tDef
   if tDef = "" then
      --     put "No definition found" into fld "glossaryDef"
      exit doGlossaryLookup
   else
      set the itemdel to colon
      put item 1 of tDef &cr& word 1 to -1 of item 2 to -1 of tDef into fld "glossaryDef"
      set the textstyle of line 1 of fld "glossaryDef" to "bold"
   end if
   set the spacebelow of line -1 of fld "glossaryDef" to 8
   set the height of fld "glossaryDef" to the formattedheight of fld "glossaryDef"
   set the loc of fld "glossaryDef" to the loc of me
   show fld "glossaryDef"
   put removeQuotes(pTerm) into pTrackdata["targetContent"]
   tracking_RecordActivity "Path To Siva", "options/glossarylookup", pTrackdata
end doGlossaryLookup


--# handlers below used for manual glossary flags on touch;
--# replaced by TOC menu item that flags all words in bulk

-- on checkGlossary pChunk -- flag a word if it's in the glossary; used for brief flag on touch; replaced by TOC lookups
--   -- Note: "is among the lines of" fails on 2-word strings or in white space;
--   -- using offset incorrectly matches partials (i.e. "the" matches "theism".)
--   -- Using moustext, there are less errors.
--   get the mousetext
--   if it = "" then exit checkGlossary
--   if it is among the lines of the cGlossaryTerms of cd "glossary" then -- show a temp flag
--     put the mouseChunk into tWordChunk
--     setGlossaryIndicator tWordChunk,true
--     send "setGlossaryIndicator tWordChunk,false" to me in 60 -- remove flag
--   end if
-- end checkGlossary

-- command setGlossaryIndicator pChunk,pBool -- turn glossary indicator on/off; for manual word flagging
--   set the flagged of pChunk to pBool
-- end setGlossaryIndicator
