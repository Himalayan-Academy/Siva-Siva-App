script "behavior_ViewSivaSivaImageHeader"
--> MetaData
-
license: GPLv3
name: behavior_ViewSivaSivaImageHeader
type: behavior
version: 0.1

/*
This is a fixed height view, at the top of the home screen of a SivaSiva module.

It is designed for showing an image, or an SVG / web page.
*/

--> Variables
-
local LocalArray


--> Props
-
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
