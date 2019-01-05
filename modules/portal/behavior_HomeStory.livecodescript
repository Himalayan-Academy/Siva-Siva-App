script "behavior_HomeStory" with behavior "model_Narratives"

/* 
This script  is the behavior assigned to card 1 of the Home
assign to group "HomeStory"
*/

global sConfigA,sDefaultImage,sMainImage
local  sStopRequested,sImageList,sLastImage,sQuoteList,sLastQuote,sImageCount

on mouseUp
   toggleNarrative
end mouseUp


command SetStopRequested pBool
   put pBool into sStopRequested
end SetStopRequested

command toggleNarrative
   if (sStopRequested = empty) OR (sStopRequested= "TRUE") then 
      put FALSE into sStopRequested
      startNarrative
   else
      put TRUE into sStopRequested 
      show widget "goNext"
   end if
end  toggleNarrative
   
command  getContent pPhotos,pText
   # functions from  model_Narrative:
   switch pPhotos
      case "Deities"
         put randomDietyPhotos() into sImageList 
         put the number of lines of sImageList into sImageCount
         break
   end switch
   switch pText
      case "Words of Our Master"
         put FetchQuotesCollection(pText) into sQuoteList
         break
   end switch
end getContent

command startNarrative
   
   
   getContent "Deities","Words of Our Master"
   put the long id of img "homeStoryMainImage" into sMainImage
   if sLastImage is 0 then add 1 to sLastImage
   
   #during development we have set this flag.
   # so we might as set here 
   if sStopRequested = empty then put FALSE into sStopRequested
   
   if  sStopRequested = "FALSE"  then
      repeat with x = sLastImage to sImageCount
         ntinfo ("repeat again" & x)
         if sStopRequested then exit repeat
         hide widget "goNext"
         put line x of sImageList into pPath
         put sLastImage into pQuoteNo
         # load an image
         dispatch "loadNewImage" to me with pPath
         --------------
         # development : fast show
         repeat 1 times
            if sStopRequested then exit repeat
            wait 20 millisecond with messages
         end repeat -- for the number of seconds
         -------------
         # Production
         --         repeat 2 times
         --            if sStopRequested then exit repeat
         --            wait 1 second with messages
         --         end repeat -- for the number of seconds
         -------------
         # loadNextQuote stuff here 
         dispatch "loadNextQuote" to me  with pQuoteNo-- to me with pPath
         put the number of words in fld "homeStoryText" into tTimetoRead
         
         --------------
         # development : fast show
         repeat  1 times
            wait 50 milliseconds with messages
         end repeat
         -------------
         # Production
         --         repeat  tTimetoRead times
         --            wait 50 milliseconds with messages
         --         end repeat
         add 1 to sLastImage
         
      end repeat
   end if
   ntinfo "End Narrative"
   if sLastImage > sImageCount then 
      put 0 into sLastImage
      show widget "goNext" of me
      answer "The End. Start Again?" with  "Yes" or "No"
      if it is "no" then
         stopShow
         exit startNarrative
      end if
   end if
end startNarrative

command loadNewImage pPath
   hide sMainImage with effect "dissolve" to black
   lock screen
   set the filename of sMainImage to pPath
   setImageLoc
   show sMainImage
   unlock screen with visual effect "dissolve" 
end loadNewImage

command loadNextQuote pQuoteNo
   set the itemdel to "|"
   put item pQuoteNo  of sQuoteList into fld "homeStoryText"
   hide sMainImage with effect "dissolve" to black
end loadNextQuote

command  setDefaultImage
   # store brand image 
   put path_Assets()& "img/siva-darshan/who-is-siva_1200x800.jpg" into sDefaultImage
   set the filename of sMainImage to  sDefaultImage
   show sMainImage
   setImageLoc
end  setDefaultImage

command stopShow
   put TRUE into sStopRequested
   setDefaultImage
end stopShow

command setImageLoc
   setRectOfCurrentGrc sMainImage
   put the loc of this card into tLoc
   subtract 27 from item 2 of tLoc
   resizeToHeight sMainImage,(the height of this card -58)
   set the loc sMainImage to tLoc
end setImageLoc


