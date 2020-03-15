script "lib_SivaSivaBrowser"
/* Brahmanathawami June 2017 --

David's code below target the two HAP media stacks. 
These are pretty much deprecated but we retain the code here for possible future utility
New functions/Commands on top. These are to handle any calls form anywhere relating
to web browsing, the browser widget so we hae all this in one place.  
IIf you are tempted to write code pertaining to a browser widget in our module. 
Think first: can we put those functons andcommands here, so they can be used universally later.

*/

local sLastWebPageTitle, sLastWebURL

# we store the <title> in the <head> here so we can reference this later the journal.
# hopefully this will clue the user into what page they were viewing.
# requires the web site has "intelligent" titles, which most pages do for SEO reasons)

command parseTheHTML pHtmlText, pTargetString
   # use for scraping out anything from the htmltext of a browser widget
   # must call *after* URL loads
   local tStartTitle,tEndTitle,tRawTitle
   switch pTargetString
      case "Title"
         put (offset ("<Title>", pHTMLText) +7) into tStartTitle
         put (offset ("</Title>", pHTMLText) -1) into tEndTitle
         put  (char tStartTitle to tEndTitle of pHTMLText) into tRawTitle
         replace cr with "" in tRawTitle
         replace tab with "" in tRawTitle
         # we are inconsistent in the title delimiter passed in our CMS
         # sometime the leading "realm" is separated by a colon, other time a dash
         replace ": " with "-" in tRawTitle # normalize all those...
         set the itemdel to "-" # set up for two part titles
         if tRawTitle contains "YouTube" then # leave it alone
            put "YouTube" into sLastWebPageTitle  # upgrade this later... 
         else # from our web site
            if browser_GetLastURL() contains "/book/" then
               # pass just the first words
               put word 1 to 5 of tRawTitle into tRawTitle
            else
               # not a book page...
               if the number of items of tRawTitle = 2 then
                  put item 2 of tRawTitle into tRawtitle
               end if
               If char 1 of tRawTitle = " " then 
                  delete char 1 of tRawTitle
               end if   
            end if
            
         end if
         put tRawTitle into sLastWebPageTitle
         break
   end switch
end parseTheHTML

function titleFromURL pURL
   put false into tFileID   
   set the itemdel to slash
   put item 4 of pURL into tSlug
   switch tSlug
      case "media"
         put item 6 of pURL into tFileID
         break
      case "view"
         put item 5 of pURL into tFileID
         break
   end switch
   if tFileID is not false then
      put jnanam_GetItem(tFileID) into tItemA
      switch tItemA["media_type"]
         case "text/book"
            put the merge of "https://dev.himalayanacademy.com/media/books/[[tFileID]]/web/toc.html" into tTocURL
            put url tTocURL into tTocHTML
            put item -1 of pURL into tFilename
            if tFilename is tFileID then
               return tItemA["title"]
            end if
            put offset(tFilename, tTocHTML) into tStart
            put tStart + offset("</a>", tTocHTML, tStart) into tEnd
            put char tStart to tEnd of tTocHTML into tChunk
            put the merge of "<a href=\'[[tChunk]]/a>" into tHTMLChunk
            create inv field "htmltitle"
            set the htmltext of field "htmltitle" to tHTMLChunk
            put the text of field "htmltitle" into tTitle
            delete field "htmltitle"
            return tItemA["title"] & ":" && tTitle
            break
         default
            return tItemA["title"]
      end switch
   else
      // not an item from jnanam
      put url pURL into tHTML
      put matchText(tHTML, "<title>(.*?)</title>", tTitle) into tHasTitle
      if tHasTitle then
         return tTitle
      else
         return "Unknown title"
      end if
   end if
end titleFromURL

function browser_GetLastPageTitle
   return sLastWebPageTitle
end browser_GetLastPageTitle

command browser_SetLastURL pWebURL
   put pWebURL into sLastWebURL
end browser_SetLastURL

function browser_GetLastURL
   return sLastWebURL
end browser_GetLastURL

########### MOSTLY OBSOLETE: 

--> MetaData

-- license: GPLv3
-- name: lib_SivaSivaBrowser
-- type: library
-- version: 0.1 by: David Bovill


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
--> BR: all the following apply to the two HapMedia viewer stacks, mostly deprecated 


command launchAudio pURL, pOptionalImage
   -- temporarily using launchURL for this one.
   launchURL pURL
end launchAudio

command launchBook pFileID
   get "https://www.himalayanacademy.com/book/" & pFileID
   launchURL it
end launchBook


command launchURL pOrientation, pURL
   local tViewerType, tNewViewer,tOldviewer
   ntInfo pURL
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
