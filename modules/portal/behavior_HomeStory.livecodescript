script "behavior_HomeStory" with behavior "model_Narratives"

/* 
This script  is the behavior assigned to card 1 of the Home
assign to group "HomeStory"
*/

global sConfigA,sDefaultImage,sStopRequested,sMainImage

command toggleNarrative
   switch sStopRequested
      case (sStopRequest is empty)
      case FALSE
         startNarrative
         break
      case TRUE
         put FALSE into sStopRequested 
         break
   end switch
end  toggleNarrative
   
command startNarrative
   local sPhotoList
   # store brand image 
   put the long id of img "homeStoryMainImage" of me into sMainImage
   put path_Assets()& "img/siva-darshan/who-is-siva_1200x800.jpg" into sDefaultImage
   
   put FALSE into sStopRequested
   
   # from model_Narrative:
   
   put randomDietyPhotos() into sPhotoList 
   
   repeat for each line pPath in sPhotoList
      if sStopRequested then exit repeat
      dispatch "loadNewImage" to me with pPath
      repeat 2 times
         if sStopRequested then exit repeat
         wait 1 second with messages
      end repeat -- for the number of seconds
   end repeat
   setDefaultImage
end startNarrative

command  setDefaultImage
   set the filename of sMainImage to  sDefaultImage
   setImageLoc
end  setDefaultImage

command loadNewImage pPath
   hide sMainImage with effect "dissolve" to black
   lock screen
   set the filename of sMainImage to pPath
   setImageLoc
   show sMainImage
   unlock screen with visual effect "dissolve" 
   
end loadNewImage

command setImageLoc

   setRectOfCurrentGrc sMainImage
   put the loc of this card into tLoc
   subtract 27 from item 2 of tLoc
   resizeToHeight sMainImage,(the height of this card -58)
   set the loc sMainImage to tLoc
end setImageLoc

command stopShow
   setDefaultImage
   put TRUE into sStopRequested
end stopShow


