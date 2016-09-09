script "behavior_ViewSivaSivaTraitPlusMinus"
--> MetaData
-
license: GPLv3
name: behavior_ViewSivaSivaTraitPlusMinus
type: behavior
version: 0.1


local LocalArray


--> Events
-
on mouseUp
   put the short name of the target into tName
   switch tName
      case "Right"
         display_NextChapter
         break
      case "Left"
         display_PreviousChapter
         break
      default
         -- put tName
   end switch
end mouseUp

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   
   -- what controls are we talking about
   put _squareView() into squareView
   put _positiveView() into positiveView
   put _negativeView() into negativeView
   put _verticalArrow() into verticalArrow
   
   -- let's make sure the objects are there (optional safety feature)
   -- could be done during preOpenControl (being careful for now)
   _createNestedViews squareView, positiveView, negativeView, verticalArrow
   
   put the group_InnerRect [pRect] of me into innerRect
   put rect_GetCentre (innerRect) into squareCentre
   
   put item 1 of someMargins into someMargin
   put item 1 of squareCentre into centreX
   put item 2 of squareCentre into centreY
   
   put item 2 of innerRect into innerTop
   put item 4 of innerRect into innerBottom
   put  item 3 of innerRect -  item 1 of innerRect into innerWidth
   put  item 4 of innerRect -  item 2 of innerRect into innerHeight
   
   -- work out key scaleable proportions for the view   
   put the arrow_Length [innerHeight] of me into arrowLengthGuess
   put the arrow_Gap [innerHeight] of me into arrowGap
   put the arrow_LineWidth [innerHeight] of me into arrowWidth
   put the trait_Margin [innerWidth] of me into extraInnerMargin
   
   put the trait_Height [innerHeight] of positiveView into traitHeight
   
   put innerTop + extraInnerMargin into pTop
   put pTop + traitHeight into pBottom
   put innerBottom - extraInnerMargin into nBottom
   put nBottom - traitHeight into nTop
   put pBottom + arrowGap into aTop
   put nTop - arrowGap into aBottom
   
   
   -- work out inner square   
   put aTop + arrowLengthGuess into innerSquareTop
   put aBottom - arrowLengthGuess into innerSquareBottom
   if the keep_Square of me is true then
      put _innerSquareRect (innerWidth, centreX, innerTop, innerBottom, centreY, innerHeight, traitHeight, arrowLengthGuess) into innerSquareRect
      -- put _innerSquareRect (innerWidth, centreX, innerSquareTop, innerSquareBottom) into innerSquareRect
   else
      put _innerRectangle (innerWidth, centreX, innerSquareTop, innerSquareBottom) into innerSquareRect
   end if
   
   -- now let's centre the traits in the available space
   put item 2 of innerSquareRect into squareTop
   put squareTop - innerTop into availableHeight
   put round (availableHeight / 2) into halfAvailableHeight
   
   put the arrow_Factor of me into arrowFactor
   put round (arrowFactor * halfAvailableHeight) into halfAvailableHeight
   put 1 * traitHeight into minGap
   put max (halfAvailableHeight, minGap) into halfAvailableHeight
   
   -- work out trait rects
   put squareTop - halfAvailableHeight into pTraitY
   put item 3 of innerSquareRect - item 1 of innerSquareRect into squareWidth
   put _traitWidth (squareWidth) into traitWidth
   put centreX,pTraitY into pLoc
   
   put rect_LocWidthHeight (pLoc, traitWidth, traitHeight) into positiveTraitRect
   
   put item 4 of innerSquareRect into squareBottom
   put squareBottom + halfAvailableHeight into nTraitY
   put centreX,nTraitY into nLoc
   put rect_LocWidthHeight (nLoc, traitWidth, traitHeight) into negativeTraitRect
   
   -- put _positiveTraitRect (centreX, traitWidth, pTop, pBottom) into positiveTraitRect
   -- put _negativeTraitRect (centreX, traitWidth, nTop, nBottom) into negativeTraitRect
   
   -- work out arrow points
   put item 4 of positiveTraitRect into aTop
   put item 2 of negativeTraitRect into aBottom
   put _arrowPoints (aTop, aBottom, centreX, innerSquareRect) into arrowPoints
   
   -- set the rects
   lock screen
   --  
   set the rect of squareView to innerSquareRect
   
   -- test_Rect positiveTraitRect, "positiveTraitRect", "pink"
   set the rect of positiveView to positiveTraitRect
   
   set the rect of negativeView to negativeTraitRect
   set the points of verticalArrow to arrowPoints
   set the linesize of verticalArrow to arrowWidth
   --
   unlock screen
