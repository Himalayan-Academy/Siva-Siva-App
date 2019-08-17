Script "stack_surprise_bkgnd_id_1509"

/*
# Name: bkgnd "share-ui" of stack "surprise"
# ID: bkgnd id 1509 of stack "surprise"
# Behavior: stack "behavior_SocialShare"

# Background on card IDs: 1494, 1037
*/


local tapFlag

on resizeControl
   set the clipstorect of me to true
   
   # use the bkgnd rect as the coords system
   put the long id of grc "share-controls-bkgnd" into tGroupContainer
   set the width of tGroupContainer to the width of this card
   set the height of tGroupContainer to 100
   set left of tGroupContainer to 0
   set the bottom of tGroupContainer to the height of this card
   
   # place objects
   put the width of tGroupContainer into tControlWidth
   put "facebook,tweet,email" into tShareOptions
   
   # math is not my forte. so let's just man handle these 
   set the left of widget "facebook" to tControlWidth/3/2 -25
   set the left of widget "tweet" to ((tControlWidth/2) -25)
   set the right of widget "email" to (tControlWidth - (tControlWidth/3/2) +25) 
   repeat for each item x in tShareOptions
      set the bottom of widget x to the bottom of tGroupContainer -15
   end repeat
   
   
   set the left of widget "close-sharing" to the ( (the width of tGroupContainer /2)-(the width of widget "close-sharing"/2) )
   set the top  of widget "close-sharing" to the top of tGroupContainer
   set the loc of btn "close-sharing" to the loc of widget "close-sharing"
   
   
   
end resizeControl

on mouseUp
 share_MouseEvent
end mouseUp



