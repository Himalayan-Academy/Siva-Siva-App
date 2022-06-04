script "behavior_footerNavigation"
global sConfigA
local sButtons

# footerNavigation needs to be a "background" so that the "preOpenControl" message
# is received before "preOpenCard" is sent otherwise "updateUI" will crash with div by 0

on preOpenControl
   --breakpoint
   local tStack
   put the short name of this stack into tStack
   switch tStack
      case "gems"
         put "home,save,share,settings" into sButtons
         break
      case "lib_CustomControls" 
         put "home,journal,save,share,settings" into sButtons
         break
      default
         put "home,journal,share,settings" into sButtons
         hide btn "save" of me
         send "resizeControl" to me
   end switch
end preOpenControl


on mouseup  
   
   local tTarget, tShareControl, tControl, tCard, tLongTarget
   local tBrowserExists, tBrowser, tBrowserRect, tBrowseHeader
   local tCdHeight, tSharingHeight, tLastStack, tDownloadIsVisible
   local tMyMenuYesNo
   --
   lock screen
   put short name of the target into tTarget
   put the short name of this card into tCard
   put (there is a widget "body") into tBrowserExists
   put the long id of the target into tLongTarget
   --
   switch tTarget
      case "home"
         --         if tBrowserExists then
         --            terminateBrowser
         --         end if
         --         if checkIsLoading() is true then exit mouseup
         
         put the short name of this card into tCard
         
         if tCard is "SivaSivaBrowser" then
            put portal_GetLastStack() into tLastStack
            if tLastStack is "read" then
               portal_GoStack "read"
               exit mouseup
            end if
         end if
         
         if tCard is "surprise_verse" then
            go card "surprise_verses"
         else if tCard is among the items of "surprise,surprise_verses,surprise_audio,surprise_darshan,surprise_art" then
            go card "surprise_menu"
         else if tCard is "showStories" or tCard is "storyDeleteFile" then
            go card "storyHome"
         else if tCard is "storiesHome" and (the vis of grp "storiesMenu") = false then
            showStoryMenu
         else if tCard is "bookDetail" then
            go card "readHome"
         else if tCard is among the items of "listen-browse" then
            go card "listen-collection"
         else if tCard is among the items of "listen-my-audio" then
            go card "listen-browse"
         else if tCard is "listen-file" then
            --
            --            get runningAudioIndicatorVis("true")
            --            show grp "viewLogging"
            --            put sStopRunningAudio into fld "log"
            --            wait 1000 milliseconds
            --            show grp "viewLogging"
            --            exit to top
            --
            put getBrowseHeaderText() into tBrowseHeader
            --
            go card "listen-browse"
            send "CreateScroller audioList" to fld "audioList" of card "listen-browse"
            put tBrowseHeader into fld "title-label"
            --
            --            put portal_GetLastStack() into tLastStack
            --            put portal_GetMyMenu() into tMyMenuYesNo
            --            --
            --            if (tLastStack = "Journal") OR (tMyMenuYesNo = true) then            
            --               go card "listen-collection"
            --            else 
            --               if fld "FilesOnDisk" of card "listen-delete-file" is empty then
            --                  go card "listen-browse"
            --               else
            --                  go card "listen-my-audio"
            --               end if
            --         end if
            unlock screen
            
         else if tCard is "listen-delete-file" then
            go card "listen-browse"
            put "listen-browse" into tCard
            
         else if tCard is "listen-search" then
            go card "listen-collection"
            
         else if tCard is "listen-collection" then
            portal_GoStack ("Siva-Siva-Portal")
            
         else if tCard is "mainImagePuzzle" and \
               there is an image "tile_1"  then
            clearImageTiles
            show img "orion_nebula"
            show group "makeTiles"
            
         else
            portal_GoStack ("Siva-Siva-Portal")
         end if
         --
         break
         --
      case "journal"
         local sCityName 
         unlock screen
         --
         if tCard is "main-calendar" then
            put getCityName() into sCityName
            if sCityName is false then
               dialog_CustomMsg "Pick and Submit a City"
               exit mouseup
            end if
         end if
         --
         if tCard is "surprise_audio" then
            if the visible of grp "downloadSelection"  then
               dialog_CustomMsg "You have not Downloaded."
               exit to top
            end if
         end if
         --
         if tCard is among items of \
               "listen-collection, listen-browse, listen-my-audio, listen-delete-file, listen-search" then
            exit to top
         else
            put "listen-file" into tCard
         end if
         --
         moveMe target, 0,-100, 200
         moveMe target, 0,100, 70
         Journal_AddEntry
         dialog_CustomMsg "Saved to Journal"
         --
         break
         --
      case "save"
         unlock screen
         --
         move control target relative 0,-100 in 100 milliseconds
         move control target relative 0,100 in 70 milliseconds
         --
         Journal_AddEntry "pReadQuote"
         --
         break
         --
         
      case "share"
         unlock screen
         lock screen for visual effect
         put sConfigA["shareControl"] into tShareControl
         --
         if (exists(group "share-ui" of this card) ) then
            -- it has a preopencontrol which hides me
         else
            copy tShareControl to this card 
         end if
         --
         put the long id of group "share-ui" of this card into tControl
         bottomCenterMe tControl, -safeBottomMargin()
         if tBrowserExists then
            put the long id of widget "body" of this card into tBrowser
            put the rect of tBrowser into tBrowserRect
            put the top of tControl into item 4 of tBrowserRect
            set the rect of tBrowser to tBrowserRect
         end if
         --
         --deleteMobileControl "audioPlayer"
         show tControl with visual "dissolve" very fast
         --
         break
         --
      case "settings"
         if tBrowserExists then
            terminateBrowser
         end if
         portal_GoStack "settings"
         --
         break
         --
      default
         unlock screen
         pass mouseUp
   end switch
   unlock screen
end mouseup


command unHiliteBtn pTarget
   set the hilited of control pTarget to false
end unHiliteBtn


on updateUI
   set the width of me to CardWidth()
   bottomCenterMe (the long id of me), -safeBottomMargin()
end updateUI


on resizeControl
   local tHSpace, tV, tH, tControl, tRect
   put the width of me / (the number of items in sButtons) into tHSpace
   put item 2 of the loc of button 1 of me into tV
   put the left of me + (tHSpace / 2) into tH
   --
   repeat for each item tName in sButtons
      put the long name of btn tName of me into tControl
      set the width of tControl to tHSpace
      set the loc of tControl to (tH, tV)
      add tHSpace to tH
   end repeat
   --
   set the height of me to 50 + safeBottomMargin()
   set the bottom of me to CardHeight()
   set the rect of grc "footerBackground" to the rect of me
end resizeControl

