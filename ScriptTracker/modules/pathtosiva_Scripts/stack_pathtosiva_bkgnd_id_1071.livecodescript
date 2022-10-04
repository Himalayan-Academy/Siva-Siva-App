Script "stack_pathtosiva_bkgnd_id_1071"

/*
# Name: bkgnd "indexGrp" of stack "pathtosiva"
# ID: bkgnd id 1071 of stack "pathtosiva"
# Behavior: button id 1252 of stack "pathToSiva"

# Shared group on card IDs: 1002
*/


command doScrollerTap  -- navigate
   local tNum, tLesson, tTrackdata
   setPref "index","photo index"
   put char 1 to 2 of the short name of the mousecontrol into tNum
   set the numberformat to "0"
   add 0 to tNum -- remove any leading zero
   put "lesson" && tNum into tLesson
   goCd tLesson,"reveal left"
   put tLesson into tTrackdata["targetContent"]
   tracking_RecordActivity "Path To Siva", "navigation/goContent", tTrackdata
end doScrollerTap
