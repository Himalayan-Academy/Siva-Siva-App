Script "stack_pathtosiva_card_id_1253"

/*
# Name: card "choose your path" of stack "pathtosiva"
# ID: card id 1253 of stack "pathtosiva"
*/


on mouseUp
   put the short name of the target into tCd
   put the cIndex of the target into tIndex
   goCd tCd,"push left"
   setPref "index",tIndex
   put tCd into pTrackdata["contentTarget"]
   tracking_RecordActivity "Path To Siva", "navigation/goFromIndex", pTrackdata
end mouseUp

  
