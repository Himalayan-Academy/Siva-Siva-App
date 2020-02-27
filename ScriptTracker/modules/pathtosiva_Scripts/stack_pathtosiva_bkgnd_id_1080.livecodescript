Script "stack_pathtosiva_bkgnd_id_1080"

/*
# Name: bkgnd "menuGrp" of stack "pathtosiva"
# ID: bkgnd id 1080 of stack "pathtosiva"
# Behavior: button id 1252 of stack "pathToSiva"

# Shared group on card IDs: 1088, 1002, 1094, 1083, 1246, 1244
*/




command doScrollerTap
   local tLine,tcd,tCdNum,tEffect
  put the clickline into tLine
  if tLine = "" or word 2 of tLine < 2 then exit doScrollerTap -- empty or "show glossary terms"
  set the hilitedline of fld "toc" to word 2 of tLine
  wait 100 millisecs -- to see it
  put the text of tLine into tCd
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
  goCd tCd,tEffect
end doScrollerTap
