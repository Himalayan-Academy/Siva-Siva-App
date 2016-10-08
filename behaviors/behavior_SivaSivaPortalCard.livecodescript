script "behavior_SivaSivaPortalCard"
--> MetaData
-
license: GPLv3
name: behavior_SivaSivaPortalCard
type: behavior
version: 0.1

--> Variables
-
local sConfigA


on launchAction pKey
   put sConfigA[pKey]["action"] into tAction
   switch
      case "//" is in tAction
         launchURL tAction
         break
      default
         break
   end switch
end launchAction

command loadPortalImages
   setBasePath
   // load hero image
   loadImage sConfigA ["portal-links"]["hero"]["image"], the long id of image "surprise_hero"
   
   loadImage sConfigA ["portal-links"]["verses"]["image"], the long id of image "portal-link-image" of group "surprise_verses"
   loadImage sConfigA ["portal-links"]["audio"]["image"], the long id of image "portal-link-image" of group "surprise_audio"
   loadImage sConfigA ["portal-links"]["video"]["image"], the long id of image "portal-link-image" of group "surprise_video"
   loadImage sConfigA ["portal-links"]["gurudeva"]["image"], the long id of image "portal-link-image" of group "surprise_gurudeva"
   loadImage sConfigA ["portal-links"]["bodhinatha"]["image"], the long id of image "portal-link-image" of group "surprise_bodhinatha"
   loadImage sConfigA ["portal-links"]["art"]["image"], the long id of image "portal-link-image" of group "surprise_art"
end loadPortalImages

command loadImage pImg, pTarget
   put (getPathToModulesFolder() & "surprise/" & pImg) into tImgPath
   logInfo "Loading image:" && tImgPath
   set the filename of pTarget to tImgPath
end loadImage


--> Events
-
on preOpenCard
  set the acceleratedRendering of this stack to true
  put getModuleConfiguration ("surprise") into sConfigA
  loadPortalImages
end preOpenCard

on opencard
  set the blendLevel of button "home-Logo" to 0
  send "hideLogo" to group "surprise_links" 
  set the vScroll of grp "surprise_links"  to 0 -- ensures correct initial alignment
  send "createScroller surprise_links" to me in 500 milliseconds
end opencard

on closeCard
  deleteMobileControl "surprise_links" 
end closeCard

on relaunch
   logInfo "went back to home module"
end relaunch
