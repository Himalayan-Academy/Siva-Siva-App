script "behavior_ViewSivaSivaLayout"
--> MetaData
-
license: GPLv3
name: behavior_ViewSivaSivaLayout
type: behavior
version: 0.2

--> Variables
-
local LocalArray


--> Events
-
on resizeControl
   LayoutControl
end resizeControl

on preOpenControl
   -- bug: for some reason we occasionally lose references to nested behaviors
   -- here we (re)set them manually when the view is first opened
   -- currently not doing this for the row_View
   breakpoint
   put _scrollingView() into scrollingView
   set the behavior of scrollingView to the behavior of scrollingView
   put _navigationView() into navigationView
   set the behavior of navigationView to the behavior of navigationView
   put _headerView() into headerView
   set the behavior of headerView to the behavior of headerView
end preOpenControl


--> Portal
-
/*
The "set the portal_Name"  functionailty depends on the "portal_GetArray" of "model_SivaSiva".
*/

getprop portal_RowNames
   put the scrolling_View of me into scrollingView
   put the row_Views of scrollingView into rowViews
   repeat for each line rowView in rowViews
      put the row_Name of rowView into rowName
      put rowName & CR after rowNames
   end repeat
   delete char -1 of rowNames
   return rowNames
end portal_RowNames

setprop portal_RowNames [headerName] rowNames
   replace comma with CR in rowNames
   put the scrolling_View of me into scrollingView
   -- put view_GetTemplateObject ("View|SivaSiva|Contents|Row") into rowTemplate
   put the row_View [2] of scrollingView into rowTemplate
   
   lock screen
   if headerName is not empty then
      set the portal_Header of _headerView() to headerName
   end if
   
   set the vScroll of scrollingView to 0 -- ensures correct initial alignment
   put the number of lines of rowNames into maxRowNum
   set the row_Number [rowTemplate] of scrollingView to (maxRowNum + 1)
   repeat with rowNum = 1 to maxRowNum
      put the row_View [rowNum] of scrollingView into rowView
      put line rowNum of rowNames into rowName
      set the row_Name of rowView to rowName
   end repeat
   unlock screen
end portal_RowNames

getprop portal_Array
   put _scrollingView() into scrollingView
   put the row_Views of scrollingView into rowViews
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
      display_ExecutionContexts
      exit to top
   end if
   
   put _scrollingView() into scrollingView
   put _headerView() into headerView
   put the row_View [2] of scrollingView into rowTemplate
   
   lock screen
   put portalArray ["portalName"] into portalName
   set the portal_Header of headerView to portalName
   
   put portalArray ["rowData"] into portalRowData
   set the vScroll of scrollingView to 0
   if pForceRefresh is true then
      -- slows things. Only needed if we are switching view types (like adding a grid)
      set the row_Number of me to 1
   end if
   put (item 2 of the extents of portalRowData) + 1 into maxRowNum
   set the row_Number [rowTemplate] of scrollingView to maxRowNum
   repeat for each key rowNum in portalRowData
      put portalRowData [rowNum] into rowData
      put the row_View [rowNum] of scrollingView into rowView
      put rowData ["rowName"] into rowName
      set the row_Name of rowView to rowName
   end repeat
   unlock screen
end portal_Array

getprop portal_Name
   put the portal_Name of me into portalName
   if portalName is empty then put "home" into portalName
   return portalName
end portal_Name

setprop portal_Name portalName  
   put portal_GetArray (portalName) into portalArray
   set the portal_Array of me to portalArray
end portal_Name

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


--> Props
-
getprop logo_Faded
   if the long id of me is not the long id of the target then pass logo_Faded
   put _headerView() into headerView
   if exists (headerView) is false then return empty
   put the logo_Faded of headerView into someBoolean
   return someBoolean
end logo_Faded

setprop logo_Faded someBoolean
   if the long id of me is not the long id of the target then pass logo_Faded
   put _headerView() into headerView
   if exists (headerView) is false then return false
   set the logo_Faded of headerView to someBoolean
   return true
end logo_Faded

getprop background_Transparent
   put the showBorder of me into someBoolean
   return someBoolean
end background_Transparent

setprop background_Transparent someBoolean
   if the long id of the target is not the long id of me then pass background_Transparent
   lock screen
   set the showBorder of me to someBoolean
   set the opaque of me to someBoolean
   set the background_Transparent of _scrollingView() to (not someBoolean)
   unlock screen
end background_Transparent


--> Object
-
getprop portal_View
   return the long id of me
end portal_View

getprop layout_View
   return the long id of me
end layout_View

getprop view_Object
   return the long id of me
end view_Object


--> Object | Children
-
getprop scrolling_View
   return _scrollingView()
end scrolling_View

getprop navigation_View
   return _navigationView()
end navigation_View

getprop header_View
   -- a child of a child
   if the long id of me is not the long id of the target then pass header_View
   return _headerView()
end header_View

private function _headerView
   put the scrolling_View of me into scrollingView
   put the header_View of scrollingView into headerView
   return headerView
end _headerView

private function _scrollingView
   return the long id of control "SivaSiva Portal Scrolling" of me
end _scrollingView

private function _navigationView
   return the long id of control "SivaSiva Portal Navigation" of me
end _navigationView


--> Geometry
-
on LayoutControl pRect
   local FixedWidth = 414
   local FixedHeight = 736
   local NavHeight = 50
   
   if pRect is empty then put the rect of me into pRect
   
   put _scrollingView() into scrollingView
   put _navigationView() into navigationView
   
   put item 1 of pRect into layoutLeft
   put item 2 of pRect into layoutTop
   put layoutLeft + FixedWidth into layoutRight
   put layoutTop + FixedHeight into layoutBottom
   put rect_GetCentre (pRect) into layoutCentre
   
   put pRect into layoutRect
   put layoutRight into item 3 of layoutRect
   put layoutBottom into item 4 of layoutRect
   
   put pRect into scrollingRect
   put layoutRight into item 3 of scrollingRect
   put layoutTop + 680 into scrollingBottom
   put scrollingBottom into item 4 of scrollingRect
   
   put pRect into navigationRect
   put layoutRight into item 3 of navigationRect
   put layoutTop + FixedHeight - NavHeight into item 2 of navigationRect
   put layoutBottom into item 4 of navigationRect
   
   lock screen
   set the rect of scrollingView to scrollingRect
   set the rect of navigationView to navigationRect
   set the rect of me to layoutRect
   set the loc of me to layoutCentre 
   unlock screen
end LayoutControl

