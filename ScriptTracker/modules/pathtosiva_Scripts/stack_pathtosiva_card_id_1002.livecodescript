Script "stack_pathtosiva_card_id_1002"

/*
# Name: card "photo index" of stack "pathtosiva"
# ID: card id 1002 of stack "pathtosiva"
*/


on openCard
  if isMobile() then
    createScroller "indexGrp"
 end if
 hide button "SVG Menu"
  pass openCard
end openCard


