script "behavior_DailyLesson"
local sConfigA, sOnLine, sCurrentRealm, sViewState
local sLastActivityA, sLesson, sLineStyle

on preopenstack
   local tOrientations
   
   put "portrait,portrait upside down" after tOrientations
   put ",landscape left,landscape right" after tOrientations
   
   if isMobile() then 
      mobileSetAllowedOrientations tOrientations 
   end if
end preopenstack

on preOpenCard
   setCardCoords
   resetUI
   updateUI
   
   # Fix image path from desktop when loading on Mobile
   # should not be required since David's method solve the issue (we think)
   
   # reusing some functions here from the gems module 
   # to pull in images for the background
   # only call God and Soul realm images for now.
   
   put random(2) into sCurrentRealm 
   
   --play (localPath() &"shared/audio/aum.mp3")
   
   hide grp "lessonTextControl" 
   put empty into sLesson
   
   send "fetchLessonAndImage" to me in 20 milliseconds
end preOpenCard


on opencard
   audioIsRunning  
end opencard

on mouseup
   
   local tTarget, tResizeText
   
   put the short name of the Target  into tTarget
   --put tTarget
   switch tTarget
      
      case "right-arrow"
         goNextLesson
         break
         
      case "left-arrow"
         goPreviousLesson
         break
         
      case "fontResize"
         
         if the vis of fld "daily-lesson-text" is true then
            put the long id fld "daily-lesson-text" into tResizeText
            if the textSize of  tResizeText  = 32 then
               set the textSize of tResizeText to 20
            else
               set the textsize of tResizeText  to (the textsize of tResizeText  + 4)
            end if
         end if
         
         break
         
      case "turnOffAudio"
         turnOffAudio
         
         break
         
         
   end switch
end mouseup


command resetUI
   put empty into fld "title"
   put empty into fld "daily-lesson-text"
end resetUI

# more than needed but we may expand activities in this module later
# so keeping Jacque's nice construct for now.



on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

on updateUI
   local tFooter, tTitle, tRect, tControl, tTextBottom, tOrientation
   
   put the long id of grp "footerNavigation" into tFooter
   if currentlyLandscape() then
      set the visible of tFooter to false
      put CardHeight() into tTextBottom
      put "landscape" into tOrientation
   else
      set the visible of tFooter to true
      send "updateUI" to tFooter
      put the top of tFooter into tTextBottom
      put "portrait" into tOrientation
   end if
   
   put the long id of fld "Title" into tTitle
   topCenterMe tTitle, 7
   
   put the long id of btn "right-arrow" into tControl
   topRightMe tControl
   
   put the long id of btn "left-arrow" into tControl
   topLeftMe tControl
   
   put the long id of grp "resizeFonts" into tControl
   set the bottomRight of tControl to (CardWidth()-15,tTextBottom-6)
   
   put the long id of grp "lessonTextControl" into tControl
   put (0,the bottom of tTitle + 30,CardWidth(),tTextBottom) into tRect
   set the rect of tControl to tRect
   
   if isMobile() then
      send "deleteMobileControl daily-lesson-text" to fld "daily-lesson-text"
      if the formattedheight of fld "daily-lesson-text" > the height of fld "daily-lesson-text" then
         send "CreateScroller daily-lesson-text" to fld "daily-lesson-text"
      end if
   end if
   
   put the long id of img "lesson-background" into tControl
   setImageToFullCardLoc tControl, tOrientation
   set the loc of tControl to CardLoc()
end updateUI

command goNextLesson
   put empty into fld "title"
   if sLesson= 365 then
      put 1 into sLesson
   else 
      add 1 to sLesson
   end if
   send "fetchLessonAndImage sLesson" to me
end goNextLesson

command goPreviousLesson
   put empty into fld "title"   
   if sLesson= 1 then
      put 365 into sLesson
   else 
      subtract 1 from sLesson
   end if
   send "fetchLessonAndImage sLesson" to me    
end goPreviousLesson

