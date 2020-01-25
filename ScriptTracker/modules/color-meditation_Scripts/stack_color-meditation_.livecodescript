Script "stack_color-meditation_"

/*
# Name: stack "color-meditation"
# ID: stack "color-meditation"
*/


local sColorA,sAboutText,sLastLevel,sLastLevelCycle,sMylocation,sLastActivityA
local sCurrentFillGradientColor,sCurrentLevel,sColorCount,aColorMedPrefs
local  sBreathCount, sBreathPace, sCycles,sAudioOn

# BR vars are a bit of a mess... I would do it differnently today
# sCurrentLevel is also used for interim navigation cards, which is "wrong"
# So we are using sLastLevel for the actual color meditation level

on preopenstack
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
   initializeColorMeditation
end preopenstack

on opencard
   set the acceleratedRendering of this stack to true
   audioIsRunning  
   pass opencard
end opencard

on setLastactivity  sCurrentColorLevel 
   put sCurrentColorLevel into sLastLevel 
   -- always resumes at a color start on runColors card
end setLastactivity

command initializeColorMeditation
   showTools
   ####### INITIALIZE COMMON VARS
   #############################
   
   put sivasiva_GetModuleConfigArray("color-meditation") into sColorA
   put ("255,0,255") into sCurrentFillGradientColor
   setBackGroundGradient sCurrentFillGradientColor
   setCurrentLevel ("colorOpening")  
   put sivasiva_GetModuleFolder ("color-meditation") into sMylocation
   get getUserPreferences()
end initializeColorMeditation

####### NAVIGATION UI CHANGE UPS
##############################

on hideTools
   hide group "contentCardHeader"
   hide group "colorMedsToolbar"
   hide group "aboutDisplay"
end hidetools


on showTools
   show group "contentCardHeader"
   show group "colorMedsToolbar"
end showTools


on closeStack
   addJournalEntry
   portal_SetLastStack "color-meditation"
end closeStack

####### RESPONSIVE DESIGN
##############################

on preOpenCard
   updateUI
end preOpenCard

on resizeStack
   setCardCoords
   updateUI
end resizeStack

on updateUI
   local tHeader, tFooter, tControl, tRect, tCardRect
   
   put CardRect() into tCardRect
   
   -- check to see if the card has already been updated
   if the uCardRect of this card is tCardRect then exit updateUI
   
   put the long id of grp "contentCardHeader" into tHeader
   set the width of tHeader to CardWidth()
   topCenterMe tHeader
   
   put the long id of grp "colorMedsToolbar" into tFooter
   bottomCenterMe tFooter, 24
   
   put the long id of grp "aboutDisplay" into tControl
   centerMe tControl, 0, 62
   
   if the short name of this card is "runColors" then
      put the long id of grc "currentColor" into tControl
      set the rect of tControl to tCardRect
      
      put the long id of grp "breathControl" into tControl
      bottomCenterMe tControl, 100
      
      put the long id of fld "progressMessage" into tControl
      centerMe tControl, 0, 100
      
      put the long id of widget "pause" into tControl
      bottomCenterMe tControl, 34
   else
      put the long id of grc "colorMeditationBkgnd" into tControl
      set the rect of tControl to tCardRect
      
      put the long id of grp "titleControls" into tControl
      topCenterMe tControl, 214
   end if
   
   if the short name of this card is "levelsIndex" then
      put the long id of grp "levelsLinks" into tControl
      centerMe tControl, the height of tHeader, 116
   end if
   
   if the short name of this card is "colorPreferences" then
      put the long id of grp "prefsSelectorGrp" into tControl
      set the height of tControl to \
            the top of tFooter - bottom of tHeader
      centerMe tControl, the height of tHeader, 116
      put the long id of grp "cardBody" into tControl
      centerMe tControl, 100, 116
   end if
   
   set the uCardRect of this card to tCardRect
end updateUI

####### SOUND CONTROL
#############################

command playSound pSoundFile
   if the environment is "mobile" then
      play pSoundFile
      wait until the sound is "done"
      mobileClearTouches
   else
      set the filename of player "HiddenPlayer" to pSoundFile
      start player "HiddenPlayer"
   end if
end playSound

command stopSound
   if the environment is "mobile" then
      play stop
   else
      
      ## KM 05/17/2017
      ## pSoundFile is neither local nor global and thus not defined
      ## set the filename of player "HiddenPlayer" to pSoundFile
      stop player "hiddenPlayer"
   end if
end stopSound

######### TEXT HANDLING
##############################

on displayAbout 
   if not (the vis of grp "aboutDisplay") then
      # we need to show it and create a scroller if necessary
      
      # fetch about text array 
      
      put url ("file:" & sMyLocation & "/color-meditation-about.txt") into sAboutText  
      
      # Proprietary micro data format elements separated by pipe |
      # key value pairs separated by back slash (never use in the text)   
      
      split sAboutText with "|" and "\"
      
      switch sCurrentLevel
         case "colorOpening"
            hide fld "moduleTitle"
            break
         case "levelsIndex"
            hide grp "LevelsLInks"
            break
      end switch
      set the htmltext of fld "aboutText" to sAboutText[sCurrentLevel]
      if the formattedheight of fld "aboutText" > the height of fld "aboutText" then
         send "CreateScroller aboutText" to fld "aboutText"
      end if
      show grp "aboutDisplay"
      
      set the foregroundcolor of button "getInfo" to "violetRed3"
   else
      set the foregroundcolor of button "getInfo" to "white"
      deleteMobileControl "aboutText"
      # hide it and destroy scroller
      hide grp "aboutDisplay"
      switch sCurrentLevel
         case "colorOpening"
            show fld "moduleTitle"
            break
         case "levelsIndex"
            show grp "LevelsLInks"
            break
      end switch
   end if
