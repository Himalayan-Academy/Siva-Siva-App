script "behavior_globalNavControl"
###################
-- BR: 2018-12-4
-- the model for the global nav control 
-- which is be place on all card
-- for now will use the common library of SivaSivaPortal
-- all this need to do is call 
--  portal_DoRowLink tRowName
--  where to tRowName is the string we previous use
-- on the portals labels. 
-- not the string does now have a space. 

local sRowName, sMap, sFavoritesA

on preOpenCard
   put the short name of this card into pCard
   setUpUi pCard
end preOpenCard

on mouseup
   put empty into sFavoritesA
   put the short name of the target into tTarget
   if tTarget is among the items of "gems,surprise,listen,look,practice,read,websites,fun,journal,my home" then
      switch tTarget
         lock screen
         
         # Cases where we to go to stacks directly with no secondary navigation
      case "Gems"
      case "Surprise"
      case "Listen"
      case "Journal"
         portal_GoStack tTarget
         break
         
         # cases require connectivity
      case "Look"
      case "Websites"
         if checkConnectionStop() then
            getModuleList tTarget
         end if
         break
         
         # we need to get the modules, not connection required
      case "Fun"
      case "Practice"
      case "Read"
         getModuleList tTarget
         break
         # oad Journal Entries to My Home
      case "My home"
         go to card "modulesList"
         loadFavoritesToMyHome
         
         break
   end switch
end if
end mouseup

on getModuleList tTarget
   # we this on behavior on cards "MainNav"  and card "modulesList"
   # so have to dispatch from one common behavior to the card name, specifically 
   
   dispatch "loadModulesList" to card "modulesList" with tTarget 
   go to card "modulesList"
end getModuleList

on setUpUi pCard
   # we hide some controls on one are or another
   # this behavior it in both cards
   # Be sure to pass to preopencard handle
   switch pCard
      case "Home"
         break 
      case "modulesList"
         show widget "goToMainNav"
         break
      case "mainNav"
         hide widget "goToMainNav"
         break
   end switch
   
end setUpUi

function checkConnectionStop
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Connection required."
      return "false"
      exit to top
   else
      return "true"
   end if
end checkConnectionStop



on loadModulesList tTarget
   put getNavigationMap() into sMap 
   put sMap[portalData][tTarget][rowdata] into tRowdataA
   set dgData of grp "modulesList" of me to tRowdataA
   reSizeDataGrid 

end loadModulesList

command  loadFavoritesToMyHome
   
   put Journal_GetEntries() into tJournalEntriesA
   repeat for each key x in tJournalEntriesA
      if tJournalEntriesA[x]["is_favorite"] = 1 then
         add 1 to y
         put tJournalEntriesA[x]  into sFavoritesA[y]
         put sFavoritesA[y]["label"] into sFavoritesA[y]["rowname"]
      end if
   end repeat
   if sFavoritesA is empty then
      tellUserToGetFavorites
      exit to top
   end if
   set dgData of grp "modulesList"  of card "modulesList"  to sFavoritesA
   reSizeDataGrid 
end  loadFavoritesToMyHome

command reSizeDataGrid pNumOfRows
   put the dgNumberOfRecords of group "modulesList"  into tNumberOfRecords
   put the dgProp ["row height"] of group "modulesList" into tRowHeight
   Set the height of group "modulesList"  to min(12, tNumberOfRecords) * (tRowHeight) + 10 -- account for header and scrollbar
   --set the height of group "modulesList" of me to ( (67*pNumOfRows) )
   --set top of group "modulesList" of me to 100
end reSizeDataGrid

command launchModule
   put the dgHilitedLines of group "modulesList" into theLine
   put the dgDataOfLine[theLine] of group "modulesList" into theDataA
   if  theDataA["is_favorite"] is a number then
      Journal_LaunchEntry theDataA["journal_id"]
   else
      portal_DoRowLink theDataA["rowName"]
   end if
end launchModule