command fetchLessonAndImage sLesson
   local tTitles, tRealm, tTrackData
   
   put "Realm of God,Realm of Soul" into tTitles # Currently wired to Realm of god and soul (no "Life")
   put item sCurrentRealm of tTitles into tRealm # set to 1 for the daily MC lesson
   ## Fetch Images
   fetchImage tRealm
   wait 300 milliseconds with messages
   
   buildLesson sLesson
   
   if isMobile() then
      
      # there is no way to dynamically fetch the new formatted height if the
      # next lesson is longer than the last one. Our only option is to delete
      # and recreate the mobilescroller on the fly      
      
      #scroller_Delete "scrolling gems field"
      send "deleteMobileControl daily-lesson-text" to fld "daily-lesson-text"
      # recreate:
      if the formattedheight of fld "daily-lesson-text" > the height of fld "daily-lesson-text" then
         send "CreateScroller daily-lesson-text"  to fld "daily-lesson-text"
      end if
      
   end if
   put fld "title" into tTrackData["currentLesson"]
   tracking_RecordActivity "Daily Lesson", "navigation/goContent", tTrackdata
end fetchLessonAndImage

command fetchImage pRealm
   local tImgSQL, tConnectionID, tImageFileID, tNextImagePath, tControl
   
   put _getRandomImageSQL() into tImgSQL
   replace ":1" with pRealm in tImgSQL
   put JnanamDB() into tConnectionID
   dbSetSQL tImgSQL
   put dbGet("file_id", tConnectionID) into tImageFileID
   put textDecode(tImageFileID[1]["file_id"], "UTF8")  into tImageFileID     
   put sivasiva_AssetFolder() & "img/photography/" & tImageFileID & "/" & \
         tImageFileID & "_med.jpg" into tNextImagePath
   
   put the long id of img "lesson-background" into tControl
   set the filename of tControl to tNextImagePath   
   setImageToFullCardLoc tControl, "portrait"
   set the loc of tControl to CardLoc()
end fetchImage

on updateImages # call if needed to update the dbase after changes made on disk to photo folders
   jnanam_UpdatePhotoCache
end updateImages

private function _getRandomSQL
   local tSQL
   put the uRandomSQLQuery of this card into tSQL
   return tSQL
end _getRandomSQL

private function _getRandomImageSQL
   local tSQL
   put the uRandomImageSelect of this card into tSQL
   return tSQL
end _getRandomImageSQL

on setLastactivity  pLessonNum, pCdName  
   put pCdName into sLastActivityA["CdName"]
   put pLessonNum into sLastActivityA["LessonNum"]
end setLastactivity

-----------------
on _BuildTheLesson
end _BuildTheLesson

