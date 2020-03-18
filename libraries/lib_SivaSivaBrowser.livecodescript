script "lib_SivaSivaBrowser"
/* Brahmanathawami June 2017 --

David's code below target the two HAP media stacks. 
These are pretty much deprecated but we retain the code here for possible future utility
New functions/Commands on top. These are to handle any calls form anywhere relating
to web browsing, the browser widget so we hae all this in one place.  
IIf you are tempted to write code pertaining to a browser widget in our module. 
Think first: can we put those functons andcommands here, so they can be used universally later.

*/

local sLastWebPageTitle, sLastWebURL

# we store the <title> in the <head> here so we can reference this later the journal.
# hopefully this will clue the user into what page they were viewing.
# requires the web site has "intelligent" titles, which most pages do for SEO reasons)

function parseTheHTML pHtmlText, pTargetString
   # use for scraping out anything from the htmltext of a browser widget
   # must call *after* URL loads
   local tStartTitle,tEndTitle,tStartSubHead,tEndSubHead,tClass,tBookMark,tSubHead
   switch pTargetString
      case "bookmark"
         put (offset ("<Title>", pHTMLText) +7) into tStartTitle
         put (offset ("</Title>", pHTMLText) -1) into tEndTitle
         put  (char tStartTitle to tEndTitle of pHTMLText) into tBookmark
         replace cr with "" in tBookmark
         replace tab with "" in tBookmark
         
         # You is already send for you
         ##if tBookmark contains "YouTube" then # leave it alone
         ## put "YouTube" into sLastWebPageTitle  # upgrade this later... 
         ##else # from our web site
         put  browser_GetLastURL() into tClass 
         # we know our CMS and the page will be have 2 or 3  classes
         
         switch
            case (tClass contains "media/books/")
               # we are looking at  static web page inside book
               put word 1 to 5 of tBookmark into tBookmark
               put ", " after tBookmark
               
               put (offset ("book-content", pHTMLText) +13) into tStartSubHead
               put (offset ("</h3>", pHTMLText) -1) into tEndSubHead
               put  (char tStartSubHead to tEndSubHead of pHTMLText) into tSubHead
               replace cr with "" in tSubHead
               put  stripHTMLTags(tSubHead)  after tBookmark
               break
            case  (tClass contains "/views")
               # one a revIgnitie media page
               break
            default
               # any other html page
               # we are inconsistent in the title delimiter passed in our CMS
               # sometime the leading "realm" is separated by a colon, other time a dash
               replace ": " with "-" in tBookmark # normalize all those...
               set the itemdel to "-" # set up for two part titles
               
               if the number of items of tBookmark = 2 then
                  put item 2 of tBookmark into tBookmark
               end if
               If char 1 of tBookmark = " " then 
                  delete char 1 of tBookmark
               end if   
               
         end switch
         
         put tBookmark into sLastWebPageTitle
         break
         
   end switch
   
   return tBookmark
end parseTheHTML
function titleFromTOC pFilename, pTocHTML, pSkip
   if pSkip is not a number then
      put 0 into pSkip
   end if
   
   put offset(pFilename, pTocHTML, pSkip) into tStart
   put tStart + offset("</a>", pTocHTML, pSkip + tStart) into tEnd
   put char pSkip+tStart to pSkip+tEnd of pTocHTML into tChunk
   put the merge of "<a href=\'[[tChunk]]/a>" into tHTMLChunk
   create inv field "htmltitle"
   set the htmltext of field "htmltitle" to tHTMLChunk
   put the text of field "htmltitle" into tTitle
   delete field "htmltitle"
   if the length of tTitle > 2 then
      return  tTitle
   else if pSkip is 0 then
      return tTitle && "-" && titleFromToc(pFilename, pTocHTML, tEnd)
   else 
      return false 
   end if
end titleFromTOC

function titleFromURL pURL
   put false into tFileID   
   set the itemdel to slash
   put item 4 of pURL into tSlug
   switch tSlug
      case "media"
         put item 6 of pURL into tFileID
         break
      case "view"
         put item 5 of pURL into tFileID
         break
   end switch
   if tFileID is not false then
      put jnanam_GetItem(tFileID) into tItemA
      switch tItemA["media_type"]
         case "text/book"
            put the merge of "https://dev.himalayanacademy.com/media/books/[[tFileID]]/web/toc.html" into tTocURL
            put url tTocURL into tTocHTML
            put item -1 of pURL into tFilename
            if tFilename is tFileID then
               return tItemA["title"]
            end if
            put titleFromToc(tFilename, tTocHTML) into tTitle
            if tTitle is false then
               return tItemA["title"]
            else 
               return tItemA["title"] & ":" && tTitle
            end if
            break
         default
            return tItemA["title"]
      end switch
   else
      // not an item from jnanam
      put url pURL into tHTML
      
      --put matchText(tHTML, "<title>(.*?)</title>", tTitle) into tHasTitle
      
      put (offset ("<Title>", tHTML) +7) into tStartTitle
      put (offset ("</Title>", tHTML) -1) into tEndTitle
      put  (char tStartTitle to tEndTitle of tHTML) into tTitle
      replace cr with "" in tTitle
      replace tab with "" in tTitle
      
      if tTitle <> empty then
         return tTitle
      else
         return "Unknown title"
      end if
   end if
end titleFromURL

function browser_GetLastPageTitle
   return sLastWebPageTitle
end browser_GetLastPageTitle

command browser_SetLastURL pWebURL
   put pWebURL into sLastWebURL
end browser_SetLastURL

function browser_GetLastURL
   return sLastWebURL
end browser_GetLastURL

--> Browser | Utility handlers
-
function getOrientationByType pURL -- return correct orientation for a URL;
   -- called by launchURL and orientationChanged in browser cd of both viewer stacks
   -- Some media is locked to an orientation, some allow any.
   -- This tries to determine the allowed orientation for a media type.
   -- (Add slideshows later to landscape view)
   switch
      case pURL contains "youtube" --  a movie [add slideshow when URL format is known]
         --     case pURL contains "SLIDESHOW"  --### add when format is known
         return "landscape" 
         break
      case pURL contains "PORTRAIT" --### fix this when format is known
         return "portrait"
         break
      default
         return "any" -- allows rotation
   end switch
end getOrientationByType
