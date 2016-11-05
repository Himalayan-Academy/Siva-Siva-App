script "behavior_ViewSivaSivaNavigationBottom"
--> MetaData
-
license: GPLv3
name: behavior_ViewSivaSivaNavigationBottom
type: behavior
version: 0.1


--> Variables
-
local LocalArray


--> Work in Progress
-
getprop bar_Thickness
   return 50
end bar_Thickness

private command _displayMouseUpCommand
   -- should be in an authoring layer
   if the environment is "development" then
      -- put toUpper (char 1 of btnName) into char 1 of btnName -- totally unecessary :)
      replace "-" with space in btnName
      get text_InitialCaps (btnName)
      replace space with empty in it
      put "sivasiva_" & it into mCommand
      
      put "command" && mCommand && "btnObject, hiliteBoolean" into someHandler
      put CR & "    -- code here" after someHandler
      put CR & "end" && mCommand after someHandler
      set the clipboarddata ["text"] to someHandler
      put someHandler
   end if
end _displayMouseUpCommand

command layout_EdgeToEdgeHorizontally innerRect
   -- rough draft
   -- should speed up by looping through the childControl IDs once
   put _viewBackground() into viewBackground
   put the child_Controls of me into iconViews
   put the number of lines of iconViews into iconNum
   
   put item 1 of innerRect into iconLeft
   put item 2 of innerRect into iconTop
   put item 4 of innerRect into iconBottom
   put item 3 of innerRect - iconLeft into innerWidth
   put iconBottom - iconTop into iconWidth
   put innerWidth - (iconNum * iconWidth) into availableWidth
   put availableWidth / (iconNum - 1) into widthSpacing
   
   set the rect of viewBackground to innerRect
   repeat for each line iconView in iconViews
      put iconLeft + iconWidth into iconRight
      put iconLeft,iconTop,iconRight,iconBottom into iconRect
      
      set the rect of iconView to iconRect
      
      put round (iconRight + widthSpacing) into iconLeft
   end repeat
end layout_EdgeToEdgeHorizontally

command layout_SpreadHorizontally pRect
   put the childcontrolids of me into topControlIDs
   if topControlIDs is empty then return 0
   put the number of lines of topControlIDs into numberOfChildren
   
   put the view_Spacing of me into viewSpacing
   put item 3 of pRect - item 1 of pRect into innerWidth
   
   put numberOfChildren - 2 into gutterNum
   put innerWidth - (gutterNum * viewSpacing) into availableWidth
   put round (availableWidth / (numberOfChildren - 1)) into indexWidth
   
   put item 1 of pRect into thisLeft
   repeat with cNum = 1 to numberOfChildren 
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID into childView
      
      if word 1 of childView = "graphic" then
         set the rect of childView to pRect
         next repeat
      end if
      
      put pRect into childRect
      put thisLeft into item 1 of childRect
      put thisLeft + indexWidth into thisRight
      put thisRight into item 3 of childRect
      
      set the rect of childView to childRect
      
      put thisRight + viewSpacing into thisLeft
   end repeat
end layout_SpreadHorizontally


--> Events
-
on mouseDown
   put the long id of the target into btnObject
   put the short name of btnObject into btnName
   switch btnName
      case "bottomTabBkgnd"
         -- do nothing
         break
      default
         set the highlite of btnObject to true
         if the environment is "development" then
            -- put btnName
         end if
   end switch
end mouseDown

on mouseUp pWhichButton
   put the long id of the target into btnObject
   put the short name of btnObject into btnName
   if btnName = "bottomTabBkgnd" then pass mouseUp
   
   put btnName into mCommand
   replace "-" with empty in mCommand
   put "sivasiva_" before mCommand
   
   put the highlite of btnObject into someBoolean
   set the highlite of btnObject to false
   
   dispatch mCommand with btnObject, someBoolean
   switch it
      case "handled"
         break
      case "unhandled"
      default
         -- _displayMouseUpCommand
   end switch
end mouseUp

on resizeControl
   LayoutControl
end resizeControl


--> Props
-
getprop view_Height
   return the height of me
end view_Height

setprop view_Height [pRect] newHeight
   if newHeight is not a number then return empty
   -- could add a minimum
   
   lock screen
   if pRect is empty then
      put the rect of me into pRect
   end if
   
   put rect_GetCentre (pRect) into newCentre
   put item 2 of newCentre into centreY
   
   put round (newHeight/2) into bottomBit
   put newHeight - bottomBit into topBit
   
   put pRect into newRect
   put centreY - topBit into item 2 of newRect
   put centreY + bottomBit into item 4 of newRect
   
   LayoutControl newRect
   unlock screen
end view_Height

getprop view_Margins
   return the margins of me
end view_Margins

setprop view_Margins newMargins
   lock screen
   put the rect of me into oRect
   set the margins of me to newMargins
   LayoutControl oRect
   unlock screen
end view_Margins

getprop stack_Edge
   put LocalArray ["stackEdge"] into stackEdge
   return stackEdge
end stack_Edge

