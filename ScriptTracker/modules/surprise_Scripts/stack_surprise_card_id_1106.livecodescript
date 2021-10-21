Script "stack_surprise_card_id_1106"

/*
# Name: card "surprise_verse" of stack "surprise"
# ID: card id 1106 of stack "surprise"
*/




on setUpQuote
   local aQuoteDetails
   
   --lock screen
   put getQuoteData() into aQuoteDetails
   put aQuoteDetails["content"] into fld "random-verse"
   
   put cr & cr & aQuoteDetails["author"] after fld "random-verse"
   set the textalign of line -1 of fld "random-verse" to left
   set the textStyle of line -1 of fld "random-verse" to "plain"
   set the textStyle of line -1 of fld "random-verse" to "italic"
   
   put cr & cr & aQuoteDetails["subject"] after fld "random-verse"
   set the textalign of line -1 of fld "random-verse" to right
   set the textStyle of line -1 of fld "random-verse" to "plain"
   
   put cr & aQuoteDetails["citation"] after fld "random-verse"
   set the textalign of line -1 of   fld "random-verse" to right
end setUpQuote



on positionQuote
   local tRequiredHeight, tAvailableHeight
   
   wait 200 milliseconds # for android since we are setting the accelleratedRendering
   
   set the width of fld "random-verse" to CardWidth() - 64
   put the formattedHeight of fld "random-verse" into tRequiredHeight
   
   put the top of grp "footerNavigation" - safeTopMargin() - 93 into tAvailableHeight
   
   if tRequiredHeight > tAvailableHeight then
      set the rect of fld "random-verse" to \
            (32, 62 + safeTopMargin(), CardWidth() - 32, the top of grp "footerNavigation" - 21) 
      dispatch "createScroller" to fld "random-verse" with "random-verse" 
   else
      set the height of fld "random-verse" to tRequiredHeight
      set the left of fld "random-verse" to 32
      set the top of fld "random-verse" to \
            (tAvailableHeight-tRequiredHeight)/2 + safeTopMargin() + 62
      dispatch "deleteMobileControl" to fld "random-verse" with "random-verse"
   end if
   unlock screen
   log ("go next: layer: " & the layer of grp "go-next" & " vis: "  & the vis of group "go-next" of me)
end positionQuote

command share_Items
   local tShareItemsA
   -- put mediaUrl_Get() into tShareItemsA["url"]  
   # later we get the URL for the book from which the verse was taken and pass that.
   put "Sacred Verses" into tShareItemsA["subject"]
   put fld "random-verse" & cr & cr & "From the SivaSiva app." into tShareItemsA["text"]
   return tShareItemsA
end share_Items

on closeCard
   put empty into fld "random-verse"
   dispatch "deleteMobileControl" to fld "random-verse" with "random-verse"
end closeCard







