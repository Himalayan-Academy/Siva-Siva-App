script "behavior_updateUIPortal"


--on resizestack x,y
--    x,y

--end resizeStack

on opencard
   lock screen
   setCardCoords
   updateUIPortal
   unlock screen
end opencard

command updateUIPortal
   
   # background group of all cards
   
   
   put the long id of group "audioGlobalControl" of me  into pControl
   topRightMe pControl,40,30
   
   
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
         setImageToFullCardLoc pControl, "portrait", 50
         centerMe pControl,0,50
         
         
         put the long id of btn "goNext" into pControl
         bottomCenterMe pControl,8    
         ntInfo ("Go Next loc: " & location of  btn "goNext" )
         
         put the long id of button "openGlobalNav" into pControl
         bottomLeftMe pControl,0,8 
         
         break
         
         
      case  "mainNav"
         put the long id of grp "footer" into pControl
         bottomCenterMe pControl,8
         
         put the long id of btn "backgroundOverlay" into pControl
         centerMe pControl
         
         put the long id of grp "globalPortalMap" into pControl
         topCenterMe pControl,55
         break
         
         
   end switch
  
end updateUIPortal

