Script "stack_pathtosiva_widget_id_1275"

/*
# Name: widget "showTerms" of bkgnd "menuGrp" of stack "pathtosiva"
# ID: widget id 1275 of bkgnd id 1080 of stack "pathtosiva"
# Widget Kind: com.livecode.widget.switchbutton
*/



on hiliteChanged
  flagGlossaryTerms the hilited of me
  --toggleHeader false
  toggleMenu
end hiliteChanged
