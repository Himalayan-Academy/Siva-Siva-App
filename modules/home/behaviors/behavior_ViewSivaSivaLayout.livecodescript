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


--> Data
-
getprop portal_Name
   if the long id of me is not the long id of the target then pass portal_Name
   put the scrolling_View of me into scrollingView
   put the portal_Name of scrollingView into portalName
   return portalName
end portal_Name

setprop portal_Name portalName
   if the long id of me is not the long id of the target then pass portal_Name
   put the scrolling_View of me into scrollingView
   set the portal_Name of scrollingView to portalName
   return the result
end portal_Name

getprop logo_Faded
   if the long id of me is not the long id of the target then pass logo_Faded
   put the header_View of me into headerView
   put the logo_Faded of headerView into someBoolean
   return someBoolean
end logo_Faded

setprop logo_Faded someBoolean
   if the long id of me is not the long id of the target then pass logo_Faded
   put the header_View of me into headerView
   set the logo_Faded of headerView to someBoolean
   return the result
end logo_Faded


--> Props
-
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
   put the scrolling_View of me into scrollingView
   put the header_View of scrollingView into headerView
   return headerView
end header_View

private function _scrollingView
   return the long id of control "SivaSiva Portal Scrolling" of me
end _scrollingView

private function _navigationView
   return the long id of control "SivaSiva Portal Navigation" of me
end _navigationView


--> Events
-
on resizeControl
   LayoutControl
end resizeControl


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

