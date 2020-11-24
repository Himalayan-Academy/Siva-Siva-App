script "behavior_Stories" with behavior "model_Stories"

/* 
This script  is the behavior  stack "modules/stories.livecode"
It is nested under a parent behavior: behavior "model_Stories"
Revised 2020-01-15
Revised 2020-10-01
*/


global sConfigA, sDefaultImage,
local sStoriesMetaArray,sWhere  # get the metadata for each story; and parameters

# geometry vars
local sStoryMenu, sTips, sStoryImage, sStoryText, sStoryTextBkg

# story control variables, stored cache
# must wipe them on end of story
local  sImageList, sLastImage, sQuoteList, sLastQuote, sLastStory
local sAttribution, sStoryTitle,sLastScene,sTotalSceneCount
local sStoryDataStack

# various screen display options
local sTarget, sTargetOwner

on preopenstack
   put loadStoriesMetadata() into sStoriesMetaArray
   go cd "storyHome"
end preopenstack


/* Per Card Layout and UI

Summary: We are putting layout of UI here
Based on the card name

*/

on preOpenCard
   local tCard 
   put the short name of this card into tCard
   --
   if the logMessage <> empty then
      copyLogControl
   end if
   setCardCoords "portrait"
   if tCard is "storyHome" then
      put the long id of fld "storyMenu" into sStoryMenu
      put the long id of fld "tips" into sTips
   else if tCard is "showStories" then
      put the long id of image "storyImage" into sStoryImage
      put the long id of fld "storyText" into sStoryText
      put the long id of grc "storyTextBkg" into sStoryTextBkg
      updateUI
   end if
end preopenCard

on opencard
   local tCard 
   put the short name of this card into tCard
   
   if tCard is "storyHome" then
      # load the menu in any case:
      put the keys of sStoriesMetaArray["Stories"] into fld "storyMenu"
      showStoryMenu
   else if tCard is "showStories" then
      send "goNextScene" to me in 0 milliseconds
   end if
end opencard

