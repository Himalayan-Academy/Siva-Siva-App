script "behavior_globalNavControl"
--> ###################
-- BR: 2019-09-20
-- This behavior is assigned to the widget "globalNavTree" which, initially, is part of the
-- Siva-Siva-Portal stack, card "home" 
-- conceivably is could be implement "app wide" to take the user 
-- where he wanted to go without going "Home" 
-- so, with that in mind, we do not want to have this behavior dependent 
-- on any "local stuff" which can only be found it the portal stack -> home card
-- there are useful functions here, so we will keep the code intact for a while

local sTarget,sFavoritesA,sWhichMenu,



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
   
   if the number of items in the hilitedElement of me = 1 and the hilitedElementIsFolded of me then 
      set the foldstate of me to empty -- collapse all
   end if
   --   if the hilitedElement of me <> empty then
   set the hilitedElementIsFolded of me to not the hilitedElementIsFolded of me -- doesn't effect a leaf
   --      send "clearHilites" to me in 200 milliseconds
   --   else
   --      exit hiliteChanged
   --   end if
   --   ----------
   --   put  the hilitedElement of me into sTarget
   
   --breakpoint
   
   --   if sTarget is empty then exit hiliteChanged
   
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


command goMainMenu
   # if this is a "portal" node, it means that it has sublevel elements 
   # and therefore, its only job it to expose the second level
   # now, the tree widget does this automatically, so no code is necessary for
   # but to save processing time: we explicity exit.
   
   if sTarget is among items of "Practice,Read,Fun & Games" then
      exit goMainMenu
   end if
   
   if sTarget is among the items of "Gems of Wisdom,Surprise Me,Listen,Look,Websites,Journal,My Menu" then
      # These are top links, using the portaLabel, 
      # some go  directly to another module stack
      # Some have to trigger connectivity, but do nothing (look and websites)

      switch sTarget
         
         # Cases where we to go to stacks directly with no secondary navigation
         case "Gems of Wisdom"
            put "gems" into sTarget # portal stack in not its "label"
            hideShowGlobalNav "false"
            portal_GoStack sTarget
            break
         case "Surprise Me"
            put "surprise" into sTarget
            hideShowGlobalNav "false"
            portal_GoStack sTarget
            break
         case "Listen"
            hideShowGlobalNav "false"
            portal_GoStack sTarget
            break
         case "Journal"
            # may no longer by needed?
            --            if the platform is "iPhone" then
            --               # handle the shift of the main nav screen when returning
            --               set the destroyStack of this stack to false
            --            end if
            hideShowGlobalNav "false"
            portal_GoStack sTarget
            break
            
            # cases that require connectivity, 
            # and there are sub-level URLs or Modules
            
         case "Look"
         case "Websites"
            if checkConnectionStop() is "false" then
               set the foldState of me to empty
               exit goMainMenu
            end if
            break
            
            --               # no trigger ; Need to find out how the tree work... we should disabled these:
            
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
      # otherwise we have a URL on a different module
      # pass to lib_SivaSivaPortal to resolve
      hideShowGlobalNav "false"
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
         hideShowGlobalNav "true" 
         Journal_LaunchEntry ,pModule,pData 
         exit repeat
      end if
      
   end repeat
   
end goMyMenu

command setGlobalNavVisible tVisible
   lock screen for visual effect
   if tVisible is true or tVisible is "true" or tVisible is "yes" then
      show grp "globalNav"
      show button "brandLogo"
   else
      hide grp "globalNav"
      hide button "brandLogo"
   end if
   unlock screen with visual effect "dissolve" very fast
end setGlobalNavVisible

command hideShowGlobalNav tBol
   # tBol is vis of the tree,
   # if it is true then we toogle to hide it
   # otherwise, toggle to show it
   lock screen for visual effect
   switch tBol
      case "true" --means we intend to show the tree, should overlay main image
         hide grp "globalNav"
         hide button "brandLogo"
         break
      case "false" --means we intend to hide the tree, should show main image
         show grp "globalNav"
         show button "brandLogo"
         break
   end switch
   unlock screen with visual effect "dissolve" very fast
