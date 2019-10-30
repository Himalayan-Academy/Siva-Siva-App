Script "stack_color-meditation_card_id_1066"

/*
# Name: card "runColors" of stack "color-meditation"
# ID: card id 1066 of stack "color-meditation"
*/


local sStopFlag, sLevel,sColorList,sColors,sColorNames
local sBreathCount,sBreathPace,sCycles,sAudioOn,sPendingMessages
CONSTANT kLEVELS="Primary Colors,Tertiary Colors,Transmute to Whilte"

# pass the user settings array units to locals for easeier coding

 
on preopencard
  -- breakpoint
   hide grc "currentColor" # only used on third level
   set the blendlevel of grc "currentColor" to 0
   put getColorWheel() into sColorList 
   getUserPrefs
   # 12 lines in proper wheel order: [name] tab [RGB value]
   # cannot use comma as itemdel because RGB values are separated by comma already
   # Primary colors; Line 1, red; line 5, yellow; line 9, blue
   # but we use them in this order red, blue, yellow
   
   put getCurrentLevel() into sLevel 
   setLastactivity sLevel     
   # we  do different things for each level display here
   # we should probalby move thie to the stack script somehow...
   
   switch sLevel
      
      ## KM 05/17/2017
      ## Commented these two lines out of the SWITCH statement of the script would not indent correctly = possible inconvenience!
      ## and they are already written above!
      #       put empty into sColorColor count # user may be switching levels without leaving stack
      #       set itemdel to tab
      case "1" # three primary colors
         setTitle "Primary Colors" # UI changes
         setUpLevel "1"      
         put (1 & tab & 9 & tab & 5) into sColors
         break
      case "2"
         setTitle "Tertiary Colors"
         # based on Panchakashara/Chakra colors 
         setUpLevel "2"
         put (1 & tab & 3 & tab & 5 & tab & 7 & tab & 9 & tab & 10) into sColors
         break
         
      case "3"
         setTitle "Transmute to White"
         # based on Panchakashara/Chakra colors 
         setUpLevel "3"
         put (1 & tab & 9 & tab & 5) into sColors
         break
         
   end switch
   
   
   # clear the stage in case anything left over from 
   # previous run
   hide group "breathControl" 
   hide widget "pause"
   hide fld "progressMessage"
   put empty into fld "progressMessage"
   put 0 into sStopFlag   
   
   # Need to store the current color count in the stack
  
end preopencard

on opencard
   blinkStart "true"
end opencard

command setTitle pTitle
     put pTitle into fld "title" 
end setTitle

on toggleShow
   if the vis of grp "breathControl"  then  # show is paused
      # we need to start again
      put 0 into sStopFlag
      runLevel sLevel
   else
      put 1 into sStopFlag
      interruptColorShow
   end if
   
end toggleShow

command setUpLevel pLevel
   switch pLevel
      case "1"
         set the backgroundcolor of this card to "255,0,0"  
         set the textcolor of fld "title" to "235,235,235" 
         break
      case "2"   
         set the backgroundcolor of this card to "127,0,255"   
         set the textcolor of fld "title" to "235,235,235"
         break
      case "3"   
         set the backgroundcolor of this card to "255,255,255"   
         set the textcolor of fld "title" to "26,26,26" 
         break
   end switch
   
end setUpLevel


