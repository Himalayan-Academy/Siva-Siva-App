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

- to have two different stacks preset for portrait or landscape. So we have to pass the orientation to fork to the correct Stack(s) which are put into use on start up as a lib
- use responsive design and "set the fullscreenmode of this stack to empty"

*/


--> Browser | Public API
-
command launchAudio pURL, pOptionalImage
   -- temporarily using launchURL for this one.
   launchURL pURL
end launchAudio

command launchBook pFileID
   get "https://www.himalayanacademy.com/book/" & pFileID
   launchURL it
end launchBook

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
   if tOldViewer is in the openStacks then close stack tOldViewer -- device was rotated; close orig viewer
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

function pingServer
   -- currenlty ony used by stack "gems"
    --jg: UTF8 text file on server should contain only the word "true"
   get url "https://www.himalayanacademy.com/ping.txt"
   return textDecode(it,"UTF8") = "true"
end pingServer
