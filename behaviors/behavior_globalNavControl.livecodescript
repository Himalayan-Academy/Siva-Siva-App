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

local sTarget



on hiliteChanged
   
   breakpoint
   
   put  the hilitedElement of me into sTarget
   
   
   if the number of items in the hilitedElement of me = 1 and the hilitedElementIsFolded of me then 
      set the foldstate of me to empty -- collapse all
   end if
   if the hilitedElement of me <> empty then
      set the hilitedElementIsFolded of me to not the hilitedElementIsFolded of me -- doesn't effect a leaf
      send "clearHilites" to me in 200 milliseconds
   else
      exit hiliteChanged
   end if
   --breakpoint
   put the uNavMap of me into sMap
   
   put the hilitedElementFoldState of me
   
   put the hilitedElement of me & the hilitedElementFoldState of me into tState
   
   put  the hilitedElement of me into sTarget 
   
   if sTarget is empty then exit hiliteChanged
   
   if the number of items of sTarget > 1 then
      delete item 1 of sTarget # we get the top menu out.
   end if
   delete char 1 to 3 of sTarget
   delete char -1 of sTarget
   -- move widget "globalNavTree"  to ( -420,vertCenter() ) in 10 ticks
   
   
   
   
   
   if sTarget is among the items of "Gems of Wisdom,Surprise Me,Listen,Look,Practice,Read,Websites,Fun & Games,Journal,My Home" then
      # These are top links, using the portaLabel, 
      # some go  directly to another module stack
      # other do nothing but expose content/other modules/pUrls on level two of the menu
      
      switch sTarget
         --lock screen
         
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
            # may no longer by needed
            --            if the platform is "iPhone" then
            --               # handle the shift of the main nav screen when returning
            --               set the destroyStack of this stack to false
            --            end if
            hideShowGlobalNav "false"
            portal_GoStack sTarget
            break
            
            # cases that require connectivity, 
            # and there are sub-level menu
            
         case "Look"
         case "Websites"
            if checkConnectionStop() then
               exit hiliteChanged
            end if
            break
            
            # no trigger ; Need to find out how the tree work... we should disabled these:
            
         case "Fun & Games"
            put "fun" into sTarget
            break
         case "Practice"
         case "Read"
            break
            
         case "My home"
            hideShowGlobalNav "false"
            go to card "modulesList"
            loadFavoritesToMyHome
            break
      end switch
   else
      # otherwise we have a URL on a different module
      # pass to lib_SivaSivaPortal to resolve
      hideShowGlobalNav "false"
      portal_DoRowLink sTarget
      
   end if
   
   
end hiliteChanged

command hideShowGlobalNav tBol
   switch tBol
      case "true"
         --if item 1 of the loc widget "globalNavTree"  = horizCenter() then
         move widget "globalNavTree" to -418,vertCenter()  in 10 ticks
         set the layer of button "backgroundOverlay" to 1
         set the blendlevel of button "backgroundOverlay" to 0
         break
      case "false"
         set the layer of button "backgroundOverlay" to (the layer of btn "openGlobalNav") -1
         set the blendlevel of button "backgroundOverlay" to 30
         move widget "globalNavTree" to cardLoc()  in 10 ticks
         break
   end switch
   
end hideShowGlobalNav

--on clearHilites -- except for leafs
--   if the hilitedElementFoldState of me <> "leaf" then
--      set the hilitedElement of me to empty
--   end if
--end clearHilites

function checkConnectionStop
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Connection required."
      return "false"
      exit to top
   else
      return "true"
   end if
end checkConnectionStop

--on formattedHeightChanged -- tree changed dimensions
--   LOG "FORMATTEDHEIGHTCHANGED"
--   updateMobileScroller (the short name of me)
--end formattedHeightChanged

command createNavTree
   set the numberformat to "00"
   put getNavigationMap() into  sMap
   set the uNavMap of widget "globalNavTree"  to sMap
   
   put 0 into tCt
   
   
   # set the order of appearance
   put "gems,surprise,listen,look,fun,practice,read,websites,journal,home" into tSortTopMenu
   
   #  manually set the modules that we go to directly to 
   # eliminate the deprecated row data in the json file
   # argh! is not among does not work...
   
   put "gems,listen,surprise,journal,home" into tSkipSubMenu
   
   repeat with x = 1 to the number of items in tSortTopMenu # Later, will have to refactor.
      
      put item x of tSortTopMenu into sTarget
      
      --repeat for each key sTarget in sMap["portalData"]
      
      set the numberformat to "00"
      add 1 to tCt
      put tCt && sMap["portalData"][sTarget]["portalLabel"] into tTopMenu
      
      
      put 0  into tSecondKey
      
      --breakpoint
      put  sMap["portalData"][sTarget]["portalName"] 
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
         -- delete variable  tRowName in aTreeA[tTopMenu][tRowName]
      end if
      
      
   end repeat
   
   --breakpoint
   set arraydata of widget "globalNavTree" to aTreeA
   
