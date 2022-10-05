script "behavior_WordPuzzles"
doAnswer "Could not find your city. Tap the location pin to choose one.","OK"

local sWordCount, sSourceURL, sTextSize, sPuzzleNo,sUserColorRange
local sCurLevel,sTileGlow,sCluesGiven,sRendering,sWordLocationsA,sClues,sQuote


/*
The important handles for the tiles are  located in the script
behavior_WordTile, which apply each tile, this were we post to the 
array that keeps the track tile locations.
*/

--script "behavior_WordPuzzles"
local thePixie,tFadeIncrement,sPixies,sPuzzleLevel,sCardRect

on preOpenStack
   if isMobile() then
      mobileSetAllowedOrientations "landscape left,landscape right" 
      mobileSetFullScreenRectForOrientations "landscape left,landscape right","0,0,736,414"
      set the fullscreenmode of this stack to "showAll" -- better for wider screens
   end if
   hide grc "blankScreen"
   setCardCoords "landscape"
end preOpenStack


--> Events
-
on preopencard
   # we have to  clear everything
   # while in development
   
   hide grp "indexOfQuotes"
   hide grp "randomPuzzleControls"
   hide grp "randomPuzzleInProgress"
   hide fld "MesmorizeFld"
   hide fld  "titleUnjumbleFld"
   
   loadNewBgImg
end preopencard

on openStack
   
   if sCurLevel is empty then
      put 1 into sCurLevel
   end if
   
   showTitle
   
end openStack

on mouseup
   
   local tTarget, tTargetOwner
   
   put the short name of the owner of the target into tTargetOwner
   put the short name of the target into tTarget
   
   # one set of actions occurs if the user hits grp ""bkgndcontrol"
   # Another set, is  trapped by the mouseUp to behavior_GlobalNav because navigition
   # and not abpout the UI perse
   
   switch tTarget
      
      case "Random Puzzle"
         hide grp "indexOfQuotes"
         hide fld "MesmorizeFld"
         show  group "randomPuzzleControls"
         --show  group "randomPuzzleInProgress"
         
         break
         
         
      case "Yamas"
         clearBoard
         hide widget "randomPuzzleSettings"
         hide btn "getInfo"
         createRandomPuzzle
         
         break
         
         
      case "Niyamas"
         clearBoard
         hide grp "indexOfQuotes"
         hide fld "MesmorizeFld"
         fetchMesmorizeMap
         
         break
         
         
      case "Random"
         clearBoard
         hide widget "randomPuzzleSettings"
         hide btn "getInfo"
         createRandomPuzzle
         
         break
         
      case "Clear"
         clearBoard
         show widget "randomPuzzleSettings" 
         show button "getInfo"
         break
         
      case "Clues"
         showClues
         
         break
         
      case "Index"
         clearBoard
         
         hide  group "randomPuzzleControls"
         hide group "randomPuzzleInProgress"
         
         show grp "indexOfQuotes"
         
         break
         
      case "randomPuzzleSettings"
         clearBoard
         show grp "prefsSelectorGrp"
         break
         
      case "getInfo"
         displayAbout (the short name of this card)
         break
         
      case "back-arrow"
         
         if (the vis of grp "randomPuzzleControls") then
            clearBoard
            hide grp "randomPuzzleControls"
            show grp "indexOfQuotes"
            exit mouseUp
         else
            local tParam
            portal_GoStack "Siva-Siva-Portal"
         end if
         break
         
   end switch
   
end mouseup

on mousedown
   
   local tTarget, tTargetOwner
   
   put the short name of the owner of the target into tTargetOwner
   put the short name of the target into tTarget
   
   switch tTarget
      
      case "Reveal"
         revealQuote
         break
         
   end switch
   
end mousedown

command loadNewBgImg -- change img for each new puzzle
   local pControl, tFolderPath, tFiles, tImgPath
   ntInfo (" loadNewBgImg: lockscreen: " & the lockscreen)
   put the long id of img "bgImage" into pControl
   put path_Assets() & "/img/bkgnds/nature/landscape/"   into tFolderPath
   put files(tFolderPath) into tFiles
   put any line of tFiles into tImgPath
   set the filename of img "bgImage" to tFolderPath&tImgPath
end loadNewBgImg

