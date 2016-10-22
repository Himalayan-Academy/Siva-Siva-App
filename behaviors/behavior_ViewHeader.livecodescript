script "behavior_ViewHeader"
--> MetaData
-
license: GPLv3
name: behavior_ViewHeader
type: behavior
version: 0.1


--> Header | Props
-
getprop title_Text
   put the label of me into titleText
   return titleText
end title_Text

setprop title_Text titleText
   set the label of me to titleText
   return the long id of me
end title_Text



--> Object
-
getprop header_View
   return the long id of me
end header_View


--> View
-
getprop view_Object
   return the long id of me
end view_Object

getprop view_Name
   return "View|Header"
end view_Name


--> Events
-
on mouseUp
   local tActionName
   put the mouseAction of me into tActionName
   switch tActionName
      case "back"
         go back
         break
      case "add"
         set the opaque of me to true
         set the backgroundcolor of me to white
         break
      default
         put tActionName
   end switch
end mouseUp


--> Layout | Header
-


