Script "stack_surprise_card_id_1494"

/*
# Name: card "surprise" of stack "surprise"
# ID: card id 1494 of stack "surprise"
*/


on preopencard
   put the long id img "randomPhoto" into tBkgndPhoto
   put fetchRandomImageAsset("photography") into tImagePath
   set the filename of tBkgndPhoto to tImagePath
   setRectOfCurrentGrc tBkgndPhoto
   resizeToHeight tBkgndPhoto,736
   set the loc of tBkgndPhoto to the loc of this card
end preopencard