command showTitle
   local tFld
   
   wait 300 milliseconds --with messages
   show fld "titleUnjumbleFld" with visual effect "dissolve" very slow
   
   wait 1000 milliseconds
   hide fld "titleUnjumbleFld" with visual effect "dissolve" very slow
   
   wait 200 milliseconds --with messages
   show fld "MesmorizeFld" with visual effect "dissolve" very slow
   
   wait 500 milliseconds --with messages
   show grp "indexOfQuotes"  with visual effect "dissolve" very slow
   
end showTitle

command toggleFldVis pFldName,pVis, pEffect, pSecs
   lock screen for visual effect
   if pVis = true then
      show fld pFldName
   else
      hide fld pFldName
   end if
   send "unlock screen with visual effect pEffect" to this cd in pSecs seconds
end toggleFldVis

--> CREATE THE PUZZLE
local tWordLoc
local sSelectedQuotes

on createRandomPuzzle
   local tColors, tRGB, tTileBkgndRGB, tLoc, tNextWordRect, tNextWord, tTileName, tWordList
   --local sWordCount
   
   if (the acceleratedRendering of this stack is true ) then
      set the acceleratedRendering of this stack to false 
   end if
   
   ntinfo ("the lockscreen" && the lockscreen)
   
   lock screen
   
   --Reset
   
   put empty into sWordLocationsA
   stopTimer
   
   --hide widget "context"
   loadNewBgImg
   show graphic "startHere"
   if sCurLevel < 1 then difficultyPicker-- not yet initialized, should never happen
   --getPixieList # deprecated for now... 
   put empty into sQuote
   
   fetchRandomQuote # get a different one -- random for now dbase
   
   # for testing. comment the above an uncomment this quote:
   --put "The group helps the individual and the individual helps the group." into sQuote
   
   ## uncomment the option to get from local custom prop 
   ## if distributing without dbase  and comment out the jnanam fetch
   
   put empty into sWordCount
   put 0 into sCluesGiven
   --clearBoard
   startTimer
   
   getTheQuote
   
   --   -- Set the quote in a field
   --   put (the number of words of sQuote) into sWordCount
   --   put sQuote into fld "revealQuote"
   --   setSizeAndLocationOfQuote sQuote
   
   --   set the blendlevel of fld "revealQuote" to 0  
   --   show grp "revealQuoteGroup"
   --   show fld "revealQuote"
   
   --   -- Take a snapsite of the quote, move it off screen
   --   import snapshot from   grp "revealQuoteGroup"
   
   
   --   # need to save it because we are going to crop each word in a loop
   --   # put it away for safe keeping
   --   set the name of the last image to "currentPuzzle" 
   --   set the loc of image "currentPuzzle"  to -1000,-1000
   
   
   --   -- copy the image to the same location/rect as the quote
   
   --   put empty into tLoc  # set the extents of loc array to 0 each iterations
   
   --   repeat with x = 1 to the number of words of fld "revealQuote"  
   
   --      copy img "CurrentPuzzle" to this card
   --      set the name of the last image to "tempForCrop"
   --      set the rect of the last image to the rect of fld "revealQuote"
   
   --      --make individual word tiles
   --      put the formattedRect of word x of fld "revealQuote" into tNextWordRect  
   
   --      subtract 8 from item 1 of tNextWordRect
   --      add 2 to item 2 of tNextWordRect
   --      add 6 to item 3 of tNextWordRect
   --      add 4 to item 4 of tNextWordRect
   
   --      #####################################################################
   --      ### BM: `tNextWord` is undefined on the first time through this loop.
   --      put word x of fld "revealQuote" into tNextWord
   --      local tWordCantBeTileName
   --      ### BM: this block of code seems unnecessary
   --      if ( isNumber(tNextWord) ) OR ( tNextWord contains "---")  then
   --         put tNextWord into tWordCantBeTileName
   --         replace "---" with quote in tWordCantBeTileName
   --         put  ("_" & tNextWord) into tNextWord
   --         crop image "tempForCrop" to tNextWordRect
   --         set the  name of image "tempForCrop"  to tWordCantBeTileName
   --      else
   --         crop image "tempForCrop" to tNextWordRect
   --         set the  name of image "tempForCrop"  to tNextWord
   --      end if
   --      ### BM: line 132 below changes the image name again
   --      #####################################################################
   
   --      -- name the tiles and apply the name as custom prop of the tile
   --      put ("word_"&x) into tTileName
   --      put tTileName & cr after tWordList
   --      set the name of the last image to tTileName
   --      set the showborder of the last image to true
   --      set the behavior of the last image to the long id of btn "behavior_tileScript"
   
   --      set the cWord of last image to word x of fld "revealQuote"
   --      put word x of fld "revealQuote" into tNextWord
   
   --      --Store tiles of screen, ready to distribute
   
   --      set the loc of the last image to  -200,-200
   --      set the borderwidth of the last image to "4"
   --      set the topcolor of the last image to tRGB
   --      set the layermode of the last image to "dynamic"
   --      set the alwaysbuffer of the last image to true
   --      -- jg: required for smooth movment on slower devices
   
   --      getLocations tNextWord,tNextWordRect 
   
   --   end repeat
   
   --   assignHomeLocations 
   
   --   delete char -1 of tWordList
   --   set the uWordList of this card to tWordList
   
   --   arrangeWords # Jacque's Method
   
   --   # set start indicator to the beginning of the first word
   --   local pWord, tFirstWordPosition, tStartIconPosition
   --   put the cWord of image "word_1" into pWord
   --   put the  uWordLocation of image "word_1"  into tFirstWordPosition
   --   put sWordLocationsA[pWord][1] into tFirstWordPosition
   --   subtract  (the width of image "word_1" /2-10) from item 1 of tFirstWordPosition
   --   put tFirstWordPosition into tStartIconPosition
   --   add 4 to item 1 of tStartIconPosition
   --   set the loc of grc "startHere" to tStartIconPosition
   --   set the vis of grc "startHere" to true
   
   
   --   hide grp "revealQuoteGroup"
   --   hide fld "revealQuote" -- comment this out to see the quote during dev
   
   --   local pTile, pTrackdata
   --   put the long id of image "word_1" into pTile
   --   setTileGlow "large" 
   --   relayer  pTile to front of card "word-puzzle"
   --   glowtile pTile, true
   
   --   put "Level" && sCurLevel into pTrackdata["puzzleLevel"]
   --   tracking_RecordActivity "Word Puzzle", "generate/newpuzzle", pTrackdata
   --   unlock screen
   --   set the acceleratedRendering  of this stack to true
   --   show fld "wordPuzzleSubject"
   --   send "hideSubjectFld" to me in 10 seconds
   --   show grp "randomPuzzleInProgress"
   
