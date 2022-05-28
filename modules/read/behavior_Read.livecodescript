script "behavior_Read"
local sBookNavTree, sTips
local sBooksMetaData, sBookData, sBookLanguage, sBookTitle, sDataLabels


on preOpenStack
   loadBooksMetaData
   set the filename of img "menuImage" of cd "readHome" to \
         (path_Assets()&"img/portal-screens/Iravan-pillars-ceiling_opt-80.jpg")
   initDataLabels
   go cd "readHome"
end preOpenStack


on preOpenCard
   local tCard
   put the short name of this card into tCard
   --
   if tCard is "readHome" then
      hide grp "tipsGroup"
   end if
   --
   setCardCoords "portrait"
   display_SetStatusBarVis true
   if tCard is "readHome" then
      put the long id of widget "bookNavTree" into sBookNavTree
      put the long id of fld "tips" into sTips
      buildBooksMenu
   else if tCard is "bookDetail" then
      put sBookTitle into fld "bookTitle"
      buildBookDetail
   end if
   updateUI
end preopenCard


on closeCard
   local tCard
   put the short name of this card into tCard
   
   --
   portal_SetLastStack "read" 
   --
   if tCard is "readHome" then
      deleteMobileControl "bookNavTree"
   else
      deleteMobileControl "bookDataGroup"
      put empty into fld "bookData"
      put empty into fld "bookTitle"
   end if
end closeCard


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
      put char 3 to -1 of item 1 of tHilitedElement into sBookLanguage
      put char 3 to -1 of item 2 of tHilitedElement into sBookTitle
      put sBooksMetaData[sBookLanguage][sBookTitle] into sBookData
      go cd "bookDetail"
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
   local tCard, tFooter, tControl, tRect, tWidth, tLeft
   local tMenu, tMenuBkgnd, tMenuImage, tGoTips, tGoBack
   local tStoryTextBkg, tGoNext, tGoPrev
   local tProgressTitle
   --
   put the short name of this card into tCard
   --
   put the long id of grp "footerNavigation" into tFooter
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
   if tCard is "readHome" then
      put the long id of img "menuImage" into tMenuImage
      setImageToFullCardLoc tMenuImage, "Portrait"
      --
      --put the long id of btn "back" into tGoBack
      --bottomCenterMe tGoBack,65
      --set the bottom of tGoBack to the top of tFooter - 15
      --
      put the long id of btn "showTips" into tGoTips
      bottomCenterMe tGoTips,30
      set the bottom of tGoTips to the top of tFooter - 18
      --
      --set the rect sTips to (10, 50, cardWidth() - 10, the top of btn "back" - 21)
      --
      set the rect of sBookNavTree to (0, 0, cardWidth() - 24, the top of btn "showTips" - 21)
      set the uRect of sBookNavTree to the rect of sBookNavTree
    
      --
      put the long id of grc "menuBkgnd" into tMenuBkgnd
      set the rect tMenuBkgnd to (0, 75, cardWidth(), the top of btn "showTips" - 9)
      --
      set the rect of sBookNavTree to the rect of tMenuBkgnd
      --
      show grc "footerBackground" of grp "footerNavigation"
   end if
   --
   if tCard is "bookDetail" then
      put the long id of btn "openBook" into tControl
      bottomCenterMe tControl,70
      set the bottom of tControl to the top of tFooter - 18
      --
      put 12 into tLeft
      put CardWidth() - (2 * tLeft) into tWidth
      put the long id of fld "bookTitle" into tControl
      set the width of tControl to tWidth
      set the height of tControl to the formattedHeight of tControl
      topCenterMe tControl, 60
      put the rect of tControl into tRect
      --
      set the rect of grp "bookDataGroup" to (tLeft, (item 4 of tRect) + 18, \
            item 3 of tRect, the top of btn "openBook" - 18)
      set the vScroll of grp "bookDataGroup" to 0
      --
      put the long id of fld "bookData" into tControl
      set the width of tControl to tWidth - 4
      set the height of tControl to the formattedHeight of tControl
      set the top of tControl to (item 4 of tRect) + 18
      set the left of tControl to tLeft
      put the rect of tControl into tRect
      --
      put the rect of grp "bookDataGroup" into tRect
      put the top of fld "bookTitle" - 16 into item 2 of tRect
      set the rect of grc "textBackground" to tRect
      --
      if the height of fld "bookData" > the height of grp "bookDataGroup" then
         dispatch "createScroller" to grp "bookDataGroup" with "bookDataGroup"
      end if
   end if
   --
   if there is a grp "share-ui" then
      set the width of grp "share-ui" to cardWidth()
   end if
