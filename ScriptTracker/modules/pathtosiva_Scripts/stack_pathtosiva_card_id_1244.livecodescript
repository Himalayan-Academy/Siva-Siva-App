Script "stack_pathtosiva_card_id_1244"

/*
# Name: card "glossary" of stack "pathtosiva"
# ID: card id 1244 of stack "pathtosiva"
*/



on preOpenCard
   setLastactivity "glossary"  # for journal
   set the scroll of grp "glossaryTextGrp" to 0
   createScroller "glossaryTextGrp"
end preOpenCard

command glossaryLookup pTerm -- look up a term
  if the clicktext = "" then exit glossaryLookup
  put lineoffset(cr & pTerm,cr & the cGlossaryTerms of me) into tLine
  if tLine = 0 then exit glossaryLookup 
  put the long ID of fld "glossaryText" into tFld
  put the effective textheight of tFld into tTxHt
  put the spaceBelow of line 1 of tFld into tSpace
  put the formattedheight of line 1 to tLine of tFld into tHt  
  set the scroll of grp "glossaryTextGrp" to tHt - (the formattedheight of line tLine of tFld) - tSpace
  set the backcolor of line tLine of tFld to the textcolor of fld "glossaryTitle"
end glossaryLookup

command doScrollerTap -- tap in fld, see if there's a matching lookup
  glossaryLookup the clicktext
end doScrollerTap

function getGlossaryDef pTerm -- return definition for display elsewhere
  -- called from lessonView cd on long-press
  put lineoffset(cr & pTerm,cr & the cGlossaryTerms of me) into tLine -- use prop for faster initial lookup
  if tLine = 0 then return empty
  return line tLine of fld "glossaryText" of cd "glossary"
end getGlossaryDef

command resetFldColor
  set the backcolor of line 1 to -1 of fld "glossaryText" of me to empty
end resetFldColor


-- dev --

on resetscroll
  set the scroll of grp "glossaryTextGrp" to 0
  set the top of fld "glossarytext" to the top of grp "glossarytextgrp"
end resetscroll
