script "behavior_Stories" with behavior "model_Stories"

/* 
This script  is the behavior  stack "modules/stories.livecode"
It is nested under a parent behavior: behavior "model_Stories"
Revised 2020-01-15:
BR: In order not to proliferate more and more files, 
I am try to use the same behaviour for
a) the stack layout/responsiveness as a whole
b) using it one other cards as the behaviour for presenting stories
So, rather that settng up multi-file are behaviors, this requires us to 
pass parameters to the common handler and use switch statements instead.
*/

global sConfigA,sDefaultImage,sMainImage
local  sImageList,sLastImage,sQuoteList,sLastQuote,sLastScene,sTotalSceneCount
local sAttribution,sStoryNumber


on preopenstack
   if isMobile() then
      mobileHideStatusBar
   end if
end preopenstack

#########
# we want to be able  come back to the story

--on journalResume  pDataA, pEntryA
--   dispatch "restoreFromJournalEntry" to card #####" with pDataA
--end journalResume

#############

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

on updateUI
   local tFooter, tQuote, tRect, tControl
   put the long id of grp "footerNavigation" into tFooter
   send "updateUI" to tFooter

   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
   end if
end updateUI

--/assets/img/bkgnds/patterns/M09-Bkgrd-SYM-Sun-moon_opt-30.jpg

on preopencontrol pControl
   if pControl is empty then exist preOpenControl
   
  --breakpoint
   # fresh reboot these will be null. 
   # handle in initializeNarrative
   
   put getPref ("preferences/modules/portal/story/storyNumber") into sStoryNumber
   if sStoryNumber is "false" then # no prefs, first time app being loaded
      put 1 into sStoryNumber
   end if
   setCache"storyNumber", sStoryNumber
   
   put getPref ("preferences/modules/portal/story/storyScene") into sLastScene
   if sLastScene is "false" then      # no prefs, first time app being loaded
      put "" into sLastScene           # must be null to start by showing Attribution
   end if
   setCache "storyScene",sLastScene
   
   initializeNarrative
   
end preopencontrol

command initializeStory
   
   # for testin,set last scene toward the and
   --put 38 into sLastScene         
   
   # story is cached
   if getCache("storyIsCachedFlag") = 1 then 
      exit initializeStory #all content is cached
   end if
   
   #first run; story number is was not save to pref and is null
   if getCache("storyNumber") = "" then 
      setCache"storyNumber",1
   end if
   
   put getCache("storyNumber")  into sStoryNumber
   getContent sStoryNumber
   
   # Load local  with images and text
   put getCache("imageList") into simageList
   put getCache("Quotes") into sQuoteList
   put getCache("Attribution") into sAttribution 
   put getCache("sceneCount") into sTotalSceneCount
   
   # sCacheA["narrationScene"]  tell us where we have in the current story
   # so that we can come back and start from where we left off.
   # see getters and setters lib_SivaSiva
   
   ntinfo "Initialize scene"
   
   put the long id of img "storyBgkImage" into sMainImage
   
   if (the lockscreen) then unlock screen
   
end initializeStory



-----------------------------------------
## Trying to find architect that is scaleble and maintainable
## "getContent" is meant to "get a story"
## we are not using "model_Stories" but we should be
## we should be able get and slide show in content store in that app
## slide show from the internet
## "a story" for the server , to be developed that called XML
##  which is a description of scened (see spec a google doc)
## for now is is hard wired to in-app photo + quote from the dBase
## this is just the beginning, It weill need to be responsive

# later should be  in model_Narratives


