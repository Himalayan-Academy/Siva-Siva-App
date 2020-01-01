Script "stack_color-meditation_field_id_1173"

/*
# Name: field "prefsSelector" of group "prefsSelectorGrp" of card "colorPreferences" of stack "color-meditation"
# ID: field id 1173 of group id 1162 of card id 1023 of stack "color-meditation"
*/


on mouseup
   put the uPrefsSetting of me  into tSetting
   put  value (clickline() ) into fld ("current"& tSetting)
   hide grp "prefsSelectorGrp"
   saveUserPrefs
   showCommitment
end mouseup