end createNavTree




--> ###################
-- BR: 2019-09-20
-- Previous handlers were related to now deprecated global nav card and datagrid
-- There are useful functions here, so we will keep the code intact for a while

--###################
---- BR: 2018-12-4
---- the model for the global nav control 
---- which is be place on all card
---- for now will use the common library of SivaSivaPortal
---- all this need to do is call 
----  portal_DoRowLink tRowName
----  where to tRowName is the string we previous use
---- on the portals labels. 
---- not the string does now have a space. 

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


--on mouseup
--   local sTarget

--   put empty into sFavoritesA
--   put the short name of the target into sTarget
--   if sTarget is among the items of "gems,surprise,listen,look,practice,read,websites,fun,journal,my home" then
--      switch sTarget
--         --lock screen

--         # Cases where we to go to stacks directly with no secondary navigation
--         case "Gems"
--         case "Surprise"
--         case "Listen"
--         case "Journal"
--            if the platform is "iPhone" then
--               # handle the shift of the main nav screen when returning
--               set the destroyStack of this stack to false
--            end if
--            portal_GoStack sTarget
--            break

--            # cases that require connectivity
--         case "Look"
--         case "Websites"
--            if checkConnectionStop() then
--               getModuleList sTarget
--            end if
--            break

--            # we need to get the modules, no connection required
--         case "Fun"
--         case "Practice"
--         case "Read"
--            getModuleList sTarget
--            break

--            # load Journal Entries to My Home
--         case "My home"
--            go to card "modulesList"
--            loadFavoritesToMyHome
--            break
--      end switch
--   end if
--end mouseup


--on getModuleList sTarget
--   # we this on behavior on cards "MainNav"  and card "modulesList"
--   # so have to dispatch from one common behavior to the card name, specifically 

--   go to card "modulesList"
--   dispatch "loadModulesList" to card "modulesList" with sTarget 

--end getModuleList


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

--function checkConnectionStop
--   if connectivity_PingServer() = "false" then
--      dialog_CustomMsg "Connection required."
--      return "false"
--      exit to top
--   else
--      return "true"
--   end if
--end checkConnectionStop


--on loadModulesList sTarget
--   breakpoint
--   local tRowdataA

--   portal_SetModulesList sTarget
--   put getNavigationMap() into sMap 
--   put sMap["portalData"][sTarget]["rowdata"] into tRowdataA
--   set dgData of grp "modulesList" of me to tRowdataA
--   reSizeDataGrid 
--   unlock screen
--end loadModulesList


--command  loadFavoritesToMyHome
--   local tJournalEntriesA, y

--   put Journal_GetEntries() into tJournalEntriesA
--   repeat for each key x in tJournalEntriesA
--      if tJournalEntriesA[x]["is_favorite"] = 1 then
--         add 1 to y
--         put tJournalEntriesA[x] into sFavoritesA[y]
--         put sFavoritesA[y]["label"] into sFavoritesA[y]["rowname"]
--      end if
--   end repeat
--   if sFavoritesA is empty then
--      tellUserToGetFavorites
--      exit to top
--   end if
--   set dgData of grp "modulesList" of card "modulesList" to sFavoritesA
--   reSizeDataGrid 
--end  loadFavoritesToMyHome




--command reSizeDataGrid pNumOfRows
--   local tNumberOfRecords, tRowHeight

--   put the dgNumberOfRecords of group "modulesList"  into tNumberOfRecords
--   put the dgProp ["row height"] of group "modulesList" into tRowHeight
--   Set the height of group "modulesList"  to min(12, tNumberOfRecords) * (tRowHeight) + 10 -- account for header and scrollbar
--   --set the height of group "modulesList" of me to ( (67*pNumOfRows) )
--   --set top of group "modulesList" of me to 100
--end reSizeDataGrid


--command launchModule
--   local tLine, tDataA

--   put the dgHilitedLines of group "modulesList" into tLine
--   put the dgDataOfLine[tLine] of group "modulesList" into tDataA
--   if  tDataA["is_favorite"] is a number then
--      Journal_LaunchEntry tDataA["journal_id"]
--   else
--      portal_DoRowLink tDataA["rowName"]
--   end if
--end launchModule


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
