-- Field script
on mouseDown
  put the num of lines of me into tmax # Store drag constraint
  put word 2 of the clickLine into tcl
  if not the listBehavior of me then set the textcolor of line tcl of me to
"red" # Cosmetic
  if line tcl of me is empty then
    exit mousedown
  end if
  put item 2 of the mouseLoc into tstarty
  put the effective textHeight of me into th
  repeat while the mouse is down
    if item 2 of the mouseLoc - tstarty > (th/2) then
      if within (me, the mouseLoc) is true then
        lock screen
        if tcl<tmax then # Constrain drag to max lines
          put cr & line tcl of me after line (tcl + 1) of me
          delete line tcl of me
          add 1 to tcl
          if not the listBehavior of me then set the textcolor of line tcl
of me to "red" # Cosmetic
          add th to tstarty
        end if
        if the listBehavior of me then set the hilitedLine of me to tcl #
Update hilitedline
        unlock screen
      end if
    else if tstarty - item 2 of the mouseLoc > (th/2) then
      if within (me, the mouseLoc) is true then
        lock screen
        put line tcl of me & cr before line (tcl - 1) of me
        delete line tcl + 1 of me
        subtract 1 from tcl
        if tcl<1 then put 1 into tcl # Constrain drag to min lines
        if not the listBehavior of me then set the textcolor of line tcl of
me to "red" # Cosmetic
        subtract th from tstarty
         if the listBehavior of me then set the hilitedLine of me to tcl #
Update hilitedline
        unlock screen
      end if
    end if
  end repeat
  if not the listBehavior of me then set the textcolor of line tcl of me to
empty # Cosmetic
end mouseDown
