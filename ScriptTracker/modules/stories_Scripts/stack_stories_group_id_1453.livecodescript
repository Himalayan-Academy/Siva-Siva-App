Script "stack_stories_group_id_1453"

/*
# Name: group "Icons" of group "ToolGroup" of card "colorIt" of stack "stories"
# ID: group id 1453 of group id 1449 of card id 1421 of stack "stories"
*/


on mouseUp
  if word 1 of the name of the target is "button"
  then choose (the short name of the target) tool
end mouseUp
