Script "stack_color-meditation_widget_id_1198"

/*
# Name: widget "saveToJournal" of card "colorPreferences" of stack "color-meditation"
# ID: widget id 1198 of card id 1023 of stack "color-meditation"
# Widget Kind: com.livecode.widget.svgpath
*/


on mouseUp
   journal_AddEntry
   dialog_CustomMsg "Saved to Journal"
end mouseUp
