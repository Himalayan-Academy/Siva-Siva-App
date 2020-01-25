Script "stack_color-meditation_group_id_1159"

/*
# Name: group "selectPreferences" of group "cardBody" of card "colorPreferences" of stack "color-meditation"
# ID: group id 1159 of group id 1197 of card id 1023 of stack "color-meditation"
*/


on mouseup
   local tOptions, tSetting
   
   put empty into tOptions
   put the short name of the target into tSetting 
   set the uPrefsSetting of fld "prefsSelector" to tSetting
   switch tSetting
      case "Count"
         repeat with x = 1 to 9
            put x & cr after tOptions
         end repeat
         delete the last char of tOptions
         break
      case "Pace"
         put ("1" & cr & "1.25" & cr & "1.5" & cr & "1.75" & cr & "2" \
               & cr & "2.25" & cr & "2.50" & cr & "2.75" & cr & "3") into tOptions
         break
      case "Cycles"
         put ("1" & cr & "2" & cr & "3" & cr & "4" & cr & "5" & cr & "6")  into tOptions
         break
      case "Audio"
         put ( "On" & cr & "Off" ) into  tOptions
         break
   end switch
   put tOptions into fld "PrefsSelector"
   set the height of fld "PrefsSelector" to the formattedHeight of fld "PrefsSelector"
   show grp "PrefsSelectorGrp"
end mouseup
