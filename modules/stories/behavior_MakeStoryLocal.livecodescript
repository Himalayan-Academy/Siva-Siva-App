script "behavior_MakeStoryLocal"

local sOriginalSize
local sStoriesMetaArray, sStoryTitle
local sImageList, sQuoteList, sAttribution, sTotalSceneCount, slidesLimit
local imageList, Quotes, Attribution, SceneCount, storyIsCachedFlag, storyTitle
local sStoryImage 

on preOpencard
  setOriginalSize
  set the title of this stack to fld "imageFilename"
  put the layer of this card into fld "cardLayer"
end preOpencard

on makeStoryLocal pPassTitle
    
   put pPassTitle into sStoryTitle
   
   # just for development
   put  loadStoriesMetadata() into sStoriesMetaArray 
   
   # clean up the current content
   
   repeat with i = the number of cards down to 2
      delete card i
   end repeat
   
   # based on "model_Stories"
   put randomPhotos(sStoriesMetaArray["Stories"][sStoryTitle]["imageTags"]) into sImageList 
   put FetchQuotesCollection(sStoriesMetaArray["Stories"][sStoryTitle]["quotesCollection"]) into sQuoteList
   
   
   # based of "stories.json"
   if sStoriesMetaArray["Stories"][sStoryTitle][slidesLimit] = "quotes" then
      put the number of lines of  sQuoteList into sTotalSceneCount
   else
      put the number of lines of  sImageList into sTotalSceneCount
   end if
   
   # Make the stack with empty cards 
   
   put "" into fld "mainText"
   
   # get sTotalSceneCount from stores.json
   
   lock screen
   repeat with x = 2 to sTotalSceneCount
      clone this card
      set the cantDelete of this card to false
   end repeat
 
   
   
   set the itemDelimiter to "|"
   repeat with x = 2 to sTotalSceneCount
      set the filename of img "slideImage" of card x to line x of sImageList
      set the text of fld "mainText" of card x to item x of of sQuoteList
   end repeat
  
   htmlTitleAttribution
   unlock Screen
   
end makeStoryLocal

on htmlTitleAttribution
   go to card 1
   put sStoriesMetaArray["Stories"][sStoryTitle]["attribution"] into sAttribution 
   
   put   "<p><b><font size=32>"  & sStoryTitle  & "</font></b></p>" \
         & cr&  "<p><b><font size=25>By</font></p>" & cr & \
         "<p><b><font size=25>" & sAttribution  & "</font></p></center>" into fld "mainText"
end htmlTitleAttribution


on toggleMe		
   local tLayer, tImage,tWd, tHg
   put the long id of img "slideImage" into tImage
   put the layer of  img "slideImage"  into tLayer
   put the formattedWidth  of tImage into tWd
   put the formattedHeight  of tImage into tHg
   
   if the layer of tImage > 1 then
      if tHg > tWd then
         		
         resizeToHeight tImage, 600
      else
         		
         resizeToWidth tImage, 600		
      end if
      set the layer of  tImage  to 1
   else
      
      if tWd > tHg then
         			
         resizeToWidth tImage, the width of this stack
         --			resizeToHeight tImage, the height of this stack	
      else
         ----resizeToHeight tImage,  the height of this stack
         resizeToWidth tImage, the width of this stack	
      end if
      set the layer of  tImage  to top
      				
   end if
   
end toggleMe							

on setOriginalSize
   put rect of img "slideImage" into sOriginalSize
end setOriginalSize


on resizestack x,y,oX,oY
   local tCaption,  tMainText 
   put the long id of fld "caption" into tCaption
   put the long id of fld "maintext" into tMainText
   set the rect of tCaption to (the left of tCaption , the top of tCaption,x-10, the bottom of tCaption )
   --set the rect of tMainText to (the left of tMainText , the top of tMainText, x-10,y-10)
   set the right of tMainText to (x-10)
   
end resizestack

on putHtmlText
   set the relayerGroupedControls to true
   
   if the layer of fld "checkHtml" > 3 then
      set the layer of fld "checkHtml" to 3
   else
      set the layer of fld "checkHtml" to 20			
   end if
   -- put text of fld "caption" into  fld "checkHTML" --tCheckHtml
   --set the htmltext of fld "mainText" into fld "checkHTML"
   
   -- set the text of fld "mainText" to the htmlText of  fld "checkHTML"
   set the htmltext of fld "checkHTML" to the htmlText of fld "mainText"
end putHtmlText

on __UTILITIES
end __UTILITIES

on resizeToHeight pImage,pSize
   local tOrigImgWidth, tOrigImgHeight, tRatio, tNewWidth, tNewHeight
   put the formattedWidth  of pImage into tOrigImgWidth
   put the formattedHeight  of pImage into  tOrigImgHeight
   
   if tOrigImgHeight is 0 then exit resizeToHeight
   put (pSize)/tOrigImgHeight  into tRatio
   put (tOrigImgWidth * tRatio) into tNewWidth
   put (tOrigImgHeight * tRatio) into tNewHeight
   set the rect of pImage to 0,0,tNewWidth,tNewHeight   
end resizeToHeight

on resizeToWidth pImage,pSize 
   local tOrigImgWidth, tOrigImgHeight, tRatio, tNewWidth, tNewHeight
   put the formattedWidth  of pImage into tOrigImgWidth
   put the formattedHeight  of pImage into  tOrigImgHeight
   
   
   if tOrigImgWidth is 0 then exit resizeToWidth
   put pSize/tOrigImgWidth into tRatio 
   put (tOrigImgWidth * tRatio) into tNewWidth
   put (tOrigImgHeight * tRatio) into tNewHeight
   set the rect of  pImage to 0,0,tNewWidth,tNewHeight
   
end resizeToWidth


local sSearchItem

on findIt
   ask "Text to Find" 
   put it into sSearchItem
   find sSearchItem 
end findIt

on findAgain
   find sSearchItem
end findAgain


on check
   put sOriginalSize
end check



