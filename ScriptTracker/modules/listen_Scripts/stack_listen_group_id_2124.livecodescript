Script "stack_listen_group_id_2124"

/*
# Name: group "searchButton" of bkgnd "searchControls" of stack "listen"
# ID: group id 2124 of bkgnd id 2121 of stack "listen"
*/


on mouseUp
  if fld "searchString" is empty then
    answer "Please enter a search string" with "OK"
    exit to top
  else 
    runSearch (fld "searchString")
  end if
end mouseUp
