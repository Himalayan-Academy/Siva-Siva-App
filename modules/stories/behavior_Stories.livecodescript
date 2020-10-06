script "behavior_Stories" with behavior "model_Stories"

/* 
This script  is the behavior  stack "modules/stories.livecode"
It is nested under a parent behavior: behavior "model_Stories"
Revised 2020-01-15
Revised 2020-10-01
*/


global sConfigA, sDefaultImage,
local sStoriesMetaArray,sWhere  # get the metadata for each story; and parameters

# geometry vars
local sStoryMenu 

# story control variables, stored cache
# must wipe them on end of story
local  sImageList, sLastImage, sQuoteList, sLastQuote
local sAttribution, sStoryTitle,sLastScene,sTotalSceneCount

# various screen display options
local sTarget, sTargetOwner
local sTips

on preopenstack
   put loadStoriesMetadata() into sStoriesMetaArray
end preopenstack


/* Per Card Layout and UI

Summary: We are putting layout of UI here
Based on the card name

*/

on preOpenCard
   if the logMessage <> empty then
      copyLogControl
   end if
   setCardCoords "portrait"
   put the long id of fld "storyMenu" into sStoryMenu
   put the long id of fld "tips" into sTips
end preopenCard

on opencard
   local tCard 
   put the short name of this card into tCard
   
   # load the menu in any case:
   put the keys of sStoriesMetaArray["Stories"] into fld "storyMenu"
   showStoryMenu
end opencard
      
command showStoryMenu
   dispatch "deleteMobileControl" to sTips with "tips"
   dispatch "createScroller" to sStoryMenu with "storyMenu"
   set the filename of img "menuImage" to (path_Assets()&"img/portal-screens/00-DonAngeIraivan-darkened_opt-80.jpg")
   hide grp "tips"
   show grp "storyMenu"
   display_SetStatusBarVis true
   
end showStoryMenu 

/*
UX for user for the stack and cardi
*/
on mouseup
   local tTips
   
   put the short name of the owner of the target into sTargetOwner
   put the short name of the target into sTarget
   put loadStoriesMetadata() into sStoriesMetaArray
   
   switch sTarget
      case "storyMenu"
         put value(clickLine() ) into sStoryTitle
         if sStoryTitle is empty then exit mouseup
         
         put  sStoriesMetaArray["Stories"][sStoryTitle]["where"] into sWhere
         
         switch sWhere
            case "local" 
               dataLocalStack
               
               # development
               open (path_Modules() & "stories/makeStoryLocal.livecode")
               
               break
            case "server"
               dataServerStack
               
               # development
               open (path_Documents() & "media/stories/"  & sStoryTitle & "/" & sStoryTitle & ".livecode")
               break
         end switch
         
         # development
         visualArticle sWhere
         
         break
         
      case "tips"
         set the filename of img "tipsImage" to (path_Assets()&"img/bkgnds/patterns/Blue-Texture-Square.jpg")
         put url ("file:"& path_Modules()& "stories/stories-user-guide.html") into tTips
         set the htmltext of fld "tips" to tTips 
         dispatch "createscroller" to sTips with "tips"
         show grp "tips"
         break
         
      case "back"
         dispatch "deleteMobileControl" to sTips with "tips"
         hide grp "tips"
         break
   end switch
   
end mouseup

on dataLocalStack
   local pPassTitle
   put sStoryTitle into pPassTitle
   send "makeStoryLocal pPassTitle" to stack "makeStoryLocal" in 0 seconds
   
   
end dataLocalStack

on dataServerStack
   local tHttpsServerRoot, tLocalDocumentsStories
   local tFilePath, tServerPath, tFiles, tLocation
   
   put "https://dev.himalayanacademy.com/media/stories/" into tHttpsServerRoot
   put path_Documents()& "media/stories/" into tLocalDocumentsStories
   
   put (tHttpsServerRoot & sStoryTitle & "/" & sStoryTitle & ".zip") into tServerPath
   replace space with "%20" in tServerPath
   
   create folder tLocalDocumentsStories & sStoryTitle
   
   put tLocalDocumentsStories & sStoryTitle & "/" & sStoryTitle & ".zip" into tFilePath
   
   put URL (tServerPath) into  URL ("binfile:" & tFilePath)
   
   // Open the archive
   revZipOpenArchive tFilePath, "update"
   
   // Get the list of files in the archive
   put revZipEnumerateItems(tFilePath) into tFiles
   
   // Get the path to the folder the files should be extracted to
   set the itemDel to "/"
   put tFilePath into tLocation
   delete item -1 of tLocation
   
   // Extract each file
   repeat for each line tItem in tFiles
      revZipExtractItemToFile tFilePath, tItem, tLocation & "/" & tItem
   end repeat
   
   // Close the archive
   revZipCloseArchive tFilePath
   
end dataServerStack 

#development
command visualArticle sWhere
   if sWhere is "server" then
      
      // answer the questions:
      --      "There are XX metabytes of images. Shall we download them?
      --      You have a chance to get rid of them. Or save to your phone.
      --       You will go back and finish up the story."
      --  No | Yes
      --      if it is "No" then don't
      
      --         you do the visualArticl3
      end  if
      
   end visualArticle
   
   
   -------
   local pData,  tCd,  
   
   command addJournalEntry -- save a bookmark to db
   local tTitle
   if (sStoryTitle is "false") OR (sStorytitle is empty) then 
      put "Main Menu" into tTitle 
   else 
      put sStoryTitle into pData["storyTitle"]
      put sLastScene into pData["storyScene"]
      put sAttribution into pData["Attribution"]
      put sTotalSceneCount into pData["SceneCount"]
   end if
   put "storiesHome" into pData["card"]
   Journal_RecordEntry "Stories",(sStoryTitle &", "& sLastScene), pData -- send to journal
end addJournalEntry
		
on journalResume pData -- sent from journal stack
   put pData["Card"] into tCd
   go to card tCd
   put loadStoriesMetadata() into sStoriesMetaArray
   getcontent pData["storyTitle"]
   
   put getCache("imageList") into simageList
   put getCache("Quotes") into sQuoteList
   
   put pData["storyTitle"] into sStoryTitle
   put pData["storyScene"] into sLastScene
   put pData["Attribution"] into sAttribution
   put pData["SceneCount"] into sTotalSceneCount
   setCache "storyScene",sLastScene
   display_SetStatusBarVis false
   showStoryText
   goNextScene
   
end journalResume


on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack


on updateUI
   local tFooter,tMenu,tTextDisplay,tStoryBkgndImage,tStoryImage,tGoNext,tControl
   local tGoTips
   
   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
   end if
   
   put the long id of grp "storiesMenu" into tMenu
   topcenterMe tMenu,120
   
   put the long id of img "StoryBkgndImage" into tStoryBkgndImage
   CenterMe tStoryBkgndImage
   
   put the long id of img "StoryImage" into tStoryImage
   CenterMe tStoryImage
   
   put the long id of btn "goNext" into tGoNext
   bottomCenterMe tGoNext,65
   
   put the long id of btn "tips" into tGoTips
   bottomCenterMe tGoTips,70
   
   set the rect sTips to (10, 50, cardWidth() - 10, the top of btn "goNext" - 21)
   
   set the rect sStoryMenu to (32, 50, cardWidth() - 32, the top of btn "back" - 21)
   set the uRect of sStoryMenu  to the rect of sStoryMenu 
   
   put the long id of grp "footer" into tFooter
   send "updateUI" to tFooter
end updateUI

on closeCard
   showStoryMenu
end closecard

on closestack  
   portal_SetLastStack "stories" 
end closestack


