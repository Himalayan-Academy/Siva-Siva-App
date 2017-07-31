script "behavior_WordPuzzles"
local sWordCount, sQuote,sSourceURL, sTextSize, sPuzzleNo,sUserColorRange
local sCurLevel,sTileGlow,sCluesGiven



 --> Events
 -
 on preOpenCard
   --clearBoard  # Always save the stack with no puzzle show
   # we don't want to issue clearBoard when the stack opens
   # only if the users calls of this.
   # so, in dev, clear the board first, then save the stack
   # use resetUI then save and close the stack
    loadNewBgImg
    setTileGlow "small"
     put 0 into sCluesGiven
   # we should be storing the user's pref for length, but for V1
   # we will just default to the lowest level every time the puzzles are opened:
   
  end preOpenCard
  

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
  
on closecard
  storeCurrentLevel sCurLevel
   set the acceleratedRendering of this stack to false
end closecard
  
on openCard
   --    put getPref("word puzzle","level") into sCurLevel  --### USE ANDRE'S LIB HERE
   send "showTitle false" to me in 800 milliseconds
   if sCurLevel is empty then
      put 1 into sCurLevel
   end if
end openCard

 --> Working on
 -
command loadNewBgImg -- change img for each new puzzle
   -- called by createWordPuzzle

   put path_Assets() & "/img/bkgnds/nature/landscape/"   into tFolderPath
   put files(tFolderPath) into tFiles
   put any line of tFiles into tImgPath
   set the filename of img "bgImage" to tFolderPath&tImgPath
   put the width of this cd/the width of img "bgImage" into tRatio
   set the width of img "bgImage" to the width of img "bgImage" * tRatio
   set the height of img "bgImage" to the height of img "bgImage" * tRatio
   set the loc of img "bgImage" to the loc of this cd
end loadNewBgImg

on checkLevel
   put sCurlevel
end checkLevel

on closeCard
    deleteMobileControl "aboutText"
    dialog_CustomMsg false
end closeCard

on displayAbout pLevel
   put sivasiva_GetModuleFolder ("wordpuzzles") into tPath
   put url ("file:" & tPath & "/wordPuzzles-about.txt") into tAboutText
   send "createScroller aboutText" to fld "aboutText" in 500 milliseconds -- behavior attached to field
  set the htmltext of fld "aboutText" to tAboutText
  set the layer of grp "aboutDisplay" to top
  show grp "aboutDisplay"
end displayAbout

on closeAbout
    deleteMobileControl "aboutText"
    hide group "aboutDisplay"
end closeAbout


command showTitle pBool
  if pBool then -- show title
    hide grp "puzzleControls" with visual effect dissolve very fast
    show fld "titleFld"
  else -- hide title
    hide fld "titleFld" with visual effect dissolve
    show grp "puzzleControls" with visual effect dissolve very fast
  end if
end showTitle

command fetchQuote
   ## Methods for getting from dBase
   put  JnanamDB() into tConnectionID   
   put the uFetchSQL of this stack into tSQL
   put line sCurLevel of the uLevelRanges of this cd into tCurRange
   replace ":1" with  (trueword 1 of tCurRange) in tSQL
   replace ":2" with  (trueword 2 of tCurRange) in tSQL
   dbSetSQL tSQL
   put dbGet("quote", tConnectionID) into aSelectedQuotes
   put random (the number of lines of the keys of aSelectedQuotes) into tNo
   put textDecode ( aSelectedQuotes[tNo]["content"], UTF8)  into sQuote
   put textDecode ( aSelectedQuotes[tNo]["subject"], UTF8)  into fld "wordPuzzleSubject"
   put textDecode ( aSelectedQuotes[tNo]["source_url"], UTF8)  into sSourceURL
   if sSourceURL <> empty then
      set  the uSourceURL of widget "Context" to sSourceURL
   else
      set  the uSourceURL of widget "Context" to empty # wipe an old link
   end if
   
   show fld "wordPuzzleSubject"
   #hack to deal with endline bug
   replace "\n" with space in sQuote
   
   if connectivity_GetStatus ="true"  then
      ## Source URL may or may not there
      put   textDecode ( aSelectedQuotes[tNo]["source_url"], UTF8)  into sSourceURL
      replace "http:" with "https:" in sSourceURL
      set the uSourceURL of widget "context" to sSourceURL
      ## could be somethign else, if connectivity is bad... will check that on completion
   end if
   
   # fix  strings with straight quotes, which are word delimiters in LC
   # change to curly's when they are included with the word 
   replace (space & quote) with (space & "“") in sQuote 
   replace (quote& space) with ( "”"& space) in sQuote 
   
   ## Later we can pull from a file on disk  that gets updated #
   ## or pull from the database
   ## we will need to constrain to len(sQuote)<2=330 chars 
   
   ## Method for getting small set from custom Property
   
   -- --    put the uQuotes of this card into tQuotes
   --    --   set the itemdelimiter to "|" --jg: why aren't we using lines?
   --    --   if FALSE then -- for testing, change to TRUE if using fixed quote numbers
   --    --     --put any item of tQuotes into sQuote  ## any quote
   --    --     --put item 7  of tQuotes into sQuote # 37 words! longest possible quote
   --    --     --put item 11  of tQuotes into sQuote  # 18 words
   --    --     put item 2 of tQuotes into sQuote   # very short if you want to dev fast
   --    --   else
   --    --     put line sCurLevel of the uLevelRanges of this cd into tCurRange
   --    --     put trueword 1 of tCurRange into tMin
   --    --     put trueword 2 of tCurRange into tMax
   --    --     repeat for each item i in tQuotes
   --    --       get the number of truewords in i
   --    --       if it <= tMax and it >= tMin then
   --    --         put i & "|" after tQuoteList
   --    --       end if
   --    --     end repeat
   --    --     put any item of tQuoteList into sQuote
   --    --   end if 
