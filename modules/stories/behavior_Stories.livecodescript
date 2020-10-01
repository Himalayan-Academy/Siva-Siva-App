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
So, ratheAr that settng up multi-file are behaviors, this requires us to 
pass parameters to the common handler and use switch statements instead.
but make sure the any handler in the "model" category an don't there
*/


global sConfigA, sDefaultImage,
local sStoriesMetaArray  # get the metadata for each story; and parameters

# geometry vars
local sStoryMenu, sImageloc


# story control variables, stored cache
# must wipe them on end of story
local  sImageList, sLastImage, sQuoteList, sLastQuote
local sAttribution, sStoryTitle,sLastScene,sTotalSceneCount

# various screen display options
local sTarget, sTargetOwner
local sTips

on preopenstack
   put loadStoriesMetadata() into sStoriesMetaArray
end preopenstack


/* Per Card Layout and UI

Summary: We are putting layout of UI here
Based on the card name

*/

on preOpenCard
   if the logMessage <> empty then
      copyLogControl
   end if
   setCardCoords "portrait"
   put the long id of fld "storyMenu" into sStoryMenu
   put the long id of fld "tips" into sTips
end preopenCard

on opencard
   local tCard 
   put the short name of this card into tCard
   
         # assume opening img if a story has not been started by user
         # load the menu in any case:
         put the keys of sStoriesMetaArray["stories"] into fld "storyMenu"
         showStoryMenu
end opencard
      
