script "behavior_JournalListView"
/**
TODO:
- There is a bug with font copying to android. The folder returned by the assets lib doesn't work
*/

local sLastFilter

on preopencard
  deleteAllMobileControls
  # uncomment this when you go into production:
  # i.e. leave out if you want to use the controls on the device while
  # testing

  --HideAuxiliaryControls


  --loadFonts
  layoutScreen

end preopencard

on HideAuxiliaryControls
   if the environment is "development" then
      exit HideAuxiliaryControls
   end if

   repeat with x = 1 to  the number of controls of this card
      if the cAuxiliary of control x of this card is true then
         hide control x of this card
      end if
   end repeat
end HideAuxiliaryControls

on closeCard
  --deleteAllMobileControls
end closeCard

command loadFonts
   --    if the environment is mobile then
   --       put specialFolderPath("engine") & "/assets/fonts" into tFontFolder
   --    else
   --       put sivasiva_AssetFolder() & "assets/fonts" into tFontFolder
   --    end if
   --    put (tFontFolder & "/OpenSans-Light.ttf") into tFontPath
   --    start using font file tFontPath
   if the result is not empty then
      answer error the result
      put "Error loading font:"&& tFontPath
      put the defaultfolder into tDF
      set the defaultfolder to tFontFolder
      put "default: " && tFontFolder
      put "exists?" && there is a folder tFontFolder

      put the files
      set the defaultfolder to tDF
   end if
end loadFonts

function checkDateRange pEntryA, pDateRange
   put pEntryA["date"] into tDate
   -- since LC doesn't understand the SQLite date format. this is a hack to emulate dateitems.
   set the itemdel to "-"
   put item 1 of tDate, item 2 of tDate, item 3 of tDate into tDate 
   replace " " with "," in tDate
   replace ":" with "," in tDate
   put ",1" after tDate
   set the itemdel to comma
   if char 1 of item 2 of tDate is 0 then
      delete char 1 of item 2 of tDate
   end if
   if char 1 of item 3 of tDate is 0 then
      delete char 1 of item 3 of tDate
   end if
   
   -- end of not-clever dateitems hack.
   put the internet date into tTodayDate
   convert tTodayDate to dateitems
   set the itemdel to comma
   switch pDateRange
      // LAST 3 DAYS
      case "Last 3 Days"
         convert tTodayDate to seconds
         convert tDate to seconds
         put 3 * 24 * 60 * 60 into tThreeDays
         
         get tTodayDate - tDate 
         if it <= tThreeDays then
            return true
         end if
         
         return false
         break
         // THIS WEEK
      case "Last 7 Days"
         convert tTodayDate to seconds
         convert tDate to seconds
         put 7 * 24 * 60 * 60 into tSevenDays
         
         
         get tTodayDate - tDate 
         if it <= tSevenDays then
            return true
         end if
         
         return false
         break
      case "This Month"
         if item 2 of tTodayDate is item 2 of tDate then
            if item 1 of tTodayDate is item 1 of tDate then
               return true
            end if
         end if
         return false
         break
      case "Last 6 Months"
         if item 1 of tTodayDate is item 1 of tDate then
            if item 2 of tTodayDate - item 2 of tDate <= 6 then
               return true
            end if
         end if
         return false
         break
      case "All"
      default
         return true
         break
   end switch
end checkDateRange
   
on layoutScreen pModuleFilter, pDateRange
   lock screen
   log_Debug "======================"
   if (pModuleFilter, pDateRange) is sLastFilter then
      log_Debug "Do nothing, same as last filter"
      exit layoutScreen
   end if
   put pModuleFilter, pDateRange into sLastFilter
   log_Debug "pModuleFilter:" && pModuleFilter
   log_Debug "pDateRange:" && pDateRange
   put the millisecs into tStart
   -- set card
   set the backgroundColor of this card to getConfigForLayout("listView", "cardBackgroundColor")
   
   -- set header
   
   -- fix group rect
   
   set the width  of group "header" to the width of this card +8
   set the left of group "header" to -4
   set the top of group "header" to 0
   set the margins of group "header" to 0
   
   set the width  of  grc "header bar"  to the width of this card +20
   set the loc of grc "header bar" to the loc of this card
   
   # must always do this because LC defaults to a margin of 4
   # this offsets elements in the group. So your controls will be topleft 4,4 even if you set them to 0,0
   # so eliminate the margins in the group first.
   
   set the height of grc "header bar" to getConfigForLayout("listView", "headerHeight")
   -- couldn't find a good way to set the gradient programatically, so commented the code below and set it
   -- by hand using the inspector
   --    set the backgroundColor of grc "header bar" to getConfigForLayout("listView", "headerBackgroundColor")
   set the topleft of grc "header bar" to 0,0
   
   -- set the textFont of fld "header text" to "Open Sans Light"
   set the width of fld "header text" to the width of this card
   set the height of fld "header text" to getConfigForLayout("listView", "headerHeight")
   set the foreColor of fld "header text" to getConfigForLayout("listView", "headerColor")
   set the topleft of fld "header text" to 0,0
   set the left of widget "Go Back" to 12
   set the htmltext of fld "header text" to getConfigForLayout("listView", "headerLabel")
   
   -- set item list
   if there is a group "item list" then
      delete group "item list"
   end if
   put Journal_GetEntries() into tEntriesA
   put 1 into tEntryNum
   repeat for each element tEntryA in tEntriesA
      switch
         case pModuleFilter is  empty and pDateRange is empty
         case tEntryA["module"] is pModuleFilter
         case pModuleFilter is "Favorites" and tEntryA["is_favorite"] is 1
         case pDateRange is not empty and checkDateRange(tEntryA, pDateRange)
            createNewJournalEntry tEntryA, tEntryNum
            add 1 to tEntryNum
            break
      end switch
   end repeat
   
   
   if there is a group "item list" then
      put the topleft of group "item list" into tTopLeft
      put the width of this card - 3, the height of this card - 10 into tBottomRight
      set the rect of group "item list" to tTopLeft, tBottomRight
      
      set the behavior of group "item list" to (the long id of stack "behavior_mobileScroller")
      set the layerMode of grp "item list" to "scrolling"
      --if isMobile then
      put "item list" into tScrollingGroup
      dispatch "CreateScroller" to group "item list" with "item list"
      --end if
   end if
   log_Debug "took:"&& the millisecs - tStart && "millisecs to run"
   unlock screen
   set the acceleratedRendering of this stack to true
