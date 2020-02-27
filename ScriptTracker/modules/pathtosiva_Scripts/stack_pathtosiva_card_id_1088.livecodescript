Script "stack_pathtosiva_card_id_1088"

/*
# Name: card "cover" of stack "pathtosiva"
# ID: card id 1088 of stack "pathtosiva"
*/


local sGoToPhotoIndexID

on preOpenCarD
   
   resetTOCColors -- init
   if the platform is "iPhone" then
      set the theme of widget "showTerms" to "iOS"
   else
      set the theme of widget "showTerms" to "Android"
   end if
   set the hilited of widget "showTerms" to false
   send "gotoPathIndex" to me in 4 seconds
   
   put the result into sGoToPhotoIndexID

   
end preOpenCard

on mouseup
   gotoPathIndex
end mouseup

on openCard
   animateCard
end openCard

on closeCard
   stop moving img "Tiger"
   cancel sGoToPhotoIndexID
end closeCard

on animateCard
   put the right on this card into tStart
   set the repeatCount of img "Tiger" to -1
   move img "Tiger" from tStart,705 to -59,705 in 10 seconds without waiting 
end animateCard


command goToPathIndex
   
   # NOTE for now user to photo index
   # later version will take index with  scope:
   # listen to audio, play game, etc.
   
   --goCd "choose your path","reveal left"
   
   goCd "photo index","reveal left"
   
end goToPathIndex

command resetTOCColors
  put lineoffset("lesson 1",fld "toc") into tLessonStart
  set the textcolor line 1 to -1 of fld "toc" to empty -- default textcolor
  set the backcolor line 1 of fld "toc" to the hilitecolor of fld "toc" -- "show defined words"
  set the backcolor of line 2 to tLessonStart-1 of fld "toc" to "226,131,80" -- orange
  set the backcolor of line tLessonStart to -1 of fld "toc" to empty --  use grp color
end resetTOCColors

