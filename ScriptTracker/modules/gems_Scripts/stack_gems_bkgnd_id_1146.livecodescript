Script "stack_gems_bkgnd_id_1146"

/*
# Name: bkgnd "quoteControl" of stack "gems"
# ID: bkgnd id 1146 of stack "gems"

# Shared group on card IDs: 1002, 1184, 1179
*/


--> Variables
--
local readingLongQuote, gemsSet


--> Events
--
on mouseup
   local tHotspotWidth, tMouseY, tCardWidth
   put 50 into tHotspotWidth
   get the clickH
   put it into tMouseY
   put the width of this card into tCardWidth
   lock screen
   switch 
      case (tMouseY > (tCardWidth - tHotspotWidth)  )
         fetchImage
         fetchQuote
         break
      case (tMouseY < tHotspotWidth)
         fetchImage
         fetchQuote
         break
      case (  (tMouseY > tHotspotWidth)  AND ( tMouseY <   (tCardWidth - tHotspotWidth) ) ) AND (checkScrollDone()="true") 
         if (checkQuoteFits() ="true") OR (readingLongQuote="false") then
            fetchImage
            fetchQuote
            put "true" into readingLongQuote
         else
            # do nothing but toggle the flag
            put "false" into readingLongQuote
         end if
         break
   end switch
   unlock screen
end mouseup


--> Gems
--
function checkQuoteFits
   if  ( (the formattedheight of fld "gems-quote") -  (the height of fld "gems-quote") ) < 15 then
      return "true"
   else
      return "false"
   end if
end checkQuoteFits

function checkScrollDone
   local tTextHeight, tVscroll, tBalanceToScroll
   put the formattedHeight of fld "gems-quote" into tTextHeight
   put the vScroll of fld "gems-quote" into tVscroll
   put tTextHeight - tVscroll into tBalanceToScroll
   if tBalanceToScroll < 195 then
      return   "true"
   else
      return  "false"
   end if
end checkScrollDone

on resizeControl
   local tRect, tControl
   put the long id of grc "quoteBackground" of me into tControl
   topCenterMe tControl, 321
   --set the rect of grc "quoteBackground" of me to the rect of me
   set the right of grp "goNextQuote" of me to CardWidth() + 13
   put (9, the top of tControl + 21, CardWidth() - 5, \
         the top of grp "footerNavigation" of this cd - 12) into tRect
   set the rect of fld "gems-quote" of me to tRect
end resizeControl
