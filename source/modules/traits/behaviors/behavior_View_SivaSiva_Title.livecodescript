script "behavior_View|SivaSiva|Title"
--> MetaData
-
license: GPLv3
name: behavior_View|SivaSiva|Title
type: behavior
version: 0.1

getprop title_Text
   put _titleField() into titleField
   put the text of titleField into titleText
   return titleText
end title_Text

setprop title_Text titleText
   put _titleField() into titleField
   set the text of titleField to titleText
   return titleText
end title_Text

private function _titleField
   return the long id of field 1 of me
end _titleField