command goNextScene
   
   --breakpoint
   local tImage, tPath
   
   put  getCache("narrationScene") into sLastScene
   put  getCache("Attribution") into sAttribution
   put  getCache("SceneCount") into sTotalSceneCount
   put  getCache("Quotes") into sQuoteList
   put  getCache("ImageList") into sImageList
   --breakpoint
   --ntinfo ("last Image: " & sLastImage && "ImageCount:" &sTotalSceneCount)
   
   if sLastScene= empty then
      # it means we are starting again
      # TO DO we should have attributions as part of the story content
      # that is called from the model, so that it is not hard wired into the UI handlers
      showAttribution sAttribution
      setCache "storyScene",1
      exit goNextScene
   end if
   
   put empty into fld "homeMainImage"
   
   if (sLastScene is 0 )  then add 1 to sLastScene
   
   # following is hard wired to slide show from the app
   # refactor when we get to an XML cum "SMILE" model
   
   #Deal with scene count, begin again etc.
   # we have reach the end.
   
   if sLastScene > sTotalSceneCount then 
      showIsOver
      exit goNextScene
   end if
   
   # We have not reached then end. We are in the middle of a story
   # so we can actually "go next" 
   
   if not (the vis of sMainImage) then
      put random(the number of lines of sImageList) into tLine
      put line tLine of sImageList into tPath
      # put line  sLastImage of sImageList into tPath
      loadNewImage tPath
   else
      loadNextQuote sLastImage
   end if
   
   
   add 1 to sLastScene
   setCache "narrationScene",sLastScene 
   
end goNextScene

command showIsOver
   # story if finished. back to default and prepare to 
   # increment to the next story 
   put empty into sLastScene
   setCache("ContentFlag"),0
   put getCache("storyNumber") into sStoryNumber
   
   if (sStoryNumber  = "" ) OR (sStoryNumber =3) then 
      # new app user first run, or an upgrade: preference on story are empty..
      # or we are reach the end of stories... hard wired right now to 2
      # we have 5 slideshows, but are not show 4 and 5 until a later release
      # when we get the mobilescrolled working.
      
      put 1 into sStoryNumber
   else
      add 1 to sStoryNumber
   end if
   setCache ("storyNumber"),sStoryNumber
   setCache "narrationScene",""
   setDefaultImage
   
   # get the new story
   getContent sStoryNumber
   put getCache("imageList") into sImageList
   put getCache("Quotes") into sQuoteList
   put getCache("Attribution") into sAttribution
   put getCache("SceneCount")  into sTotalSceneCount
   setCache ContentFlag, 1
end showIsOver


## we think for following handle my belong to the "model"
# but this a UI call  to show something in the "view"
# in MVC architecture, this would be part of a "controller"
# perhaps this script falls in that category?  

command loadNewImage pPath
   lock screen for visual effect
   set the filename of sMainImage to pPath
   setImageToFullCardLoc sMainImage, "portrait", 0,0
   centerMe sMainImage,0,0
   show sMainImage --with visual effect "dissolve" 
   unlock screen with visual effect "dissolve" 
end loadNewImage

command loadNextQuote pQuoteNo
   local tControl
   lock screen for visual effect
   set the itemdel to "|"
   # random quote
   put random(the number of items of sQuoteList) into tQuote
   put item tQuote of sQuoteList into fld "preferences"
   --put item pQuoteNo  of sQuoteList into fld "homeStoryText"
   put the long id of fld "homeStoryText" into tControl
   centerMe tControl,0,5
   hide sMainImage
   unlock screen with visual effect "dissolve"  very fast
   
   --   breakpoint
   --   if isMobile() then
   --      deleteMobileControl "homeStoryText"
   --      # recreate:
   --      if the formattedheight of fld "homeStoryText" > the height of fld "homeStoryText" then
   --         send "CreateScroller homeStoryText" to fld "homeStoryText"
   --      end if
   --end if
   
end loadNextQuote

command showAttribution sAttribution
   lock screen
   hide sMainImage
   put "(Story - Slideshow)" & cr & cr & sAttribution into fld "homeStoryText"
   unlock screen
end showAttribution

command fitFieldToContent  pField
   set the height of pField to the formattedHeight of pField
end fitFieldToContent

command hideShowField pField,pBool
   set the vis of pField to pBool
end hideShowField

on closeControl
   setPref "preferences/modules/portal/story/storyNumber", getCache("storyNumber")
   setPref "preferences/modules/portal/story/storyScene/", sLastScene
