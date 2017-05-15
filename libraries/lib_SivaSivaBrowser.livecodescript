script "lib_SivaSivaBrowser"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaBrowser
type: library
version: 0.1


--> From API | Web Browser API
/*
Objective: library stack that provides auxiliary routines and UI for:

- viewing web pages,
- listening to audio and watching videos.

Its public API may be called from any stack. It will cause a defaultstack change as it takes over the app. 
Buttons for going "recent card" are provided and an optional  "relaunch" message is sent to the cards when going back

== PUBLIC API =-

-  launchURL <pOrientation>,<pURL>: launches given web page.
-  launchAudio <pURL>, [pOptionalImage]: launches the audio with an optional cover image.
-  launchBook <pFileID>: just a convenience method for launching books, internally it calls launchURL.

== Note ==

The browser widget has issues with dynamic resizing and repositioning (when using "set the fullscreenmode of this stack to 'showAll'").
This dynamic resizing works fine when a stack in the default (empty) - "set the fullscreenmode of this stack to empty"

While using 'showAll' it is not possible to have two cards in the same stack one portrait orientation and then dynamically change the size of the stack and resize the browser widget.
There are currently two fixes:

1) to have two different stacks preset for portrait or landscape. So we have to pass the orientation to fork to the correct Stack(s) which are put into use on start up as a lib
2) use responsive design and "set the fullscreenmode of this stack to empty"

BR: Note this stack offers options to use 1) above to fork  between
hapMediaViewerPortraitLib and hapMediaViewerLandscapeLib
but as of V1 these are not in use and all URLs are passed viea Portal_GoURL
to Davids responsive view_SivaSivaBrowser stack
which defaults to portrait orientation and responds 
when and if the users rotates the device.

But since this lib is put into use on init, we can use it to our advantage for all
all "vars needed for web browsing.  e.g. to store the last URL viewed in the web browser stack as a local 
so that value can be accessed by the journal before it is wiped out and also use to go back if necessary,
to the same web page.

*/


--> Browser | Public API

local sLastWebURL

command launchAudio pURL, pOptionalImage
   -- temporarily using launchURL for this one.
   launchURL pURL
end launchAudio

command launchBook pFileID
   get "https://www.himalayanacademy.com/book/" & pFileID
   launchURL it
end launchBook

command browser_SetLastURL pWebURL
   put pURL into sLastWebURL
end browser_SetLastURL

function browser_GetLastURL
   return sLasteWebURL
end browser_GetLastURL

command launchURL pOrientation, pURL
   if pOrientation = "" then -- try to determine based on media type
      put getOrientationByType(pURL) into tViewerType
   end if
   if pOrientation="portrait" then
      put "hapMediaViewerPortraitLib" into tNewViewer
      put "hapMediaViewerLandscapeLib" into tOldViewer
   else
      put "hapMediaViewerLandscapeLib" into tNewViewer
      put "hapMediaViewerPortraitLib" into tOldViewer
   end if
   if "hapMediaViewer" is in the openstacks then deleteMobileControl "browser" -- in case any exist
   go card "web viewer" of stack tNewViewer
   set the URL of widget "browser" of stack tNewViewer to pURL
   if tOldViewer is in the openStacks then delete stack tOldViewer -- device was rotated; close orig viewer
end launchURL


--> Browser | Utility handlers
-
function getOrientationByType pURL -- return correct orientation for a URL;
   -- called by launchURL and orientationChanged in browser cd of both viewer stacks
   -- Some media is locked to an orientation, some allow any.
   -- This tries to determine the allowed orientation for a media type.
   -- (Add slideshows later to landscape view)
   switch
      case pURL contains "youtube" --  a movie [add slideshow when URL format is known]
         --     case pURL contains "SLIDESHOW"  --### add when format is known
         return "landscape" 
         break
      case pURL contains "PORTRAIT" --### fix this when format is known
         return "portrait"
         break
      default
         return "any" -- allows rotation
   end switch
end getOrientationByType
