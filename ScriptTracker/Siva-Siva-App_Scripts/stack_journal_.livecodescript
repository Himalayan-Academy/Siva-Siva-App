Script "stack_journal_"

/*
# Name: stack "journal" of stack "Siva-Siva-App"
# ID: stack "journal" of stack "Siva-Siva-App"
*/


local sConfigA
local sStateA
local sLastStack


on preopenstack
   if isMobile() then    
      set the fullscreenmode of this stack to "showAll" -- better for wider screens
      mobileSetAllowedOrientations "portrait,portrait upside down"
      mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,736"
   end if
end preopenstack

function getConfigForLayout pScreenIdentifier, pKey
   return sConfigA["style"][pScreenIdentifier][pKey]
end getConfigForLayout
 
on journalresume pDataA
   if the keys of pDataA is not empty then
      put jsonexport(pDataA) into pDataA
   end if
   -- answer "launched from journal" && pDataA
end journalresume

on refreshUI
   lock screen
   put sivasiva_GetModuleConfigArray("journal") into sConfigA
   layoutHeader
   layoutFilters
   layoutCard
   fetchEntries
   layoutEntries
   unlock screen
end refreshUI

on layoutHeader
   set the topleft of grc "header bar" to 0,0
   set the width of grc "header bar" to the width of this card
   
   set the topleft of button "go-home-portal" to 0,0
   
   set the topleft of fld "header text" to (the width of this card / 2) - (the width of fld "header text" / 2), 15
end layoutHeader


on layoutFilters
   local tRect
   put 10,(the bottom of grc "header bar" + 10),(the width of this card - 10), (the bottom of grc "header bar" + 70) into tRect
   set the rect of button "favorites" to tRect
   if the cFlag of button "favorites" then
      set the backColor of button "favorites" to "green4"
      set the foreColor of button "favorites" to 255,255,255
   else
      set the backColor of button "favorites" to 128,128,255
      set the foreColor of button "favorites" to 255,255,255
   end if
end layoutFilters

on layoutCard
   local tRect
   set the backgroundColor of this card to getConfigForLayout("listView", "cardBackgroundColor")
   -- left, top, right, and bottom is a rect
   put 10,(the bottom of button "favorites" + 10),(the width of this card - 10), (the bottom of this card - 10) into tRect
   set the rect of grc "list boundaries" to tRect
   show grc "list boundaries" 
   
   if there is a group "entries" then
      delete group "entries"
   end if
   
   clone invisible grc "list boundaries" as "temp" 
   hide grc "list boundaries" 
   set the rect of grc "temp" to tRect
   group grc "temp"
   set the name of it to "entries" 
   set the lockupdates of group "entries" to true
end layoutCard

on fetchEntries
   put Journal_GetEntries() into sStateA["entries"]
   local tStateA -- BWM - not sure about this one, should be sStateA?
   put 0 into tStateA["current entry"]
end fetchEntries

on layoutEntries
   repeat for each element tEntryA in sStateA["entries"]
      if the cFlag of button "favorites" is true and tEntryA["is_favorite"] is 0 then
         next repeat
      else
         local tStateA -- BWM - not sure about this one, should be sStateA?
         createNewJournalEntry tEntryA, tStateA["current entry"]
         add 1 to tStateA["current entry"]
      end if
   end repeat
   set the rect of group "entries" to the rect of grc "list boundaries"
   set the behavior of group "entries" to (the long id of stack "behavior_mobileScroller")
   set the layerMode of grp "entries" to "scrolling"
   dispatch "CreateScroller" to group "entries" with "entries"
end layoutEntries

