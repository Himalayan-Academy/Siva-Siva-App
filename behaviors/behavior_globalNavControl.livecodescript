script "behavior_globalNavControl" with behavior "behavior_mobileScroller"
--> ###################
-- BR: 2019-09-20
-- This behavior is assigned to the widget "globalNavTree" which, initially, is part of the
-- And to grp "navMandala"
-- Siva-Siva-Portal stack, card "home" 
-- conceivably is could be implement "app wide" to take the user 
-- where he wanted to go without going "Home" 
-- so, with that in mind, we do not want to have this behavior dependent 
-- on any "local stuff" which can only be found it the portal stack -> home card
-- there are useful functions here, so we will keep the code intact for a while
-- to call these handlers and functions use a dispatch from any other script ot behavior

local sTarget,sFavoritesA,sWhichMenu


######### -- Tree Widget Handlers -- ##########
on hiliteChanged
   local sMap, tHilitedElement
   
   put the hilitedElement of me into tHilitedElement
   
   # need to check at the top of the handler since we manually clear the
   # highlight after it is processed
   if tHilitedElement is empty then exit hiliteChanged
   
   --breakpoint
   set the pathDelimiter of me to "|"
   put the uNavMap of me into sMap
   put the uWhichMenu of me into sWhichMenu
   
   #  BR: we have to play with hilited node of the tree of make sure we can "hits"
   # frankly, I don't have a handle on this yet, 
   
   lock screen
   if the number of items in the hilitedElement of me = 1 and the hilitedElementIsFolded of me then 
      set the foldstate of me to empty -- collapse all
   end if
   
   set the hilitedElementIsFolded of me to not the hilitedElementIsFolded of me -- doesn't effect a leaf
   unlock screen
   
   --breakpoint
   
   # only call from the Tree
   put truncateTarget(tHilitedElement) into sTarget
   
   # conceivably, various kind of menus could be presented
   # handle each one separately (saves stepping thru code)
   switch sWhichMenu 
      case "MainMenu" 
         goMainMenu
         break 
      case "myMenu"
         goMyMenu
         break
   end switch
   
   # Clear the highlight after it is processed
   set the hilitedElement of me to empty
end hiliteChanged


function truncateTarget sTarget
   set the itemdelimiter to "|"
   if the number of items of sTarget > 1 then
      delete item 1 of sTarget # if is a leaf, delete first part of path
   end if
   set the itemdelimiter to comma
   delete char 1 to 3 of sTarget
   if (char -1 of sTarget = ",")  OR (char -1 of sTarget = "|") then delete char -1 of sTarget
   return sTarget
end truncateTarget


--> ####### GoMainMenu #####
-- This is Tree Specific and 
-- 


command goMainMenu
   # if this is a "portal" node, it means that it has sublevel elements 
   # and therefore, its only job it to expose the second level
   # now, the tree widget does this automatically, so no code is necessary for
   # but to save processing time: we explicity exit.
   
   if sTarget is among items of "Practice,Read,Fun & Games" then
      exit goMainMenu
   end if
   
   if sTarget is among the items of "Gems of Wisdom,Surprise Me,surprise,Listen,Look,Video,Websites,Journal,My Menu" then
      # These are top links, using the portaLabel, 
      # some go  directly to another module stack
      # Some have to trigger connectivity, but do nothing (look and websites)
      
      switch sTarget
         
         # Cases where we to go to stacks directly with no secondary navigation
         case "Gems of Wisdom"
            put "gems" into sTarget # portal stack in not its "label"
            portal_GoStack sTarget
            break
         case "Surprise Me"
            put "surprise" into sTarget
         Case "surprise"
            portal_GoStack sTarget
            break
         case "Listen"
            portal_GoStack sTarget
            break
         case "Journal"
            portal_GoStack sTarget
            break
            
            # cases that require connectivity, 
            # and there are sub-level URLs or Modules
            
         case "Look"
         case "Video"
         case "Websites"
            if checkConnectionStop() is "false" then
               set the foldState of me to empty
               exit goMainMenu
            end if
            break
            
         case "Fun & Games"
            put "fun" into sTarget
            break
         case "Practice"
         case "Read"
            break
            
         case "My Menu"
            loadFavoritesToMyHome
            break
      end switch
   else
      # otherwise we have a URL or a different module
      # pass to lib_SivaSivaPortal to resolve
      --hideShowGlobalNav "false"
      portal_DoRowLink sTarget
   end if
end goMainMenu
   
command goMyMenu
   local aTreeA, tMenuItem, pModule, pData
   
   # User want to switch menus
   # avoid stepping thru unecessarily
   
   if sTarget = "(Back to Main Menu)" then
      set arraydata of widget "globalNavTree" to (the uMainMenuArray of me)
      set the uWhichMenu of me to "mainMenu"
      exit goMyMenu
   end if
   
   # Otherwise 
   
   put the arraydata of me into aTreeA 
   
   repeat for each key tKey in aTreeA
      
      put truncateTarget(tKey) into tMenuItem
      if sTarget = tMenuItem then
         --breakpoint
         put item 1 of aTreeA[tKey] into pModule
         put item 2  to -1 of aTreeA[tKey] into pData
         
         # see model_SivaSivaJournal for this next handler
         # first parameter is a lookup ID from database 
         # But we have the data already,  when made the tree array my My Menu
         #  So we don't have to go to disk again... So leave it empty
         --hideShowGlobalNav "true"
         Journal_LaunchEntry ,pModule,pData 
         exit repeat
      end if
      
   end repeat
   
