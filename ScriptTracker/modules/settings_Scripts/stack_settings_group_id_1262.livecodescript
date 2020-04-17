Script "stack_settings_group_id_1262"

/*
# Name: group "diskDataOverview" of card "disk_data_overview" of stack "settings"
# ID: group id 1262 of card id 1261 of stack "settings"
*/


i# Assume full bar = 3 GB of content for that media type...
# Anything over is 3+ but not shown...
# Uses binary values 1024 *1024*1024 bytes = 1 GB = 1073741824 bytes

local tDataArrayA,tDataCap
local tTotal,tDataSize,tBar,theBar,theBase,theRect
local tBarRight,tBarWidth,tBarRect

on mouseup
   set the itemdelimiter to "-"  
   
   # all convention all UI elements and name with media type as the first item
   # "art-base, photo-bar" , by click any one we pass the media to the next handler
   
   displayTargetFiles (item 1 of the short name of the target)
     if isMobile() then
      display_SetStatusBarVis "false"
      end if
end mouseup

command updateUsageOverview tDataStoreA
   --breakpoint

   put tDataStoreA into  tDataArrayA
   graphResets "zeroOut"
   put empty into tTotal
   repeat for each key N in tDataStoreA
      if N = "files" then next repeat
      put tDataStoreA[N]["categorySum"] into tDataSize
      if tDataSize > 0 then 
         show button (N & "-go-files")
      else 
         hide button (N & "-go-files")
      end if
      put tDataSize & " MB" into fld (N& "-data")
      add tDataSize to tTotal 
      put long id of grc (N & "-bar" ) of grp "bar_group" into theBar
      set the fillgradient of theBar to empty
      put long id of grc (N & "-base") of grp "base_group" into theBase
      put rect of theBar into theRect
      put the width of theBase into tDataCap
      
      # length of bar is a percentage of it's base (fullwidth) 
      # where full length = 2 GB
      # same ratio as data over 2000
      
      put round  ( (tDataSize/2000*tDataCap),0) into tBarWidth
      put    (the left of theBase)  + tBarWidth  into tBarRight
      put (tBarWidth+(item 3 of theRect) ) into item 3 of theRect    
      if (item 3 of theRect- item 1 of theRect) >= tDataCap then 
         put tDataCap + (the left of theBase) into tBarRight
      end if
      set the rect of theBar to theRect
      get url "https://www.himalayanacademy.com/ping.txt"
      
   end repeat
   put tTotal & " MB (" & round((tTotal/1000),2) & " GB)"  into fld "total-data"
   -- aeUnlockRects
   hide btn"load-spinner"
end updateUsageOverview

on closeControl
   hide group "displayFilesSizes"
end closeControl

command graphResets pType
   local tDisplayTypes
   put "audio,books,art" into tDisplayTypes  # Manually update when we add more data types  
   repeat for each item N in tDisplayTypes
      put long id of grc (N & "-bar" ) of grp "bar_group" into theBar
      put long id of grc (N & "-base") of grp "base_group" into theBase
      Switch pType 
         case "overageAlerts" 
            put the rect of theBar into theRect
            if (item 3 of theRect- item 1 of theRect) >= tDataCap then 
               set the fillgradient of theBar to the uDataCapAlertGradient of me
            end if
            break
         case "zeroOut"      
            put empty into fld (N&"-data")
            set the fillgradient of theBar to empty
            put the rect of theBase into tBarRect
            put  (item 1 of tBarRect +2) into item 3 of tBarRect
            set the rect of theBar to tBarRect
            break
      end switch
   end repeat
  
end graphResets
