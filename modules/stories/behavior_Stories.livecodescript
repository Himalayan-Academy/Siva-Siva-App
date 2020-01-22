script "behavior_Stories" with behavior "model_Stories"

/* 
This script  is the behavior  stack "modules/stories.livecode"
It is nested under a parent behavior: behavior "model_Stories"
Revised 2020-01-15:
BR: In order not to proliferate more and more files, 
I am tryoing to use the same behavior for
a) the stack layout/responsiveness as a whole
b) using it for the specific UI/UX of the stack/card; using it one other cards 
as the behaviour for presenting stories
So, rather that settng up multi-file are behaviors, this requires us to 
pass parameters to the common handler and use switch statements instead.
but make sure the any handler in the "model" category an don't there
*/


global sConfigA, sDefaultImage,
local sStoriesMetaArray  # get the metadata for each story; and parameters
local  sImageList, sLastImage, sQuoteList, sLastQuote
local sLastScene, sTotalSceneCount,sCardBkgnd,sStoryBkgnd,sStoryImage
local sAttribution, sStoryTitle

on preopenstack
   if isMobile() then
      mobileShowStatusBar
   end if
   put loadStoriesMetadata() into sStoriesMetaArray
end preopenstack


/** Per Card Layout and UI

Summary: We are putting layout of UI here
Based on the card name

*/

on preOpenCard
   local tCard 
   put the short name of this card into tCard
  getPref "preferences/modules/stories/storyTitle", sStoryTitle
   getPref "preferences/modules/stories/storyScene/", sLastScene
   
   switch tCard
      case "storiesHome"
         # assume opening img if a story in not in play
         # load the menu in any case:
         put the keys of sStoriesMetaArray["stories"] into fld "storiesMenuFld"
         
         put the long id of img "HomeCardBkgnd" into sCardBkgnd
         put the long id of img "StoryBkgndImage" into sStoryBkgnd
         put the long id of img "StoryImage" into sStoryImage
         
         showStoryMenu
         
         break
   end switch
   
end preopenCard




/** 
UX for user for the stack and card
*/
on mouseup
   local tTarget,tTargetOwner
   put the short name of the owner of the target into tTargetOwner
   put the short name of the target into tTarget
   
   switch tTarget
      case "storiesMenuFld"
         put value(clickLine() ) into sStoryTitle
         getcontent sStoryTitle
         showAttribution sAttribution
         showStory
         break
   end switch
   
end mouseup

command showStory
   set the filename of sStoryBkgnd to (path_Assets()&"img/bkgnds/patterns/Blue-Texture-Square.jpg")
   show grp "homeStory"
   hide grp "storiesMenu"
end showStory