end createRandomPuzzle

command fetchRandomQuote
   
   local tConnectionID, tSQL, tCurRange, tNo
   
   ## Methods for getting from dBase
   put  JnanamDB() into tConnectionID   
   
   --   ## for testing specific quote from the datebase
   --   put the uFetchOneQuote of this stack into tSQL
   --   ## You must supply the quote_id manually here
   --   replace ":1" with  "5428" in tSQL
   
   # production routine, comment out the above
   #  and use this for a runtime random selection
   put the uFetchSQL of this stack into tSQL
   put line sCurLevel of the uLevelRanges of this cd into tCurRange
   replace ":1" with  (trueword 1 of tCurRange) in tSQL
   replace ":2" with  (trueword 2 of tCurRange) in tSQL
   
   dbSetSQL tSQL
   
   put dbGet("quote", tConnectionID) into sSelectedQuotes
   put random (the number of lines of the keys of sSelectedQuotes) into tNo
   put textDecode ( sSelectedQuotes[tNo]["content"], "UTF8")  into sQuote
   put textDecode ( sSelectedQuotes[tNo]["subject"], "UTF8")  into fld "wordPuzzleSubject"
   
end fetchRandomQuote

local sMesmorizeGame

command fetchMesmorizeMap
   local tPath, tJSON
   put path_HomeLocal() into tPath
   
   put "modules/wordpuzzles/mesmorize-game-1.json" after tPath
   if there is not a file tPath then
      put "portalerr,mesmorize-game-1.json not found"
      exit fetchMesmorizeMap
   end if
   
   put url("file:" & tPath) into tJSON
   
   try
      put JSONToArray(tJSON) into sMesmorizeGame
      
   catch n
      put "Error reading navigation map."
      repeat for each line x in n
         put x
      end repeat
   end try
   
   put sMesmorizeGame["MesmorizeGame1"][Niyamas][1][content]   into  sQuote
   
   put  sMesmorizeGame["MesmorizeGame1"][Niyamas][1][subject]  into fld "wordPuzzleSubject"

   getTheQuote
   
end fetchMesmorizeMap

