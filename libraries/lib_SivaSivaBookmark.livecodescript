script "lib_SivaSivaBookmark"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaBookmark
type: library
version: 0.1


--> Portal | Bookmark

local portalView, portalList, stackName, shortFile,  sivasivaData


command parseTheHTML pHtmlText, pTargetString
   local tStartTitle, tEndTitle, tRawTitle, sLastWebPageTitle
   
   
   # use for scraping out anything from the htmltext of a browser widget
   # must call *after* URL loads
   switch pTargetString
      case "Title"
         put (offset ("<Title>", pHTMLText) +7) into tStartTitle
         put (offset ("</Title>", pHTMLText) -1) into tEndTitle
         put  (char tStartTitle to tEndTitle of pHTMLText) into tRawTitle
         replace cr with "" in tRawTitle
         replace tab with "" in tRawTitle
         # we are inconsistent in the title delimiter passed in our CMS
         # sometime the leading "realm" is separated by a colon, other time a dash
         replace ": " with "-" in tRawTitle # normalize all those...
         set the itemdel to "-" # set up for two part titles
         if tRawTitle contains "YouTube" then # leave it alone
            put "YouTube" into sLastWebPageTitle  # upgrade this later... 
         else # from our web site
            if browser_GetLastURL() contains "/book/" then
               # pass just the first words
               put word 1 to 5 of tRawTitle into tRawTitle
            else
               # not a book page...
               if the number of items of tRawTitle = 2 then
                  put item 2 of tRawTitle into tRawtitle
               end if
               If char 1 of tRawTitle = " " then 
                  delete char 1 of tRawTitle
               end if   
            end if
            
         end if
         put tRawTitle into sLastWebPageTitle
         break
   end switch
end parseTheHTML

command portal_DisplayBookmarks
   -- just a test for now
   put portal_GetHomeView() into portalView
   put "Frequently Asked Questions,Listen,Mantras,Practice" into portalList
   set the portal_RowNames of portalView to portalList
end portal_DisplayBookmarks

command sivasiva_FetchBookmarkArray
   put "model_SivaSivaBookmarks" into stackName
   put stackName & ".json" into shortFile-- could use ".array"
   put the model_Array [shortFile] of stack "model_SivaSiva" into sivasivaData
   return sivasivaData
end sivasiva_FetchBookmarkArray
