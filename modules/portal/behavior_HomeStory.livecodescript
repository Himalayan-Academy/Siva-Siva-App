script "behavior_HomeStory" with behavior "model_Narratives"

/* 
This script  is the behavior assigned to card 1 of the Home
assign to group "HomeStory"
*/

global sConfigA,sDefaultImage,sMainImage
local  sImageList,sLastImage,sQuoteList,sLastQuote,sImageCount


command initializeNarrative
   ntinfo "Initialize scene"
   put the long id of img "homeStoryMainImage" into sMainImage
   if (sImageList is empty) OR (sQuoteList is empty) then 
      getContent "Deities","Words of Our Master"   # make random later
   end if
   if sConfigA["narrationScene"] = empty then
      # it means this a brand new session, start of the app.
      #  or, the user finished to story and back at a new beginning
      setDefaultImage  # on the card script
   else
      goNextScene
      if (the lockscreen) then unlock screen
   end if
   # responsive for the qute
   
   
end initializeNarrative


command  getContent pPhotos,pText
   # functions from  model_Narrative:
   switch pPhotos
      case "Deities"
         put randomDeityPhotos() into sImageList 
    
         put the number of lines of sImageList into sImageCount
         --ntInfo ("image list: " & line 1 of sImageList)
         break
   end switch
   switch pText
      case "Words of Our Master"
         put FetchQuotesCollection(pText) into sQuoteList
         break
   end switch
end getContent


command goNextScene
   --ntinfo ("last Image: " & sLastImage && "ImageCount:" &sImageCount)
   if sConfigA["narrationScene"] = empty then
      # it means we are starting again
      # TO DO we should have attributions as part of the narrative content
      # that is called from the model, so that it is not hard wired into the UI handlers
      showAttribution ("Words of Our Master" & cr  & cr  & "By" & cr  & cr  & "Siva Yogaswami" )
      put 1 into sConfigA["narrationScene"]
      exit goNextScene
   end if
   put sConfigA["narrationScene"] into sLastImage 
   # this keeps the Scene position when we leave this stack and come back
   put empty into fld "HomeStoryText"
   # load an image
   if (sLastImage is 0 ) OR (sLastImage is empty) then add 1 to sLastImage
   if not (the vis of sMainImage) then
      if sLastImage > sImageCount then 
         put 0 into sLastImage
         put empty into sConfigA["narrationScene"] 
         put path_Assets()& "img/siva-darshan/who-is-siva_1200x800.jpg" into pImage
         setDefaultImage pImage
         answer "The End. Start Again?" with  "Yes" or "No"
         if it is "Yes" then goNextScene
         exit goNextScene
      end if
      put line  sLastImage of sImageList into pPath
      loadNewImage pPath
   else
      loadNextQuote sLastImage
   end if
   add 1 to sLastImage
   put sLastImage into  sConfigA["narrationScene"] 
end goNextScene

command loadNewImage pPath
lock screen for visual effect
   set the filename of sMainImage to pPath
   setImageToFullCardLoc sMainImage, "portrait", 0,0
   centerMe sMainImage,0,0
   show sMainImage --with visual effect "dissolve" 
unlock screen with visual effect "dissolve" 
end loadNewImage

command loadNextQuote pQuoteNo
   
   lock screen for visual effect
   set the itemdel to "|"
   put item pQuoteNo  of sQuoteList into fld "homeStoryText"
   put the long id of fld "homeStoryText" into pControl
   centerMe pControl,0,5
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



