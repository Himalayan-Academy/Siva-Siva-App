script "behavior_updateUIPortal"
after preopencard
   lock screen
   setCardCoords "portrait"
   updateUIPortal
   unlock screen
end preopencard

on resizeStack x,y,ox,oy
   lock screen
   -- When coming from a landscape stack, card rect is not updated correctly
   -- and the resizeStack is called with a landscape rect.  If an answer is
   -- inserted here, a second resizeStack gets sent with the correct rect.
   setCardCoords "portrait"
   updateUIPortal
   unlock screen
end resizeStack

command updateUIPortal
   local pControl, tBrandImage
   
   # background group of all cards
   
   
   put the long id of group "audioGlobalControl" of me into pControl
   topRightMe pControl,40,15
   
   
   put the long id of fld "Notification" of me into pControl
   topCenterMe pControl,150
   
   
   switch (the short name of this card)
      case "Home"
         
         # Backgrond
         
         put the long id of btn "backgroundOverlay" into pControl
         centerMe pControl
         
         # Main Image
         # Opens SivaSiva Brand Image, which we locate
         # subsequent in image of content and managed 
         # from the home 
         
         put the long id of button "brandLogo" of me into pControl
         topCenterMe pControl,20
         
         
         put long Id of img "HomeStoryMainImage" into pControl
         put path_Assets()& "img/siva-darshan/who-is-siva_1200x800.jpg" into tBrandImage
         set filename of pControl to tBrandImage
         setImageToFullCardLoc pControl, "portrait", 0
         centerMe pControl, 0, 0
         
         
         put the long id of btn "goNext" into pControl
         bottomCenterMe pControl,0 --8    
         ntInfo ("Go Next loc: " & location of  btn "goNext" )
         
         put the long id of button "openGlobalNav" into pControl
         bottomLeftMe pControl,0,0 --8 
         
         break
         
         
      case  "mainNav"
         put the long id of grp "footer" into pControl
         bottomCenterMe pControl,0 --8
         
         put the long id of btn "backgroundOverlay" into pControl
         centerMe pControl
         
         put the long id of button "brandLogo" of me into pControl
         topCenterMe pControl,20
         
         put the long id of grp "globalPortalMap" into pControl
         topCenterMe pControl,55
         break
         
         
   end switch
   
end updateUIPortal