end fetchQuote
 
 --  command fetchQuote -- ORIG
 --    # here is where we pick our quote.  Later we need to get it from the dBase
 --    # for V1 all we want is to set levels based on the number of words
 --    # for young people and beginners, very short quote are needed.
 
 --    # Here is where we pick our quote...
 --    # for development  we use a custom prop
 
 --     put the uQuotes of this card into tQuotes
 
 --     ## Later we can pull from a file on disk  that gets updated #
 --     ## or pull from the database
 --     ## we will need to constrain to len(sQuote)<2=330 chars 
 
 --    set the itemdelimiter to "|"
 --    put the number of items of tQuotes into tNoOfQuotes
 
 --    ## any quote
 --    --put item ( random (tNoOfQuotes) ) of tQuotes into sQuote
 
 --    ## longest possible quote: JG will determine if the tiles are not too small:
 --    --put item 7  of tQuotes into sQuote # 37 words!
 
 --    --put item 11  of tQuotes into sQuote  # 18 words
 
 --    # very short if you want to dev fast:
 --  put item 2 of tQuotes into sQuote 
 
 
 --  #fix  strings with straight quotes, which are word delimiters in LC
 --  # change to curly's then they are included with the word 
 
 --   replace (space & quote) with (space & "“") in sQuote 
 --    replace (quote& space) with ( "”"& space) in sQuote 
 
 -- end fetchQuote
 
 command setSizeAndLocationOfQuote sQuote
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
         set the textSize of fld "_quote" to 50
         break
      case tCharCount < 141
         set the textSize of fld "_quote" to 45
         break
      case tCharCount < 206
         set the textSize of fld "_quote" to 40
         break
      case tCharCount < 271
         set the textSize of fld "_quote" to 35
         break
   end switch
   
   set the textstyle of fld "_quote" to bold
   
   put the formattedHeight of fld "_Quote" into tRequiredHeight
   set the height of fld "_quote" to tRequiredHeight
   set the top of fld "_Quote" to 40
   set the rect of grc "quoteBkgnd" to the rect of fld "_quote"
   
end setSizeAndLocationOfQuote

