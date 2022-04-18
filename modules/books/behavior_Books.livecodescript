script "behavior_Books"
local sBookNavTree, sTips


on preOpenCard
   local tCard 
   put the short name of this card into tCard
   --
   setCardCoords "portrait"
   display_SetStatusBarVis true
   if tCard is "bookHome" then
      put the long id of widget "bookNavTree" into sBookNavTree
      put the long id of fld "tips" into sTips
   else if tCard is "bookDetail" then
      --      put the long id of img "storyImage" into sStoryImage
      --      put the long id of fld "storyText" into sStoryText
      --      put the long id of grc "storyTextBkg" into sStoryTextBkg
      --      put the long id of fld "captionText" into sCaptionText
      --      put the long id of img "white-tran.png" into sCaptionBkg
      --      hide sStoryText
      --      hide sStoryTextBkg
      --      hide sCaptionText
      --      hide sCaptionBkg
   end if
   updateUI
end preopenCard


# Tree Widget handler
on hiliteChanged
   local tHilitedElement
   --
   put the hilitedElement of sBookNavTree into tHilitedElement
   --
   # need to check at the top of the handler since we manually clear the
   # highlight after it is processed
   if tHilitedElement is empty then exit hiliteChanged
   --
   lock screen
   set the itemdelimiter to "|"
   if the number of items in tHilitedElement = 1 and \
         the hilitedElementIsFolded of sBookNavTree then 
      set the foldstate of sBookNavTree to empty -- collapse all
   end if
   --
   set the hilitedElementIsFolded of sBookNavTree to \
         not the hilitedElementIsFolded of sBookNavTree -- doesn't effect a leaf
   --
   # Clear the highlight after it is processed
   set the hilitedElement of sBookNavTree to empty
   --
   unlock screen
   --
   if the number of items in tHilitedElement = 2 then
      --      put char 3 to -1 of item 2 of tHilitedElement into sStoryTitle
      --      put sStoriesMetaArray["Stories"][char 3 to -1 of item 1 of tHilitedElement][sStoryTitle] into sStoryMetaArray
      --      --
      --      setupOrDownloadStory
      --      --
      --      visualArticle
   end if
end hiliteChanged


on formattedHeightChanged -- tree changed dimensions
   if the target is sBookNavTree then
      dispatch "updateScroller" to sBookNavTree with "storyNavTree"
   end if
end formattedHeightChanged


on resizeStack
   setCardCoords
   updateUI
end resizeStack


on updateUI
   local tCard, tFooter, tControl, tRect
   local tMenu, tMenuBkgnd, tMenuImage, tGoTips, tGoBack
   local tStoryTextBkg, tGoNext, tGoPrev
   local tProgressTitle
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
   if tCard is "bookHome" then
      put the long id of img "menuImage" into tMenuImage
      setImageToFullCardLoc tMenuImage, "Portrait"
      --
      put the long id of btn "back" into tGoBack
      bottomCenterMe tGoBack,65
      set the bottom of tGoBack to the top of tFooter - 15
      --
      put the long id of btn "showTips" into tGoTips
      bottomCenterMe tGoTips,70
      set the bottom of tGoTips to the top of tFooter - 18
      --
      set the rect sTips to (10, 50, cardWidth() - 10, the top of btn "back" - 21)
      --
      set the rect sBookNavTree to (45, 141, cardWidth() - 24, the top of btn "back" - 21)
      set the uRect of sBookNavTree to the rect of sBookNavTree
      --
      put the long id of grc "menuBkgnd" into tMenuBkgnd
      set the rect tMenuBkgnd to (0, 129, cardWidth(), the top of btn "back" - 9)
      --
      set the rect of sBookNavTree to the rect of tMenuBkgnd
      --
      show grc "footerBackground" of grp "footer"
   end if
   --
   if tCard is "bookDetail" then
      
   end if
   --
   --set the width of grp "share-ui" to cardWidth()
end updateUI

