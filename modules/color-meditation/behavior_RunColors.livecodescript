script "behavior_RunColors"

global sConfigA

local sStopFlag, sLevel,sColorList,sColors,sColorNames
local sBreathCount,sBreathPace,sCycles,sAudioOn,sPendingMessages,sCountDown
local sColorName,sColorValue,sColorsTotal,sCurrentColor

CONSTANT kLEVELS="Primary Colors,Tertiary Colors,Transmute to Whilte"

# pass the user settings array units to locals for easeier coding
# Note: Hide and show controls impact performance 
# instead we are trying to leave all fields vis and text on empty into each field.
 

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
   set the itemdel to tab
   put the number of items of sColors into sColorsTotal
   put 0 into sCurrentColor #this is an integer which tell us we item of sColor we are on
 
   
   # clear the stage in case anything left over from 
   # previous run
   hide widget "pause"
   hide fld "progressMessage"
   put 0 into sStopFlag   
   
   # Need to store the current color count in the stack
   pass preOpenCard
end preopencard

--on opencard
--   blinkStart "true"
--end opencard

on mouseUp 
   
   put short name  of the target into tTarget
   
   switch  tTarget
      
      # the runColors show UI controllers
      case "Start"
         hide group "aboutDisplay"
         try
            visProgressMessage false
         end try
         put getCurrentLevel() into tCurrentLevel 
         switch tCurrentLevel
            case "1"
               runLevel "1"
               break
            case "2"
               runLevel "2"
               break
            case "3"
               runLevel "3"
               break
            case "4"
               runLevel "4"
               break
         end switch
         break
         
      case "pause"
         interruptColorShow
         break
         
         
   end switch
   pass mouseup
end mouseUp

command setTitle pTitle
   put pTitle into fld "title" 
end setTitle

--on toggleShow
--   if the vis of grp "breathControl"  then  # show is paused
--      # we need to start again
--      put 0 into sStopFlag
--      runLevel sLevel
--   else
--      put 1 into sStopFlag
--      interruptColorShow
--   end if

--end toggleShow

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
   show widget "pause"
   
   # give user a chance to get ready
   put "Exhale"& cr & "Completely" into fld "practiceInstructions"
   
   put empty into fld "breathCount"  
   put empty into fld "breathPhase"
   
   --wait 1 seconds
   put empty into fld "practiceInstructions"
   -- put item sLevel of kLEVELS into pTrackdata["colorLevel"]
   -- tracking_RecordActivity "Color Meditation", "practice/begin", pTrackdata
   
   colorBreathingCycle sCycles
   
   
   if sStopflag=0  then
      # it means cycles ran through to the end; user did not interrupt
      # so we can do:
      showCompletion
   end if 
end runLevel

command colorBreathingCycle sCycles
   if sStopFlag=1 then  # user pause
      exit colorBreathingCycle
   end if   
   
   if sCycles = 0 then # end of cycle
      exit colorBreathingCycle
   end if
   
   # number of cycles, default on app install is 1
   # there after calls the user setting that is save as a preference
   
   --wait 30 milliseconds with messages
   
   put sCycles - 1 into sCycles

   colorHueBreath
   
end colorBreathingCycle

command colorHueBreath
   --breakpoint
   -- we are going through each color
   -- after we finish all color 
   -- we have to go back to see if there using has another cycle
   
   if sStopFlag=1 then 
      exit colorHueBreath
   end if
   
   put empty into fld "breathPhase"
   put empty into fld "breathCount"
   add 1 to sCurrentColor
   
   if sCurrentColor > sColorsTotal then
      exit colorHueBreath # done with all colors
      colorBreathingCycle
   end if
   
   set the itemdel to tab
   put item sCurrentColor of sColors into tColorLine
   
   #repeat for each item tColorLine in sColors
   put item 1 of line tColorLine of sColorList into sColorName
   put item 2 of line tColorline of sColorList into sColorValue
   
   # Now changing the colors is easy:
   # level three require a grc and a pure white card
   set the backgroundcolor of grc "currentColor" to sColorValue
   if sLevel= 3 then
      set the backgroundcolor of this card to "255,255,255"
      set the backgroundcolor of grc "currentColor" to sColorValue
      set the blendlevel of grc "currentColor" to 0     
   else 
      set the backgroundcolor of this card to sColorValue
      set the backgroundcolor of grc "currentColor" to sColorValue 
   end if
   put  "Visualize" & cr &  sColorName  into fld "practiceInstructions"

   
   -- Now we  inhale
   put 0 into sCountDown 
   colorInhalation
   
