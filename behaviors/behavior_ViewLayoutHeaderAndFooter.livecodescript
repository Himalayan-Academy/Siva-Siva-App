script "behavior_ViewLayoutHeaderAndFooter"
--> MetaData
-
license: GPLv3
name: behavior_ViewLayoutHeaderAndFooter
type: behavior
version: 0.2

--> Variables
-
local LocalArray


--> Display | Props
-
getprop header_IsVisible
   return the visible of _headerView()
end header_IsVisible

setprop header_IsVisible someBoolean
   lock screen
   set the visible of _headerView() to someBoolean
   LayoutControl
   unlock screen
end header_IsVisible

getprop footer_IsVisible
   return the visible of _footerView()
end footer_IsVisible

setprop footer_IsVisible someBoolean
   lock screen
   set the visible of _footerView() to someBoolean
   LayoutControl
   unlock screen
end footer_IsVisible

getprop footer_Height
   return _footerHeight()
end footer_Height

setprop footer_Height footerHeight
   if footerHeight is not a number then put empty into footerHeight
   lock screen
   put footerHeight into LocalArray ["footerHeight"]
   LayoutControl
   unlock screen
end footer_Height

getprop header_Height
   return _footerHeight()
end header_Height

setprop header_Height headerHeight
   if headerHeight is not a number then put empty into headerHeight
   lock screen
   put headerHeight into LocalArray ["headerHeight"]
   LayoutControl
   unlock screen
end header_Height

private function _headerHeight
   if the header_IsVisible of me is true then
      put LocalArray ["headerHeight"] into headerHeight
      if headerHeight is empty then put 55 into headerHeight
      return headerHeight
   else
      return 0
   end if
end _headerHeight

private function _footerHeight
   if the footer_IsVisible of me is true then
      put LocalArray ["footerHeight"] into footerHeight
      if footerHeight is empty then put 50 into footerHeight
      return footerHeight
   else
      return 0
   end if
end _footerHeight


--> Events
-
on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   put the inner_Rect [pRect] of me into innerRect
   put the landscape_Layout of me into isLandscape
   
   lock screen
   -- could use switch and more complex naming like "left-right" etc
   -- or could work out from pRect if we are landscape or portrait
   if isLandscape is true then
      set the vertical_Layout of _footerView() to true
      
      -- strangely we we place the footer to the left :)
      set the rect of _footerView() to _leftRect (innerRect)
      set the rect of _bodyView() to _middleRect (innerRect)
      set the rect of _headerView() to _rightRect (innerRect)
   else
      set the vertical_Layout of _footerView() to false
      
      set the rect of _headerView() to _headerRect (innerRect)
      set the rect of _bodyView() to _bodyRect (innerRect)
      set the rect of _footerView() to _footerRect (innerRect)
   end if
   unlock screen
end LayoutControl


--> Geometry
-
getprop mobile_Orientation
   if the landscape_Layout of me is true then
      return "landscape"
   else
      return "portrait"
   end if
end mobile_Orientation

setprop mobile_Orientation whichOrientation
   lock screen
   set the footer_IsVisible of me to true
   switch whichOrientation
      case "portrait"
         set the header_IsVisible of me to true
         set the landscape_Layout of me to false
         set the view_Margins of _footerView() to "16,8,16,10"
         break
      case "landscape"
         set the header_IsVisible of me to false
         set the landscape_Layout of me to true
         set the view_Margins of _footerView() to "8"
         break
   end switch
   unlock screen
end mobile_Orientation

getprop landscape_Layout
   put the landscape_Layout of me is true into someBoolean
   return someBoolean
end landscape_Layout

setprop landscape_Layout someBoolean
   set the landscape_Layout of me to someBoolean
   LayoutControl
end landscape_Layout

private function _headerRect pRect
   put item 2 of pRect + _headerHeight() into item 4 of pRect
   return pRect
end _headerRect

private function _bodyRect pRect
   add _headerHeight() to item 2 of pRect
   subtract _footerHeight() from item 4 of pRect
   return pRect
end _bodyRect

private function _footerRect pRect
   put item 4 of pRect - _footerHeight() into item 2 of pRect
   return pRect
end _footerRect


--> Geometry | Landscape
-
private function _leftRect pRect
   put item 1 of pRect + _footerHeight() into item 3 of pRect
   return pRect
end _leftRect

private function _middleRect pRect
   add _footerHeight() to item 1 of pRect
   subtract _headerHeight() from item 3 of pRect
   return pRect
end _middleRect

private function _rightRect pRect
   put item 3 of pRect - _headerHeight() into item 1 of pRect
   return pRect
end _rightRect


--> Controls
-
getprop header_View
   put _headerView() into headerView
   return headerView
end header_View

getprop title_View
   put _headerView() into headerView
   return headerView
end title_View

getprop body_View
   put _bodyView() into headerView
   return headerView
end body_View

getprop footer_View
   put _footerView() into headerView
   return headerView
end footer_View


--> Private
-
private function _headerView
   put the long id of control "Header" of me into headerView
   return headerView
end _headerView

private function _bodyView
   put the long id of control "Body" of me into bodyView
   return bodyView
end _bodyView

private function _footerView
   put the long id of control "Footer" of me into footerView
   return footerView
end _footerView


--> Deps
-
getprop inner_Rect [pRect]
   if pRect is empty then put the rect of me into pRect
   put the margins of me into myMargins
   margin_Normalize myMargins, leftM, topM, rightM, bottomM
   
   add leftM to item 1 of pRect
   add topM to item 2 of pRect
   subtract rightM from item 3 of pRect
   subtract bottomM from item 4 of pRect
   return pRect
end inner_Rect

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
