Script "stack_listen_field_id_2210"

/*
# Name: field "searchString" of group "searchControls" of bkgnd "filterAudio" of stack "listen"
# ID: field id 2210 of group id 2317 of bkgnd id 2176 of stack "listen"
*/


on returnInField
   if (char -1 of me) is CR then
      delete char -1 of me
   end if
   focus on fld "changeFocus"
end returnInfield

on inputReturnKey
    if (char -1 of me) is CR then
      delete char -1 of me
   end if
   focus on fld "changeFocus"
end inputReturnKey

on returnkey
   focus on fld "changeFocus"
end returnkey

on keyDown pKey

if the platform="android" and pKey = cr then
 -- do all of the stuff you would have done in the ReturninField handler.
 -- Or just put this line in and execute your existing ReturninField handler.
 ReturninField 
else
 pass keyDown
end if

end keyDown