end goMyMenu

command setGlobalNavVisible pVisible
   
   lock screen for visual effect
   
   if pVisible is true then
      hide grp "subNav"
      hideMandala
      hide img "homeMainImage"
      show btn "backgroundOverlay"
      show grp "globalNavigation"
      createScroller "globalNavTree"
   else
      showMandala
      hide grp "globalNavigation"
      deleteMobileControl "globalNavTree"
   end if
   unlock screen with visual effect "dissolve" fast
end setGlobalNavVisible



command  loadFavoritesToMyHome
   local tJournalEntriesA, y
   
   put Journal_GetEntries() into tJournalEntriesA
   repeat for each key x in tJournalEntriesA
      if tJournalEntriesA[x]["is_favorite"] = 1 then
         add 1 to y
         put tJournalEntriesA[x] into sFavoritesA[y]
      end if
   end repeat
   
   if sFavoritesA is empty then
      tellUserToGetFavorites
      exit to top
   end if
   
   -----------------
   # instead go out to a datagrid, we will try build a new array from the tree menu
   
   createNavTree "MyMenu"
   
   
end  loadFavoritesToMyHome

-- BM:  From MainNav card script
command tellUserToGetFavorites 
   doAnswer "No Favorites in My Menu. Go to the Journal." && \
         "Click the star to chose Favorites. They will appear in My Menu", \
         "OK","downloadAffirmed"
end tellUserToGetFavorites

command downloadAffirmed
   lock screen
   portal_GoStack "Journal"
   unlock screen
end downloadAffirmed


function checkConnectionStop
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Connection required."
      return "false"
      exit to top
   else
      return "true"
   end if
end checkConnectionStop





on formattedHeightChanged -- tree changed dimensions
   updateScroller (the short name of me)
end formattedHeightChanged

on openCard
   -- path delimiter is not currently saved with the widget
   set the pathDelimiter of me to "|"
end openCard

on closeCard
   showMandala
   set the uWhichMenu of me to "mainMenu"
   deleteMobileControl (the short name of me)
   deleteMobileControl ("SubNavfld")
   pass closecard
end closeCard

###### ###-- Utility Handlers -- ###########
# Run to create a new array an  save it to the tree 
# before production


command createNavTree pMenu
   local tCt, sMap, tSortTopMenu, tSkipSubMenu, tTopMenu, tSecondKey, tRowName, aTreeA, tSortKey, tData
   local tKeys
   set the pathDelimiter of me to "|"
   
   set the numberformat to "00"
   put 0 into tCt
   
   switch pMenu
      case "mainMenu"
         --breakpoint
         put getNavigationMap() into  sMap
         set the uWhichMenu of me to "mainMenu"
         
         set the uNavMap of widget "globalNavTree"  to sMap
         --breakpoint
         # set the order of appearance
         put "gems,surprise,listen,stories,look,fun,practice,read,websites,journal,settings,myMenu" into tSortTopMenu
         
         #  manually set the modules that we go to directly to 
         # eliminate the deprecated row data in the json file
         # argh! is not among does not work...
         
         put "gems,listen,surprise,stories,journal,settings,myMenu" into tSkipSubMenu
         
         repeat with x = 1 to the number of items in tSortTopMenu # Later, will have to refactor.
            put item x of tSortTopMenu into sTarget
            add 1 to tCt
            put tCt && sMap["portalData"][sTarget]["portalLabel"] into tTopMenu
            put 0  into tSecondKey
            
            --breakpoint
            
            if sMap["portalData"][sTarget]["portalName"] is not among the items of tSkipSubMenu then
               put the keys of sMap["portalData"][sTarget]["rowdata"] into tKeys
               sort lines of tKeys ascending numeric
               --repeat for each key tSecondLevel in sMap["portalData"][sTarget]["rowdata"]
               repeat for each line tSecondLevel in tKeys
                  add 1 to tSecondKey
                  put sMap["portalData"][sTarget]["rowdata"][tSecondLevel]["rowName"] into tRowName
                  put tSecondKey && tRowName into  tRowName
                  put  tRowname into aTreeA[tTopMenu][tRowName]
                  put empty into aTreeA[tTopMenu][tRowName]
               end repeat
               
            else
               # how to get rid of the row data being carried over to the next loop?
               put empty into aTreeA[tTopMenu]
               
            end if
            
         end repeat
         set the uMainMenuArray of me to aTreeA
         break
         
      case "myMenu"
         set the uWhichMenu of me to "myMenu"
         
         put the keys of sFavoritesA into tSortKey
         sort lines of tSortKey
         repeat for each line tKey in  tSortKey
            add 1 to tCt
            put tCt && sFavoritesA[tKey]["label"] into tTopMenu
            --put empty into aTreeA[tTopMenu]
            
            put sFavoritesA[tKey]["module"]  &","  & sFavoritesA[tKey]["data"] into tData
            put tdata into aTreeA[tTopMenu]
         end repeat
         
         add 1 to tCT
         put tCt && "(Back to Main Menu)" into tTopMenu
         put empty into aTreeA[tTopMenu]
         
         break
         
   end switch
   
   --breakpoint
   set arraydata of widget "globalNavTree" to aTreeA
   
end createNavTree

