Script "stack_surprise_card_id_1106"

/*
# Name: card "surprise_verse" of stack "surprise"
# ID: card id 1106 of stack "surprise"
*/


on opencard
   positionQuote
   pass opencard
end opencard

on closeCard
   put empty into fld "random-verse"
   dispatch "deleteMobileControl" to fld "random-verse" with " random-verse"
end closeCard

on setUpQuote
   local aQuoteDetails
   
   lock screen
   put getQuoteData() into aQuoteDetails
   put aQuoteDetails["content"] into fld "random-verse" of card "surprise_verse"
   put cr & cr & aQuoteDetails["author"] after fld "random-verse" of card "surprise_verse"
   set the textalign of line -1 of   fld "random-verse" of card "surprise_verse" to left
   set the textStyle of line -1 of   fld "random-verse" of card "surprise_verse" to "plain"
   set the textStyle of line -1 of   fld "random-verse" of card "surprise_verse" to "italic"
   put cr & cr & aQuoteDetails["subject"] after fld "random-verse" of card "surprise_verse"
   set the textalign of line -1 of   fld "random-verse" of card "surprise_verse" to right
   set the textStyle of line -1 of   fld "random-verse" of card "surprise_verse" to "plain"
   put cr & aQuoteDetails["citation"] after fld "random-verse" of card "surprise_verse"
   set the textalign of line -1 of   fld "random-verse" of card "surprise_verse" to right
end setUpQuote

on SetUpCard 
   #called by the go next group/widget
   # each media type may have different requirements.
   positionQuote
end SetUpCard

on positionQuote
   local tRequiredHeight
   
   wait 200 milliseconds # for android since we are setting the accelleratedRendering
   # function here to get the formatted height of the quote
   # set the field height to that height
   # subtract from card height
   # divide by 2 and set top
   # if over length set generic height to 614, top to 62 and turn on scroll bar
   # We will no
   
   put the formattedHeight of fld "random-verse" into tRequiredHeight
   
   if tRequiredHeight > 612 then
      set the rect of fld "random-verse" to 32,62,396,674
      dispatch "createScroller" to fld "random-verse" with  "random-verse" 
   else
      set the height of fld "random-verse" to tRequiredHeight
      set the loc of fld "random-verse" to the loc of this card
   end if
   unlock screen
end positionQuote

command share_Items
   local tShareItemsA
   -- put mediaUrl_Get() into tShareItemsA["url"]  
   # later we get the URL for the book from which the verse was taken and pass that.
   put "Sacred Verses" into tShareItemsA["subject"]
   put fld "random-verse" & cr & cr & "From the SivaSiva app." into tShareItemsA["text"]
   return tShareItemsA
end share_Items