end updateUI


command loadBooksMetaData
   local tBooksData, tArray
   put url ("binfile:" & path_Documents()& "modules/read/read.lson") into tBooksData
   if tBooksData is empty then
      put url ("binfile:" & path_Modules()& "read/read.lson") into tBooksData
   end if
   put arrayDecode(tBooksData) into sBooksMetaData
end loadBooksMetaData


command buildBooksMenu
   local tLanguage, tFoldState, tBooksTree
   # load the menu
   # path delimiter is not currently saved with the widget
   set the pathDelimiter of sBookNavTree to "|"
   repeat for each key tKey1 in sBooksMetaData
      put tKey1 into tLanguage
      switch char 1 to 2 of tKey1
         case "En"
            put "1 " before tLanguage
            put false into tFoldState[tLanguage]["folded"]
            break
         default
            put "4 " before tLanguage
      end switch
      repeat for each key tKey2 in sBooksMetaData[tKey1]
         put empty into tBooksTree[tLanguage]["--" & tKey2]
      end repeat -- tKey2
   end repeat -- tKey1
   set the arraydata of sBookNavTree to tBooksTree
   set the foldstate of sBookNavTree to tFoldState
end buildBooksMenu


command buildBookDetail
   local tDetail, tKeyList
   --
   put "sub_title,author,language,sales_blurb,description" into tKeyList
   repeat for each item tKey in tKeyList
      if sBookData[tKey] is not empty then
         put sBookData[tKey] & lf & lf after tDetail
      end if
   end repeat
   --
   put "subject,product_details,publisher,edition,copyright,category" into tKeyList
   repeat for each item tKey in tKeyList
      if sBookData[tKey] is not empty then
         put sDataLabels[tKey] & ":" && sBookData[tKey] & lf & lf after tDetail
      end if
   end repeat
   --
   put tDetail into fld "bookData"
end buildBookDetail


command initDataLabels
   put "Sales Blurb" into sDataLabels["sales_blurb"]
   put "Description" into sDataLabels["description"]
   put "Subject" into sDataLabels["subject"]
   put "Product Details" into sDataLabels["product_details"]
   put "Publisher" into sDataLabels["publisher"]
   put "Edition" into sDataLabels["edition"]
   put "Copyright" into sDataLabels["copyright"]
   put "Categories" into sDataLabels["category"]
   --put "" into sDataLabels[""]
   --put "" into sDataLabels[""]
end initDataLabels


on mouseUp
   local tTarget
   put the short name of the target into tTarget
   switch tTarget
      case "openBook"
         if sBookData["link"]["portal command"] is "portal_GoUrl" then
            portal_GoUrl sBookData["link"]["portal param"]
         end if
         break
      case "backFromTips"
         hide grp "tipsGroup"
         break
      case "showTips"
         set the filename of img "tipsImage" to (path_Assets()&"img/bkgnds/patterns/Blue-Texture-Square.jpg")
         put url ("file:"& path_Modules()& "read/read-user-guide.html") into tTips
         set the htmltext of fld "tips" to tTips 
         dispatch "createscroller" to sTips with "tips"
         show grp "tipsGroup"
         break
         --
   end switch
   
   
end mouseUp


