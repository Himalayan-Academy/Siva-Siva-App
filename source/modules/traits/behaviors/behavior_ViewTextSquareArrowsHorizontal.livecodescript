script "behavior_View|Text|Square|Arrows|Horizontal"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_View|Text|Square|Arrows|Horizontal
type: behavior
version: 0.3


local LocalArray


--> Controls
-
getprop view_Object
   return the long id of me
end view_Object

getprop horizontalArrow_View
   return the long id of me
end horizontalArrow_View

getprop sivaSquareText_View
   if exists (group "Square Text" of me) is false then return empty
   put the long id of group "Square Text" of me into sivaTraitView
   return sivaTraitView
end sivaSquareText_View


--> Children
-
getprop square_View
   return _squareView()
end square_View


--> Geometry
-
getprop arrow_HeightFactor
   return 2.5
   return arrowHeightFactor
end arrow_HeightFactor

getprop arrow_Scale
   put LocalArray ["arrow_Scale"] into arrowScale
   if arrowScale is empty then return 0.5
   return arrowScale
end arrow_Scale

setprop arrow_Scale arrowScale
   put arrowScale into LocalArray ["arrow_Scale"]
   LayoutControl
end arrow_Scale

getprop arrow_Margin [arrowWidth]
    -- shifts the arrow left or right a bit
   put LocalArray ["arrow_Margin"] into arrowMargin
   if arrowMargin is a number then return arrowMargin
   
   put the arrow_Margin [arrowWidth] of the owner of me into arrowMargin
   if arrowMargin is a number then return arrowMargin
   
   put default_ArrowMargin (arrowWidth) into arrowMargin
   return arrowMargin
end arrow_Margin

setprop arrow_Margin arrowMargin
   -- shifts the arrow left or right a bit
   put arrowMargin into LocalArray ["arrow_Margin"]
   LayoutControl
end arrow_Margin


--> Geometry | Fixed
-
function _arrowWidth squareWidth
   if squareWidth is empty then return 50
   
   put round ( squareWidth / 10 ) into halfArrowWidth
   put 2 * halfArrowWidth into arrowWidth
   return arrowWidth
end _arrowWidth

private function default_ArrowMargin arrowWidth
   if arrowWidth is not a number then return -7
   
   put -1 * round ( arrowWidth / 3.2 ) into defaultArrowMargin
   return defaultArrowMargin
end default_ArrowMargin



--> Events
-
on resizeControl
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl

command LayoutControl pRect
   -- twice as tall as it is wide
   if pRect is empty then put the rect of me into pRect
   
   -- what controls are we talking about
   put _leftArrow() into leftArrow
   put _rightArrow() into rightArrow
   put _squareView() into squareView
   
   -- work out geometry
   put the arrow_heightFactor of me into arrowHeightFactor -- vector icons are proportional
   put the arrow_Scale of me into arrowScale -- vector icons are proportional
   
   calculate_SquareRect pRect, squareRect, squareCentre, squareWidth, halfSquareWidth
   put item 1 of squareCentre into squareX
   put item 2 of squareCentre into squareY
   
   -- fetch some props
   put _arrowWidth (squareWidth) into arrowWidth
   put the arrow_Margin [arrowWidth] of me into arrowMargin
   -- put the arrow_Scale of me into arrowScale
   
   put round (arrowScale * arrowWidth) into arrowWidth
   put round ( arrowWidth / 2 ) into halfArrowWidth
   
   put squareY - arrowHeightFactor * halfArrowWidth into arrowTop
   put squareY + arrowHeightFactor * halfArrowWidth into arrowBottom
   
   -- work out left arrow rect
   put squareX - halfSquareWidth into leftArrowRight
   subtract arrowMargin from leftArrowRight -- shift it out or in a variable bit
   
   put leftArrowRight - arrowWidth into item 1 of leftArrowRect
   put leftArrowRight into item 3 of leftArrowRect
   put arrowTop into item 2 of leftArrowRect
   put arrowBottom into item 4 of leftArrowRect
   
   -- work out right arrow rect
   put squareX + halfSquareWidth into rightArrowLeft
   add arrowMargin to rightArrowLeft
   
   put rightArrowLeft into item 1 of rightArrowRect
   put rightArrowLeft + arrowWidth into item 3 of rightArrowRect
   put arrowTop into item 2 of rightArrowRect
   put arrowBottom into item 4 of rightArrowRect
   
   -- set the rects
   lock screen
   --
   set the rect of leftArrow to leftArrowRect
   set the rect of rightArrow to rightArrowRect
   if exists (squareView) is true then
      set the rect of squareView to squareRect
   else
      test_Rect squareRect, "squareRect"
   end if
   --
   unlock screen
end LayoutControl

command calculate_SquareRect pRect, @squareRect, @squareCentre, @squareWidth, @halfSquareWidth, pSquareMargin
   rect_ExtractDimensions pRect, someX, someY
   put min (someX, someY) into squareWidth
   put round ( squareWidth / 2 ) into halfSquareWidth
   put 2 * halfSquareWidth into squareWidth
   
   put rect_GetCentre (pRect) into squareCentre
   put rect_LocWidthHeight (squareCentre, squareWidth, squareWidth) into squareRect
   
   rect_SubtractMargins squareRect, pSquareMargin
   return squareRect
end calculate_SquareRect


--> Private
-
private function _squareView
   if exists (control "Square Text" of me) is false then
      return empty
   end if
   
   put the long id of control "Square Text" of me into squareView
   return squareView
end _squareView

private function _leftArrow
   put the long id of widget "Left" of me into leftWidget
   return leftWidget
end _leftArrow

private function _rightArrow
   put the long id of widget "Right" of me into rightWidget
   return rightWidget
end _rightArrow