end closeControl


on closestack
   portal_SetLastStack "stories" 
end closestack


### old attempt to show stories by setting attribute of a screen format
# e.g./ background,  fld for text, other images, video etc.

--on showNarrative pNarrativeA, pSceneNumber
--   go stack "narrative"
--   lock screen

--   if there is a group "controls" then
--      delete group "controls"
--   end if

--   create image "background"
--   group image "background"
--   set the name of it to "controls"
--   set the lockUpdates of group "controls" to true


--   if pSceneNumber is not a number then
--      put 1 into pSceneNumber
--   end if

--   put pNarrativeA["scenes"][pSceneNumber] into tSceneA

--   repeat for each key k in tSceneA
--      put tSceneA[k] into tItemA
--      switch tItemA["type"]
--         case "image"
--            set the filename of image "background" to tItemA["path"]
--            resizeToHeight the long id of image "background", the height of this card
--            set the loc of image "background" to the loc of this card
--            break
--         case "text"
--            put "text" & the milliseconds into tName
--            create field tName in group "controls"
--            setDefaultPropertiesForField the long id of field tName
--            set the HTMLText of field tName to tItemA["contents"]
--            alignItem the long id of field tName, tItemA
--            break
--      end switch
--   end repeat

--   unlock screen
--end showNarrative


--on setDefaultPropertiesForField pControl
--   set the opaque of pControl to false
--   set the textSize of pControl to 18
--   set the lockText of pControl to true
--   set the threeD of pControl to false
--   set the borderWidth of pControl to 0
--end setDefaultPropertiesForField

--on alignItem pControl, pItemA
--   if pItemA["attributes"]["font"] is not empty then
--      set the textFont of pControl to pItemA["attributes"]["font"]
--   end if

--   if pItemA["attributes"]["font-size"] is not empty then
--      set the textSize of pControl to pItemA["attributes"]["font-size"]
--   end if

--   if pItemA["attributes"]["text-align"] is not empty then
--      set the textAlign of pControl to pItemA["attributes"]["text-align"]
--   end if

--   switch pItemA["attributes"]["width"]
--      case "fit"
--         set the width of pControl to the formattedWidth of pControl
--         break
--      case "card"
--         set the width of pControl to the width of this card
--         break
--      default
--         if pItemA["attributes"]["width"] is a number then
--            set the width of pControl to (the width of this card / pItemA["attributes"]["width"])
--         else
--            set the width of pControl to the formattedWidth of pControl
--         end if
--   end switch

--   switch pItemA["attributes"]["height"]
--      case "fit"
--         set the height of pControl to the formattedheight of pControl
--         break
--      case "card"
--         set the height of pControl to the height of this card
--         break
--      default
--         if pItemA["attributes"]["height"] is a number then
--            set the height of pControl to (the height of this card / pItemA["attributes"]["height"])
--         else
--            set the height of pControl to  the formattedheight of pControl
--         end if
--   end switch


--   if pItemA["attributes"]["blend"] is a number then
--      set the blendlevel of pControl to pItemA["attributes"]["blend"]
--   end if

--   if pItemA["attributes"]["color"] is not empty then
--      set the foreColor of pControl to pItemA["attributes"]["color"]
--   end if

--   if pItemA["attributes"]["background-color"] is not empty then
--      set the opaque of pControl to true
--      set the backgroundcolor of pControl to pItemA["attributes"]["background-color"]
--   end if




--on resizeToHeight pImage,pSize

--   put the width of pImage into tOrigImgWidth
--   put the height of pImage into tOrigImgHeight
--   put pSize/tOrigImgHeight  into tRatio
--   put tOrigImgWidth * tRatio into tNewWidth
--   put tOrigImgHeight * tRatio into tNewHeight
--   set the rect of pImage to 0,0,tNewWidth,tNewHeight  
--end resizeToHeight

--on linkClicked pText
--   launch url pText
--end linkClicked