command buildLesson pLessonNumber
   local tStartYear, tToday, theNow, tNewYear, tLessonNo, tDwSNo, \
         tTodaysDWS, tTodaysLWS, tTodaysSUTRA, tTodaysMWS
   lock screen for visual effect
   show grp "lessonTextControl"
   # Start with getting the right number  based on the day
   # or specific request
   if pLessonNumber is empty then
      
      	
      # no value was pass so 
      # this is the daily lesson and not a request for a specific lesson number
      # We have to fetch the number for today based on the days since
      # Tamil New Year which is fixed for this context to April 13
      
      # First we get todays date items from the local system
      --       put the long date into tToday
      --       put item 3 of tToday into tYear
      --       put word 1 of item 2 of tToday into tMonth
      --       put word 2 of item 2 of tToday into tDay
      --       if tDay is in (1,2,3,4,5,6,7,8,9) then put "0" before tDay
      --       put tMonth & " " & tDay & ", " & tYear into tDate
      
      # next we have to determine the correct Tamil New Year to count from
      # this is tricky because from Jan-Feb-Mar-Apr 1-12: we have to use last year's date
      	
      # set some base values for the algorithm to rollover automatically
      put "4/13/" into tStartYear
      put the date into tToday
      put tToday into theNow
      convert theNow to seconds
      set the itemdel to "/"
      
      if item 1 of tToday < 4 then # we are in the months of 1,2,3 Jan, Feb March
         put (item 3 of tToday-1)  after tStartYear  # Still counting from last April
      end if  
      
      if item 1 of tToday = 4 then 
         # we are in April and keep counting from last April until the 13th
         # the only way is to check is on the seconds
         put tStartYear into tNewYear
         put item 3 of tToday after tNewYear  # this is the April 13 of this year....
         convert tNewYear to seconds
         if theNow < tNewYear then # we are i the period of April 1-12 and retain last year's start year
            put (item 3 of tToday-1)  after tStartYear  
         else  # this is April 13-30th 
            put (item 3 of tToday)  after tStartYear
         end if
      end if  
      if item 1 of tToday > 4  then
         # we are in the period from May thru December and count from April of the current year
         put (item 3 of tToday)  after tStartYear
      end if
      
      
      
      	  
      -- Next we get the integer of the day of the year since April 13th
      	  
      #  In order to find the integer we need for today's lesson, we use the
      # rule that lesson one starts on the first day of the Hindu year, which
      # is generally about April 13, but could vary every year, so we have that
      # date hard coded and have to change it each year, and put the correct
      # day and year. Later we may find a way to get this from the system...
      #  
      # We then take advantage of the fact that Unix dates are stored as a number
      # of seconds from some base offset year (like 1970), and we convert both
      # today's date, and the new year date to seconds, and subtract, then divide
      #  by the number of seconds (86,000 = 24*60*60) in a day, to get the number
      # of days we are past the new year (= lesson number). However, we found
      # out, this only works when we sample the date after twelve noon.
      # 
      # When our cron job runs anytime before twelve noon (which it does) then
      # the difference between the seconds at midnite (which is the default moment
      # for the "generic" conversion of a date to seconds) and the seconds on the
      # machine when we query for the seconds integer "now", divided by 86,000
      # (the number of seconds in a day) the result will always be an integer,
      # plus a decimal fraction below .5 (probably around .3 on april 13, 1.3
      # on April 14, 2.3 on april 15 etc.) which is 1 integer off after round
      # because, being below .5, it rounds down (to 0 on April 13, 1 on april
      # 14 etc.) so we add 1 to make it (1 on april 13, 2 on april 14)
      	 
      # Must Solve the issue of setting the year here automatically!
      # Meditate on this ....
      
      convert tStartYear to seconds
      put the date into theNow
      convert theNow to seconds
      put  (the round of ((theNow-tStartYear)/(24*60*60)))+ 1 into pLessonNumber
      put pLessonNumber into sLesson  # save locally for nav buttons
      # we want the date to appear in this case only
      put "Today's Lesson - " &   pLessonNumber into  fld "Title"
   else
      	
      # the user is requesting a specific lesson
      # we only display the lesson # he request and no date	  
      put "Lesson " &   pLessonNumber into  fld "Title"
      put pLessonNumber into tLessonNo
      	  
   end if
   setLastactivity pLessonNumber,"daily-lesson" # for journal `  
   ---create the lesson of the day 
   	    
   --extracts from Dancing with Siva , but first
   --We also have to deal with DwS rotating 155 slokas for the internet
   
   put pLessonNumber into tDwSNo
   if tDwSNo > 155 and tDwSNo < 311 then
      put (tDwSNo-155) into  tDwSNo
   else
      if tDwSNo > 310  then #cycled around 2nd time...
         put (tDwSNo-310) into  tDwSNo
      end if
   end if
   
   put  (returnFiles("dws-lessons",tDwsNo) ) into tTodaysDWS
   
   --  put the long id of fld "daily-lesson-text" into tTargetField
   -- put "hello" into tTargetField --  fld "daily-lesson-text"
   
   
   #We have to style each lesson with custom styles
   
   lock screen
   
   --    #DWS: center the book title, 
   
   put empty into fld "daily-lesson-text"
   
   
   
   #Book Title
   
   put line 1 of tTodaysDWS after fld "daily-lesson-text" 
 -- put 20 into sLineStyle["textsize"]
   put "center" into sLineStyle["textalign"]
   put "italic" into sLineStyle["textstyle"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Question
   put cr & line 2 of tTodaysDWS after fld "daily-lesson-text"
   
   put "bold" into sLineStyle["textstyle"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Sloka - Number
   put cr & line 4 of tTodaysDWS after fld "daily-lesson-text"
   
   put "bold" into sLineStyle["textstyle"]
   --put 14 into sLineStyle["textsize"]
   put 4 into sLineStyle["spaceBelow"]
   
   styleLastLIne sLineStyle
   
   # Sloka - text
   
   put cr & line 6 of tTodaysDWS after fld "daily-lesson-text"
   --put 20 into sLineStyle["textsize"]
   put  20 into sLineStyle["leftIndent"]
   put 4 into sLineStyle["spaceBelow"]
   put "plain" into sLineStyle["textstyle"]
   put "left" into sLineStyle["textalign"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Bhashya Header
   put cr & line 8 of tTodaysDWS after fld "daily-lesson-text"
   put  0 into sLineStyle["leftIndent"]
   put "center" into sLineStyle["textalign"]
   put "bold" into sLineStyle["textstyle"]
   --put 14 into sLineStyle["textsize"]
   put 4 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Bhashya - text
   
   put cr & line 10 of tTodaysDWS after fld "daily-lesson-text"
   
   --put 18 into sLineStyle["textsize"]
   put  20 into sLineStyle["leftIndent"]
   put 4 into sLineStyle["spaceBelow"]
   put "plain" into sLineStyle["textstyle"]
   put "left" into sLineStyle["textalign"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   ## Living with Siva Next
   
   put  (returnFiles("lws-lessons",pLessonNumber) ) into tTodaysLWS
   put  cr & "__________" after fld "daily-lesson-text"
   put "center" into sLineStyle["textalign"]
   styleLastLIne sLineStyle
   
   # Book Title
   put  cr & "Living with Siva" after fld "daily-Lesson-Text"
   --put 20 into sLineStyle["textsize"]
   put "center" into sLineStyle["textalign"]
   put "italic" into sLineStyle["textstyle"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Lesson number 
   put cr & (word 1 to 2 of line 1 of  tTodaysLWS) after fld "daily-lesson-text"
   
   put "bold" into sLineStyle["textstyle"]
   --put 14 into sLineStyle["textsize"]
   put 6 into sLineStyle["spaceBelow"]  
   styleLastLIne sLineStyle
   
   # Lesson Head
   
   put cr & line 3 of tTodaysLWS after fld "daily-lesson-text"
   put "bold" into sLineStyle["textstyle"]
  --put 20 into sLineStyle["textsize"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Lesson Text
   # need to change style in advance to cover all the follow paragraphs
   # just use one line to start
   
   put  cr  & line 5 of tTodaysLWS after fld "daily-lesson-text"    
   --put 18 into sLineStyle["textsize"]
   put  20 into sLineStyle["leftIndent"]
   put "plain" into sLineStyle["textstyle"]
   put "left" into sLineStyle["textalign"]
   put 0 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # finish with the rest of text
   put cr & (line 6 to -1 of tTodaysLWS) after fld "daily-lesson-text"
   
   # Sutra Next
   
   put  (returnFiles("nandinatha-sutras",pLessonNumber) ) into tTodaysSUTRA
   
   put cr &  "__________" after fld "daily-lesson-text"
   put "center" into sLineStyle["textalign"]
   put  0 into sLineStyle["leftIndent"]
   styleLastLIne sLineStyle
   put cr after fld "daily-Lesson-Text"
   
   #Book Title & section (for sutra category
   
   put cr & line 1 of tTodaysSUTRA after fld "daily-lesson-text"  #Book Title
   
   --put 20 into sLineStyle["textsize"]
   put "center" into sLineStyle["textalign"]
   put "italic" into sLineStyle["textstyle"]
   put 5 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   put cr & line 2 of tTodaysSUTRA after fld "daily-lesson-text"  #Sutra section
   --put 20 into sLineStyle["textsize"]
   styleLastLIne sLineStyle
   
   # Sutra- Number
   put cr & (trueword 1 to 2 of line 4 of tTodaysSUTRA) after fld "daily-lesson-text"    
   put "bold" into sLineStyle["textstyle"]
   --put 14 into sLineStyle["textsize"]
   put 0 into sLineStyle["spaceBelow"]    
   styleLastLIne sLineStyle
   
   # Sutra- Title
   put cr &  (trueword 3 to-1 of line 4 of tTodaysSUTRA) after fld "daily-lesson-text"   
   put 10 into sLineStyle["spaceBelow"]
   --put 18 into sLineStyle["textsize"]
   put 30 into sLineStyle["leftIndent"]
   put 30 into sLineStyle["RightIndent"]
   styleLastLIne sLineStyle
   
   # Sutra- text
   put cr &   line 5 of tTodaysSUTRA after fld "daily-lesson-text"   
   
   
   --put 20 into sLineStyle["textsize"]
   put 20 into sLineStyle["leftIndent"]
   put "plain" into sLineStyle["textstyle"]
   put "center" into sLineStyle["textalign"]
   put 10 into sLineStyle["spaceBelow"]
   
   styleLastLIne sLineStyle
   
   ## Merging with Siva Next
   
   put  (returnFiles("mws-lessons",pLessonNumber) ) into tTodaysMWS
   
   put  cr & "__________" after fld "daily-lesson-text"
   put "center" into sLineStyle["textalign"]
   styleLastLIne sLineStyle
   
   # Book Title
   put  cr & "Merging with Siva" after fld "daily-Lesson-Text"
   --put 20 into sLineStyle["textsize"]
   put "center" into sLineStyle["textalign"]
   put "italic" into sLineStyle["textstyle"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Lesson number 
   put cr & (word 1 to 2 of line 1 of  tTodaysMWS) after fld "daily-lesson-text"
   
   put "bold" into sLineStyle["textstyle"]
   --put 14 into sLineStyle["textsize"]
   put 6 into sLineStyle["spaceBelow"]  
   styleLastLIne sLineStyle
   
   # Lesson Head
   
   put cr & line 3 of tTodaysMWS after fld "daily-lesson-text"
   put "bold" into sLineStyle["textstyle"]
   --put 20 into sLineStyle["textsize"]
   put 20 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # Lesson Text
   # need to change style in advance to cover all the follow paragraphs
   # just use one line to start
   
   put  cr  & line 5 of tTodaysMWS after fld "daily-lesson-text"    
  --put 18 into sLineStyle["textsize"]
   put  20 into sLineStyle["leftIndent"]
   put "plain" into sLineStyle["textstyle"]
   put "left" into sLineStyle["textalign"]
   put 0 into sLineStyle["spaceBelow"]
   styleLastLIne sLineStyle
   
   # finish with the rest of text
   put cr & (line 6 to -1 of tTodaysMWS) after fld "daily-lesson-text"
   put  cr & "__________" after fld "daily-lesson-text"
   put "center" into sLineStyle["textalign"]
   styleLastLIne sLineStyle
   put cr &cr & "Aum Tat Sat" after fld "daily-lesson-text"
   put "center" into sLineStyle["textalign"]
   styleLastLIne sLineStyle
   
   unlock screen with visual effect "dissolve" very fast
   	  
end buildLesson


function returnFiles pBook,pNumber
   local tFolder, tListOfLessons, tLessonTextFile, tPathToLesson, tLessonText
   put (path_Assets()&"books/"&pBook) into tFolder
   put files(tFolder) into tListOfLessons
   filter tListOfLessons without ".*"
   sort lines of tListOfLessons ascending numeric
   put line pNumber of tListOfLessons into tLessonTextFile
   put   (tFolder&"/"&tLessonTextFile )  into tPathToLesson
   put url ("binfile:"& tPathToLesson) into tLessonText
   return (textDecode(tLessonText,"UTF-8"))  
end returnFiles

command styleLastLine sLineStyle
    repeat for each key x in sLineStyle
        set the x of line -1 of fld "daily-Lesson-Text" to sLineStyle[x]
    end repeat
end styleLastLine


------------------
on _JournalPostResume
end _JournalPostResume

command addJournalEntry -- save a bookmark to db
   local tCdName, tData, tTitle
   put sLastActivityA["CdName"] into tCdName
   put tCdName into tData["card"] -- store the last user cd   
   if tCdName = "daily-lesson" then -- store the lesson number
      --put sLastActivityA["LessonNum"] into tLessonNum
      --put tLessonNum into tData["lessonNum"]
      --put "Master Course Dialy Lesson - " & tLessonNum into tTitle -- "lesson x"
      put "Master Course Daily Lesson"  into tTitle
   end if
   Journal_RecordEntry "daily-lesson",tTitle,tData -- send to journal
end addJournalEntry


on journalResume pData,pEntryA -- sent from journal stack
   local tCd
   put pData["card"] into tCd
   go to card tCd
   --put pData["lessonNum"] into tNum
   --send "fetchLessonAndImage tNum" to this cd
   
end journalResume

on closeStack
   --addJournalEntry
   portal_SetLastStack "daily-lesson" 
end closeStack