end LayoutControl

on preOpenControl
   put _squareView() into squareView
   put _positiveView() into positiveView
   put _negativeView() into negativeView
   put _verticalArrow() into verticalArrow
   _createNestedViews squareView, positiveView, negativeView, verticalArrow
end preOpenControl


--> Working On
-
getprop trait_Hilite
   put the trait_Hilite of the positive_View of me into pHilite
   put the trait_Hilite of the negative_View of me into nHilite
   put nHilite and pHilite into bHilite
   switch
      case pHilite is false and nHilite is false
         return "none"
      case pHilite is true and nHilite is false
         return "positive"
      case nHilite is true and pHilite is false
         return "negaitve"
      default
         return "both"
   end switch
end trait_Hilite

setprop trait_Hilite plusMinusZero
   lock screen
   switch plusMinusZero
      case "positive"
         set the trait_Hilite of the positive_View of me to true
         set the trait_Hilite of the negative_View of me to false
         break
      case "negative"
         set the trait_Hilite of the positive_View of me to false
         set the trait_Hilite of the negative_View of me to true
         break
      case "both"
         set the trait_Hilite of the positive_View of me to true
         set the trait_Hilite of the negative_View of me to true
         break
      default
         set the trait_Hilite of the positive_View of me to false
         set the trait_Hilite of the negative_View of me to false
   end switch
   unlock screen
end trait_Hilite

getprop trait_Hilites
   return "positive,negative,both,none"
end trait_Hilites

getprop show_TraitLabels
   put the visible of the arrow_View of me into someBoolean
   return someBoolean
end show_TraitLabels

setprop show_TraitLabels someBoolean
   lock screen
   set the visible of the positive_View of me to someBoolean
   set the visible of the negative_View of me to someBoolean
   set the visible of the arrow_View of me to someBoolean
   unlock screen
end show_TraitLabels

getprop displayed_ChapterTitle
   return the chapter_Title of me
end displayed_ChapterTitle

setprop displayed_ChapterTitle chapterTitleOrNum
   if chapterTitleOrNum is a number then
      set the chapter_Num of me to chapterTitleOrNum
   else
      set the chapter_Title of me to chapterTitleOrNum
   end if
   
   set the displayed_PositiveLabel of me to the positive_Label of me
   set the displayed_NegativeLabel of me to the negative_Label of me
   set the displayed_SquareText of me to the trait_Description of me
end displayed_ChapterTitle

getprop situation_Num
   put LocalArray ["situation_Num"] into situationNum
   return situationNum
end situation_Num

setprop situation_Num situationNum
   put situationNum into LocalArray ["situation_Num"]
   
   put the trait_Situation [situationNum] of me into traitSituation
   set the displayed_SquareText of me to traitSituation
end situation_Num


--> Display
-
command display_NextChapter
   put the chapter_Num of me into chapterNum
   if chapterNum = 64 then
      put 1 into nextChapterNum
   else
      put chapterNum + 1 into nextChapterNum
   end if
   set the displayed_ChapterTitle of me to nextChapterNum
end display_NextChapter

command display_PreviousChapter
   put the chapter_Num of me into chapterNum
   if chapterNum = 1 then
      put 64 into nextChapterNum
   else
      put chapterNum - 1 into nextChapterNum
   end if
   set the displayed_ChapterTitle of me to nextChapterNum
end display_PreviousChapter


--> Display | Props
-
getprop displayed_PositiveLabel
   put _positiveView() into positiveView
   put the trait_Text of positiveView into positiveText
   return positiveText
end displayed_PositiveLabel

setprop displayed_PositiveLabel positiveText
   put _positiveView() into positiveView
   set the trait_Text of positiveView to positiveText
   put the result into fieldControl
   return fieldControl
end displayed_PositiveLabel

getprop displayed_NegativeLabel
   put _negativeView() into negativeView
   put the trait_Text of negativeView into negativeText
   return negativeText
end displayed_NegativeLabel

