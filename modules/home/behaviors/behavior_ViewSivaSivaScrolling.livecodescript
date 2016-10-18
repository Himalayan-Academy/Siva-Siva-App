script "behavior_ViewSivaSivaScrolling"
--> MetaData
-
license: GPLv3
name: behavior_ViewSivaSivaScrolling
type: behavior
version: 0.2
deps: function portal_GetArray

/*
Cloned and customised many of the LayoutControl handlers from "behavior_ViewLayoutVertical"
The "behavior_ViewLayoutVertical" behavior can be added to add some extra functionality.
But it should work without "behavior_ViewLayoutVertical"

*/


--> Variables
-
local sMouseLoc, sStartLoc,sBlendLevel,sTargetOwner,sTargetModule,sTargetAction
local LocalArray


--> Working on
-
command portal_Navigate portalName
   if portalName is empty then
      answer "Portal name is empty"
      breakpoint
   else
      set the portal_Name of me to portalName
   end if
end portal_Navigate


--> Events
-
on mouseUp
   put the portal_Row of the target into portalRow
   switch
      case _mouseMoved() is true
         -- answer "Has scrolled"
         break
      case portalRow is empty
         -- answer "Not a row"
         break
      default
         -- answer "User tapped"
         put the row_Name of the target into portalName
         portal_Navigate portalName
   end switch
end  mouseup

on setScroll
   if the mouse is down then
      lock screen
      if item 2 of sMouseLoc > the mouseV then
         set the vscroll of me to the vscroll of me - (the mouseV - item 2 of sMouseLoc)
      else
         set the vscroll of me to the vscroll of me + (item 2 of sMouseLoc - the mouseV)
      end if
      put the mouseloc into sMouseLoc
      send "setScroll" to me in 20 millisec
      unlock screen
   else
      put empty into sMouseLoc
   end if
end setScroll

on mouseDown
   put the mouseloc into sMouseLoc
   put sMouseLoc into sStartLoc
   if the environment is not "mobile" then
      -- mobile will use stack handlers to scroll instead
      setScroll
   end if
end mouseDown

on touchStart pID
   -- using touch msgs on android, because something is blocking mouseUps when scroller is active;
   mouseDown
end touchStart

on touchEnd pID
   -- using touch msgs on android, because something is blocking mouseUps when scroller is active;
   mouseUp
end touchEnd

on resizeControl
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl


--> Geometry
-
on LayoutControl pRect
   -- for portal view with fixed header and row height
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   -- put the effective height of _headerView() into FirstHeight
   put 288 into FirstHeight
   -- put the effective height of control id topControlID into RowHeight
   put 122 into RowHeight
   
   put the view_Spacing of me into viewSpacing
   put item 2 of pRect into childTop
   
   put the childcontrolids of me into topControlIDs
   if topControlIDs is empty then return empty
   
   put line 1 of topControlIDs into headerID
   delete line 1 of topControlIDs
   
   -- set header height
   put childTop + FirstHeight into childBottom
   put pRect into childRect
   put childTop into item 2 of childRect
   put childBottom into item 4 of childRect
   --
   set the rect of control id headerID to childRect
   
   -- now set row heights
   put childBottom + viewSpacing into childTop
   repeat for each line topControlID in topControlIDs      
      put childTop + RowHeight into childBottom
      
      put pRect into childRect
      put childTop into item 2 of childRect
      put childBottom into item 4 of childRect
      --
      set the rect of control id topControlID to childRect
      
      put childBottom + viewSpacing into childTop
   end repeat
   unlock screen
end LayoutControl

private function _mouseMoved
   put abs (the mouseV - item 2 of sStartLoc) into someDistance
   put someDistance >= 10 into someBoolean
   return someBoolean
end _mouseMoved


--> Portal
-
/*
The "set the portal_Name"  functionailty depends on the "portal_GetArray" of "model_SivaSiva".
*/

getprop portal_Name
   put LocalArray ["portalName"] into portalName
   if portalName is empty then put "home" into portalName
   return portalName
end portal_Name

setprop portal_Name portalName
   put portalName into LocalArray ["portalName"]
   put portal_GetArray (portalName) into portalArray
   set the portal_Array of me to portalArray
   return the result
end portal_Name

getprop portal_Array
   put the row_Views of me into rowViews
   repeat with indexNum = 1 to the number of lines of rowViews
      put line indexNum of rowViews into rowView
      put the row_Data of rowView into rowData
      put rowData into portalArray [indexNum]
   end repeat
   return portalArray   
end portal_Array

