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
local sAllowLandscape, sStoryMenuTree, sStoryMetaArray

# story control variables, stored cache
# must wipe them on end of story
local  sImageList, sLastImage, sQuoteList, sLastQuote, sLastStory
local sAttribution, sStoryTitle,sLastScene,sTotalSceneCount
local sStoryDataStack

# various screen display options
local sTarget, sTargetOwner

on preOpenStack
   put false into sAllowLandscape
   setupOrientations sAllowLandscape
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
      put the long id of widget "storyNavTree" into sStoryMenu
      put the long id of widget "storyNavTree" into sStoryMenuTree
      put the long id of fld "tips" into sTips
   else if tCard is "showStories" then
      put the long id of img "storyImage" into sStoryImage
      put the long id of fld "storyText" into sStoryText
      put the long id of grc "storyTextBkg" into sStoryTextBkg
      put the long id of fld "captionText" into sCaptionText
      put the long id of img "white-tran.png" into sCaptionBkg
      hide sStoryText
      hide sStoryTextBkg
      hide sCaptionText
      hide sCaptionBkg
   end if
   updateUI
end preopenCard


on opencard
   local tCard, tStoryTree, tGroup, tTitle, tCount, tKeys, tFoldState, tStoryPath
   put the short name of this card into tCard
   
   if tCard is "storyHome" then
      # load the menu
      # path delimiter is not currently saved with the widget
      set the pathDelimiter of sStoryMenuTree to "|"
      repeat for each key tKey1 in sStoriesMetaArray["Stories"]
         put tKey1 into tGroup
         switch char 1 to 2 of tKey1
            case "Sc"
               put "1 " before tGroup
               put false into tFoldState[tGroup]["folded"]
               break
            case "St"
               put "2 " before tGroup
               break
            case "Ar"
               put "3 " before tGroup
               break
            default
               put "4 " before tGroup
         end switch
         repeat for each key tKey2 in sStoriesMetaArray["Stories"][tKey1]
            put empty into tStoryTree[tGroup]["--" & tKey2]
            if sStoriesMetaArray["Stories"][tKey1][tKey2]["where"] = "server" then
               put (path_Documents() & "media/stories/"  & tKey2 & "/" & \
                     tKey2 & ".livecode") into tStoryPath
               if there is no file tStoryPath then
                  put sStoriesMetaArray["Stories"][tKey1][tKey2]["imageSize"] into tStoryTree[tGroup]["--" & tKey2]
               end if
            end if
         end repeat -- tKey2
      end repeat -- tKey1
      set the arraydata of sStoryMenuTree to tStoryTree
      set the foldstate of sStoryMenuTree to tFoldState
      --
      showStoryMenu
   else if tCard is "showStories" then
      --send "goNextScene" to me in 0 milliseconds
   end if
end opencard


command showStoryMenu
   dispatch "deleteMobileControl" to sTips with "tips"
   dispatch "createScroller" to sStoryMenuTree with "storyMenu"
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
         setupOrDownloadStory
         --
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
      case "goPrev"
         if the visible of sStoryText then
            lock screen
            deleteMobileControl "storyText"
            hide sStoryText
            hide sStoryTextBkg
            if the text of sCaptionText is not empty then
               show sCaptionText
               show sCaptionBkg
            end if
            set the blendlevel of sStoryImage to 0
            if sLastScene = 1 then
               hide btn "goPrev"
            end if
            unlock screen
         else
            subtract 2 from sLastScene
            goNextScene
         end if
         break
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

# Tree Widget handler
on hiliteChanged
   local tHilitedElement
   --
   put the hilitedElement of sStoryMenuTree into tHilitedElement
   --
   # need to check at the top of the handler since we manually clear the
   # highlight after it is processed
   if tHilitedElement is empty then exit hiliteChanged
   --
   lock screen
   set the itemdelimiter to "|"
   if the number of items in tHilitedElement = 1 and \
         the hilitedElementIsFolded of sStoryMenuTree then 
      set the foldstate of sStoryMenuTree to empty -- collapse all
   end if
   --
   set the hilitedElementIsFolded of sStoryMenuTree to \
         not the hilitedElementIsFolded of sStoryMenuTree -- doesn't effect a leaf
   unlock screen
   --
   if the number of items in tHilitedElement = 2 then
      put char 3 to -1 of item 2 of tHilitedElement into sStoryTitle
      put sStoriesMetaArray["Stories"][char 3 to -1 of item 1 of tHilitedElement][sStoryTitle] into sStoryMetaArray
      --
      setupOrDownloadStory
      --
      visualArticle
   end if
   --
   # Clear the highlight after it is processed
   set the hilitedElement of sStoryMenuTree to empty
end hiliteChanged

on formattedHeightChanged -- tree changed dimensions
   if the target is sStoryMenuTree then
      dispatch "updateScroller" to sStoryMenuTree with "storyMenu"
   end if
