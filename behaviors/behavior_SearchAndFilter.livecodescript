script "behavior_SearchAndFilter"

###################
-- BR: 2017-09-30  
-- changed "mouseup" to "executeSearch" 
-- because "send mouseup" was failing for some reason.
-- but "Send executeSearch" works from the mouse main group.
-- BR: 2017-10-13
-- DESCRIPTION:
-- General purpose  library for searchs and filters 
-- Assumes are that we pass three different data classes here
-- 1) an array of records from Jnanam
-- 2) a list, as from a list field or datagrid
-- 3) search a block of text and return results to do generic actions
-- 4) follows from #3 above but target is a field, and we colorize the text or set links text etc.
-- presumably these funtions will be generic enough to use across different stacks/cards/contexts
-- this behavior can be attached to a group where the mouse down passes the target
-- and based on the target or parent of target different actions are taken
-- if functionality for the results is unique ot the calling context, this script just returns results
-- and the calling context decides what to do with it
-- REQUIREMENTS:
-- minimally you must have this behavior attached to a group containing
-- 1) button "search"
--  2) field "searchString"
-- 3) classes for search are 
--                  dbaseRecords
--                  listLInes
--                  fieldText
--                  [later we will have datagrids to consider here...]
-- At this level for all intents and purposes search and filter are the same
-- we don't want to use the rawkeydown style of filtering on mobile
-- it even very non-performant in long lists on desktop.
-- just keep original data in a var; search that var; use results and reset as needed.

###################

local sSearchClass,sCallContext,sPlaylistQueryA

on executeSearch pTarget
   put getTargetOwnerSegs(pTarget) into sCallContext
   switch 
      case (sCallContext contains "listen-search")
         # it means search comes from the audio filter card
         searchPlayList
         break
   end switch
   
end executeSearch

------------------------------------------------------------------------
#  UNIQUE SEARCHES FOR DIFFERENT MODULES ARE ADDED HERE
# there is a diversity of requirements and use cases 
# but we only ever look up this kind of data for a cached list
# i.e. never for recent or audio books, which go to the server.
# all we need to do is pass a new query up to behavior_Listen.playList_FetchData
------------------------------------------------------------------------

command searchPlayList  # Search Audio
   # we must get the original collection data
   # determine whether to it is an Inspired Talk or if it in a Songs or chant
   # We not do search audio books.
   put  getCollectionsJson() into tAllCollections
   put the hilitedbuttonname of grp "collectionChoice" into pWhichClass
   
   put "cached" into tColl
   put "YES" into pFilterListQueryA["approved_for_public"]
   switch
      case  (pWhichClass= "Songs") # unique seach criteria:
         put "audio/song" into pFilterListQueryA["media_type"]
         put the hilitedbuttonname of grp "deity"  into tDeity
         if tDeity is not "All" then
            put tDeity into pFilterListQueryA["deity"]
         end if
         put the hilitedbuttonname of grp "genre" into tGenre
         if tGenre is not "All" then
            put tGenre into pFilterListQueryA["genre"]
         end if
         put fld "searchstring" into tStringToFind  
         put the hilitedButtonName of grp "textColumns" into tTextTarget
         if (tStringToFind is not empty) AND (tTextTarget is empty) then
            put "Pick Title, Description or Artist" into fld "searchString"
            put tstringToFind into fld "searchstring"
            exit to top
         else
            put tStringToFind into pFilterListQueryA[tTextTarget]         
         end if
         break
      case (pWhichClass contains "Inspired Talks")
         
         put "inspiredtalk" into pFilterListQueryA["media_type"]
         if tPlayList contains "Gurudeva" then 
            put  "Satguru Sivaya Subramuniyaswami" into pFilterListQueryA["author"]
         end if
         if tPlayList contains "Bodhinatha" then 
            put  "Satguru Bodhinatha Veylanswami" into pFilterListQueryA["author"]
         end if
         put fld "searchstring" into tStringToFind  
         put the hilitedButtonName of grp "titleDescription" into tTextTarget
         if tTextTarget = "Subtitle" then
            put "sub_title" into tTextTarget # has to match the dBase column name
         end if
         if (tStringToFind is not empty) AND (tTextTarget is empty) then
            put "Pick Search In" into fld "searchString"
            wait 1 second
            put tstringToFind into fld "searchstring"
            exit to top
         else
            put tStringToFind into pFilterListQueryA[tTextTarget]         
         end if
         
   end switch
   
   --  revealMoreActions "false"
   playList_fetchData pFilterListQueryA
  -- show widget "revealMoreActions"
   
end searchPlayList

------------------------------------------------------------------------
#  GENERIC SEARCH CLASS FUNCTIONS BELOW
# dbaseRecords,listLines,fieldText
------------------------------------------------------------------------

