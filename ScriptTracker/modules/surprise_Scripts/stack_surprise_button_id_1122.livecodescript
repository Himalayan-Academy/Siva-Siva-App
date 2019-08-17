Script "stack_surprise_button_id_1122"

/*
# Name: button "behavior- List Buttons" of card "image-resources" of stack "surprise"
# ID: button id 1122 of card id 1023 of stack "surprise"
*/


constant kSelectedColor = "226,232,186"
constant kBackgroundBrown = "96,12,12"

on mousewithin
   local tSurpriseButtonsRollOver
   put "70,105,134" into tSurpriseButtonsRollOver["color"]
   put "normal" into tSurpriseButtonsRollOver["blendMode"]
   put "100" into tSurpriseButtonsRollOver["opacity"]
   put "box2Pass" into tSurpriseButtonsRollOver["filter"]
   put "40" into tSurpriseButtonsRollOver["size"]
   put "86" into tSurpriseButtonsRollOver["spread"]
   set the textcolor of me to kSelectedColor
   set the outerglow of me to tSurpriseButtonsRollOver
end mousewithin

on mouseleave
   local tWipeOutEffect
   set the outerglow of me to tWipeOutEffect # an empty variable
   set the textcolor of me to kBackgroundBrown
end mouseleave