setprop displayed_NegativeLabel negativeText
   put _negativeView() into negativeView
   set the trait_Text of negativeView to negativeText
   put the result into fieldControl
   return fieldControl
end displayed_NegativeLabel

getprop displayed_SquareText
   put the sivaSquareText_View of me into sivaSquareTextView
   if exists (sivaSquareTextView) is false then return empty
   
   put the view_Text of sivaSquareTextView into squareText
   return squareText
end displayed_SquareText

setprop displayed_SquareText squareText
   put the sivaSquareText_View of me into sivaSquareTextView
   if exists (sivaSquareTextView) is false then return empty
   
   set the view_Text of sivaSquareTextView to squareText
   -- set the view_UTF8 of sivaSquareTextView to squareText
   put the result into textField
   return textField
end displayed_SquareText


--> Geometry
-
getprop arrow_Factor
   return 0.6
end arrow_Factor

getprop arrow_Length [innerWidth]
   put round (innerWidth / 18) into arrowLength
   put max (arrowLength, 4) into arrowLength
   return arrowLength
end arrow_Length

getprop arrow_LineWidth [innerHeight]
   -- put innerHeight
   switch
      case innerHeight < 2000
         return 1
      case innerHeight < 250
         return 2
      case innerHeight < 400
         return 3
      default
         return 4
   end switch
end arrow_LineWidth

getprop arrow_Gap [innerWidth]
   -- this is the gap between the trait and the top of the line
   -- you may need to set this if you choose to show arrow heads
   -- because unfortunately Livecode does not include the arrow in legnth calculations.
   
   -- this value works well with oval graphics
   return -3
   
   put item 1 of the margins of me into someMargin
   put _arrowTopFactor() * someMargin into arrowGap
   
   put round (innerWidth * 0.05) into arrowHeight
   return arrowHeight
end arrow_Gap

getprop trait_Margin [innerWidth]
   put 0 into extraInnerMargin
   -- put item 1 of the margins of me into someMargin
   -- put _arrowTopFactor() * someMargin into extraInnerMargin
   return extraInnerMargin
end trait_Margin

getprop trait_Height [innerHeight]   
   put round (innerHeight / 8) into traitHeight
   if traitHeight > 50 then return 50
   return traitHeight
end trait_Height

getprop keep_Square
   return LocalArray ["keep_Square"] is not false
end keep_Square

setprop keep_Square someBoolean
   put someBoolean is true into LocalArray ["keep_Square"]
   LayoutControl
end keep_Square


--> Controls
-
getprop siva_TraitView
   return the long id of me
end siva_TraitView

getprop view_Object
   return the long id of me
end view_Object

getprop sivaSquareText_View
   if exists (group "Square Text" of me) is false then return empty
   put the long id of group "Square Text" of me into sivaSquareTextView
   return sivaSquareTextView
end sivaSquareText_View


--> Children
-
getprop positive_View
   return _positiveView()
end positive_View

getprop negative_View
   return _negativeView()
end negative_View

getprop square_View
   return _squareView()
end square_View

getprop arrow_View
   return _verticalArrow()
end arrow_View


--> Private
-
private function _traitWidth innerWidth
   put round (0.4 * innerWidth) into traitWidth
   return traitWidth
 end _traitWidth

private function _innerSquareRect  innerWidth, centreX, innerTop, innerBottom, centreY, innerHeight, traitHeight, arrowLength
   -- return the smallest square
   -- put innerBottom - innerTop into innerHeight
   -- put the arrow_Length of me into arrowLength
   -- put the trait_Height [innerHeight] of me into traitHeight
   
   put innerHeight - 2 * (arrowLength + traitHeight) into availableHeight 
   put min (availableHeight, innerWidth) into innerSquareWidth
   put round (innerSquareWidth / 2) into halfWidth
   
   put centreX - halfWidth into item 1 of innerSquareRect
   put centreX + halfWidth into item 3 of innerSquareRect
   put centreY - halfWidth into item 2 of innerSquareRect
   put centreY + halfWidth into item 4 of innerSquareRect
   return innerSquareRect
end _innerSquareRect

