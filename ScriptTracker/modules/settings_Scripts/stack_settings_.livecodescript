Script "stack_settings_"

/*
# Name: stack "settings"
# ID: stack "settings"
*/


on preopenstack
   
   if isMobile() then  
      set the fullscreenMode of this stack to "showAll"  
      --mobileSetFullScreenRectForOrientations "landscape left,landscape right","0,0,414,736"
      mobileSetAllowedOrientations "portrait,portrait upside down"
      mobileShowStatusBar
   end if
   # Livecode is terrible running animation 
   # Or I have yet to figure out the method, but Gif animation does not well.
   --runFishAnimation
end preopenstack

on closeStack
   portal_SetLastStack "settings"
   if isMobile() then
      display_SetStatusBarVis "false"
   end if  
end closeStack

command HandleToastDialog
   quit
end HandleToastDialog

command runFishAnimation
   set the right of img "tropical-fish-1" to -10
   move img "tropical-fish-1" relative 900,0 in 25 seconds without waiting
end runFishAnimation




