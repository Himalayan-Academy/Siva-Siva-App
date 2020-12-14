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
local sStoryMenu, sTips, sStoryImage, sStoryText, sStoryTextBkg, sCaptionText, sCaptionBkg

# story control variables, stored cache
# must wipe them on end of story
local  sImageList, sLastImage, sQuoteList, sLastQuote, sLastStory
local sAttribution, sStoryTitle,sLastScene,sTotalSceneCount
local sStoryDataStack

# various screen display options
local sTarget, sTargetOwner

on preOpenStack
   put loadStoriesMetadata() into sStoriesMetaArray
   set the filename of img "menuImage" of cd "storyHome" to \
         (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
   go cd "storyHome"
end preOpenStack


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
      put the long id of img "storyImage" into sStoryImage
      put the long id of fld "storyText" into sStoryText
      put the long id of grc "storyTextBkg" into sStoryTextBkg
      put the long id of fld "captionText" into sCaptionText
      put the long id of img "white-feathered-rect" into sCaptionBkg
   end if
   updateUI
end preopenCard


on opencard
   local tCard, tLineNum
   put the short name of this card into tCard
   
   if tCard is "storyHome" then
      # load the menu in any case:
      put the keys of sStoriesMetaArray["Stories"] into fld "storyMenu"
      put 0 into tLineNum
      repeat for each line tLine in fld "storyMenu"
         add 1 to tLineNum
         if sStoriesMetaArray["Stories"][tLine]["where"] = "server" then
            set the foregroundColor of line tLineNum of fld "storyMenu" to yellow
         end if
      end repeat
      showStoryMenu
   else if tCard is "showStories" then
      send "goNextScene" to me in 0 milliseconds
   end if
end opencard


command showStoryMenu
   dispatch "deleteMobileControl" to sTips with "tips"
   dispatch "createScroller" to sStoryMenu with "storyMenu"
   set the filename of img "menuImage" of cd "storyHome" to \
         (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
   hide grp "tips" of cd "storyHome"
   show grp "storyMenu" of cd "storyHome"
   display_SetStatusBarVis true
end showStoryMenu 


/*
UX for user for the stack and cardi
*/
on mouseup
   local tTips
   --
   put the short name of the owner of the target into sTargetOwner
   put the short name of the target into sTarget
   put loadStoriesMetadata() into sStoriesMetaArray
   --
   switch sTarget
      case "storyMenu"
         put value(clickLine() ) into sStoryTitle
         if sStoryTitle is empty then exit mouseup
         --
         put sStoriesMetaArray["Stories"][sStoryTitle]["where"] into sWhere
         --
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
                  local tMsg
                  put "This story contains" && sStoriesMetaArray["Stories"][sStoryTitle]["imageDate"] \
                        && "of images.  Once the story is complete" && \
                        "you will have an opportunity to delete the images." && \
                        "Would you like to proceed?" into tMsg
                  doAnswer tMsg, "Download,Cancel", "downloadAndShowStory"
                  exit mouseUp
               end if
               break
         end switch
         --
         # development
         visualArticle
         break
         --
      case "tips"
         set the filename of img "tipsImage" to (path_Assets()&"img/bkgnds/patterns/Blue-Texture-Square.jpg")
         put url ("file:"& path_Modules()& "stories/stories-user-guide.html") into tTips
         set the htmltext of fld "tips" to tTips 
         dispatch "createscroller" to sTips with "tips"
         show grp "tips"
         break
         --
      case "back"
         dispatch "deleteMobileControl" to sTips with "tips"
         hide grp "tips"
         break
         --
      case "showStories"
      case "storyImage"
      case "captionText"
      case "white-feathered-rect"
         updateImageState
         break
         --
      case "goNext"
         if the visible of sStoryText or the text of sStoryText is empty then
            deleteMobileControl "storyText"
            goNextScene
         else
            lock screen
            show sStoryText
            show sStoryTextBkg
            hide sCaptionText
            hide sCaptionBkg
            if the formattedHeight of sStoryText > the height of sStoryText then
               dispatch "createScroller" to sStoryText with "storyText"
            end if
            set the blendlevel of sStoryImage to 15
            unlock screen
         end if
         break
   end switch
end mouseup

on downloadAndShowStory
   // show a "downloading..." message
   dataServerStack sStoryTitle
   visualArticle
end downloadAndShowStory

on doScrollerTap
   put the short name of the target into sTarget
   --
   switch sTarget
      case "storyImage"
         updateImageState
         break
      case "storyText"
         --
         break
   end switch
end doScrollerTap


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
      -- once the source stack is redone, will use htmltext on both sides of the set
      set the htmltext of sStoryText to the text of \
            field "mainText" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      show sStoryTextBkg
      hide sCaptionText
      hide sCaptionBkg
      -- hide "previous" button
   else
      hide sStoryText
      set the htmltext of sStoryText to the htmltext of \
            field "mainText" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      -- will not be necessary once the source stack is redone
      if the text of sStoryText is not empty then
         set the textfont of line 1 to -1 of sStoryText to empty
         set the textsize of line 1 to -1 of sStoryText to empty
         set the foregroundColor of line 1 to -1 of sStoryText to empty
         set the backgroundColor of line 1 to -1 of sStoryText to empty -- seems to have no effect
      end if
      hide sStoryTextBkg
      set the text of sCaptionText to the text of \
            field "Caption" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      if the text of sCaptionText is not empty then
         set the width of sCaptionText to .65 * CardWidth()
         set the height of sCaptionText to the formattedHeight of sCaptionText
         set the width of sCaptionText to the formattedWidth of sCaptionText
         set the bottomRight of sCaptionText to the bottomRight of sStoryText
         set the width of sCaptionBkg to the width of sCaptionText + 60
         set the height of sCaptionBkg to the height of sCaptionText + 60
         set the bottomRight of sCaptionBkg to \
               (the right of sCaptionText + 25, the bottom of sCaptionText + 30)
         show sCaptionText
         show sCaptionBkg
      else
         hide sCaptionText
         hide sCaptionBkg
      end if
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
   set the blendlevel of sStoryImage to 0
   initializeCycleImage sStoryImage
   --
   unlock screen
end goNextScene


command updateImageState
   local tState
   if not (the visible of sStoryText) then
      cycleImageState sStoryImage
      put the result into tState
      if tState is 1 then
         if the text of sCaptionText is not empty then
            show sCaptionText
            show sCaptionBkg
         end if
         show grp "footer"
         show widget "goNext"
         dispatch "deleteMobileControl" to grp "storyImageGroup" with "storyImageGroup"
      else
         if tState is 3 then
            hide grp "footer"
            hide widget "goNext"
            set the hscroll of grp "storyImageGroup" to 0
            set the vscroll of grp "storyImageGroup" to 0
            set the topLeft of sStoryImage to 0,0
            dispatch "createImageScroller" to grp "storyImageGroup" with "storyImageGroup"
         end if
         hide sCaptionText
         hide sCaptionBkg
      end if
   end if
end updateImageState


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
   put the long id of grp "footer" into tFooter
   send "updateUI" to tFooter
   --
   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
   end if
   --
   if tCard is "storyHome" then
      put the long id of img "menuImage" into tMenuImage
      setImageToFullCardLoc tMenuImage, "Portrait"
      --
      put the long id of btn "back" into tGoBack
      bottomCenterMe tGoBack,65
      set the bottom of tGoBack to the top of tFooter - 15
      --
      put the long id of btn "tips" into tGoTips
      bottomCenterMe tGoTips,70
      set the bottom of tGoTips to the top of tFooter - 18
      --
      set the rect sTips to (10, 50, cardWidth() - 10, the top of btn "back" - 21)
      --
      set the rect sStoryMenu to (45, 141, cardWidth() - 24, the top of btn "back" - 21)
      set the uRect of sStoryMenu to the rect of sStoryMenu
      --
      put the long id of grc "menuBkgnd" into tMenuBkgnd
      set the rect tMenuBkgnd to (0, 129, cardWidth(), the top of btn "back" - 9)
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
      set the rect of sCaptionText to the rect of sStoryText
      --
      set the rect of grp "storyImageGroup" to CardRect()
      --
      put the long id of grc "storyTextBkg" into tStoryTextBkg
      set the rect of tStoryTextBkg to CardRect()
      --
      hide grc "footerBackground" of grp "footer"
   end if
   --
   set the width of grp "share-ui" to cardWidth()
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
      deleteMobileControl "storyMenu"
   else if tCard is "showStories" then
      set the text of sStoryText to empty
      set the text of sCaptionText to empty
      set the filename of sStoryImage to "../../assets/img/bkgnds/patterns/M09-Bkgrd-SYM-Sun-moon_opt-30.jpg"
      close stack sStoryDataStack
      hide sStoryText
      hide sStoryTextBkg
      hide sCaptionText
      hide sCaptionBkg
      show grc "footerBackground" of grp "footer"
   end if
end closecard


on closestack
   portal_SetLastStack "stories" 
end closestack