end formattedHeightChanged

on setupOrDownloadStory
   put sStoryMetaArray["where"] into sWhere
   --
   switch sWhere
      case "local"
         put (path_Modules() & "stories/makeStoryLocal.livecode") \
               into sStoryDataStack
         if sLastStory is empty or sLastStory is not sStoryTitle then
            dataLocalStack sStoryTitle
         end if
         put true into sAllowLandscape
         break
      case "server"
         put (path_Documents() & "media/stories/"  & sStoryTitle & "/" & \
               sStoryTitle & ".livecode") into sStoryDataStack
         if there is no file sStoryDataStack then
            local tMsg
            put "This story contains" && sStoryMetaArray["imageSize"] \
                  && "of images.  Once the story is complete" && \
                  "you will have an opportunity to delete the images." && \
                  "Would you like to proceed?" into tMsg
            doAnswer tMsg, "Download,Cancel", "downloadAndShowStory"
            exit to top
         end if
         put true into sAllowLandscape
         break
   end switch
end setupOrDownloadStory

on downloadAndShowStory
   // show a "downloading..." message
   dataServerStack sStoryTitle
   put true into sAllowLandscape
   visualArticle
end downloadAndShowStory

on deleteFinishedStory
   local tStoryPath
   --
   put path_Documents() & "media/stories/" & sStoryTitle into tStoryPath
   deleteFolder tStoryPath
   put empty into sLastStory
   go cd "storyHome"
end deleteFinishedStory

command deleteFolder pFolder
   local tFileList, tFolderList
   --
   put files(pFolder) into tFileList
   filter tFileList without "."
   filter tFileList without ".."
   repeat for each line tFile in tFileList
      delete file pFolder & "/" & tFile
   end repeat
   --
   put folders(pFolder) into tFolderList
   filter tFolderList without ".."
   repeat for each line tFolder in tFolderList
      deleteFolder pFolder & "/" & tFolder
   end repeat
   delete folder pFolder
end deleteFolder

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
   goNextScene
   setupOrientations sAllowLandscape
end visualArticle


command goNextScene
   local tImagePath, tMsg
   --
   lock screen
   if sLastStory is empty or sLastStory is not sStoryTitle then
      if sWhere is "local" then
         put 0 into sLastScene
      else
         put getpref("stories/" & sStoryTitle) into sLastScene
         if sLastScene is a number then
            subtract 1 from sLastScene
         end if
      end if
      put the number of cards in stack sStoryDataStack into sTotalSceneCount
      put sStoryTitle into sLastStory
   end if
   if sTotalSceneCount is not a number then
      put the number of cards in stack sStoryDataStack into sTotalSceneCount
   end if
   if sLastScene is not a number or sLastScene < 1 then
      put 0 into sLastScene
   else if sLastScene >= sTotalSceneCount then
      put 0 into sLastScene
      unlock screen
      if sWhere is "server" then
         setpref "stories/" & sStoryTitle, sLastScene
         put "This is the end of this story.  Would you like to delete the files?" into tMsg
         doAnswer tMsg, "Delete,Cancel", "deleteFinishedStory"
      else
         go cd "storyHome"
      end if
      exit goNextScene
   end if
   --
   add 1 to sLastScene
   if sWhere is "server" then
      setpref "stories/" & sStoryTitle, sLastScene
   end if
   if sLastScene is 1 then
      show sStoryText
      -- once the source stack is redone, will use htmltext on both sides of the set
      set the htmltext of sStoryText to the text of \
            field "mainText" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      show sStoryTextBkg
      hide sCaptionText
      hide sCaptionBkg
      hide btn "goPrev"
   else
      hide sStoryText
      show btn "goPrev"
      show btn "goNext"
      set the htmltext of sStoryText to the htmltext of \
            field "mainText" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      if the text of sStoryText is not empty then
         -- will not be necessary once the source stack is redone
         set the textfont of line 1 to -1 of sStoryText to empty
         set the textsize of line 1 to -1 of sStoryText to empty
         set the foregroundColor of line 1 to -1 of sStoryText to empty
         --
         optimizeTextHeight sStoryText
      end if
      hide sStoryTextBkg
      set the text of sCaptionText to the text of \
            field "Caption" of grp "bkgndControl" of cd sLastScene of stack sStoryDataStack
      if the text of sCaptionText is not empty then
         setupCaptionField
         show sCaptionText
         show sCaptionBkg
      else
         hide sCaptionText
         hide sCaptionBkg
      end if
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