command showStoryMenu
   dispatch "deleteMobileControl" to sTips with "tips"
   dispatch "createScroller" to sStoryMenu with "storyMenu"
   set the filename of img "menuImage" of cd "storyHome" to (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
   hide grp "tips" of cd "storyHome"
   show grp "storyMenu" of cd "storyHome"
   display_SetStatusBarVis true
end showStoryMenu 

/*
UX for user for the stack and cardi
*/
on mouseup
   local tTips
   
   put the short name of the owner of the target into sTargetOwner
   put the short name of the target into sTarget
   put loadStoriesMetadata() into sStoriesMetaArray
   
   switch sTarget
      case "storyMenu"
         put value(clickLine() ) into sStoryTitle
         if sStoryTitle is empty then exit mouseup
         
         put sStoriesMetaArray["Stories"][sStoryTitle]["where"] into sWhere
         
         switch sWhere
            case "local"
               put (path_Modules() & "stories/makeStoryLocal.livecode") \
                     into sStoryDataStack
               dataLocalStack sStoryTitle
               break
            case "server"
               put (path_Documents() & "media/stories/"  & sStoryTitle & "/" & \
                     sStoryTitle & ".livecode") into sStoryDataStack
               if not exists(stack sStoryDataStack) then
                  
                  // answer the questions:
                  --      "There are XX metabytes of images. Shall we download them?
                  --      You have a chance to get rid of them. Or save to your phone.
                  --       You will go back and finish up the story."
                  --  No | Yes
                  --      if it is "No" then don't
                  --      (exit mouseUp)
                  
                  // show a "downloading..." message
                  dataServerStack sStoryTitle
               end if
               break
         end switch
         
         # development
         visualArticle
         
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
         
      case "storyImage"
         if not (the visible of sStoryText) then
            cycleImageState sStoryImage
         end if
         break
      case "goNext"
         if the visible of sStoryText or the text of sStoryText is empty then
            goNextScene
         else
            lock screen
            show sStoryText
            show sStoryTextBkg
            unlock screen
         end if
         break
   end switch
   
end mouseup

#development
command visualArticle
   open stack sStoryDataStack
   --
   go card "showStories" of stack "stories"
end visualArticle

command goNextScene
   local tImagePath
   --
   lock screen
   if sLastStory is empty or sLastStory is not sStoryTitle then
      put 0 into sLastScene
      put the number of cards in stack sStoryDataStack into sTotalSceneCount
      put sStoryTitle into sLastStory
   end if
   if sTotalSceneCount is not a number then
      put the number of cards in stack sStoryDataStack into sTotalSceneCount
   end if
   if sLastScene is not a number or sLastScene < 1 then
      put 0 into sLastScene
   else if sLastScene = sTotalSceneCount then
      -- hide "next" button
   else if sLastScene >= sTotalSceneCount then
      -- end of show handling needs to go here
      put 0 into sLastScene
      unlock screen
      exit goNextScene
   end if
   --
   add 1 to sLastScene
   if sLastScene is 1 then
      show sStoryText
      set the htmltext of sStoryText to the text of \
            field "mainText" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      show sStoryTextBkg
      -- hide caption
      -- hide "show caption" button
      -- hide "previous" button
   else
      hide sStoryText
      set the text of sStoryText to the text of \
            field "mainText" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      hide sStoryTextBkg
      -- set caption text
      -- if caption text not empty, show caption
      -- hide "show caption" button
   end if
   put the filename of image "slideImage" of cd sLastScene of stack sStoryDataStack into tImagePath
   if sWhere is "local" then
      if tImagePath is empty then
         put "../../assets/img/bkgnds/patterns/M09-Bkgrd-SYM-Sun-moon_opt-30.jpg" into tImagePath
      end if
      set the filename of sStoryImage to tImagePath
   else
      set the itemdel to "/"
      set the filename of sStoryImage to item 1 to -2 of sStoryDataStack & "/" & tImagePath
   end if
   initializeCycleImage sStoryImage
   --
   unlock screen
end goNextScene

-------
local pData,  tCd,  

command addJournalEntry -- save a bookmark to db
   local tTitle
   if (sStoryTitle is "false") OR (sStorytitle is empty) then 
      put "Main Menu" into tTitle
      put "storyHome" into pData["card"]
   else 
      put sStoryTitle into pData["storyTitle"]
      put sLastScene into pData["storyScene"]
      put sAttribution into pData["Attribution"]
      put sTotalSceneCount into pData["SceneCount"]
      put "showStories" into pData["card"]
   end if
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
   local tCard, tFooter, tControl
   local tMenu, tMenuBkgnd, tMenuImage, tGoTips, tGoBack
   local tStoryTextBkg, tGoNext
   --
   put the short name of this card into tCard
   --
   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
   end if
   --
   if tCard is "storyMenu" then
      --      put the long id of grp "storyMenu" into tMenu
      --      topcenterMe tMenu,120
      --
      --      put the long id of img "menuBkgnd" into tMenuBkgnd
      --      CenterMe tMenuBkgnd
      --
      --      put the long id of img "menuImage" into tMenuImage
      --      CenterMe tMenuImage
      --
      put the long id of btn "back" into tGoBack
      bottomCenterMe tGoBack,65
      --
      put the long id of btn "tips" into tGoTips
      bottomCenterMe tGoTips,70
      --
      set the rect sTips to (10, 50, cardWidth() - 10, the top of btn "back" - 21)
      --
      set the rect sStoryMenu to (32, 50, cardWidth() - 32, the top of btn "back" - 21)
      set the uRect of sStoryMenu to the rect of sStoryMenu
      --
      show grc "footerBackground" of grp "footer"
   end if
   --
   if tCard is "showStories" then
      put the long id of widget "goNext" into tGoNext
      bottomCenterMe tGoNext,65
      --
      set the rect of sStoryText to (10, 50, cardWidth() - 10, the top of tGoNext - 21)
      --
      put the long id of grc "storyTextBkg" into tStoryTextBkg
      set the rect of tStoryTextBkg to CardRect()
      --
      hide grc "footerBackground" of grp "footer"
   end if
   --
   put the long id of grp "footer" into tFooter
   send "updateUI" to tFooter
end updateUI

on closeCard
   local tCard 
   put the short name of this card into tCard
   --
   if tCard is "storyHome" then
      set the filename of img "menuImage" of cd "storyHome" to \
            (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
      hide grp "tips" of cd "storyHome"
      show grp "storyMenu" of cd "storyHome"
   else if tCard is "showStories" then
      put empty into fld "storyText"
      set the filename of sStoryImage to "../../assets/img/bkgnds/patterns/M09-Bkgrd-SYM-Sun-moon_opt-30.jpg"
      close stack sStoryDataStack
      hide sStoryText
      hide sStoryTextBkg
      show grc "footerBackground" of grp "footer"
   end if
end closecard

on closestack  
   portal_SetLastStack "stories" 
end closestack




