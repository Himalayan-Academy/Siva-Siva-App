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
# There short always be string to finder 
local  sStringToFind  
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

command setFindString
   put fld "searchstring" into sStringToFind  
   put (line 1 of sStringToFind) into sStringToFind 
end setFindString

------------------------------------------------------------------------
#  UNIQUE SEARCHES FOR DIFFERENT MODULES ARE ADDED HERE
# there is a diversity of requirements and use cases 
# but we only ever look up this kind of data for a cached list
# i.e. never for recent or audio books, which go to the server.
# all we need to do is pass a new query up to behavior_Listen.playList_FetchData
------------------------------------------------------------------------

command searchPlayList  # Search Audio
   local tAllCollection, pWhichClass, pFilterListQueryA
   local tDeity, tGenre, tTextTarget, pBrowseHeader, tAuthor
   
   
   
   setFindString
   # we must get the original collection data
   # determine whether to it is an Inspired Talk or if it in a Songs or chant
   # We not do search audio books.
   put  getCollectionsJson() into tAllCollection
   put the hilitedbuttonname of grp "collectionChoice" into pWhichClass
   put "YES" into pFilterListQueryA["approved_for_public"]
   switch
      
      # songs
      case  (pWhichClass= "Songs") # unique seach criteria:
         put "audio/song" into pFilterListQueryA["media_type"]
         put the hilitedbuttonname of grp "deity"  into tDeity
         if tDeity is not "All Collections" then
            put tDeity into pFilterListQueryA["deity"]
         end if
         put the hilitedbuttonname of grp "genre" into tGenre
         if tGenre is not "All Genres" then
            put tGenre into pFilterListQueryA["genre"]
         end if
         put the hilitedButtonName of grp "titleDescription" into tTextTarget
         if tTextTarget = "Subtitle" then
            put "sub_title" into tTextTarget # has to match the dBase column name
         end if
         if the hilite of btn "artists" is true then 
            put "artists" into tTextTarget
         end if
         if (sStringToFind is empty) OR (tTextTarget is empty) then
            put "Pick Title, Subtitle, Artists..." into fld "searchString"
            wait 2 seconds
            put empty into fld "searchString"
            exit to top
         end if
         
         put sStringToFind into pFilterListQueryA[tTextTarget]    
         put sStringToFind &&tDeity && tGenre into pBrowseHeader
         
         break
         
         # Talks
      case (pWhichClass contains "Inspired Talks")
         put the hilitedbuttonname of grp "author"  into tAuthor
         put "inspiredtalk" into pFilterListQueryA["media_type"]
         if tAuthor contains "Gurudeva" then 
            put  "Satguru Sivaya Subramuniyaswami" into pFilterListQueryA["author"]
         end if
         if tAuthor contains "Bodhinatha" then 
            put  "Satguru Bodhinatha Veylanswami" into pFilterListQueryA["author"]
         end if
         put the hilitedButtonName of grp "titleDescription" into tTextTarget
         if tTextTarget = "Subtitle" then
            put "sub_title" into tTextTarget # has to match the dBase column name
         end if
         if (sStringToFind is empty) OR (tTextTarget is empty) then
            put "Enter title, subtitle..." into fld "searchString"
            wait 2 seconds
            put empty into fld "searchString"
            exit to top
         else
            put sStringToFind into pFilterListQueryA[tTextTarget]     
            
         end if
         
   end switch
   
   ## those call in coming from search
   # still need to set two parameter for the collection and play list, every though
   # will not access these in the search
   # we use "none" to be explicit
   put "Search:" && sStringToFind into pBrowseHeader
   playList_fetchData "none","none", pFilterListQueryA,pBrowseHeader
   
end searchPlayList

------------------------------------------------------------------------
#  GENERIC SEARCH CLASS FUNCTIONS BELOW
# dbaseRecords,listLines,fieldText
------------------------------------------------------------------------