# requires uTextSize custom property to hold the initial text size
command optimizeTextHeight pControl
   local tTextHeight, tMaxHeight, tMinHeight
   local tTextSize
   --
   put the uTextSize of pControl into tTextSize
   if tTextSize is not a number then
      put 18 into tTextSize
   end if
   set the textSize of pControl to tTextSize
   put the formattedHeight of pControl into tTextHeight
   put the height of pControl into tMaxHeight
   put 0.75 * tMaxHeight into tMinHeight
   if tTextHeight < tMinHeight then
      repeat with i=1 to 6
         add 4 to tTextSize
         set the textsize of pControl to tTextSize
         put the formattedHeight of pControl into tTextHeight
         if tTextHeight > tMinHeight then
            if tTextHeight > tMaxHeight then
               set the textsize of pControl to tTextSize - 2
            end if
            exit repeat
         end if
      end repeat
   end if
end optimizeTextHeight


command setupCaptionField
   set the width of sCaptionText to .65 * CardWidth()
   set the height of sCaptionText to the formattedHeight of sCaptionText
   set the width of sCaptionText to the formattedWidth of sCaptionText
   set the bottomRight of sCaptionText to the bottomRight of sStoryText
   set the width of sCaptionBkg to the width of sCaptionText + 60
   set the height of sCaptionBkg to the height of sCaptionText + 60
   set the bottomRight of sCaptionBkg to \
         (the right of sCaptionText + 25, the bottom of sCaptionText + 30)
end setupCaptionField


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
         show btn "goPrev"
         show btn "goNext"
         dispatch "deleteMobileControl" to grp "storyImageGroup" with "storyImageGroup"
      else
         if tState is 3 then
            hide grp "footer"
            hide btn "goPrev"
            hide btn "goNext"
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


command setupOrientations pAllowLandscape
   local tOrientations
   --
   put (pAllowLandscape is true) into sAllowLandscape
   put "portrait,portrait upside down" into tOrientations
   if sAllowLandscape then
      put ",landscape left,landscape right" after tOrientations
   end if
   if isMobile() then
      mobileSetAllowedOrientations tOrientations
   end if
end setupOrientations

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
   put cr&"journalResume"&cr after msg
   put pData["Card"] into tCd
   go to card tCd
   --   put loadStoriesMetadata() into sStoriesMetaArray
   --   getcontent pData["storyTitle"]
   
   --   put getCache("imageList") into simageList
   --   put getCache("Quotes") into sQuoteList
   
   put pData["storyTitle"] into sStoryTitle
   put pData["storyScene"] - 1 into sLastScene
   put pData["Attribution"] into sAttribution
   put pData["SceneCount"] into sTotalSceneCount
   setCache "storyScene",sLastScene
   display_SetStatusBarVis false
   --   showStoryText
   if tCd is "showStories" then
      repeat for each element tElement in sStoriesMetaArray["Stories"]
         if tElement[sStoryTitle] is not empty then
            put tElement[sStoryTitle] into sStoryMetaArray
            exit repeat
         end if
      end repeat
      setupOrDownloadStory
      put sStoryTitle into sLastStory
      visualArticle
   end if
end journalResume


on resizeStack
   -- for development, use screen rotation to quickly get to the end of the story
   add 50 to sLastScene
   --
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack


on updateUI
   local tCard, tFooter, tControl
   local tMenu, tMenuBkgnd, tMenuImage, tGoTips, tGoBack
   local tStoryTextBkg, tGoNext, tGoPrev
   --
   put the short name of this card into tCard
   --
   put the long id of grp "footer" into tFooter
   if currentlyLandscape() then
      hide tFooter
   else
      show tFooter
      send "updateUI" to tFooter
   end if
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
      set the rect of sStoryMenuTree to the rect of tMenuBkgnd
      --
      show grc "footerBackground" of grp "footer"
   end if
   --
   if tCard is "showStories" then
      put the long id of btn "goPrev" into tGoPrev
      put the long id of btn "goNext" into tGoNext
      if currentlyLandscape() then
         bottomLeftMe tGoPrev
         bottomRightMe tGoNext
      else
         topLeftMe tGoPrev
         topRightMe tGoNext
      end if
      --
      set the rect of sStoryText to (10, the bottom of tGoNext + 12, cardWidth() - 10, the top of tFooter - 12)
      set the uRect of sStoryText to the rect of sStoryText
      if the text of sStoryText is not empty then
         optimizeTextHeight sStoryText
         if sStoryText is visible then
            if the formattedHeight of sStoryText > the height of sStoryText then
               dispatch "createScroller" to sStoryText with "storyText"
            else
               deleteMobileControl "storyText"
            end if
         end if
      end if
      --
      set the rect of sCaptionText to the rect of sStoryText
      if the text of sCaptionText is not empty then
         setupCaptionField
      end if
      --
      set the rect of grp "storyImageGroup" to CardRect()
      --
      put the long id of grc "storyTextBkg" into tStoryTextBkg
      set the rect of tStoryTextBkg to CardRect()
      --
      hide grc "footerBackground" of grp "footer"
      resetCycleImage sStoryImage
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
      put false into sAllowLandscape
      setupOrientations sAllowLandscape
   end if
end closecard


on closestack
   portal_SetLastStack "stories" 
end closestack




