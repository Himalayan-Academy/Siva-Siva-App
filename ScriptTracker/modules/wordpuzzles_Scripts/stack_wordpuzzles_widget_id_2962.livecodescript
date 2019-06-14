Script "stack_wordpuzzles_widget_id_2962"

/*
# Name: widget "wordPuzzleSettings" of bkgnd "puzzleControls" of stack "wordpuzzles"
# ID: widget id 2962 of bkgnd id 1003 of stack "wordpuzzles"
# Widget Kind: com.livecode.widget.svgpath
*/


on mouseUp
   clearBoard
   set the hilited of me to true
   difficultyPicker "pickLevel"   
   set the hilited of me to false
end mouseUp
