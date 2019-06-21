Script "stack_settings_bkgnd_id_1364"

/*
# Name: bkgnd "display-info" of stack "settings"
# ID: bkgnd id 1364 of stack "settings"

# Shared group on card IDs: 1363
*/


local tapFlag

on resizeControl
   set the clipstoRect of me to true
   set the width of me to (the width of this card * .98)
   set the width of grc "info-field-bkgnd" to the width of me * .95
   set the height of grc "info-field-bkgnd" to the height of me * .92
   set the top of grc "info-field-bkgnd" to 70
   set the width of fld "info-text" to the width of me * .92
   set the height of fld "info-text" to the height of me * .80
   set the width of btn "close-info" to the width of me * .95
   set the loc of grc "info-field-bkgnd" to the loc of me
   set the loc of  fld "info-text"  to the loc of me
   set the left of widget "close-info" to the ( (the width of me /2)-(the width of widget "close-info"/2) )
   set the top  of widget "close-info" to the top of grc "info-field-bkgnd" 
   set the loc of btn "close-info" to the loc of widget "close-info"
   set the loc of me to the loc of this card 
end resizecontrol

on mouseUp
   put the short name of the target into tMouseEvent
   switch tMouseEvent
      case "close-info"
         hideme
         break
      case "info-bkgnd-img"
         switch tapFlag
            case 0
               hide fld "info-text" with visual effect scroll up very fast
               hide group "info-container" with visual effect dissolve very fast
               add 1 to tapFlag
               break
            case 1
               hideMe
               break        
         end switch
         break      
   end switch
end mouseUp

on hideMe
   hide widget "fontResize"
   hide fld "info-text" with visual effect scroll up very fast
   hide group "info-container" with visual effect dissolve very fast 
   set the textsize of fld "info-text" to 18hide img "info-bkgnd-img" with visual effect dissolve very fast 
   deleteMobileControl "info-text" 
   hide img "info-bkgnd-img"
   go to card "settings-home"
end hideMe

