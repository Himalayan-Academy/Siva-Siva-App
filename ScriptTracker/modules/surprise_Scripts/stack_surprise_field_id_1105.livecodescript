Script "stack_surprise_field_id_1105"

/*
# Name: field "random-verse" of card "surprise_verse" of stack "surprise"
# ID: field id 1105 of card id 1106 of stack "surprise"
# Behavior: stack "behavior_mobileScroller"
*/


on textChanged
   set the vscrollbar of fld "random-Verse" to \
   (the height of fld "random-Verse" < the formattedheight of fld "random-Verse")
end textChanged
