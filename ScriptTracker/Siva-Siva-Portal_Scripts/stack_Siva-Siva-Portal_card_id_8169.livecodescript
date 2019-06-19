Script "stack_Siva-Siva-Portal_card_id_8169"

/*
# Name: card "Home" of stack "Siva-Siva-Portal"
# ID: card id 8169 of stack "Siva-Siva-Portal"
# Behavior: stack "behavior_updateUIPortal"
*/


global sConfigA
local sStartLoc,sScreenRect


on preopenCard
   local pControl
   
   setCardCoords
   updateUIPortal
   audioIsRunning
   ntInfo ("Home card rect: " & the rect of this card)
   put empty into fld "homeStoryText"
   hide image "homeStoryMainImage"
   put the long id of fld "homeStoryText" into pControl
   centerMe pControl,0,5
   ntInfo ("fld homestoryText loc: "& the loc of pControl)
   dispatch "initializeNarrative" to grp "homeStory"
   show btn "brandLogo"
end preopenCard


command  setDefaultImage
   local pImage
   local sLastImage, sMainImage -- BWM - should these be script locals?
   
   # store brand image; set stage to screen to 1
   put path_Assets()& "img/siva-darshan/who-is-siva_1200x800.jpg" into pImage
   put 0 into sLastImage
   put  empty into sConfigA["narrativeScene"]
   put the long id of img "homeStoryMainImage" of card "Home" into sMainImage
   set the filename of sMainImage to  pImage
   setImageToFullCardLoc sMainImage,"portrait",0,0
   centerMe sMainImage,0,0
   show btn "brandLogo"
   show sMainImage with visual effect "dissolve"
end  setDefaultImage


on opencard
   News_Fetch
end opencard





