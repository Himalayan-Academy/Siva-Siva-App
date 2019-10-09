Script "stack_calendar_group_id_1014"

/*
# Name: group "city-picker-view" of card "main-calendar" of stack "calendar"
# ID: group id 1014 of card id 1002 of stack "calendar"
# Behavior: stack "behavior_mobileScroller"
*/



# TO DO we should be getting city list for the so that would can update it easily
on showCityList pBool
  if pBool then -- show list
    set the acceleratedRendering of this stack to false -- prevent window push-up
    put the cCityList of fld "cityList" into fld "cityList"
    put "" into fld "citySearch"
    send "resetDefaultText" to fld "citySearch"
    show grp "citySearchGrp"
    if not the vis of fld "citylist" then
      lock screen for visual effect in rect (the rect of fld "citylist")
      show fld "citylist"
      unlock screen with visual effect scroll down fast
    end if
    wait 10 milliseconds -- in case
    createScroller "cityList"
  else-- hide list
    lock screen
    hide grp "citySearchGrp"
    hide fld "cityList"
    unlock screen
    deleteMobileControl "cityList"
    wait 1 millisecond
    set the acceleratedRendering of this stack to true -- restore
 end if
 show btn "submit"
end showCityList




-- on showYearList pBool
--   if pBool then -- show list
--     get the date
--     convert it to dateitems
--     put item 1 of it into tYear
--     put tYear-1 &cr& tYear & cr into tYearList
--     repeat 5
--       add 1 to tYear
--       put tYear & cr after tYearlist
--     end repeat
--     put tYearlist into fld "yearList"
--     if not the vis of fld "yearList" then
--       lock screen for visual effect in rect (the rect of fld "yearList")
--       show fld "yearList"
--       unlock screen with visual effect scroll down fast
--     end if
--     wait 10 milliseconds -- in case
--     createScroller "yearList"
--   else-- hide list
--     lock screen
--     hide fld "yearList"
--     unlock screen
--     deleteMobileControl "yearList"
--   end if
-- end showYearList