end hideShowGlobalNav

--on clearHilites -- except for leafs
--   if the hilitedElementFoldState of me <> "leaf" then
--      set the hilitedElement of me to empty
--   end if
--end clearHilites


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
   doAnswer "There are no Favorites in My Menu yet. Go to the Journal." && \
         "Click the star by some of your Favorites. They will then appear in My Menu", \
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


on closeCard
   set the uWhichMenu of me to "mainMenu"
   pass closecard
end closeCard

--on formattedHeightChanged -- tree changed dimensions
--   LOG "FORMATTEDHEIGHTCHANGED"
--   updateMobileScroller (the short name of me)
--end formattedHeightChanged

command createNavTree pMenu
   local tCt, sMap, tSortTopMenu, tSkipSubMenu, tTopMenu, tSecondKey, tRowName, aTreeA, tSortKey, tData
   set the pathDelimiter of me to "|"
   
   set the numberformat to "00"
   put 0 into tCt
   
   switch pMenu
      case "mainMenu"
         
         put getNavigationMap() into  sMap
         set the uWhichMenu of me to "mainMenu"
         
         set the uNavMap of widget "globalNavTree"  to sMap
         --breakpoint
         # set the order of appearance
         put "gems,surprise,listen,look,fun,practice,read,websites,journal,myMenu" into tSortTopMenu
         
         #  manually set the modules that we go to directly to 
         # eliminate the deprecated row data in the json file
         # argh! is not among does not work...
         
         put "gems,listen,surprise,journal,myMenu" into tSkipSubMenu
         
         repeat with x = 1 to the number of items in tSortTopMenu # Later, will have to refactor.
            put item x of tSortTopMenu into sTarget
            add 1 to tCt
            put tCt && sMap["portalData"][sTarget]["portalLabel"] into tTopMenu
            put 0  into tSecondKey
            
            --breakpoint
            
            if sMap["portalData"][sTarget]["portalName"] is not among the items of tSkipSubMenu then
               
               repeat for each key tSecondLevel in sMap["portalData"][sTarget]["rowdata"]
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




--> ###################
-- BR: 2019-09-26
-- Previous handlers were related to now deprecated global nav card and datagrid
-- have deleted card: moduleList, mainNav, now only three card:

-- Home
-- Surprise Index 
-- a bland card name "index-temp"

-- Possibly some of the following geometry/responsive needs to re-done 



--local sRowName, sMap, sFavoritesA

--on preOpenCard
--   local pCard

--   lock screen
--   put the short name of this card into pCard
--   setUpUI pCard

--   if getPhoneModel() is "iPhoneX" then
--      mobileShowStatusBar
--   end if
--end preOpenCard

--on resizeStack
--   local pCard

--   lock screen
--   put the short name of this card into pCard
--   setUpUI pCard
--   unlock screen
--end resizeStack

--on setUpUI pCard
--   # we hide some controls on one are or another
--   # this behavior it in both cards
--   # Be sure to pass to preopencard handle
--   switch pCard
--      case "Home"
--         break 
--      case "modulesList"
--         if the platform is "iPhone" then
--            # handle the shift of the main nav screen (return to original setting)
--            set the destroyStack of this stack to true
--         end if
--         show button "goToMainNav"
--         break
--      case "mainNav"
--         hide button "goToMainNav"
--         break
--   end switch
--   updateUI
--end setUpUi


--## GEOMETRY

--command updateUI
--   local pControl, tBottomMargin

--   if safeBottomMargin() > 0 then
--      put 0 into tBottomMargin
--   else
--      put 8 into tBottomMargin
--   end if

--   setCardCoords "portrait"
--   put the long id of grp "footer" into pControl
--   bottomCenterMe pControl,tBottomMargin
--   put the long id of btn "backgroundOverlay" into pControl
--   centerMe pControl
--   put the long id of of group "modulesList" into pControl
--   set the width of pControl to CardWidth() - 20
--   topCenterMe pControl,100
--end updateUI
