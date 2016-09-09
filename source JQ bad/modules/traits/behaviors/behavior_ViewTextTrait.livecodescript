script "behavior_ViewTextTrait"
--> MetaData
-
license: GPLv3
name: behavior_ViewTextTrait
type: behavior
version: 0.2

local LocalArray


--> Traint | Props
-
getprop trait_Text
   put the text of _textLabelField() into someText
   return someText
end trait_Text

setprop trait_Text someText
   put _textLabelField() into fieldControl
   set the text of fieldControl to someText 
   return fieldControl
end trait_Text

getprop trait_Hilite
   return LocalArray ["trait_Hilite"]
end trait_Hilite

setprop trait_Hilite someBoolean
   put someBoolean is true into LocalArray ["trait_Hilite"]
   set the visible of _frameGraphic() to someBoolean
   
   if someBoolean is true then
   else
   end if
end trait_Hilite

getprop trait_Border
   put the linesize of _frameGraphic() = 1 into someBoolean
   return someBoolean
end trait_Border

setprop trait_Border someBoolean
   if someBoolean is true then
      set the linesize of _frameGraphic() to 1
   else
      set the linesize of _frameGraphic() to 0
   end if
end trait_Border


--> Events
-
on mouseUp
  set the trait_Hilite of me to not the trait_Hilite of me
end mouseUp

on resizeControl
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   
   -- what controls are we talking about
   put _frameGraphic() into frameGraphic
   put _textLabelField() into textLabel
   
   put pRect into innerRect
   put the margins of me into someMargins
   if the showborder of me is true then
      put the borderwidth of me into bWidth
      repeat with itemNum = 1 to the number of items of someMargins
         add bWidth to item itemNum of someMargins
      end repeat
   end if
   rect_SubtractMargins innerRect, someMargins
   put rect_GetCentre (innerRect) into innerCentre
   put item 2 of innerCentre into centreY
   
   -- work out frameRect 
   put innerRect into frameRect
   
   -- change the textSize
   put item 3 of innerRect - item 1 of innerRect into innerWidth
   put _guessTextSize (innerWidth) into tSize
   set the textSize of textLabel to tSize
   
   -- work out labelRect
   put innerRect into labelRect
   put the formattedheight of textLabel into fHeight
   put round (fHeight / 2) into halfHeight
   put centreY - halfHeight into item 2 of labelRect
   put centreY + halfHeight into item 4 of labelRect
   
   -- set the rects
   lock screen
   --
   -- test_Rect innerRect, "innerRect", "green"
   set the rect of frameGraphic to frameRect
   set the rect of textLabel to labelRect
   --
   unlock screen
end LayoutControl


--> Controls
-
getprop trait_View
   return the long id of me
end trait_View

getprop view_Object
   return the long id of me
end view_Object

private function _frameGraphic
   return the long id of graphic 1 of me
end _frameGraphic

private function _textLabelField
   return the long id of fld 1 of me
end _textLabelField


--> Private
-
private function _guessTextSize innerWidth
   switch 
      case innerWidth < 100
         return innerWidth / 12
      case innerWidth > 130
         return innerWidth / 8
      default
         return innerWidth / 9
   end switch
end _guessTextSize



