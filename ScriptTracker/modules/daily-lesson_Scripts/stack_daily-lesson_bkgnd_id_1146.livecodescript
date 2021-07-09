Script "stack_daily-lesson_bkgnd_id_1146"

/*
# Name: bkgnd "lessonTextControl" of stack "daily-lesson"
# ID: bkgnd id 1146 of stack "daily-lesson"

# Background on card IDs: 1002
*/


on resizeControl
   local tRect, tControl, tFooterTop, tTitleBottom
   
   put the bottom of fld "Title" of this cd into tTitleBottom
   if currentlyLandscape() then
      put CardHeight() + 7 into tFooterTop
   else
      put the top of grp "footerNavigation" of this cd into tFooterTop
   end if
   
   put the long id of grc "quoteBackground" of me into tControl
   put (-200, 0, CardWidth()+200, tFooterTop + 1) into tRect
   set the rect of tControl to tRect
   
   put (4, tTitleBottom + 30, CardWidth() - 5, tFooterTop - 7) into tRect
   set the rect of fld "daily-lesson-text" of me to tRect
end resizeControl