on createWordPuzzle
   set the acceleratedRendering of this stack to false 
   stopTimer
   hide widget "context"
   loadNewBgImg
   if sCurLevel < 1 then pickLevel -- not yet initialized
   --getPixieList # deprecated for now... 
   put empty into sQuote
   fetchQuote # get a different one -- random for now dbase
   ## uncomment the option to get from local custom prop 
   ## if distributing without dbase  and comment out the jnanam fetch
   
   put empty into sWordCount
   put 0 into sCluesGiven
   clearBoard
   startTimer
   
   put getColors() into tColors
   put line 1 of tColors into tRGB
   put line 2 of tColors into tTileBkgndRGB
   set the foregroundcolor of fld _Quote to tRGB
   set the backgroundColor of grc quoteBkgnd to tTileBkgndRGB
   
   lock screen
   put (the number of words of sQuote) into sWordCount
   put sQuote into fld "_quote"
   setSizeAndLocationOfQuote sQuote
   
   set the blendlevel of fld "_quote" to 0  
   show grp "quoteGroup"
   show fld "_quote"
   
   import snapshot from   grp "quoteGroup"
   
   
   # need to save it because we are going to crop each word in a loop
   # put it away for safe keeping
   set the name of the last image to "currentPuzzle" 
   set the loc of image "currentPuzzle"  to -1000,-1000
   
   repeat with x = 1 to the number of words of fld "_quote"  
      copy img "CurrentPuzzle" to this card
      set the name of the last image to "tempForCrop"
      set the rect of the last image to the rect of fld _quote"
      put the formattedRect of word x of fld "_quote" into tNextWordRect  
      
      subtract 8 from item 1 of tNextWordRect
      add 2 to item 2 of tNextWordRect
      add 6 to item 3 of tNextWordRect
      add 4 to item 4 of tNextWordRect
      
      
      put getLocation (tNextWordRect) into tWordLocation
      put word x of fld "_quote" into tNextWord
      
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
      
      put ("word_"&x) into tTileName
      put tTileName & cr after tWordList
      set the name of the last image to tTileName
      set the showborder of the last image to true
      set the behavior of the last image to the long id of btn "behavior_tileScript"
      set the uWordLocation of the last image to tWordLocation
      set the cWord of last image to word x of fld "_quote"
      set the loc of the last image to  -200,-200
      set the borderwidth of the last image to "4"
      set the topcolor of the last image to tRGB
      set the layermode of the last image to "dynamic"
      set the alwaysbuffer of the last image to true
      -- jg: required for smooth movment on slower devices
   end repeat
   set the acceleratedRendering  of this stack to true
   delete char -1 of tWordList
   set the uWordList of this card to tWordList
   --distributeWords
   arrangeWords # Jacque's Method
   # set start indicator to the beginning of the first word
   put the  uWordLocation of image "word_1"  into tFirstWordPosition
   subtract  (the width of image "word_1" /2-10) from item 1 of tFirstWordPosition
   put tFirstWordPosition into tStartIconPosition
   add 4 to item 1 of tStartIconPosition
   set the loc of grc "startHere" to tStartIconPosition
   set the vis of grc "startHere" to true
   --set the blendlevel of fld "_quote" to 50
   
   hide grp "quoteGroup"
   hide fld "_quote" -- comment this out to see the quote during dev
   unlock screen
   send hideSubjectFld to me in 200 milliseconds
   set the acceleratedRendering  of this stack to true
   send "clueGoHome" to image "word_1" in 1 milliseconds
 
end createWordPuzzle

on movestopped
   answer "Move stopped" with "OK"
   --      if the number of lines of  tWordList  > 15 then
   --       put line 15 of tWordList into timage
   --       send "clueGoHome" to image tImage in 1500 milliseconds
   --    end if
end movestopped

function getColors -- return a random RGB set
  -- color sets stored in custom prop uColorSets in format: rgb1|rgb2
  -- first item is text color, second is bg color
  ## Still very ugly, sets were created by algorithm. Needs tweaking. ##
  put any line of the uColorSets of me into tRGBSet
  replace "|" with cr in tRGBSet
  return tRGBSet
end getColors

function getLocation tCoords
     put trunc ( (item 3 of tCoords - item 1 of tCoords)/2)  + trunc ( ( item 1 of tCoords) ) into theX
      put trunc ( (item 4 of tCoords - item 2 of tCoords)/2)  + trunc (item 2 of tCoords) into theY
      return (theX,theY)
end getLocation

on distributeWords
   put the uWordList of this card into tWords
   repeat for each line x in tWords
      # set up random locations that fall inside card window bounds
      # left position at least 100 pixels from the edge for long words 
      put (the width of fld _Quote) - 50 into  tMaxRight
      put   random (tMaxRight - 170 ) + 220   into tX
      put 350 into  tMaxBottom
      --put (the height of fld _Quote) - 100 into  tMaxBottom
      put   random (tMaxBottom - 100+ 1) + 100-1  into tY
      set the loc of img x to tX,tY
      set the uInPlace  of img x to "false"
   end repeat
end distributeWords

