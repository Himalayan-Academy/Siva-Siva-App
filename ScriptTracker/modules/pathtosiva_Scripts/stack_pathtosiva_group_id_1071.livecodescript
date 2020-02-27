Script "stack_pathtosiva_group_id_1071"

/*
# Name: group "indexGrp" of card "photo index" of stack "pathtosiva"
# ID: group id 1071 of card id 1002 of stack "pathtosiva"
# Behavior: button id 1252 of stack "pathToSiva"
*/



command doScrollerTap  -- navigate
   setPref "index","photo index"
   put char 1 to 2 of the short name of the mousecontrol into tNum
   set the numberformat to "0"
   add 0 to tNum -- remove any leading zero
   put "lesson" && tNum into tLesson
   goCd tLesson,"reveal left"
   put tLesson into pTrackdata["targetContent"]
   tracking_RecordActivity "Path To Siva", "navigation/goContent", pTrackdata
end doScrollerTap