end colorHueBreath

command colorInhalation
   if sStopFlag=1 then 
      exit colorInhalation
   end if
   
   put sCountDown +1 into sCountDown
   
   show grc "CurrentColor"
   put "Inhale" into fld "breathPhase"
   put sCountDown into fld "breathCount"
   wait sBreathPace milliseconds with messages
   set the blendlevel of grc "currentColor" to 0
   if sCountDown >1 then 
      put empty into fld "practiceInstructions"  
   end if
   
   if sCountDown=sBreathCount then  # stop repeat
      put empty into fld "breathCount"
      put "Hold" into fld "breathPhase"
      put " 1"  into fld "breathCount"
      wait sBreathPace milliseconds with messages
      put 0 into sCountDown 
      colorExhalation
   else
      colorInhalation   # repeat
   end if
   
   #  Inhalation Phase
   
end colorInhalation


command colorExhalation
   local sCurrentblendLevel
   
   put 100 / sBreathCount  into  sIncrementBlendLevel
   
   if sStopFlag=1 then 
      exit colorExhalation
   end if
   
   if sCountDown =1 then 
      if sLevel = 3   then # need to reduce opacity of grc currentColor over time
         put  ("Flood" && sColorName  &&  "with White into Light") into fld "practiceInstructions"    
      else
         put  "Flood Yourself" &cr & "with" &&  sColorName into fld "practiceInstructions" 
      end if
   else
      put empty into fld "practiceInstructions"
   end if
   
   put sCountDown +1 into sCountDown
   
   # set up the card
   
   put "Exhale" into fld "breathPhase"
   put sCountDown into fld "breathCount"
   
   # set up for level 3 / progressive change of tint
   if sLevel =3 then
      set the blendlevel of grc "currentColor" to (the blendlevel of grc "currentColor" + sIncrementBlendLevel)
   end if
   
   # user is exhaling
   wait sBreathPace milliseconds with messages
   
   --      if sCountDown >1 then 
   --         put empty into fld "practiceInstructions"  
   --      end if
   
   if sCountDown=sBreathCount then 
      
      put empty into fld practiceInstructions
      put "Hold"into fld "breathPhase"
      put "1" into fld "breathCount"
      
      wait sBreathPace milliseconds with messages
      put 1 into sCountDown 
      colorHueBreath
   else
      colorExhalation  
   end if
end colorExhalation

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
   if  isMobile() then
      mobileClearTouches
   end if

   put 1 into sStopFlag
   setUpLevel sLevel
   hide widget "pause"
   showTools
   put item sLevel of kLEVELS into pTrackdata["colorLevel"]
   tracking_RecordActivity "Color Meditation", "practice/interrupted", pTrackdata
end interruptColorShow

on closeCard
   # cleanup 
   put empty into fld "title"
  put empty into fld "ProgressMessage"  
   hide grc "currentColor"
end closeCard

on showCompletion
   
   setUpLevel sLevel
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
   put sivasiva_AssetFolder() & "audio/angelic-ambience_lo-res.mp3" into pSoundFile
   
   showTools
   
   playSound pSoundFile
   clearLocalVariable
   
   
   put item sLevel of kLEVELS into pTrackdata["colorLevel"]
   tracking_RecordActivity "Color Meditation", "practice/completed", pTrackdata
end showCompletion
   
command getUserPrefs
   # Fetch User Prefs
   put getUserPreferences() into tSettings
   put tSettings["breathCount"] into sBreathCount
   #prefs for pace is saved as seconds but we use milleseconds the show
   # to handle seconds decimal values
   # because timing is slow on mobile we set I second to 750 milliseconds 
   # updating screen with labels takes time
   put tSettings["breathPace"] * 1000 into sBreathPace
   put tSettings["cycles"] into sCycles
   put tSettings["audioOn"]  into sAudioOn    
end getUserPrefs

on clearLocalVariable
   put 0 into sStopFlag
   put 0 into sCurrentColor
   put 0 into sCountDown
end clearLocalVariable

------------------------


