script "Global_Layout_HeaderAndFooter_Menu"
--> MetaData
-
license: GPLv3
name: Global_Layout_HeaderAndFooter_Menu
type: controller
version: 0.1


--> Global | Layout | HeaderAndFooter | Menu
-
on menu_DisplayKenBurns layoutView, shortHtmlFile
   put the body_View of layoutView into browserView 
   put the project_HtmlFile ["burns_data.html"] of browserView into htmlFile
   set the url of browserView to htmlFile
end menu_DisplayKenBurns

on _
end _

on menu_EditBehavior layoutView, whichBehavior
   switch whichBehavior
      case "layout"
         put layoutView into childView
         put the behavior of layoutView into bObject
         break
      case "-"
      case "header"
         put the header_View of layoutView into childView 
         put the behavior of childView into bObject
         break
      case "body"
         put the body_View of layoutView into childView 
         put the behavior of childView into bObject
         break
      case "footer"
         put the footer_View of layoutView into childView 
         put the behavior of childView into bObject
         break
      default 
   end switch
   
   if exists (bObject) then
      edit the script of bObject
   else
      answer "This view does not have a behavior!"
      edit the script of childView
   end if
end menu_EditBehavior
   
on _
end _

on menu_UpdateComponents layoutView, withWhat
   put the header_View of layoutView into headerView
   put the body_View of layoutView into bodyView
   put the footer_View of layoutView into footerView
   
   lock screen
   switch withWhat
      case "Placeholders"
         set the control_Type of headerView to "placeholder"
         set the control_Type of bodyView to "placeholder"
         set the control_Type of footerView to "placeholder"
         break
      case "Browser"
         set the control_Type of headerView to "headerBar" -- "View|SivaSiva|Navigation|Bottom"
         set the control_Type of bodyView to "browser"
         put the result into newBodyView
         set the url of newBodyView to "http://dev.himalayanacademy.com/monastery/meet-the-monks"
         set the control_Type of footerView to "View|SivaSiva|Navigation|Bottom"
         break
   end switch
   unlock screen
end menu_UpdateComponents

on menu_SetOrientation layoutView, whichOrientation
   set the mobile_Orientation of layoutView to whichOrientation
end menu_SetOrientation

getprop which_Orientations
   return "portrait,landscape"
end which_Orientations

getprop which_Orientation [layoutView]
   put the mobile_Orientation of layoutView into whichOrientation
   return whichOrientation
   
   if the landscape_Layout of layoutView is true then
      return "landscape"
   else
      return "portrait"
   end if
end which_Orientation


--> Global | Layout | HeaderAndFooter | Menu | Props
-

--> Global | Layout | HeaderAndFooter | Menu | Disabled
-