command showStoryMenu
   #sCardBkgnd,sStoryBkgnd,sStoryImage
   set the filename of sCardBkgnd to (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
   # we show menu
   # no story is cached
   hide grp "homeStory"
   show grp "storiesMenu"
end showStoryMenu


on journalResume  pDataA, pEntryA
   # need to return to story and the same place they left off
   # dispatch "restoreFromJournalEntry" to card "images-quotes" with pDataA
end journalResume

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

on updateUI
   local tFooter, tBody
   
   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
   end if
   
   put the long id of grp "footer" into tFooter
   send "updateUI" to tFooter
   
   put the long id of grp "storiesMenu" into tBody
   centerMe tBody
   
end updateUI

-------------------
on _showStories
end _showStories

--on mouseup
--   if the altKey is down then
--      delete group "controls"
--   end if

--   if there is not a group "controls" then
--      put loadStoriesFromDisk("test") into sStoriesA
--      put 1 into sCurrentScene
--      showStories sStoriesA, sCurrentScene
--   else
--      add 1 to sCurrentScene
--      if sCurrentScene > sStoriesA["number of scenes"] then
--         put 1 into sCurrentScene
--      end if
--      showStories sStoriesA, sCurrentScene
--   end if
--end mouseup


--/assets/img/bkgnds/patterns/M09-Bkgrd-SYM-Sun-moon_opt-30.jpg

--on preopencontrol pControl
--   if pControl is empty then exist preOpenControl

--  --breakpoint
--   # fresh reboot these will be null. 
--   # handle in initializeNarrative



--   put getPref ("preferences/modules/portal/story/storyScene") into sLastScene
--   if sLastScene is "false" then      # no prefs, first time app being loaded
--      put "" into sLastScene           # must be null to start by showing Attribution
--   end if
--   setCache "storyScene",sLastScene

--   initializeNarrative

--end preopencontrol

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
   
   put getCache("storyNumber")  into sStoryTitle
   getContent sStoryTitle
   
   # Load local  with images and text
   put getCache("imageList") into simageList
   put getCache("Quotes") into sQuoteList
   put getCache("Attribution") into sAttribution 
   put getCache("sceneCount") into sTotalSceneCount
   
   # sCacheA["narrationScene"]  tell us where we have in the current story
   # so that we can come back and start from where we left off.
   # see getters and setters lib_SivaSiva
   
   ntinfo "Initialize scene"
   
   
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
   lock screen
   --breakpoint
   local tImage, tPath
   put  getCache("storyTitle") into sStoryTitle
   put  getCache("storyScene") into sLastScene
   put  getCache("Attribution") into sAttribution
   put  getCache("SceneCount") into sTotalSceneCount
   put  getCache("Quotes") into sQuoteList
   put  getCache("ImageList") into sImageList
   --breakpoint
   --ntinfo ("last Image: " & sLastImage && "ImageCount:" &sTotalSceneCount)
   
   if sLastScene= empty then
      # it means we are starting again
      setCache "storyScene",0
   end if
   
   put empty into fld "homeStoryText"
   
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
   # the card background a blue fld sBackgroundImage at this point
   if the vis of sStoryImage then
      loadNextQuote sLastImage
   else
      put random(the number of lines of sImageList) into tLine
      put line tLine of sImageList into tPath
      # put line  sLastImage of sImageList into tPath
      loadNewImage tPath
   end if
   
   
   add 1 to sLastScene
   setCache "storyScene",sLastScene 
   unlock Screen
end goNextScene

command showAttribution sAttribution
   lock screen
   put  getCache("Attribution") into sAttribution
   put "(Story - Slideshow)" & cr & cr &sStoryTitle & cr &cr & "by" & cr &cr & sAttribution into fld "homeStoryText"
   unlock screen
end showAttribution


command showIsOver
   # story if finished. back to default and prepare to 
   # increment to the next story 
   put empty into sLastScene
   setCache("ContentFlag"),0
   setCacher("StoryNumber"),""
   showStoryMenu
end showIsOver


## we think for following handle my belong to the "model"
# but this a UI call  to show something in the "view"
# in MVC architecture, this would be part of a "controller"
# perhaps this script falls in that category?  

command loadNewImage pPath
   # sCardBkgnd,sStoryBkgnd,sStoryImage
   lock screen for visual effect
   set the filename of sStoryImage to pPath
   setImageToFullCardLoc sStoryImage, "portrait", 0,0
   centerMe sStoryImage,0,0
   show   sStoryImage --with visual effect "dissolve" 
   unlock screen with visual effect "dissolve" 
end loadNewImage

command loadNextQuote pQuoteNo
   
   local tControl,tQuoteNo
   lock screen for visual effect
   hide sStoryImage
   set the itemdel to "|"
   # random quote
   put random(the number of items of sQuoteList) into tQuoteNo
   --put item tQuote of sQuoteList into fld "preferences"
   put item tQuoteNo  of sQuoteList into fld "homeStoryText"
   put the long id of fld "homeStoryText" into tControl
   centerMe tControl,0,5
   
   unlock screen with visual effect "dissolve"  very fast
   
end loadNextQuote


command fitFieldToContent  pField
   set the height of pField to the formattedHeight of pField
end fitFieldToContent

command hideShowField pField,pBool
   set the vis of pField to pBool
end hideShowField

on closeCard
   setPref "preferences/modules/stories/storyTitle", sStoryTitle
   setPref "preferences/modules/stories/storyScene/", sLastScene
   showStoryMenu
end closecard

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


on closestack
   portal_SetLastStack "stories" 
end closestack