on runLevel sLevel
   visProgressMessage false
   -- breakpoint
   # User might have changed settings, we have to check again
   getUserPrefs
   # clear the decks
   put 0 into sStopFlag
   hideTools
   
   # give user a chance to get ready
   put "Exhale"& cr & "Completely" into fld "practiceInstructions"
   
   put empty into fld "breathCount"  
   put empty into fld "breathPhase"
   put empty into fld "progressMessage"
   hide fld "ProgressMessage"
   show grp "breathControl"
   show widget "pause"
   show fld "practiceInstructions"
   
   wait 2 seconds
   
   put item sLevel of kLEVELS into pTrackdata["colorLevel"]
   tracking_RecordActivity "Color Meditation", "practice/begin", pTrackdata
   
   
   
   repeat  sCycles times 
      
      # number of cycles, default on app install is 1
      # there after calls the user setting that is save as a preference
      
      wait 30 milliseconds with messages
      
      if sStopFlag=1 then 
         exit repeat
      end if     
      
      set the itemdel to tab
      
      repeat for each item tColorLine in sColors
         local tColorName, tColorValue
         put item 1 of line tColorLine of sColorList into tColorName
         put item 2 of line tColorline of sColorList into tColorValue
         if sStopFlag=1 then 
            exit repeat
         end if
         
         # Now changing the colors is easy:
         # level three require a grc and a pure white card
         set the backgroundcolor of grc "currentColor" to tColorValue
         if sLevel= 3 then
            set the backgroundcolor of this card to "255,255,255"
            set the backgroundcolor of grc "currentColor" to tColorValue
            set the blendlevel of grc "currentColor" to 0
            --show grc "CurrentColor"
         else 
            set the backgroundcolor of this card to tColorValue
            set the backgroundcolor of grc "currentColor" to tColorValue
            --show grc "currentColor"
            
         end if
         put  "Visualize" & cr &  tColorName  into fld "practiceInstructions"
         show fld "practiceInstructions"
         #  Inhalation Phase
         
         show grc "CurrentColor"
         
         repeat with x = 1 to sBreathCount
            wait 32 milliseconds with messages
            if sStopFlag=1 then 
               exit repeat
            end if
            put "Inhale" into fld "breathPhase"
            put x into fld "breathCount"
            put x +1 into tNextCount
            if tNextCount > sBreathCount then
               wait sBreathPace milliseconds with messages
               exit repeat
            else
               put x into fld "breathCount"
               wait sBreathPace milliseconds with messages
               if x >1 then hide fld "practiceInstructions"         
            end if
            
         end repeat
         
         put "Hold 1" into fld practiceInstructions
         show fld "practiceInstructions"
         wait sBreathPace milliseconds with messages
         
         # Exhalation Phase
         set the blendlevel of grc "currentColor" to 0
         if sLevel = 3 then # need to reduce opacity of grc currentColor over time
            put  ("Flood" && tColorName  &&  "with White into Light") into fld "practiceInstructions"     
            --send "progressiveTint" to me
         else
            put  "Flood Yourself" &cr & "with" &&  tColorName into fld "practiceInstructions" 
         end if
         
         repeat with x = 1 to sBreathCount
            if sStopFlag=1 then 
               exit repeat
            end if
            put "Exhale" into fld "breathPhase"
            put x into fld "breathCount"
            put x +1 into tNextCount
            put  the blendlevel of grc "currentColor" into tBlendLevel
            put tBlendLevel+(round(100/sBreathCount)) into tIncrement
            set the blendlevel of grc "currentColor" to tIncrement
            if tNextCount > sBreathCount then
               wait sBreathPace milliseconds with messages
               exit repeat
            else
               put x into fld "breathCount"
               wait sBreathPace milliseconds with messages
               if x >1 then hide fld "practiceInstructions"
            end if
         end repeat
         put "Hold 1" into fld practiceInstructions
         show fld "practiceInstructions"
         wait sBreathPace milliseconds with messages         
      end repeat
      
   end repeat
   
   if sStopflag=0  then
      # it means cycles ran through to the end; user did not interrupt
      # so we can do:
      showCompletion
   end if 
end runLevel

   ## NEXT DEV TO DO:
   ## We need to save the number of rounds to gUserSettings
   ## also save the date... after the user leaves the card
   ## 
   ## if the date is not a new day, then only 2 rounds count toward progress level.
   ## gUserSettings will need a new key: level and  progressLevel  
   ## if progressLevel is 2, and the day is not= to today
   #  then expose next level.
   ## tracking also for now in the JSON  
   ## number of rounds per level   
   ## 
   ## Inform user they can adjust settings to 
     
on interruptColorShow
   setUpLevel sLevel
   put 1 into sStopFlag
   hide grp "breathControl"
   hide widget "pause"
   showTools
   put item sLevel of kLEVELS into pTrackdata["colorLevel"]
     tracking_RecordActivity "Color Meditation", "practice/interrupted", pTrackdata
end interruptColorShow

on closeCard
   # cleanup 
   put empty into fld "title"
   hide fld "ProgressMessage"  
   hide grc "currentColor"
end closeCard

on showCompletion
   setUpLevel sLevel
   hide grp "breathControl"
   hide widget "Pause"
   hide grc "currentColor"
   visProgressMessage true
   # later we should go to some cool color med animation instead of a message
   
   if sCycles = 1 then
      put " round." into tRounds
   else
      put " rounds." into tRounds
   end if
   put "Congratulations!" & cr & "You completed" & cr & sCycles & tRounds into fld "progressMessage"
   
   showTools
   
   put item sLevel of kLEVELS into pTrackdata["colorLevel"]
   tracking_RecordActivity "Color Meditation", "practice/completed", pTrackdata
end showCompletion
   
command getUserPrefs
   # Fetch User Prefs
   put getUserPreferences() into tSettings
   put tSettings["breathCount"] into sBreathCount
   #prefs for pace is saved as seconds but we use milleseconds the show
   # to handle seconds decimal values
   put tSettings["breathPace"] * 1000 into sBreathPace
   put tSettings["cycles"] into sCycles
   put tSettings["audioOn"]  into sAudioOn    
end getUserPrefs

command progressiveTint
   put sBreathCount * sBreathPace into totalExhaleTime
   put totalExhaleTime/100 into pTime   
   set the blendlevel of grc "currentColor" to (the blendlevel of grc "currentColor" +1)
   if not (the blendlevel of grc "currentColor"= 100) then
      send "progressiveTint" to me in pTime seconds      
   end if   
end progressiveTint