end displayAbout


######### START UP ROUTINES
##############################

# later we have to check settings and determine what
# level the user has achieved and  what settings he has


###### GUI RESETS
##############################


--> Preferences Methods
-

function getUserPreferences    
   put  getPref ("preferences/modules/color-meditation") into aColorMedPrefs
   if aColorMedPrefs is empty then  # first run  we set defaults
      put 4 into sBreathCount
      put 1 into sBreathPace
      put 1 into sCycles
   else
      put aColorMedPrefs["breathCount"] into sBreathCount
      put aColorMedPrefs["breathPace"] into sBreathPace
      put aColorMedPrefs["cycles"] into sCycles
      put aColorMedPrefs["audioOn"]  into sAudioOn  
      return aColorMedPrefs
   end if
end getUserPreferences

command saveUserPrefs
   # Only called from the colorPreference card
   # so assume fields are available:
   # Would be nice to  beable to pass an array to a higher level json object
   setPref "preferences/modules/color-meditation/breathCount", fld "currentCount"
   setPref "preferences/modules/color-meditation/breathPace", fld "currentPace"
   setPref "preferences/modules/color-meditation/cycles",  fld "currentCycles"
   setPref "preferences/modules/color-meditation/audioOn", fld "currentAudio"
   # instantiate new values on the fly
   get getUserPreferences()
end saveUserPrefs


function calculateTimeToCompletion
   local tCompletionTime, tKumbhakaTime
   if sColorCount is empty then put 3 into sColorCount # user got to preferences directly
   put (sBreathCount * (sBreathPace *1000) * sCycles * sColorCount * 2 ) into tCompletionTime
   # add kumbhaka (hold 1)
   put (sColorCount * 2 * sCycles * 1000) into tKumbhakaTime
   if sCurrentLevel is not a number then put 1 into sCurrentLevel
   return (4000+tCompletionTime + tKumbhakaTime)/1000,sCurrentLevel  #4000 (4sec) added for lead and instructions
   
end calculateTimeToCompletion


#### Levels Switching
## see card script of "runColors" card
##############


command setCurrentLevel pLevel
   put pLevel into sCurrentLevel
   switch sCurrentLevel
      case 1
         put 3 into sColorCount
         break
      case 2
         put 6 into sColorCount
         break
   end switch
   
end setCurrentLevel

function getCurrentLevel
   return sCurrentLevel
end getCurrentLevel



######## COLOR MODELS
#########################

command setBackGroundGradient pColor2
   # current will set the gradient of the bkgnd grc if it exists
   # simple radial with white center and color 2 in the ramp we set dynamically
   if pColor2 <> empty then
      put  pColor2 into sCurrentFillGradientColor
   end if
   # uses existing choice or updates (above)
   try
      send "setfillGradient ,,,sCurrentFillGradientColor,,," to grc "colorMeditationBkgnd"
   end try
end setBackGroundGradient

on colorizeControlChars pControl
   local y
   # only works for fields
   set the itemdel to tab
   repeat with x = 1 to  (the number of chars of control pControl)
      put x into y
      if x >12 then subtract 12 from y
      set the textcolor of char x of control pControl to \
            sColorA["color-meditation"]["colorwheel"][y]["color"]
   end repeat
end colorizeControlChars

function getColorWheel
   local tWheelIndex, aColorList
   put the keys of  sColorA["color-meditation"]["colorwheel"] into tWheelIndex
   sort tWheelIndex numeric ascending
   repeat for each line x in tWheelIndex
      put  sColorA["color-meditation"]["colorwheel"][x]["name"]  &tab&\
            sColorA["color-meditation"]["colorwheel"][x]["color"] & cr after aColorList
   end repeat
   return aColorList
end getColorWheel



command checkPrefsLoaded
   put the keys of aColorMedPrefs
end checkPrefsLoaded

command checkALocal pVar
   put pVar
end checkALocal

##------------------------------------------------------
command _VisualEffects
end _VisualEffects

command visProgressMessage pBool
   set the vis of fld "progressMessage" to  pBool
end visProgressMessage

command blinkStart pBool
   if pBool = "true" then
      repeat 3 times
         set the backgroundcolor of  grc "start" to "158,58,77"
         wait 300 milliseconds with messages
         set the backgroundcolor of  grc "start" to "220,220,220"
         wait 300 milliseconds with messages
      end repeat 
   else 
      set the backgroundcolor of  grc "start" to "220,220,220"
   end if
   
end blinkStart


command resetUI
   # Nothing to do here
end resetUI


# more than needed but we may expand activities in this module later
# so keeping Jacque's nice construct for now.

command addJournalEntry -- save a bookmark to db
   local pData, tTitle
   put "runColors" into pData["card"] 
   put sLastLevel into pData["colorLevel"]
   put ("Color Meditation - Level " & sLastLevel) into tTitle
   Journal_RecordEntry "color-meditation",tTitle,pData -- send to journal
end addJournalEntry


on journalResume pData,pEntryA -- sent from journal stack
   if isMobile() then close stack "journal"
   # do nothing special
   # just open the stack and let it run as if freshly started module
   # getting back to the color level is too tricky, maybe V2
   # but you still have issue some kind of "go" for the stack to open
   go to card 1
end journalResume
