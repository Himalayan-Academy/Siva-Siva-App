script "behavior_Listen"

local sCurrentPlayListA


on preopenstack
   wait 100 milliseconds with messages
   set the fullscreenmode of this stack to "showAll"
   mobile_SetAllowedOrientation "portrait"
end preopenstack

on openstack 
   # for V1 we know we are always coming from the Listen Portal
   # and these are basically playlists like on Spotify, though
   # some might qualify as albums, but we don't have enough to 
   # make a differentiation. So treat all as playlists
   
   # but we have different cards in this stack... 
   # let's decide where we are going first
   
   put  portal_GetLastLinkTitle() into tTargetPlayList   
   put "Bodhinatha's Latest Talks, The Guru Chronicles, Sanskrit Chanting, Gurudeva's Archives" into tLocalPlayLists
   # "Local playlist"  just means we are not sending anyone to a web page, but have a native UI 
   # for the songs here in the app
   
   if tTargetPlayList is among the items of tLocalPlayLists then
      # We set a play list 
      playlist_SetCurrent tTargetPlayList
      go to card "listen-playlists"  -- Behavior on card will handle the playlists.
   else
      # for later... when we build a more robust ui for audio
      # a "Home" card will supplement and "supplant" the listen portal 
      # which does not scale easily.
      go to card "listen-home"  
 end if
   
end openstack

# we don't know later how this will develop, so let's keep more robust
# functions all here in the stack script and we can make this a behavior later

on playlist_SetCurrent pList
   put pList into sCurrentPlayList   
end playlist_SetCurrent

function playlist_GetCurrent
   return sCurrentPlayList
end playlist_GetCurrent