command getRandomColors
   put getColors() into tColors
   put line 1 of tColors into tRGB
   put line 2 of tColors into tTileBkgndRGB
   set the foregroundcolor of fld "revealQuote" to tRGB
   set the backgroundColor of grc "quoteBkgnd" to tTileBkgndRGB
end getRandomColors


command getLocations tNextWord,tNextWordRect
   -- set up an array of the location(x) of a word.
   local tCoords, tLoc, theX, theY
   put tNextWordRect into tCoords
   if   ( item 2 of the extents of sWordLocationsA[tNextWord] is empty ) OR \
         tNextWord is among the keys of sWordLocationsA then
      --(tNextWord is among the keys of sWordLocationsA[tNextWord]) then
      put (item 2 of the extents of sWordLocationsA[tNextWord]) + 1 into tLoc
      put trunc ( (item 3 of tCoords - item 1 of tCoords)/2)  + trunc ( ( item 1 of tCoords) ) into theX
      put trunc ( (item 4 of tCoords - item 2 of tCoords)/2)  + trunc (item 2 of tCoords) into theY
      put (theX,theY) into sWordLocationsA[tNextWord][tLoc]
      --put getLocation (tNextWordRect) into sWordLocationsA[tNextWord][tLoc]
   end if
end getLocations

Command getTheQuote
   local tColors, tRGB, tTileBkgndRGB, tLoc, tNextWordRect, tNextWord, tTileName, tWordList
   
   #hack to deal with endline bug
   replace "\n" with space in sQuote
   
   # fix  strings with straight quotes, which are word delimiters in LC
   # change to curly's when they are included with the word 
   replace (space & quote) with (space & "“") in sQuote 
   replace (quote& space) with ( "”"& space) in sQuote 
   
   -- Set the quote in a field
   put (the number of words of sQuote) into sWordCount
   put sQuote into fld "revealQuote"
   setSizeAndLocationOfQuote sQuote
   
   set the blendlevel of fld "revealQuote" to 0  
   show grp "revealQuoteGroup"
   show fld "revealQuote"
   
   -- Take a snapsite of the quote, move it off screen
   import snapshot from   grp "revealQuoteGroup"
   
   
   # need to save it because we are going to crop each word in a loop
   # put it away for safe keeping
   set the name of the last image to "currentPuzzle" 
   set the loc of image "currentPuzzle"  to -1000,-1000
   
   
   -- copy the image to the same location/rect as the quote
   
   put empty into tLoc  # set the extents of loc array to 0 each iterations
   
   repeat with x = 1 to the number of words of fld "revealQuote"  
      
      copy img "CurrentPuzzle" to this card
      set the name of the last image to "tempForCrop"
      set the rect of the last image to the rect of fld "revealQuote"
      
      --make individual word tiles
      put the formattedRect of word x of fld "revealQuote" into tNextWordRect  
      
      subtract 8 from item 1 of tNextWordRect
      add 2 to item 2 of tNextWordRect
      add 6 to item 3 of tNextWordRect
      add 4 to item 4 of tNextWordRect
      
      #####################################################################
      ### BM: `tNextWord` is undefined on the first time through this loop.
      put word x of fld "revealQuote" into tNextWord
      local tWordCantBeTileName
      ### BM: this block of code seems unnecessary
      if ( isNumber(tNextWord) ) OR ( tNextWord contains "---")  then
         put tNextWord into tWordCantBeTileName
         replace "---" with quote in tWordCantBeTileName
         put  ("_" & tNextWord) into tNextWord
         crop image "tempForCrop" to tNextWordRect
         set the  name of image "tempForCrop"  to tWordCantBeTileName
      else
         crop image "tempForCrop" to tNextWordRect
         set the  name of image "tempForCrop"  to tNextWord
      end if
      ### BM: line 132 below changes the image name again
      #####################################################################
      
      -- name the tiles and apply the name as custom prop of the tile
      put ("word_"&x) into tTileName
      put tTileName & cr after tWordList
      set the name of the last image to tTileName
      set the showborder of the last image to true
      set the behavior of the last image to the long id of btn "behavior_tileScript"
      
      set the cWord of last image to word x of fld "revealQuote"
      put word x of fld "revealQuote" into tNextWord
      
      --Store tiles of screen, ready to distribute
      
      set the loc of the last image to  -200,-200
      set the borderwidth of the last image to "4"
      set the topcolor of the last image to tRGB
      set the layermode of the last image to "dynamic"
      set the alwaysbuffer of the last image to true
      -- jg: required for smooth movment on slower devices
      
      getLocations tNextWord,tNextWordRect 
      
   end repeat
   
   assignHomeLocations 
   
   delete char -1 of tWordList
   set the uWordList of this card to tWordList
   
   arrangeWords # Jacque's Method
   
   # set start indicator to the beginning of the first word
   local pWord, tFirstWordPosition, tStartIconPosition
   put the cWord of image "word_1" into pWord
   put the  uWordLocation of image "word_1"  into tFirstWordPosition
   put sWordLocationsA[pWord][1] into tFirstWordPosition
   subtract  (the width of image "word_1" /2-10) from item 1 of tFirstWordPosition
   put tFirstWordPosition into tStartIconPosition
   add 4 to item 1 of tStartIconPosition
   set the loc of grc "startHere" to tStartIconPosition
   set the vis of grc "startHere" to true
   
   
   hide grp "revealQuoteGroup"
   hide fld "revealQuote" -- comment this out to see the quote during dev
   
   local pTile, pTrackdata
   put the long id of image "word_1" into pTile
   setTileGlow "large" 
   relayer  pTile to front of card "word-puzzle"
   glowtile pTile, true
   
   put "Level" && sCurLevel into pTrackdata["puzzleLevel"]
   tracking_RecordActivity "Word Puzzle", "generate/newpuzzle", pTrackdata
   unlock screen
   set the acceleratedRendering  of this stack to true
   show fld "wordPuzzleSubject"
   send "hideSubjectFld" to me in 10 seconds
   show grp "randomPuzzleInProgress"
   
