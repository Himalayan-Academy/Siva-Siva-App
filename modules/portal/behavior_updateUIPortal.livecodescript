script "behavior_updateUIPortal"

command updateUIPortal
   
   # background group of all cards
   
   put the long id of grp "footer" into pControl
   bottomCenterMe pControl
   
   put the long id of group "audioGlobalControl" of me  into pControl
   topRightMe pControl,40,30
   
   put the long id of button "brandLogo" of me into pControl
   topCenterMe pControl,20
   
   put the long id of fld "homeNotification" of me into pControl
   topCenterMe pControl,150
   
   put the long id of fld "homeNotification" of me into pControl
   topCenterMe pControl,150
   
   
   switch (the short name of this card)
      case "Home"
         
         put the long id of image "backgroundOverlay" into pControl
         centerMe pControl
         
         put long Id of img "HomeStoryMainImage" into pControl
         put path_Assets()& "img/siva-darshan/who-is-siva_1200x800.jpg" into tBrandImage
         set filename of pControl to tBrandImage
         setImageToFullCardLoc pControl, "portrait", 50
         topCenterMe pControl
         
         put the long id of btn "goNext" into pControl
         bottomRightMe pControl,25,75 
         break
         
      case  "mainNav"
         
         put the long id of btn "backgroundOverlay" into pControl
         centerMe pControl
         
         put the long id of grp "globalPortalMap" into pControl
         topCenterMe pControl,55
         break
         
      case "moduleList"
         put the long id of grp "modulesList" into pControl
         centerMe pControl
         topCenterMe pControl,100
         break
   end switch
   
end updateUIPortal
