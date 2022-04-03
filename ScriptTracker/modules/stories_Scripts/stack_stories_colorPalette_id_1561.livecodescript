Script "stack_stories_colorPalette_id_1561"

/*
# Name: colorPalette "Color map" of card "colorIt" of stack "stories"
# ID: colorPalette id 1561 of card id 1421 of stack "stories"
*/


on mouseUp
   set the selectedColor2 of me to the mouseColor
   set the backgroundColor of btn "fillColor" of grp "footer" to the mouseColor
   hide me
   updateImageState true
   --dispatch "createImageScroller" to grp "colorItImageGroup" with "colorItImageGroup"
end mouseUp