setprop portal_Array [pForceRefresh] portalArray  
   if portalArray is not an array then
      answer warning "portal_Array is not an array!"
      exit to top
   end if
   
   lock screen
   set the vScroll of me to 0 -- ensures correct initial alignment
   
   put portalArray ["portalName"] into portalName
   put portalArray ["rowData"] into portalRowData
   
   put portalArray ["headerImage"] into shortHeaderFile
   set the portal_ShortHeaderFile of _headerView() to shortHeaderFile
   set the portal_Header of _headerView() to portalName
   
   if pForceRefresh is true then
      -- slows things. Only needed if we are switching view types (like adding a grid)
      set the row_Number of me to 1
   end if
   
   put item 2 of the extents of portalRowData into rowNum
   put _rowTemplate() into rowTemplate
   
   set the row_Number [rowTemplate] of me to rowNum
   
   repeat for each key rowNum in portalRowData
      put portalRowData [rowNum] into rowData
      put the row_View [rowNum] of me into rowView
      if exists (rowView) is false then next repeat
      
      put rowData ["rowName"] into rowName
      set the row_Name of rowView to rowName
   end repeat
   unlock screen
end portal_Array

getprop portal_Header
   if the long id of the target is not the long id of me then pass portal_Header
   put the portal_Header of _headerView() into moduleStackName
   return moduleStackName
end portal_Header

setprop portal_Header moduleStackName
   if the long id of the target is not the long id of me then pass portal_Header
   set the portal_Header of _headerView() to moduleStackName
   put the result into headerView
   return headerView
end portal_Header

getprop row_Number
   put the childControlIDs of me into someIDs
   put the number of lines of someIDs into numberOfRows
   return numberOfRows
end row_Number

setprop row_Number [cloneObject] rowNum
   lock screen
   put the childControlIDs of me into someIDs
   put the number of lines of someIDs into maxNum
   switch
      case rowNum > maxNum
         put line maxNum of someIDs into lastID
         if exists (cloneObject) is false then 
            put the long id of control id lastID into cloneObject
         end if
         repeat (rowNum - maxNum)
            -- clone only works if already in the group
            copy cloneObject to me
            put it into createdObject
         end repeat
         break
      case rowNum < maxNum
         put rowNum + 1 into toRowNum
         repeat with lineNum = maxNum down to toRowNum
            put line lineNum of someIDs into someID
            put the long id of control id someID into topObject
            delete topObject
         end repeat
         break
      default
         -- nothing to do
   end switch
   LayoutControl
   unlock screen
end row_Number


--> Props
-
getprop background_Transparent
   put not the opaque of me into someBoolean
   return someBoolean
end background_Transparent

setprop background_Transparent someBoolean
   lock screen
   put not someBoolean into isOpaque
   set the opaque of me to isOpaque
   
   put the childControlIds of me into idIndex
   repeat for each line someID in idIndex
      put the long id of control id someID of me into rowView
      set the opaque of rowView to isOpaque
   end repeat
   unlock screen
   return idIndex
end background_Transparent

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


--> Props
-
getprop title_Text
   put _headerView() into headerView
   put the text of fld 1 of headerView into titleText
   return titleText
end title_Text

setprop title_Text titleText
   put toUpper (titleText) into titleText
   put _headerView() into headerView
   set the text of fld 1 of headerView to titleText
   return headerView
end title_Text

getprop header_File
   put _headerView() into headerView
   put the image_File of headerView into imageFile
   return imageFile
end header_File

getprop image_File [rowNum] 
   put the row_View [rowNum] of me into rowView
   put the image_File of rowView into imageFile
   return imageFile
end image_File


--> Objects
-
getprop scrolling_View
   return the long id of me
end scrolling_View

getprop layout_Object
   return the long id of me
end layout_Object

getprop view_Object
   return the long id of me
end view_Object


--> Objects | Children
-
getprop row_Views
   put the childControlIds of me into idIndex
   delete line 1 of idIndex
   repeat for each line someID in idIndex
      put the long id of control id someID of me & CR after rowViews
   end repeat
   delete char -1 of rowViews
   return rowViews
end row_Views

getprop row_View [rowNum]
   if rowNum is empty then put 1 into rowNum
   put _rowView (rowNum) into rowView
   return rowView
end row_View

getprop header_View
   put _headerView() into headerView
   return headerView
end header_View

private function _headerView
   -- put the long id of group "Portal Image Header" of me into headerView
   -- return headerView
   
   -- this is more robust when we have the layout finished
   put the childControlIDs of me into idIndex
   put line 1 of idIndex into rowID
   put the long id of control id rowID of me into headerView
   return headerView
end _headerView

private function _rowView rowNum
   put the childControlIDs of me into idIndex
   put line (rowNum + 1) of idIndex into rowID
   if rowID is empty then return empty
   return the long id of control id rowID of me
end _rowView

private function _rowTemplate
   put _rowView (2) into rowTemplate
   return rowTemplate
   
   /*
   -- these handlers are for a template in a separate stack (used in authoring)
   put "View|SivaSiva|Contents|Row" into viewName
   put view_GetTemplateObject (viewName) into rowTemplate
   put the long id of control 1 of stack viewName into rowTemplate
   return rowTemplate
   */
end _rowTemplate