end getTheQuote

command assignHomeLocations
   repeat with x = 1 to ( the number of images on this card)
      if the short name of image x contains "word" then
         set the uWordLocations of image x to sWordLocationsA[the cWord of image x]
      end if
   end repeat
end assignHomeLocations
   

on checkLevel
   put sCurlevel
end checkLevel




command setSizeAndLocationOfQuote sQuote
   local tCharCount, tRequiredHeight
   # we want to call quotes of different lengths
   # practically speaking 330 chars set to 30 px is the lower limit
   # for small tiles, and even this may be too small for small devices to pick with your finger
   # we can adjust upwards after testing and feedback.
   
   # general algorithm is that we need to fetch the quote, 
   # determine it's optimum font size
   # then set the field and background accordingly centered on the card
   # so we need to return a rect and set the field and background and the start icon.
   
   put len(sQuote) into tCharCount
   
   # Max 330
   # > 270  set to 30
   #> 205  set to 32
   #> 140  set to 37
   #> 100  set to 45
   # 0 - 100 set to 50
   switch 
      # must stay in order to work!
      case tCharCount < 101
         set the textSize of fld "revealQuote" to 50
         break
      case tCharCount < 141
         set the textSize of fld "revealQuote" to 45
         break
      case tCharCount < 206
         set the textSize of fld "revealQuote" to 40
         break
      case tCharCount < 271
         set the textSize of fld "revealQuote" to 35
         break
   end switch
   
   set the textstyle of fld "revealQuote" to "bold"
   
   put the formattedHeight of fld "revealQuote" into tRequiredHeight
   set the height of fld "revealQuote" to tRequiredHeight
   set the top of fld "revealQuote" to 40
   set the rect of grc "quoteBkgnd" to the rect of fld "revealQuote"
   
end setSizeAndLocationOfQuote




function getColors -- return a random RGB set
   -- color sets stored in custom prop uColorSets in format: rgb1|rgb2
   -- first item is text color, second is bg color
   ## Still very ugly, sets were created by algorithm. Needs tweaking. ##
   local tRGBSet
   put any line of the uColorSets of me into tRGBSet
   replace "|" with cr in tRGBSet
   return tRGBSet
end getColors

function getLocation tCoords
   local theX, theY
   put trunc ( (item 3 of tCoords - item 1 of tCoords)/2)  + trunc ( ( item 1 of tCoords) ) into theX
   put trunc ( (item 4 of tCoords - item 2 of tCoords)/2)  + trunc (item 2 of tCoords) into theY
   return (theX,theY)
end getLocation

--on distributeWords
--   put the uWordList of this card into tWords
--   repeat for each line x in tWords
--      # set up random locations that fall inside card window bounds
--      # left position at least 100 pixels from the edge for long words 
--      put (the width of fld _Quote) - 50 into  tMaxRight
--      put   random (tMaxRight - 170 ) + 220   into tX
--      put 350 into  tMaxBottom
--      --put (the height of fld _Quote) - 100 into  tMaxBottom
--      put   random (tMaxBottom - 100+ 1) + 100-1  into tY
--      set the loc of img x to tX,tY
--      set the uInPlace  of img x to "false"
--   end repeat
--end distributeWords

