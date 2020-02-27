Script "stack_pathtosiva_button_id_1252"

/*
# Name: button "scrollerBehavior" of card "cover" of stack "pathtosiva"
# ID: button id 1252 of card id 1088 of stack "pathtosiva"
*/



-- Behavior of scrollers in response to mouse actions.
-- Used by all scrolling groups except lesson bodytext.
-- Lesson bodytext grp requires special handling and has its own script.

local sMouseLoc,sStartLoc

on mouseDown
  if the owner of the target is not me then exit mouseDown
  put the mouseloc into sMouseLoc
  put sMouseLoc into sStartLoc
end mouseDown

on mouseUp
  put "" into sMouseLoc
  if the short name of the owner of the target is not "menuGrp" then
    if tocVisible() then
      toggleMenu
      exit mouseUp
    end if
  end if
  if abs(the mouseH - item 1 of sStartLoc) <= 10 and abs(the mouseV - item 2 of sStartLoc) <= 10 then
    send "doScrollerTap" to the target in 0
  end if
end  mouseup

on mouseMove x,y -- desktop scrolling
  if isMobile() or sMouseLoc = "" then pass mouseMove
  put abs(y - item 2 of sMouseLoc) into tVDist
  if item 2 of sMouseLoc > y then -- pushing up
    set the vscroll of me to the vscroll of me + tVDist
  else if item 2 of sMouseLoc < y then -- pushing down
    set the vscroll of me to the vscroll of me - tVDist
  end if
  put x,y into sMouseLoc
end mouseMove

on mouseRelease
  put "" into sMouseLoc
end mouseRelease