on clearBoard
   set the acceleratedRendering  of this stack to false
   deleteMobileControl "aboutText"
   hide group "aboutDisplay"
   hide group "prefsSelectorGrp"
   set the url of widget "readContext" to empty # otherwise old content appears next time
   send hideSubjectFld to me in 2 seconds
   hide widget "readContext"
   stopTimer
   lock screen
   put empty into fld "Minutes" of me
   put empty into fld "seconds" of me
   hide widget "context"
   --set the vis of grc "startHere" to false
   put empty into fld "_Quote" of me
   if the uwordlist of me = "" then exit clearBoard -- assume imgs are gone
   repeat with x = the number of imgs of me down to 1
      if the short name of img x of me begins with "word_"
      then delete img x of me
   end repeat
   try
      delete image "currentPuzzle" of me
      delete image "tempForCrop" of me
   end try
   set the uWordList of me to empty
   unlock screen
end clearBoard 

on checkCompletion 
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
   put the uWordList of this card into tWords
   repeat for each  line x in tWords
      set the blendlevel of img x to pLevel
   end repeat
 end setTilesBlendLevel
 
 --#### SETTINGS PICKER ###--
 
 on setLevel pLevel  # coming from journal or outside
    put pLevel into sCurLevel
 end setLevel
 
command pickLevel  pAction, pValue
   
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
         dialog_CustomMsg true,tPrompt,pLoc,,50
         send "dialog_CustomMsg false" to me in 2 seconds
   end switch
   
   -- display the mobile picker
   
   # BR: Dec 1, 2016... mobile picker looks horrible
   # switching to native group/field
   
   
   # the rest is done in the fld itself
   
   
   # deprecated: 
   --   if isMobile() then 
   --     put max(sCurLevel,1) into tLevel
   --     put the uLevels of me into tLevelList -- easier to store these in a prop
   --     mobilePick tLevelList, tLevel
   --     put the result into tLevel
   --     if tLevel > 0 then -- it's been changed
   --       put tLevel into sCurLevel
   --       ## SAVE PREF HERE
   --     end if
   --   else -- for desktop testing
   --     answer "Choose a level:" with 4 or 3 or 2 or 1
   --     put it into sCurLevel
   --   end if
end pickLevel

on arrangeWords
   -- alternate distribution method; not sure it's much better but there will be no hidden overlaps
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
 
command triggercompletion
  if sTimerOnFlag <> true then exit triggercompletion -- already finished
  stopTimer
  if the uSourceURL of widget "context" <> empty then show widget "context"
  put the number of lines in the uWordList of this card into tNumWords
  get fld "Minutes"
  if (word 1 of it) > 0 then
    put it into tTime
    if it < 2 then delete last char of tTime -- make it singular
    put space after tTime
  end if
  put fld "seconds"  after tTime
  put "Done!" && tNumWords && "words in" && tTime & ". Use settings to get longer quotes." into tPrompt
 dialog_CustomMsg true,tPrompt 
  send "dialog_CustomMsg false" to me in 5 seconds
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

on showClues
   put the uWordList of me into tTiles
   put the number of lines of tTiles into tWordCount
   if sCluesGiven is empty then
      put 0 into sCluesGiven
   end if
   
   switch sCluesGiven
      case 0 
         if tWordCount <16 then
            send "clueGoHome" to image (line tWordCount of tTiles)
         else
            send "clueGoHome" to image (line 15 of tTiles)
         end if  
         add 1 to sCluesGiven
         break
      case 1
           send "clueGoHome" to image (line tWordCount of tTiles)
         add 1 to sCluesGiven
         break
         case 2
          send "clueGoHome" to image (line tWordCount of tTiles)
         add 1 to sCluesGiven
         break
      case 3 
         put "No more clues. You are on your own!" into pMsg
         dialog_customMsg true,pMsg,1500
         put 0 into sCluesGiven
         break       
   end switch
   
end showClues


-- DEV _- 
## This makes a list of color sets for the custom cd prop

on makeColorSets pList -- usually I pass the clipboarddata
   repeat for each line l in pList
     put "" into tBgRGB
     repeat for each item i in l
       put i+100 & comma after tBgRGB
     end repeat
     delete last char of tBgRGB
     put l & "|" & tBgRGB & cr after tColorList
   end repeat
   breakpoint
   set the uColorSets of me to tColorList
 end makeColorSets
 
on test -- use this to test correct dimensions
  -- params: pShow,pMsg,pLoc,pWidth,pHeight:
  
  put "You did it!" && tNumWords && "words in" && tTime & ". Use settings to get longer quotes." into tPrompt
 dialog_CustomMsg true,tPrompt
end test

command resetUI
   showTitle True
   clearBoard
   set the acceleratedRendering of this stack to false
end resetUI

command checkTileGlow
   setTileGlow "small"
   put sTileGlow["size"]
   set the outerGlow of image "word_5" to sTileGlow
end checkTileGlow

on startup pMode

end startup