on clearBoard
   # use case: User want to leave the current puzzle and and new one
   lock screen
   deleteMobileControl "aboutText"
   hide group "aboutDisplay"
   hide group "prefsSelectorGrp"
   stopTimer
   
   put empty into fld "Minutes" of me
   put empty into fld "seconds" of me
   --hide widget "context"
   --set the vis of grc "startHere" to false
   put empty into fld "revealQuote" of me
   hide  fld "revealQuote" of me
   hide fld "wordPuzzleSubject"
   hide group "revealQuoteGroup"
   if the uwordlist of me = "" then exit clearBoard -- assume imgs are gone
   repeat with x = the number of imgs of me down to 1
      if the short name of img x of me begins with "word_"
      then delete img x of me
   end repeat
   repeat 10 times
      try
         delete image "currentPuzzle" of me
         delete image "tempForCrop" of me
      end try
   end repeat
   set the uWordList of me to empty
   hide grp "randomPuzzleInProgress"
   hide graphic "startHere" of me
   unlock screen
end clearBoard 

on checkCompletion
   local tWords, tStatus
   put the uWordList of this card into tWords 
   repeat for each line x in tWords 
      put the uInPlace of img x & cr after tStatus
   end repeat 
   if  tStatus contains "false" then
      #do nothing
   else
      triggerCompletion
   end if
end checkCompletion 

function randomInRange lowerLimit, upperLimit
   return random(upperLimit - lowerLimit + 1) + lowerLimit - 1
end randomInRange

on unJumble
   local tWords
   put the uWordList of this card into tWords
   repeat for each line x in tWords
      set the loc of Img x to (the uWordLocation of img x)
   end repeat
end unJumble

######## Timer Functions ########

local sSeconds, sMinutes,sTimerOnFlag


on startTimer
   put empty into fld "Minutes"
   put empty into fld "Seconds" 
   put 0 into sSeconds
   put 0 into sMinutes
   put "true" into sTimerOnFlag
   trackTimePassed
end startTimer

on stopTimer
  put "false" into sTimerOnFlag
  repeat for each line l in the pendingMessages -- clear the queue
    if l contains "trackTimePassed" then cancel item 1 of l
  end repeat
end stopTimer

on trackTimePassed
   if  sTimerOnFlag = "true" then
      if sSeconds >= 0 and sSeconds <60 then
         put sSeconds & " Secs" into field "seconds"  
         put sSeconds + 1 into sSeconds
         send "trackTimePassed"  to me in 1 second 
      end if
      if sSeconds = 60 then
         add 1 to sMinutes
         put sMinutes & " Mins" into fld "Minutes" 
         put 0 into sSeconds
      end if
   end if
end trackTimePassed

on setTilesBlendLevel pLevel
   local tWords
   put the uWordList of this card into tWords
   repeat for each  line x in tWords
      set the blendlevel of img x to pLevel
   end repeat
 end setTilesBlendLevel
 
 --#### SETTINGS PICKER ###--
 
 on setLevel pLevel  # coming from journal or outside
    put pLevel into sCurLevel
 end setLevel
 
command difficultyPicker pAction, pValue
   local tPrompt, pLoc
   switch pAction
      case "pickLevel"  # group is hidden... user want to select now.
         put the uLevels of me into fld "prefsSelector"  # hard wire to 1 for now
         show grp "prefsSelectorGrp"
         break
      case "setLevel" # user is making a selection, this is fired from the selector field
         put pValue into sCurLevel
         storeCurrentLevel sCurLevel
         switch sCurLevel
            case "1"
               put "Easy!"into tPrompt
               break
            case "2"
               put "Not so easy."into tPrompt
               break      
            case "3"
               put "More Difficult"into tPrompt
               break    
            case "4"
               put "Very Hard!" into tPrompt
               break                
         end switch
         hide grp "prefsSelectorGrp"
         put the loc of this cd into pLoc
         dialog_CustomMsg tPrompt
         
   end switch
   
end difficultyPicker