end layoutScreen

on createNewJournalEntry pEntryA, pEntryNum
   if there is not a group "item list" then
      new group "item list"
   end if

   put the long id of group "item list" into tListGroup
   set the lockUpdates of tListGroup to true
   copy group "item template" of card "templates" to tListGroup
   put the long id of it into tListItem
   set the journalEntry of tListItem to pEntryA
   set the itemOrder of tListItem to pEntryNum
 end createNewJournalEntry

 function crlist
   repeat with x = 1 to the paramcount
      put param(x) & cr after tRetVal
   end repeat
   delete char -1 of tRetVal
   return tRetVal
 end crlist

on filterByDate
   -- stub
   
   put crlist("All", "Last 3 Days", "Last 7 Days", "This Month", "Last 6 Months") into tList
   if isMobile() then
      mobilePick tList, "cancel"
      put the result into tLineNum
      put line tLineNum of tList into tDateRange
      layoutScreen empty, tDateRange
   else -- desktop
      put tList into btn "filterPopup"
      -- Possible bug: the code should block on the popup call until menupick runs.
      -- apparently this is not happening and the code is continuing to execute.
      popup btn "filterPopup" 
   end if
end filterByDate

on filterByFavorites
   if  "Favorites" is in the hilitedItemNames of widget "FilterTabBar" then
      layoutScreen "Favorites"
   else
      layoutScreen
   end if
end filterByFavorites

 local sListA -- array of current journal entries for filtering in next 2 handlers

on filterByActivityType
   local tList
   dbSetSQL "select distinct module from journal"
   put dbGet(null, journalDB()) into sListA
   repeat for each key m in sListA
      put  sListA[m]["module"] into sListA[m]["title"] // default value
      if there is a stack  sListA[m]["module"] and  the title of stack sListA[m]["module"] is not empty then
         put the title of stack sListA[m]["module"] into sListA[m]["title"]
      end if
      put  sListA[m]["title"] & cr after tList
   end repeat
   delete char -1 of tList
   sort tList
   put "All" & cr before tList
   if isMobile() then
      mobilePick tList, "cancel"
      put the result into tLineNum
      processFilter tLineNum,tList
   else -- desktop
      put tList into btn "filterPopup"
      popup btn "filterPopup" -- this calls processFilter
   end if
end filterByActivityType

on processFilter pLineNum,pList
  -- pLineNum = line number of user selection
  -- pList = list of options
  if pLineNum = 0 then
    put empty into tModule
  else
    put line pLineNum of pList into tTitle
    repeat with x = 1 to the number of lines in the keys of sListA
      if sListA[x]["title"] is tTitle then
        put sListA[x]["module"] into tModule
      end if
    end repeat
  end if
  layoutscreen tModule
end processFilter

-- on filterByActivityType
--   local tList
--   dbSetSQL "select distinct module from journal"
--   put dbGet(null, journalDB()) into tA
--   repeat for each key m in tA
--     put  tA[m]["module"] into tA[m]["title"] // default value
--     if there is a stack  tA[m]["module"] and  the title of stack tA[m]["module"] is not empty then
--       put the title of stack tA[m]["module"] into tA[m]["title"]
--     end if
--     put  tA[m]["title"] & cr after tList
--   end repeat
--   delete char -1 of tList
--   sort tList
--   put "All" & cr before tList
--   mobilePick tList, "cancel"
--   if the result is 0 then
--     put empty into tModule
--   else
--     put line (the result) of tList into tTitle
--     repeat with x = 1 to the number of lines in the keys of tA
--       if tA[x]["title"] is tTitle then
--         put tA[x]["module"] into tModule
--       end if
--     end repeat
--   end if
--   layoutscreen tModule
-- end filterByActivityType