on createNewJournalEntry pEntryA, pNum
   local tPadding, tTop, tName, tLabel, pData, tDate, tHumanReadableElapsedTime
   
   if pNum is not a number then put 0 into pNum
   put 20 into tPadding
   put pNum * 80 into tTop
   
   -- control rect
   put "rect" && pNum into tName
   if tName is "rect" then put "rect 0" into tName
   create invisible grc tName in group "entries"
   set the opaque of grc tName to true
   set the width of grc tName to the width of this card
   set the left of grc tName to 0
   set the height of grc tName to 60
   set the top of grc tName to the top of grc "list boundaries" + tTop
   
   -- entry label field
   put "title" && pNum into tName
   if tName is "rect" then put "title 0" into tName
   create field tName in group "entries"
   
   set the cEntry of field tName to pEntryA
   set the behavior of field tName to (the long id of stack "behavior_JournalEntry")
   put textDecode(pEntryA["label"],"UTF-8") into tLabel
   if len(tLabel)  >35 then
      put truncateText(tLabel,35,true) into tLabel
   end if
   set the text of field tName to tLabel
   set the width of field tName to the width of this card - 90
   set the left of field tName to 90
   set the opaque of field tName to false
   set the showBorder of field tName to false
   set the threeD of field tName to false
   set the traversalOn of field tName to false
   set the lockText of field tName to true 
   set the height of field tName to the formattedHeight of field tName
   set the textFont of field tName to "Helvetica Neue"
   set the textStyle of field tName to "bold"
   set the textSize of field tName to 16
   set the foreColor of field tName of me to getConfigForLayout("listView", "moduleNameColor")
   set the top of field tName to the top of grc ("rect" && pNum)
   
   -- module label field
   put "module" && pNum into tName
   if tName is "rect" then put "module 0" into tName
   create field tName in group "entries"
   
   set the cEntry of field tName to pEntryA
   set the behavior of field tName to (the long id of stack "behavior_JournalEntry")
   
   if there is a stack pEntryA["module"] then
      put the title of stack pEntryA["module"] into tLabel
      if tLabel is empty then
         put pEntryA["module"] into tLabel
      end if
   else
      put "Siva Siva App" into tLabel
   end if
   
   put JSONtoArray(pEntryA["data"]) into pData
   
   if pData["weburl"] contains "youtube" then
      put "Videos" into tLabel
   end if
   
   set the text of field tName to tLabel
   set the width of field tName to (the width of this card - 90) / 2
   set the left of field tName to 90
   set the opaque of field tName to false
   set the showBorder of field tName to false
   set the threeD of field tName to false
   set the traversalOn of field tName to false
   set the lockText of field tName to true 
   set the height of field tName to the formattedHeight of field tName
   set the textFont of field tName to "Helvetica Neue"
   set the textSize of field tName to 14
   set the foreColor of field tName of me to getConfigForLayout("listView", "bodyTextColor")
   set the top of field tName to the bottom of fld ("title" && pNum) + 5
   
   -- date created field
   put "date" && pNum into tName
   if tName is "rect" then put "date 0" into tName
   create field tName in group "entries"
   
   set the cEntry of field tName to pEntryA
   set the behavior of field tName to (the long id of stack "behavior_JournalEntry")
   
   put pEntryA["date"] into tDate
   put timeutils_ISOtoSeconds(tDate) into tDate
   put timeutils_elapsedTime(tDate) into tHumanReadableElapsedTime
   
   set the text of field tName to tHumanReadableElapsedTime
   set the width of field tName to formattedWidth of field tName
   set the right of field tName to the width of this card - 20
   set the opaque of field tName to false
   set the showBorder of field tName to false
   set the threeD of field tName to false
   set the traversalOn of field tName to false
   set the lockText of field tName to true 
   set the height of field tName to the formattedHeight of field tName
   set the textFont of field tName to "Helvetica Neue"
   set the textSize of field tName to 14
   set the textAlign of field tName to right
   set the foreColor of field tName of me to getConfigForLayout("listView", "bodyTextColor")
   set the top of field tName to the bottom of fld ("title" && pNum) + 5
   
   -- horizontal line
   put "separator" && pNum into tName
   if tName is "rect" then put "separator 0" into tName
   create grc tName in group "entries"
   set the width of grc tName of me to (the width of this card  - 20)
   set the left of grc tName to 10
   set the height of grc tName to 1
   set the foreColor of grc tName to 150,150,150
   set the top of grc tName to (the bottom of fld ("date" && pNum) + 5)
   
   -- module icon
   put "icon" && pNum into tName
   if tName is "icon" then put "icon 0" into tName
   create widget tName as "com.livecode.widget.svgpath" in group "entries"
   
   set the cEntry of widget tName to pEntryA
   set the behavior of widget tName to (the long id of stack "behavior_JournalEntry")
   
   set the iconPath of widget tName of me to getIconForModule(pEntryA)
   set the foreColor of widget tName of me to getConfigForLayout("listView", "activityIconColor")
   set the width of widget tName to 44
   set the left of widget tName to 45
   set the top of widget tName to the top of grc ("rect" && pNum) + 10
   
   -- favorite icon
   put "favorite" && pNum into tName
   if tName is "icon" then put "favorite 0" into tName
   create widget tName as "com.livecode.widget.svgpath" in group "entries"
   
   set the cEntry of widget tName to pEntryA
   set the behavior of widget tName to (the long id of stack "behavior_JournalEntryFavoriteToggle")
   
   set the iconPath of widget tName of me to the iconPath of widget "is favorite" of card "templates"
   if pEntryA["is_favorite"] is 0 then
      set the foreColor of widget tName of me to getConfigForLayout("listView", "favoriteDisabledIconColor")
   else
      set the foreColor of widget tName of me to getConfigForLayout("listView", "favoriteEnabledIconColor")
   end if   set the width of widget tName to 44
   set the left of widget tName to 4
   set the top of widget tName to the top of grc ("rect" && pNum) + 10
end createNewJournalEntry


function getIconForModule pEntryA
   switch pEntryA["module"]
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

command goHome
   lock screen
   portal_GoStack  "Siva-Siva-Portal"
   unlock screen
end goHome

on closestack
   portal_SetLastStack "Journal"
end closestack