on arrangeWords
   -- alternate distribution method; not sure it's much better but there will be no hidden overlaps
   local tWords, tW, tH, tPt, tHalfW, tHalfH
   put the uWordList of this card into tWords
   sort lines of tWords by random(100) -- reorder
   put the width of this cd into tW
   put the height of this cd into tH
   repeat for each  line x in tWords
      put the loc of this cd into tPt
      repeat until anyIntersect(tPt,x) = false
         put the width of img x div 2 into tHalfW
         put randomInRange(tHalfW,tW-tHalfW) into item 1 of tPt
         put the height of img x div 2 into tHalfH
         put randomInRange(tHalfH,tH-tHalfH) into item 2 of tPt
      end repeat
      set the loc of img x to tPt
      set the uInPlace  of img x to "false"
   end repeat
end arrangeWords

function anyIntersect pPt,pObjName
   repeat for each line l in the uWordList of this cd
      if l = pObjName then next repeat
      if pPt is within the rect of img l then return true
   end repeat
   return false
end anyIntersect

on deleteOccupiedLocation sOneHome,pWord
   local tWords, sMyHomes
   put  the uWordList of this card into tWords 
   repeat for each line x in tWords
      if the cWord  of image x = pWord then
         put the uWordLocations of image x into sMyHomes
         delete variable sMyHomes[sOneHome]
         set the uWordLocations of image x to sMyHomes
      end if
   end repeat
end deleteOccupiedLocation

command triggercompletion
   local tNumWords, tTime, tPrompt
   if sTimerOnFlag <> true then exit triggercompletion -- already finished
   stopTimer
   -- if the uSourceURL of widget "context" <> empty then show widget "context"
   put the number of lines in the uWordList of this card into tNumWords
   get fld "Minutes"
   if (word 1 of it) > 0 then
      put it into tTime
      if it < 2 then delete last char of tTime -- make it singular
      put space after tTime
   end if
   put fld "seconds"  after tTime
   put "Done!" && tNumWords && "words in" && tTime & ". Use settings to get longer quotes." into tPrompt
   dialog_CustomMsg tPrompt 
   # later we ahve to save a puzzle solved to tracker for this module
   # pop up the link to read in the book.
   # more quotes and timer etc. for additional fun
   show fld "wordPuzzleSubject"
end triggercompletion

command glowTile pTile, pState
   switch pState
      case "true" 
         set the outerglow of  pTile to sTileGlow
         break
      case "false"
         set the outerglow of  pTile to empty
   end switch
end glowTile

command hideSubjectFld
   hide fld "wordPuzzleSubject"
end hideSubjectFld

command revealQuote
   set the layer of grc "blankScreen" to top
   show grc "blankScreen"
   set the layer of grp "revealQuoteGroup"  to top
   show fld "revealQuote"
   show grp "revealQuoteGroup" 
   wait 2 seconds
   hide grp "revealQuoteGroup" 
   hide fld "revealQuote"
   hide grc "blankScreen"
   --losePoints # later when we give badges
end revealQuote

on showClues
   local pMsg
 -- if sTimerOnFlag <> true then exit showClues
   
   put the uWordList of me into sClues
   if sClues is empty then
      dialog_CustomMsg "Start a puzzle first."
      exit to top
   end if
   
   sort lines of sClues by random(the number of lines of sClues)
   
   
   if sCluesGiven is empty then
      put 0 into sCluesGiven
   end if
   
   switch sCluesGiven
      case 0 
         send "clueGoHome" to image (line 1 of sClues)
         add 1 to sCluesGiven
         break
      case 1
         send "clueGoHome" to image (line 2 of sClues)
         add 1 to sCluesGiven
         break
      case 2
         send "clueGoHome" to image (line 3 of sClues)
         add 1 to sCluesGiven
         break
      case 3 
         put "No more clues. You are on your own!" into pMsg
         dialog_customMsg pMsg
         put 0 into sCluesGiven
         break       
   end switch
   
   --   put the number of lines of tTiles into tWordCount
   --   if sCluesGiven is empty then
   --      put 0 into sCluesGiven
   --   end if
   
   --   switch sCluesGiven
   --      case 0 
   --         if tWordCount <16 then
   --            send "clueGoHome" to image (line tWordCount of tTiles)
   --         else
   --            send "clueGoHome" to image (line 15 of tTiles)
   --         end if  
   --         add 1 to sCluesGiven
   --         break
   --      case 1
   --           send "clueGoHome" to image (line tWordCount of tTiles)
   --         add 1 to sCluesGiven
   --         break
   --         case 2
   --          send "clueGoHome" to image (line tWordCount of tTiles)
   --         add 1 to sCluesGiven
   --         break
   --      case 3 
   --         put "No more clues. You are on your own!" into pMsg
   --         dialog_customMsg pMsg
   --         put 0 into sCluesGiven
   --         break       
   --   end switch
   
