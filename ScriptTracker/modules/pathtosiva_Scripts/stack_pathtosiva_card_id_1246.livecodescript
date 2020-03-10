Script "stack_pathtosiva_card_id_1246"

/*
# Name: card "about" of stack "pathtosiva"
# ID: card id 1246 of stack "pathtosiva"
*/


on preOpenCard
   local tPath
   put the filename of this stack into tPath
   set the itemdel to slash
   put "about.html" into last item of tPath
   if there is a file tPath then
      set the htmltext of fld "aboutFld" to url ("file:"&tPath)
   end if
   set the height of fld "aboutFld" to the formattedheight of fld "aboutFld"
   set the top of fld "aboutFld" to the top of grp "aboutTextGrp"
   set the scroll of grp "aboutTextGrp" to 0
   set the scroll of fld "aboutFld" to 0
   setLastactivity "about" # for Journal entry
   createScroller "aboutTextGrp"
   
   pass preOpenCard
end preOpenCard
