script "behavior_ItemTemplate"
local sEntryA

setprop itemOrder pNum
   layoutGroup pNum
   --    put jsonexport(sEntryA)
end itemOrder

# TODO: We are hacking the field tags, which do not contain "tags" 
# from the journal data base, this cost me hour of head ache.
# tags of the  Browser with
# we should normalize going forward with self-definitive nomenclature.


setprop journalEntry pEntryA
   put pEntryA into sEntryA
   --
   if there is a stack sEntryA["module"] then
      put the title of stack  sEntryA["module"] into tTitle
   else
      put "Siva Siva App" into tTitle
   end if
   set the htmltext of field "entry label" of me to textDecode(sEntryA["label"], "utf8")
   
   # TODO not the field "tags" if set the title of the module
   # have to fix this for YouTube, And Swap out video the 
   # View Web Page
   # Leter we have to get filter by activity to distinquish between
   # the two "Videos" "View a web page"
   
   put JSONtoArray(sEntryA["data"]) into pData
   
   if pData["weburl"] contains "youtube" then
      put "Videos" into tTitle
   end if
   
   set the htmltext of field "tags" of me to textDecode(tTitle, "utf8")
   
   put sEntryA["date"] into tDate
   put timeutils_ISOtoSeconds(tDate) into tDate
   put timeutils_elapsedTime(tDate) into tHumanReadableElapsedTime
   
   set the htmltext of field "timestamp" of me to tHumanReadableElapsedTime
   
end journalEntry

on Mouseup
   if the short name of the target is "is favorite" then
      setFavorite
   else
      put JSONtoArray(sEntryA["data"]) into pData
      setJournalData pData
      launchActivity
   end if
end mouseup

on setFavorite
   if sEntryA["is_favorite"] is 0 then
      put 1 into tValue
   else
      put 0 into tValue
   end if
   put tValue into sEntryA["is_favorite"]
   Journal_SetFavoriteFlag sEntryA["journal_id"], tValue
   if sEntryA["is_favorite"] is 0 then
      set the foreColor of widget "is favorite" of me to getConfigForLayout("listView", "favoriteDisabledIconColor")
   else
      set the foreColor of widget "is favorite" of me to getConfigForLayout("listView", "favoriteEnabledIconColor")
   end if
end setFavorite

on layoutGroup pNum
   -- general list group stuff
   set the lockupdates of group "item list" to true
   set the lockupdates of me to true
   set the name of me to ("item" && pNum)
   
   if the environment is development then
      --       activateDebugColors
   end if
   
   processInternalFormatting -- this command sets internal group elements
   processExternalFormatting pNum -- this one sets the group itself
   --fixLayoutMistakes pNum
   set the lockupdates of group "item list" to false
   set the lockupdates of me to false
end layoutGroup

on activateDebugColors
   set the backgroundColor of group "item list" to red
   set the opaque of group "item list" to true
   
   set the opaque of me to true
   set the backgroundColor of me to random(128), random(128), random(128)
   set the height of group "item list" to (the height of this card - the top of group "item list")
   
end activateDebugColors

on processInternalFormatting
   set the lockupdates of me to true  
   #Note: some attributes of the group are set on the template on this card
   # e.g. use the margins propety to 
   -- colors
   if sEntryA["is_favorite"] is 0 then
      set the foreColor of widget "is favorite" of me to getConfigForLayout("listView", "favoriteDisabledIconColor")
   else
      set the foreColor of widget "is favorite" of me to getConfigForLayout("listView", "favoriteEnabledIconColor")
   end if
   set the iconPath of widget "module icon" of me to getIconForModule()
   set the foreColor of widget "module icon" of me to getConfigForLayout("listView", "activityIconColor")
   set the foreColor of field "entry label" of me to getConfigForLayout("listView", "moduleNameColor")
   set the foreColor of field "timestamp" of me to getConfigForLayout("listView", "bodyTextColor")
   set the foreColor of field "tags" of me to getConfigForLayout("listView", "bodyTextColor")
   --    set the foreColor of grc "horizontal rule" of me to getConfigForLayout("listView", "bodyTextColor")
   
   -- widths
   set the width of field "timestamp" of me to the formattedWidth of  field "timestamp" of me
   set the width of field "entry label" of me to the formattedWidth of  field "entry label" of me
   set the width of grc "horizontal rule" of me to the width of this card 
   set the width of grc "journal-item-bkgnd" of me to the width of this card
   
   -- positioning
   set the right of field "timestamp" of me to (the width of this card - 20)
   set the left of grc "horizontal rule" of me to 0
   set the left of field "entry label" of me to the right of widget "module icon" of me +10
   set the left of field "tags" of me to the left of field "entry label" of me
   set the margins of me to 0,8,0,0
   set the lockupdates of me to false  
end processInternalFormatting

on processExternalFormatting pNum
   set the lockupdates of group "item list" to true
   set the lockupdates of me to true  
   set the height of group "item list" to formattedHeight of group "item list"
   set the top of group "item list" to the bottom of grc "header bar" + 60
   set the showBorder of me to false
   -- find group rect
   subtract 1 from pNum
   set the top of me to (the top of group "item list" + (the height of me * pNum)) 
   set the lockupdates of group "item list" to false
   set the lockupdates of me to false  
end processExternalFormatting

on fixLayoutMistakes pNum
   repeat with x = 1 to pNum
      set the left of group ("item" && x) to 0
      set the left of grc "horizontal rule"  of group ("item" && x) to 0
   end repeat
end fixLayoutMistakes

function getIconForModule
   switch sEntryA["module"]
      case "view_SivaSivaBrowser"
         return the iconPath of widget "website-svg-icon" of card "templates"
         break
      case "wordpuzzles"
         return the iconPath of widget "puzzle-svg-icon" of card "templates"
         break
      case "journal"
      case "affirmations"
      case "daily-lesson"
      case "pathtosiva"
      case "gems"
      case "panchangam"
      case "traits"
         return the iconPath of widget "book-svg-icon" of card "templates"
         break
      case "surprise"
         return the iconPath of widget "eyeopen-svg-icon" of card "templates"
         break
      case "listen"
         return the iconPath of widget "music-svg-icon" of card "templates"
         break
      case "color-meditation"
         # use for all "practices" for now
         return the iconPath of widget "plane-svg-icon" of card "templates"
         break
         
      case "settings"
      default
         return the iconPath of widget "generic-svg-icon" of card "templates"
   end switch
end getIconForModule


on launchActivity
   --put "should launch activity" && sEntryA["journal_id"]
   setJournalFlag 1
   portal_SetCurrentStack "journal"
   set the acceleratedRendering of this stack to false
   Journal_LaunchEntry sEntryA["journal_id"]
   
   if the result contains "err" then
      answer error the result
   end if
end launchActivity

