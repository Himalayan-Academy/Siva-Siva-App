script "behavior_View|Text|Square"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_View|Text|Square
type: behavior
version: 0.1

local LocalArray


--> Controls
-
getprop sivaSquareText_View
   return the long id of me
end sivaSquareText_View

getprop square_View
   return the long id of me
end square_View

getprop view_Object
   return the long id of me
end view_Object


--> SivaSiva | Text | Square | Props
-
getprop text_Size
   put _textField() into textField
   put the textsize of textField into someSize
   return someSize
end text_Size

setprop text_Size someSize
   put _textField() into textField
   lock screen
   set the textsize of textField to someSize
   LayoutControl
   unlock screen
   return textField
end text_Size

getprop view_Text
   put _textField() into textField
   put the text of textField into someText
   return someText
end view_Text

setprop view_Text someText
   put _textField() into textField
   lock screen
   put someText into LocalArray ["view_Text"]
   set the text of textField to someText
   LayoutControl
   unlock screen
   return textField
end view_Text

getprop view_UTF8
   put _textField() into textField
   put the unicodetext of textField into someUTF8
   return someUTF8
end view_UTF8

setprop view_UTF8 someUTF8
   put _textField() into textField
   lock screen
   put uniencode (someUTF8,"UTF8") into someU16
   -- set the unicodetext of textField to someU16
   put unidecode (someU16, "ANSI") into someText
   put someText into LocalArray ["view_Text"]
   set the text of textField to someText
   LayoutControl
   unlock screen
   return textField
end view_UTF8


--> Geometry
-
getprop inner_Margin
   put LocalArray ["inner_Margin"] into innerMargin
   if innerMargin is a number then return innerMargin
   
   put the inner_Margin of the owner of me into innerMargin
   if innerMargin is a number then return innerMargin
   
   put default_InnerMargin() into innerMargin
   return innerMargin
end inner_Margin

setprop inner_Margin innerMargin
   put innerMargin into LocalArray ["inner_Margin"]
   LayoutControl
end inner_Margin

private function default_InnerMargin
   return 14
end default_InnerMargin



--> Events
-
-- on rawKeydown
   send "LayoutControl" to me in 2 ticks
   pass rawKeydown
end rawKeydown

on resizeControl
   LayoutControl
end resizeControl

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   lock screen
   
   put _frameView() into frameView
   put _textField() into textField
   
   put the margins of me into someMargin
   
   rect_ExtractDimensions pRect, someX, someY
   put min (someX, someY) into squareWidth
   
   put rect_GetCentre (pRect) into innerCentre
   put rect_LocWidthHeight (innerCentre, squareWidth, squareWidth) into innerRect
   rect_SubtractMargins innerRect, someMargin
   
   -- set the rect of textField to innerRect
   
   -- put the inner_Margin of me into innerMargin
   set the auto_TextSize of textField to squareWidth
   put the result into innerMargin
   -- _autoSetTextSize squareWidth, innerMargin
   
   put innerRect into textFieldRect
   rect_SubtractMargins textFieldRect, innerMargin
   
   -- let's work out how much text there is and centre it
   set the text of textField to LocalArray ["view_Text"]
   put the formattedheight of textField into fHeight
   
   _fixOverFlow squareWidth,textField, fHeight -- does fancy trimming
   -- put the formattedheight of textField into fHeight
   
   put round (fHeight/2) into halfHeight
   
   put item 2 of innerCentre into innerY
   put innerY - halfHeight into item 2 of textFieldRect
   put innerY + halfHeight into item 4 of textFieldRect
   
   -- tweak
   -- rect_Translate innerRect, 1, 1
   
   set the rect of textField to textFieldRect
   set the rect of frameView to innerRect
   
   -- hack for odd pixel shift
   set the loc of textField to innerCentre
   set the loc of frameView to innerCentre
   unlock screen
end LayoutControl

private command _fixOverFlow squareWidth,textField, @fHeight
   -- put squareWidth
   if squareWidth < 35 then
      -- for when it is a tiny icon
      set the text of textField to "Siva SIva"
      put the formattedheight of textField into fHeight
      return "zapped"
   else if fHeight > (squareWidth - 8)  then
      -- for when the text overflows
      -- should happen rarely
      
      put _guessAutoFactor (squareWidth) into someFactor
      repeat 5
         add 1 to someFactor
         set the auto_TextSize [someFactor] of textField to squareWidth
         put the formattedheight of textField into fHeight
         if fHeight <= (squareWidth - 8) then
            return "tweaked"
         end if
      end repeat
      
      -- put "trimmed"
      set the text of textField to (word 1 to 12 of LocalArray ["view_Text"] & "...")
      put the formattedheight of textField into fHeight
      return "trimmed"
   end if
end _fixOverFlow

setprop auto_TextSize [someFactor] squareWidth
   put the long id of the target into textField
   
   if someFactor is empty then
      put _guessAutoFactor (squareWidth) into someFactor
   end if
   
   put round ( squareWidth / someFactor ) into innerMargin
   put innerMargin into LocalArray ["inner_Margin"]
   put round (squareWidth/someFactor) into someSize
   
   set the textsize of textField to someSize
   return innerMargin
end auto_TextSize

private function _guessAutoFactor squareWidth
   if squareWidth < 120 then
      put 30 into someFactor
   else if squareWidth >= 180 and squareWidth < 270 then
      put 19 into someFactor
   else if squareWidth >= 270 and squareWidth < 320 then
      put 19 into someFactor
   else if squareWidth >= 320 and squareWidth < 350 then
      put 18 into someFactor
   else -- if squareWidth >= 300 then
      put 17 into someFactor
   end if
   return someFactor
end _guessAutoFactor


--> Children
-
private function _textField
   put the long id of fld "Description" of me into textField
   return textField
end _textField

private function _frameView
   put the long id of btn "Frame" of me into frameView
   return frameView
end _frameView
