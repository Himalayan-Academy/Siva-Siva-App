Script "stack_listen_group_id_2237"

/*
# Name: group "searchButton" of bkgnd "searchControls" of stack "listen"
# ID: group id 2237 of bkgnd id 2234 of stack "listen"
*/


on mouseUp
  if fld "searchString" is empty then
    answer "Please enter a search string" with "OK"
    exit to top
  else 
    runSearch (fld "searchString")
  end if
end mouseUp