command showStoryMenu
   dispatch "deleteMobileControl" to sTips with "tips"
   
   set the filename of img "menuImage" to (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
   hide grp "tips"
   show grp "storyMenu"
   display_SetStatusBarVis true
   
end showStoryMenu 

/*
UX for user for the stack and cardi
*/
on mouseup
   local tTips
   
   put the short name of the owner of the target into sTargetOwner
   put the short name of the target into sTarget
   
   --endInTwoScenes # use for development
   
   switch sTarget
      case "storiesMenuFld"
         put value(clickLine() ) into sStoryTitle
         if sStoryTitle is empty then exit mouseup
         break
         
      case "tips"
         set the filename of img "tipsImage" to (path_Assets()&"img/bkgnds/patterns/Blue-Texture-Square.jpg")
         put url ("file:"& path_Modules()& "stories/stories-user-guide.html") into tTips
         set the htmltext of fld "tips" to tTips 
         dispatch "createscroller" to sTips with "tips"
         show grp "tips"
         break
         
      case "back"
         dispatch "deleteMobileControl" to sTips with "tips"
         hide grp "tips"
         break
   end switch
   
end mouseup

on mousedown
   switch sTarget
      case "StoryImage"
         grab img "StoryImage"
         put the loc of  img "StoryImage" into sImageLoc
         break
   end switch
   break
end mouseDown



-------
local pData,  tCd,  

command addJournalEntry -- save a bookmark to db
   local tTitle
   if (sStoryTitle is "false") OR (sStorytitle is empty) then 
      put "Main Menu" into tTitle 
   else 
      put sStoryTitle into pData["storyTitle"]
      put sLastScene into pData["storyScene"]
      put sAttribution into pData["Attribution"]
      put sTotalSceneCount into pData["SceneCount"]
   end if
   put "storiesHome" into pData["card"]
   Journal_RecordEntry "Stories",(sStoryTitle &", "& sLastScene), pData -- send to journal
end addJournalEntry
		
on journalResume pData -- sent from journal stack
   put pData["Card"] into tCd
   go to card tCd
   put loadStoriesMetadata() into sStoriesMetaArray
   getcontent pData["storyTitle"]
   
   put getCache("imageList") into simageList
   put getCache("Quotes") into sQuoteList
   
   put pData["storyTitle"] into sStoryTitle
   put pData["storyScene"] into sLastScene
   put pData["Attribution"] into sAttribution
   put pData["SceneCount"] into sTotalSceneCount
   setCache "storyScene",sLastScene
   display_SetStatusBarVis false
   showStoryText
   goNextScene
   
end journalResume


on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack


on updateUI
   local tFooter,tMenu,tTextDisplay,tStoryBkgndImage,tStoryImage,tGoNext,tControl
   local tGoTips
   
   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
   end if
   
   put the long id of grp "storiesMenu" into tMenu
   topcenterMe tMenu,120
   
   put the long id of img "StoryBkgndImage" into tStoryBkgndImage
   CenterMe tStoryBkgndImage
   
   put the long id of img "StoryImage" into tStoryImage
   CenterMe tStoryImage
   
   put the long id of btn "goNext" into tGoNext
   bottomCenterMe tGoNext,65
   
   put the long id of btn "tips" into tGoTips
   bottomCenterMe tGoTips,70
   
   set the rect sTips to (10, 50, cardWidth() - 10, the top of btn "goNext" - 21)
   
   set the rect sStoryMenu to (32, 50, cardWidth() - 32, the top of btn "back" - 21)
   set the uRect of sStoryMenu  to the rect of sStoryMenu 
   
   put the long id of grp "footer" into tFooter
   send "updateUI" to tFooter
end updateUI





on closeCard
   
   /*
   setPref "preferences/modules/stories/storyTitle", sStoryTitle
   setPref "preferences/modules/stories/storyScene/", sLastScene
   */
   
   showStoryMenu
end closecard

on closestack  
   portal_SetLastStack "stories" 
end closestack


---------------------------
on _DEPRECATED
end _DEPRECATED


--on opencard
--   if sStoryTitle is "false" or sStoryTitle is empty then
--      showStoryMenu
--   else
--      display_SetStatusBarVis false
--      showStoryText
--      goNextScene
--   end if
--end opencard

# we going to manipulate these controls across many handlers
# declare them here instead of in the handlers
--put the long id of fld "homeStoryText" into sHomeText
--put the long id of img "HomeCardBkgnd" into sCardBkgnd

--command initializeStory
--   local imageList,storyIsCachedFlag
--   # for testin,set last scene toward the and
--   --put 38 into sLastScene         

--   # story is cached
--   if getCache(storyIsCachedFlag) = 1 then 
--      --      exit initializeStory #all content is cached
--   end if

--   #first run; 

--   # Load local  with images and text
--   put getCache(imageList) into simageList
--   put getCache("Quotes") into sQuoteList
--   put getCache("Attribution") into sAttribution 
--   put getCache("sceneCount") into sTotalSceneCount

--   # sCacheA["narrationScene"]  tell us where we have in the current story
--   # so that we can come back and start from where we left off.
--   # see getters and setters lib_SivaSiva

--   ntinfo "Initialize scene"

--   if (the lockscreen) then unlock screen

--end initializeStory


-------------------------------------------
--## Trying to find architect that is scaleble and maintainable
--## "getContent" is meant to "get a story"
--## we are not using "model_Stories" but we should be
--## we should be able get and slide show in content store in that app
--## slide show from the internet
--## "a story" for the server , to be developed that called XML
--##  which is a description of scened (see spec a google doc)
--## for now is is hard wired to in-app photo + quote from the dBase
--## this is just the beginning, It weill need to be responsive

--# later should be  in model_Narratives

--command goNextScene

--   local tLine
--   lock screen
--   if sTarget is "Tips" then
--      showStoryText sUserGuideFld
--      exit goNextScene
--   end if
--   --breakpoint
--   local tImage, tPath
--   put  getCache("storyTitle") into sStoryTitle
--   put  getCache("storyScene") into sLastScene
--   if sLastScene < 0 then put 0 into sLastScene	
--   put  getCache("Attribution") into sAttribution
--   put  getCache("SceneCount") into sTotalSceneCount
--   put  getCache("Quotes") into sQuoteList
--   put  getCache("ImageList") into sImageList



--   --breakpoint
--   --ntinfo ("last Image: " & sLastImage && "ImageCount:" &sTotalSceneCount)

--   if sLastScene= empty then
--      # it means we are starting again
--      setCache "storyScene",0
--   end if

--   put empty into fld "homeStoryText"

--   if (sLastScene is 0 )  then add 1 to sLastScene

--   if sLastScene > sTotalSceneCount then 
--      unlock Screen
--      # Notify the user
--      hide sStoryImage
--      put  cr & cr &"The End"  into fld "homeStoryText"
--      wait 1 seconds

--      showIsOver
--      showStoryMenu

--      exit goNextScene
--   end if

--   # We have not reached then end. We are in the middle of a story
--   # so we can actually "go next" 
--   # the card background a blue fld sBackgroundImage at this point
--   if the vis of sStoryImage then
--      loadNextQuote sLastImage
--   else
--      put random(the number of lines of sImageList) into tLine
--      put line tLine of sImageList into tPath
--      # put line  sLastImage of sImageList into tPath
--      loadNewImage tPath
--   end if

--   add 1 to sLastScene
--   setCache "storyScene",sLastScene 
--   unlock Screen
--   log (the vis of fld "homeStoryText")
--end goNextScene

--command showStoryText sWhatText
--   set the filename of sStoryBkgnd to (path_Assets()&"img/bkgnds/patterns/Blue-Texture-Square.jpg")
--   show grp "homeStoryBkgnd"
--   show grp "textDisplay"
--   switch sWhatText
--      case (sWhatText is empty) # default
--      case "quotes"
--         show sHomeText
--         hide fld "userGuide"
--         break
--    case sUserGuideFld
--         hide image "StoryImage"
--         hide sHomeText
--         show sUserGuideFld
--         log (the vis of sUserGuideFld)
--         log th  e rect of sUserGuideFld
--         break
--   end switch

--   hide grp "storiesMenu"
--end showStoryText



--command showAttribution sAttribution

--   lock screen
--   put  getCache("Attribution") into sAttribution
--   put "(Story - Slideshow)" & cr & cr &sStoryTitle & cr &cr & "by" & cr &cr & sAttribution into fld "homeStoryText"
--   optimizeField sHomeText,34,"center"
--   setCache "storyScene",0
--   unlock screen
--end showAttribution

--command showIsOver

--   # Resent cache, locals and preferences to "nada"
--   hide sStoryImage

--   #wipe locals 
--   put "" into sAttribution
--   put "" into sStoryTitle
--   put "" into sLastScene
--   put "" into sTotalSceneCount

--   # wipe cache
--   setCache "ContentFlag",0
--   setCache "StoryTitle",""
--   setCache "storyScene",""
--   setCache "SceneCount",""
--   setCache "Attribution", ""

--   /*
--   #wipe preferemces
--   setPref "preferences/modules/stories/storyTitle", ""
--   setPref "preferences/modules/stories/storyScene/", ""
--   */

--   # showMenu
--   showStoryMenu

--   --displayCache
--end showIsOver

--command endInTwoScenes
--   if the environment is "development" then
--      if sTotalSceneCount  > 5 then
--         put 6 into sTotalSceneCount
--         setCache "SceneCount",6
--         put 6 into sLastScene
--      end if
--   end if
--end endInTwoScenes




--## we think for following handle my belong to the "model"
--# but this a UI call  to show something in the "view"
--# in MVC architecture, this would be part of a "controller"
--# perhaps this script falls in that category?  

--command loadNewImage pPath
--   # sCardBkgnd,sStoryBkgnd,sStoryImage
--   lock screen for visual effect
--   set the filename of sStoryImage to pPath
--   setImageToFullCardLoc sStoryImage, "portrait", 0,0
--   hide grp "textDisplay"
--   show   sStoryImage --with visual effect "dissolve" 
--   CenterMe sStoryImage
--   unlock screen with visual effect "dissolve" 
--end loadNewImage

--command loadNextQuote pQuoteNo

--   local tControl,tQuoteNo, pField
--   local tSmallText,tTextAlign,tTextSize
--   lock screen for visual effect
--   hide sStoryImage
--   set the itemdel to "|"
--   # random quote
--   put random(the number of items of sQuoteList) into tQuoteNo

--   put item tQuoteNo  of sQuoteList into fld "homeStoryText"

--   if (sStoryTitle = "Vedas") OR (sStoryTitle = "Songs of Tayumanavar") then
--      put 24 into tTextSize
--      put "left" into tTextalign
--   else 
--      put 34 into tTextSize
--      put "center" into tTextalign
--   end if
--   --------

--   optimizeField sHomeText,tTextSize,tTextalign

--   showStoryText "quotes"
--   unlock screen with visual effect "dissolve"  very fast

--end loadNextQuote

--command hideShowField pField,pBool
--   set the vis of pField to pBool
--end hideShowField