end showClues


-- SMALL UTILITIES
 

on displayAbout pLevel
   local tPath, tAboutText, tAnswer
   answer "About Word Puzzle or Shortcuts?"  with "About" or "Shortcuts"
   put it into tAnswer
   
   if tAnswer is "Shortcuts" then
      journal_AddEntry
   else
      
      put the acceleratedRendering of this stack into sRendering
      set the acceleratedRendering of this stack to true
      put sivasiva_GetModuleFolder ("wordpuzzles") into tPath
      put url ("file:" & tPath & "/wordPuzzles-about.txt") into tAboutText
      send "createScroller aboutText" to fld "aboutText" in 500 milliseconds -- behavior attached to field
      set the htmltext of fld "aboutText" to tAboutText
      set the layer of grp "aboutDisplay" to top
      show grp "aboutDisplay"
   end if
   
end displayAbout

on closeAbout
   --set the acceleratedRendering of this stack to sRendering
   deleteMobileControl "aboutText"
   hide group "aboutDisplay"
end closeAbout


## This makes a list of color sets for the custom cd prop

on makeColorSets pList -- usually I pass the clipboarddata
   local tBgRGB, tColorList
   repeat for each line l in pList
      put "" into tBgRGB
      repeat for each item i in l
         put i+100 & comma after tBgRGB
      end repeat
      delete last char of tBgRGB
      put l & "|" & tBgRGB & cr after tColorList
   end repeat
   --breakpoint
   set the uColorSets of me to tColorList
end makeColorSets
 
on test -- use this to test correct dimensions
   -- params: pShow,pMsg,pLoc,pWidth,pHeight:
   local tNumWords, tTime, tPrompt
   put "You did it!" && tNumWords && "words in" && tTime & ". Use settings to get longer quotes." into tPrompt
   dialog_CustomMsg tPrompt
end test


command setTileGlow pSize
   put "255,255,255" into sTileGlow["color"]
   put "normal" into sTileGlow["blendMode"]
   put "255" into sTileGlow["opacity"]
   put "box1pass" into sTileGlow["filter"]
   
   switch pSize
      case "small"    
         put "20" into sTileGlow["size"] 
         put "40" into sTileGlow["spread"]  
         break
      case "large"
         put "80" into sTileGlow["size"] 
         put " 100" into sTileGlow["spread"]  
         break
   end switch
end setTileGlow

command checkTileGlow
   setTileGlow "small"
   put sTileGlow["size"]
   set the outerGlow of image "word_5" to sTileGlow
end checkTileGlow


command resetUI
   --breakpoint
   showTitle True
   clearBoard
end resetUI

function getUserPreferences
   local aWordPuzzleLevel
   put getPref ("preferences/modules/word-puzzle") into aWordPuzzleLevel
   put aWordPuzzleLevel["level"] into sPuzzleLevel
   return sPuzzleLevel
end getUserPreferences

command saveUserPrefs sPuzzleLevel
   setPref "preferences/modules/word-puzzle/level", sPuzzleLevel
   get getUserPreferences()
end saveUserPrefs

command storeCurrentLevel pLevel
   put pLevel into sPuzzleLevel
end storeCurrentLevel

command addJournalEntry 
   local pData, tTitle
   put "word-puzzle" into pData["card"]
   put "Word Puzzles" into tTitle
   Journal_RecordEntry "wordpuzzles",tTitle,pData -- send to journal
   dialog_CustomMsg "Saved to Journal"
end addJournalEntry

on journalResume pDataA, pEntryA
   local pLevel
   go to card  pDataA["card"] 
   put pDataA["lastLevel"] into pLevel
end journalResume

on closeCard
   hide graphic "startHere"
   storeCurrentLevel sCurLevel
   --showTitle true
   ntInfo "closing word puzzle card"
end closeCard

on closeStack
   local pTrackdata -- BWM looks like something is missing
   tracking_RecordActivity "Word Puzzles", "navigation/exit", pTrackdata
   if isMobile() then
      mobileSetFullScreenRectForOrientations "landscape left,landscape right"
   end if
   portal_SetLastStack "wordpuzzles"
end closeStack
