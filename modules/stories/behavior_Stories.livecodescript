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
local sCardBkgnd,sStoryBkgnd,sStoryImage
# story control variables, stored cache
# must wipe them on end of story
local sAttribution, sStoryTitle,sLastScene,sTotalSceneCount

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
   put getPref("preferences/modules/stories/storyTitle") into sStoryTitle
   put getPref("preferences/modules/stories/storyScene/") into  sLastScene
   
   switch tCard
      case "storiesHome"
         # assume opening img if a story in not in play
         # load the menu in any case:
         put the keys of sStoriesMetaArray["stories"] into fld "storiesMenuFld"
         
         put the long id of img "HomeCardBkgnd" into sCardBkgnd
         put the long id of img "StoryBkgndImage" into sStoryBkgnd
         put the long id of img "StoryImage" into sStoryImage
         
         if sStoryTitle is "false" or sStoryTitle is empty then
            showStoryText
         else
            showStoryText
            goNextScene
         end if
         break
   end switch
   
   # for dev: 
   # go the end to the story to watch the UX
   # comment out if you want to whole story
   # or watch the another story, after opening the stack
   # and this not be called

      endInTwoScenes

end preopenCard




/** 
UX for user for the stack and card
*/
on mouseup
   local tTarget,tTargetOwner,tTips
   put the short name of the owner of the target into tTargetOwner
   put the short name of the target into tTarget
   
   switch tTarget
      case "storiesMenuFld"
         put value(clickLine() ) into sStoryTitle
         getcontent sStoryTitle
         showAttribution sAttribution
         showStoryText
         break
      case "tips"
         lock screen
         put url ("file://"& path_Modules()& "stories/stories-user-guide.html") into tTips
         set the htmltext of fld "homeStoryText" to tTips
         showStoryText  
         unlock screen
         break
   end switch
   
end mouseup

command showStoryText
   hide img "StoryImage"
   set the filename of sStoryBkgnd to (path_Assets()&"img/bkgnds/patterns/Blue-Texture-Square.jpg")
   show grp "homeStoryBkgnd"
   show fld "homeStoryText"
   show grp "textDisplay"
   hide grp "storiesMenu"
end showStoryText

command showStoryText
   #sCardBkgnd,sStoryBkgnd,sStoryImage
   set the filename of sCardBkgnd to (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
   # we show menu
   # no story is cached
   hide grp "homeStoryBkgnd"
   hide grp "textDisplay"
   show grp "storiesMenu"
end showStoryText


on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack


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
   
   if sLastScene > sTotalSceneCount then 
      unlock Screen
      # Notify the user
      hide sStoryImage
      put  cr & cr &"The End"  into fld "homeStoryText"
      wait 750 milliseconds
      
      showIsOver
      showStoryText
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
   showStoryText
   put  getCache("Attribution") into sAttribution
   put "(Story - Slideshow)" & cr & cr &sStoryTitle & cr &cr & "by" & cr &cr & sAttribution into fld "homeStoryText"
   setCache storyScene,0
   unlock screen
end showAttribution

command showIsOver
   
   # Resent cache, locals and preferences to "nada"
   hide sStoryImage

   #wipe locals 
   put "" into sAttribution
   put "" into sStoryTitle
   put "" into sLastScene
   put "" into sTotalSceneCount
   
   # wipe cache
   setCache ContentFlag,0
   setCache StoryTitle,""
   setCache storyScene,""
   setCache SceneCount,""
   setCache Attribution, ""
   
   #wipe preferemces
   setPref "preferences/modules/stories/storyTitle", ""
   setPref "preferences/modules/stories/storyScene/", ""
   
   # showMenu
   showStoryText
   
   --displayCache
end showIsOver

command endInTwoScenes
   if the environment is "development" then
      setCache storyScene,sTotalSceneCount-2
      put sTotalSceneCount-2 into sLastScene
   end if
end endInTwoScenes


## we think for following handle my belong to the "model"
# but this a UI call  to show something in the "view"
# in MVC architecture, this would be part of a "controller"
# perhaps this script falls in that category?  

command loadNewImage pPath
   # sCardBkgnd,sStoryBkgnd,sStoryImage
   lock screen for visual effect
   set the filename of sStoryImage to pPath
   setImageToFullCardLoc sStoryImage, "portrait"
   centerMe sStoryImage
   show   sStoryImage --with visual effect "dissolve" 
   hide fld "homeStoryText"
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
   showStoryText
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
   showStoryText
end closecard

on closestack
   addJournalEntry
   tracking_RecordActivity "Stories: " & sStoryTitle, "navigation/exit", pTrackdata
   portal_SetLastStack "stories" 
end closestack

on closestack
   portal_SetLastStack "stories" 
end closestack

--global sConfigA, sDefaultImage,
--local sStoriesMetaArray  # get the metadata for each story; and parameters
--local  sImageList, sLastImage, sQuoteList, sLastQuote
--local sCardBkgnd,sStoryBkgnd,sStoryImage
--# story control variables, stored cache
--# must wipe them on end of story
--local sAttribution, sStoryTitle,sLastScene,sTotalSceneCount

command addJournalEntry 
   local pData, tTitle
   put "storiesHome"into pData["card"]
   put "goNextScene" into pData["nextAction"]
   put "Stories: " &  sStoryTitle  into tTitle
   Journal_RecordEntry "stories",tTitle,pData -- send to journal
end addJournalEntry

on journalResume pDataA, pEntryA
   local pLevel -- BWM looks like this value is unused
   go to card  pDataA["card"] 
   dispatch pDataA["nextAction"] to me
end journalResume


-------------------- GEOMETRY

on updateUI
   local tFooter,tMenu,tTextDisplay,tStoryBkgndImage,tStoryImage
   
   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
   end if
   
   put the long id of grp "storiesMenu" into tMenu
   centerMe tMenu
   
   
   put the long id of img "StoryBkgndImage" into tStoryBkgndImage
   CenterMe tStoryBkgndImage
   
   put the long id of img "StoryImage" into tStoryImage
   CenterMe tStoryImage
   
   put the long id of fld "homeStoryText" into tTextDisplay
   topCenterMe tTextDisplay,10
   
   put the long id of grp "footer" into tFooter
   send "updateUI" to tFooter
   
end updateUI



