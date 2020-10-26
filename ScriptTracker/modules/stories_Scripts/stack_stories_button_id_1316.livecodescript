Script "stack_stories_button_id_1316"

/*
# Name: button "delete local-cache" of group "Tools" of card "storyHome" of stack "stories"
# ID: button id 1316 of group id 1298 of card id 1002 of stack "stories"
*/


on mouseup
   local  sAttribution, sStoryTitle,  sLastScene, sTotalSceneCount, sImageList, sLastImage, sQuoteList
   local sLastQuote, sStoryImage, tLine, storyTitle, storyScene, Attribution, SceneCount, Quotes, ImageList, storyIsCachedFlag
   
   put "" into sAttribution
   put "" into sStoryTitle
   put "" into sLastScene
   put "" into sTotalSceneCount  
   put "" into sImageList
   put "" into sLastImage
   put "" into sQuoteList
   put "" into sLastQuote
   put "" into sStoryImage   
   put "" into tLine
   put "" into storyTitle
   put "" into storyScene
   put "" into Attribution
   put "" into SceneCount
   put "" into Quotes
   put "" into ImageList
   put "" into storyIsCachedFlag
   clearCache
end mouseup
