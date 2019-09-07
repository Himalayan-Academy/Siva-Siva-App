script "behavior_HomeStory" with behavior "model_Narratives"

/* 
This script  is the behavior assigned to card 1 of the Home
assign to group "HomeStory"

It is nested under a parent behavior: behavior "model_Narratives"
*/

global sConfigA,sDefaultImage,sMainImage
local  sImageList,sLastImage,sQuoteList,sLastQuote,sLastScene,sTotalSceneCount
local sAttribution


command initializeNarrative
   --breakpoint
   
   # for testin,set last scene toward the and
   --put 38 into sLastScene         
   
   # narrative is cached
   if getCache("ContentFlag") = 1 then 
      exit initializeNarrative #all content is cached
   end if
   
   #first run; narrative number is was not save to pref and is null
   if getCache("storyNumber") = "" then 
      setCache"storyNumber",1
   end if
   
   put getCache("storyNumber")  into pStoryNumber
   getContent pStoryNumber
   
   ntinfo "Initialize scene"
   
   put the long id of img "homeStoryMainImage" into sMainImage
   
   if (getCache(pImage)) is empty OR (getCache(pQuotes)is empty) then 
      getContent (getCache("storyNumber") )
   end if
   
   # sCacheA["narrationScene"]  tell us where we have in the current story
   # so that we can come back and start from where we left off.
   # see getters and setters lib_SivaSivae
   
   if getCache("narrationScene") <> empty then
      goNextScene
   end if
   
   if (the lockscreen) then unlock screen
   
end initializeNarrative


## TO DO... when the using quits the app and reboot we need them in come back
# the narrative in the right place.
# requires saviing the story number, scene and re-initalizing the cache.

# optimize to setting of preference,
#  we doing on the main stack script, for branding, 
# and also here 

function getUserPreferences pPref
   local tPortalPreferences, tPref
   put getPref ("preferences/modules/narrative") into tPortalPreferences
   put tPortalPreferences[pPref] into tPref
   return tPref
end getUserPreferences

command saveUserPrefs sBrandImageNumber
   setPref "preferences/modules/narrative", sBrandImageNumber
end saveUserPrefs

-----------------------------------------
## Trying to find architect that is scaleble and maintainable
## "getContent" is meant to "get a story"
## we are not using "model_Narratives" but we should be
## we should be able get and slide show in content store in that app
## slide show from the internet
## "a narrative" for the server , to be developed that called XML
##  which is a description of scened (see spec a google doc)
## for now is is hard wired to in-app photo + quote from the dBase
## this is just the beginning, It weill need to be responsive

# later should be  in model_Narratives


command goNextScene
   --breakpoint
   local tImage, tPath
   
   --ntinfo ("last Image: " & sLastImage && "ImageCount:" &sTotalSceneCount)
   
   put  getCache("narrationScene") into sLastScene
   
   # see if we need to get the cache.
   
   if sTotalSceneCount =""  then
      
      # locals are empty, first run or means we have gone to another module
      # and come back, need to get content for cache
      
      put  getCache(imageList) into sImageList
      put  getCache("Quotes") into sQuoteList
      put  getCache("Attribution") into sAttribution
      put  getCache("SceneCount") into sTotalSceneCount
   end if
   
   if sLastScene= empty then
      # it means we are starting again
      # TO DO we should have attributions as part of the narrative content
      # that is called from the model, so that it is not hard wired into the UI handlers
      showAttribution sAttribution
      setCache "narrationScene",1
      exit goNextScene
   end if
   
   put empty into fld "HomeStoryText"
   
   # brand new lauch, the app only know the branding image, nothing more
   # when have to increment to first scene
   
   if (sLastScene is 0 )  then add 1 to sLastScene
   
   # following is hard wired to slide show from the app
   # refactor when we get to an XML cum "SMILE" model
   
   #Deal with scene count, begin again etc.
   # we have reach the end.
   
   if sLastScene > sTotalSceneCount then 
      showIsOver
      exit goNextScene
   end if
   
   # We have not reached then end. We are in the middle of a story
   # so we can actually "go next" 
   
   if not (the vis of sMainImage) then
      put random(the number of lines of sImageList) into tLine
      put line tLine of sImageList into tPath
      # put line  sLastImage of sImageList into tPath
      loadNewImage tPath
   else
      loadNextQuote sLastImage
   end if
   
   
   add 1 to sLastScene
   setCache "narrationScene",sLastScene 
   
end goNextScene

command showIsOver
   # story if finished. back to default and prepare to 
   # increment to the next narrative.
   put empty into sLastScene
   setCache("ContentFlag"),0
   put getCache("storyNumber") into tStoryNumber
   
   if (tStoryNumber  = "" ) OR (tStoryNumber =2) then 
      # new app user first run, or an upgrade: preference on story are empty..
      # or we are reach the end of stories... hard wired right now to 2
      put 1 into tStoryNumber
   else
      add 1 to tStoryNumber
   end if
   setCache ("storyNumber"),tStoryNumber
   setCache "narrationScene",""
   setDefaultImage
   
   # get the new story
   getContent tStoryNumber
   put getCache("imageList") into sImageList
   put getCache("Quotes") into sQuoteList
   put getCache("Attribution") into sAttribution
   put getCache("SceneCount")  into sTotalSceneCount
   setCache ContentFlag, 1
end showIsOver


## we think for following handle my belong to the "model"
# but this a UI call  to show something in the "view"
# in MVC architecture, this would be part of a "controller"
# perhaps this script falls in that category?  

command loadNewImage pPath
   lock screen for visual effect
   set the filename of sMainImage to pPath
   setImageToFullCardLoc sMainImage, "portrait", 0,0
   centerMe sMainImage,0,0
   show sMainImage --with visual effect "dissolve" 
   unlock screen with visual effect "dissolve" 
end loadNewImage

command loadNextQuote pQuoteNo
   local tControl
   lock screen for visual effect
   set the itemdel to "|"
   # random quote
   put random(the number of lines of sQuoteList) into tLine
   put item tLine  of sQuoteList into fld "homeStoryText"
   --put item pQuoteNo  of sQuoteList into fld "homeStoryText"
   put the long id of fld "homeStoryText" into tControl
   centerMe tControl,0,5
   hide sMainImage -- with effect "dissolve" 
   unlock screen with visual effect "dissolve" 
end loadNextQuote

command showAttribution pAttribution
   lock screen
   hide sMainImage
   put pAttribution into fld "homeStoryText"
   unlock screen
end showAttribution

command fitFieldToContent  pField
   set the height of pField to the formattedHeight of pField
end fitFieldToContent

command hideShowField pField,pBool
   set the vis of pField to pBool
end hideShowField



