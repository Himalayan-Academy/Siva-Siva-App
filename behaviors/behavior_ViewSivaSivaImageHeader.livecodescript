script "behavior_ViewSivaSivaImageHeader"
--> MetaData
-
license: GPLv3
name: behavior_ViewSivaSivaImageHeader
type: behavior
version: 0.2

/*
This is a fixed height view, at the top of the home screen of a SivaSiva module.

It is designed for showing an image, or an SVG / web page.
*/

--> Variables
-
local LocalArray


--> Events
-
on mouseUp
   put the short name of the target into cName
   switch cName
      case "Title"
      case "Portal Header Image"
         put the logo_Faded of me into someBoolean
         set the logo_Faded of me to (not someBoolean)
         put init_ListStacksToUse() into stackNames
         replace comma with CR in stackNames
         answer stackNames
         answer the stacksinuse
         
         /*
         put sivasiva_ProjectFolder() into projectFolder
         answer folder_ListShort (projectFolder)
         
         put sivasiva_ConstructFolder ("libraries") into standardFolder
         put mobile_ListShortFiles (standardFolder) into shortFiles
         answer shortFiles
         
         answer project_ListFolderStacks ("libraries")
         answer project_ListFolderStacks ("models")
         */
         break
      case "home-logo"
         if the environment is "development" then
            dispatch "stack_ToggleShrink" to me
         else
            set the portal_Name of me to "home"
            -- set the logo_Faded of me to true
         end if
         break
      default
         -- put cName
         pass mouseUp
   end switch
end mouseUp


--> Props
-
getprop logo_Visible
   put _logoButton() into logoButton
   put the blendLevel of logoButton = 0 into fadedIn
   put fadedIn and the visible of _logoButton() into isVisible
   return isVisible
end logo_Visible

setprop logo_Visible someBoolean
   put _logoButton() into logoButton
   lock screen
   set the visible of logoButton to someBoolean
   set the blendlevel of logoButton to 0
   unlock screen
end logo_Visible

getprop logo_Faded
   put _logoButton() into logoButton
   put the blendLevel of logoButton = 100 into fadedOut
   return fadedOut
end logo_Faded

setprop logo_Faded someBoolean
   put _logoButton() into logoButton
   set the visible of logoButton to true
   put 2 into someIncrement
   put 20 into someDelay
   put _logoButton() into logoButton
   
   if someBoolean is true then
      logo_FadeOut 0, logoButton, someIncrement, someDelay
   else
      logo_FadeIn 100, logoButton, someIncrement, someDelay
   end if
end logo_Faded

command logo_FadeIn newBlendLevel, logoButton, someIncrement, someDelay
   set the blendLevel of logoButton to newBlendLevel
   if newBlendLevel > 0 then
      subtract someIncrement from newBlendLevel
      send "logo_FadeIn newBlendLevel,logoButton,someIncrement,someDelay" to me in someDelay milliseconds
   else
      set the blendLevel of logoButton to 0
   end if
end logo_FadeIn

command logo_FadeOut newBlendLevel, logoButton, someIncrement, someDelay
   set the blendLevel of logoButton to newBlendLevel
   if newBlendLevel < 100 then
      add someIncrement to newBlendLevel
      send "logo_FadeOut newBlendLevel,logoButton,someIncrement,someDelay" to me in someDelay milliseconds
   else
      set the blendLevel of logoButton to 100
   end if
end logo_FadeOut

getprop portal_Header
   return LocalArray ["portalName"]
end portal_Header

setprop portal_Header portalName
   lock screen
   set the title_Text of me to portalName
   put portal_GetHeaderImageFile (portalName) into imageFile
   set the image_File of _imageObject() to imageFile
   put portalName into LocalArray ["portalName"]
   unlock screen
   return imageFile
end portal_Header

getprop portal_ShortHeaderFile
   put the image_File of _imageObject() into headerImageFile
   set the itemdelimiter to slash
   put item -1 of headerImageFile into shortFile
   return shortFile
end portal_ShortHeaderFile

setprop portal_ShortHeaderFile shortFile
   put sivasiva_PortalImageFile (shortFile) into headerImageFile
   set the image_File of _imageObject() to headerImageFile
   return headerImageFile
end portal_ShortHeaderFile

getprop title_Text
   put the text of fld 1 of me into titleText
   return titleText
end title_Text

setprop title_Text titleText
   put toUpper (titleText) into titleText
   set the text of fld 1 of me to titleText
   return headerView
end title_Text

getprop image_File
   put _imageObject() into imageObject
   put the filename of imageObject into someFileOrUrl
   return someFileOrUrl
end image_File

setprop image_File someFileOrUrl
   put _imageObject() into imageObject
   put _browserView() into browserView
   
   lock screen
   set the filename of imageObject to someFileOrUrl 
   hide browserView
   show imageObject
   unlock screen
   return imageObject
end image_File

getprop browser_Url
   put _browserView() into browserView
   put the url of browserView into someURL
   return someURL
end browser_Url

setprop browser_Url someURL
   put _browserView() into browserView
   put _imageObject() into imageObject
   
   lock screen
   set the url of browserView to someURL
   hide imageObject
   show browserView
   unlock screen
   return browserView
end browser_Url


--> Events
-
on resizeControl
   LayoutControl
end resizeControl

command LayoutControl pRect
   -- lets place this view at a fixed rect, but positioned at the top and centre of pRect
   if pRect is empty then put the rect of me into pRect
   
   put _browserView() into browserView
   put _imageObject() into imageObject
   put _titleView()  into titleView
   put _graphicBackground() into graphicBackground
   put the width of imageObject into fixedWidth
   
   put item 1 of pRect into pLeft
   put item 3 of pRect - pLeft into pWidth
   put round ((pWidth - fixedWidth)/2) into leftSpace
   if leftSpace < 0 then put 0 into leftSpace
   
   put pLeft + leftSpace into myLeft
   put item 2 of pRect into myTop
   put myLeft,myTop into myTopLeft
   
   lock screen
   set the topleft of graphicBackground to myTopLeft
   set the topleft of imageObject to myTopLeft
   set the topleft of titleView to myTopLeft
   
   put the rect of imageObject into imageRect -- lazy should work out rects
   set the rect of browserView to imageRect
   unlock screen
end LayoutControl


--> Objects
-
getprop sivasiva_HeaderView
   return the long id of me
end sivasiva_HeaderView

getprop view_Object
   return the long id of me
end view_Object

getprop browser_View
   return _browserView()
end browser_View

getprop image_Object
   return _imageObject()
end image_Object

getprop title_View
   return _titleView() 
end title_View

getprop logo_Button
   return _logoButton()
end logo_Button

private function _logoButton
   return the long id of button "home-logo" of me
end _logoButton

private function _titleView
   return the long id of group "Portal Header Title" of me
end _titleView

private function _browserView
   return the long id of widget "Portal Header Browser" of me
end _browserView

private function _imageObject
   return the long id of image "Portal Header Image" of me
end _imageObject

private function _graphicBackground
   return the long id of graphic 1 of me
end _graphicBackground
