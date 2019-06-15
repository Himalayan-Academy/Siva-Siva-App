Script "stack_gems_bkgnd_id_1146"

/*
# Name: bkgnd "quoteControl" of stack "gems"
# ID: bkgnd id 1146 of stack "gems"

# Shared group on card IDs: 1002, 1184, 1179
*/


--> Variables
-
local readingLongQuote, gemsSet


--> Events
-
on mouseup
   put 50 into tHotspotWidth
   get the clickH
   put it into tMouseY
   put the width of this card into tCardWidth
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
end mouseup


--> Gems
-
function checkQuoteFits
   if  ( (the formattedheight of fld "gems-quote") -  (the height of fld "gems-quote") ) < 15 then
      return "true"
   else
      return "false"
   end if
end checkQuoteFits

function checkScrollDone
   put the formattedHeight of fld "gems-quote" into tTextHeight
   put the vScroll of fld "gems-quote" into tVscroll
    put tTextHeight - tVscroll into tBalanceToScroll
   if tBalanceToScroll < 195 then
        return   "true"
   else
      return  "false"
    end if
end checkScrollDone
