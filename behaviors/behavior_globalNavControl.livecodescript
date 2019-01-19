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
         # Cases where we to go to stake with no secondary navigation
         
      case "look"
         go to card "Look"
         break
      case "Gems"
      case "Surprise"
      case "listen"
      case "Journal"
         portal_GoStack tTarget
         break
      case "My home"
         # we need to get the napMap item 
         # from the the journal
         loadFavoritesToMyHome
         go to card "modulesList"
         break
      default
         # we this on behavior on cards "MainNav"  and card "modulesList"
         # so have to dispatch from one to the other 
         # ...we refactor then to two card
         go to card "modulesList"
         dispatch "loadModulesList" to card "modulesList" with tTarget 
   end switch
end if
end mouseup

on setUpUi pCard
   # we hide some controls on one are or another
   # this behavior it in both cards
   # Be sure to pass to preopencard handle
   switch pCard
      case "Home"
         # maybe use later....
         --hide widget "goHome".
         break 
      case "modulesList"
         hide widget "GoHome"
         show widget "goToMainNav"
         break
      case "mainNav"
         show widget "GoHome"
         hide widget "goToMainNav"
         break
         break
   end switch
   
end setUpUi



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
   set dgData of grp "modulesList" of me to sFavoritesA
   reSizeDataGrid 
   setControlUI "modulesList"
end  loadFavoritesToMyHome

command reSizeDataGrid pNumOfRows
   put the dgNumberOfRecords of group "modulesList" of me into tNumberOfRecords
   put the dgProp ["row height"] of group "modulesList" of me into tRowHeight
   Set the height of group "modulesList" of me to min(12, tNumberOfRecords) * (tRowHeight) + 36 -- account for header and scrollbar
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