setprop stack_Edge whichEdge
   put the card_Object of me into cardObject
   put the rect of cardObject into cRect
   put the bar_Thickness of me into barThickness
   put cRect into myRect
   
   switch whichEdge
      case "top"
         put item 2 of cRect + barThickness into item 4 of myRect
         put false into LocalArray ["vertical_Layout"]
         break
      case "bottom"
         put item 4 of cRect - barThickness into item 2 of myRect
         put false into LocalArray ["vertical_Layout"]
         break
      case "left"
         put item 1 of cRect + barThickness into item 3 of myRect
         put true into LocalArray ["vertical_Layout"]
         break
      case "right"
         put item 3 of cRect - barThickness into item 1 of myRect
         put true into LocalArray ["vertical_Layout"]
         break
   end switch
   set the rect of me to myRect
   put whichEdge into LocalArray ["stackEdge"]
end stack_Edge

getprop vertical_Layout
   put LocalArray ["vertical_Layout"] is true into someBoolean
   return someBoolean
end vertical_Layout

setprop vertical_Layout someBoolean
   put someBoolean into LocalArray ["vertical_Layout"]
   LayoutControl
end vertical_Layout

getprop background_Colour
   put the backgroundcolor of _viewBackground() into someColour
   return someColour
end background_Colour

setprop background_Colour someColour
   set the backgroundcolor of _viewBackground() to someColour
   set the backgroundcolor of me to someColour
   return someColour
end background_Colour


--> Geometry
-
on LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   put the margins of me into myMargins
   rect_SubtractMargins pRect, myMargins
   
   if the vertical_Layout of me is true then
      layout_Vertically pRect
   else
      layout_EdgeToEdgeHorizontally pRect
   end if
   
   unlock screen
   return numberOfChildren
end LayoutControl

command layout_Vertically pRect
   put the childcontrolids of me into topControlIDs
   if topControlIDs is empty then return 0
   put the number of lines of topControlIDs into numberOfChildren
   
   put the view_Spacing of me into viewSpacing
   put item 4 of pRect - item 2 of pRect into innerHeight
   
   put numberOfChildren - 2 into gutterNum
   put innerHeight - (gutterNum * viewSpacing) into availableHeight
   put round (availableHeight / (numberOfChildren - 1)) into childHeight
   
   put item 2 of pRect into thisTop
   repeat with cNum = 1 to numberOfChildren 
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID into childView
      
      if word 1 of childView = "graphic" then
         set the rect of childView to pRect
         next repeat
      end if
      
      put pRect into childRect
      put thisTop into item 2 of childRect
      put thisTop + childHeight into thisBottom
      put thisBottom into item 4 of childRect
      
      set the rect of childView to childRect
      
      put thisBottom + viewSpacing into thisTop
   end repeat
end layout_Vertically

getprop view_Spacing
   put LocalArray ["viewSpacing"] into someNum
   if someNum is not a number then -- let's set a default
      put 8 into someNum
      put someNum into LocalArray ["viewSpacing"]
   end if
   return someNum
end view_Spacing

setprop view_Spacing someNum
   put someNum into LocalArray ["viewSpacing"]
   LayoutControl
end view_Spacing


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop navigation_View
   return the long id of me
end navigation_View

getprop horizontal_Layout
   return the long id of me
end horizontal_Layout

getprop layout_View
   return the long id of me
end layout_View

getprop view_Background
   return _viewBackground()
end view_Background

private function _viewBackground
   put the long id of graphic "bottomTabBkgnd" of me into viewBackground
   return viewBackground
   
   put the childcontrolids of me into topControlIDs
   repeat for each line topControlID in topControlIDs
      put the long id of control id topControlID into cControl
      if word 1 of cControl = "graphic" then
         return cControl
      end if
   end repeat
   return empty
end _viewBackground


--> Objects | Children
-
getprop child_Views [testViewName]
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID into cControl
      if word 1 of cControl = "graphic" then next repeat
      
      put the view_Name of cControl into viewName
      if testViewName is empty then
         put cControl & CR after childViews
      else if viewName begins with testViewName then
         put cControl & CR after childViews
      end if
   end repeat
   delete char -1 of childViews
   return childViews
end child_Views

getprop child_Controls
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID into cControl
      if word 1 of cControl = "graphic" then next repeat
      put cControl & CR after childViews
   end repeat
   delete char -1 of childViews
   return childViews
end child_Controls

getprop child_Names
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID into cControl
      if word 1 of cControl = "graphic" then next repeat
      
      put the short name of control id topControlID into childName
      put childName & CR after childNames
   end repeat
   delete char -1 of childNames
   return childNames
end child_Names


--> Deps
-
command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end rect_SubtractMargins

command margin_Normalize @someMargin, @leftM, @topM, @rightM, @bottomM
   if the number of items of someMargin < 4 then
      put item 1 of someMargin into defaultMargin
      put defaultMargin into leftM
      
      put item 2 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into topM
      else
         put actualMargin into topM
      end if
      
      put item 3 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into rightM
      else
         put actualMargin into rightM
      end if
      
      put item 4 of someMargin into actualMargin
      if actualMargin is empty then
         put topM into bottomM
      else
         put actualMargin into bottomM
      end if
   else
      put item 1 of someMargin into leftM
      put item 2 of someMargin into topM
      put item 3 of someMargin into rightM
      put item 4 of someMargin into bottomM
   end if
   put leftM,topM,rightM,bottomM into someMargin
end margin_Normalize