private function _arrowPoints aTop, aBottom, centreX, innerSquareRect
   put centreX into item 1 of arrowTopLoc
   put aTop into item 2 of arrowTopLoc
   
   put centreX into item 1 of arrowBottomLoc
   put aBottom into item 2 of arrowBottomLoc
   
   put item 2 of innerSquareRect into squareTop
   add 1 to squareTop -- tweak
   put centreX,squareTop into squareTopLoc
   
   put item 4 of innerSquareRect into squareBottom
   subtract 1 from squareBottom -- tweak
   put centreX,squareBottom into squareBottomLoc
   
   -- put arrowTopLoc & CR & arrowBottomLoc into arrowPoints
   put arrowTopLoc & CR & squareTopLoc & CR & CR & squareBottomLoc & CR & arrowBottomLoc into arrowPoints
   
   return arrowPoints
end _arrowPoints


--> Private
-
private command _createNestedViews @squareView, @positiveView, @negativeView, @verticalArrow
   -- test_Rect innerRect, "innerRect", "black"
   
   put the short id of me into groupID
   if exists (verticalArrow) is false then
      set the style of templategraphic to "line"
      set the linesize of templategraphic to 4
      set the antialiased of templategraphic to false
      set the foregroundcolor of templategraphic to "128,128,128"
      
      create graphic "Trait Line" in me
      put it into verticalArrow
      reset templategraphic
   end if
   if exists (squareView) is false then
      create_Placeholder "innerSquare", empty, groupID, "red"
      put the result into squareView
   end if
   if exists (positiveView) is false then
      create_Placeholder "Positive Trait", empty, groupID, "yellow"
      put the result into positiveView
   end if
   if exists (negativeView) is false then
      create_Placeholder "Negative Trait", empty, groupID, "green"
      put the result into negativeView
   end if
end _createNestedViews


--> Private | Geometry
-
private function _innerRectangle innerWidth, centreX, innerSquareTop, innerSquareBottom
   -- not limited to return a square
   put round (innerWidth / 2) into halfWidth
   
   put centreX - halfWidth into item 1 of innerSquareRect
   put centreX + halfWidth into item 3 of innerSquareRect
   put innerSquareTop into item 2 of innerSquareRect
   put innerSquareBottom into item 4 of innerSquareRect
   return innerSquareRect
end _innerRectangle

-- private function _innerSquareRect  innerWidth, innerHeight, centreX, innerSquareTop, innerSquareBottom
-- return the smallest square
-- put _innerSquareRect (innerWidth, innerHeight, centreX, innerSquareTop, innerSquareBottom) into innerSquareRect
put  innerSquareBottom - innerSquareTop into innerSquareHeight
put round (innerSquareHeight / 2) into halfWidth
-- put min (innerWidth, innerHeight, innerSquareHeight) into squareWidth
-- put round (squareWidth / 2) into halfWidth

put centreX - halfWidth into item 1 of innerSquareRect
put centreX + halfWidth into item 3 of innerSquareRect
put innerSquareTop into item 2 of innerSquareRect
put innerSquareBottom into item 4 of innerSquareRect
return innerSquareRect
end _innerSquareRect


--> Events
-
on resizeControl
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl


--> Children | Private
-
/*
To be super safe we should only accept top level controls
*/

private function _squareView
   put the top_Control ["innerSquare"] of me into innerSquareView
   if exists (control "innerSquare" of me) is false then return empty
   put the long id of control "innerSquare" of me into innerSquareView
   return innerSquareView
end _squareView

private function _verticalArrow
   if exists (graphic "Trait Line" of me) is false then return empty
   put the long id of graphic "Trait Line" of me into verticalArrow
   return verticalArrow
end _verticalArrow

private function _positiveView
   if exists (control "Positive Trait" of me) is false then return empty
   put the long id of control "Positive Trait" of me into positiveView
   return positiveView
end _positiveView

private function _negativeView
   if exists (control "Negative Trait" of me) is false then return empty
   put the long id of control "Negative Trait" of me into negativeView
   return negativeView
end _negativeView


--> Deps
-
getprop group_InnerRect [rectBounds]
   put the long id of the target into targetGroup
   if rectBounds is empty then put the rect of targetGroup into rectBounds
   
   put the margins of targetGroup into someMargins
   if the showborder of targetGroup is true then
      put the borderwidth of targetGroup into bWidth
      repeat with itemNum = 1 to the number of items of someMargins
         add bWidth to item itemNum of someMargins
      end repeat
   end if
   rect_SubtractMargins rectBounds, someMargins
   return rectBounds
end group_InnerRect
