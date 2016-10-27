script "behavior_ViewSivaSivaContentsRow"
--> MetaData
-
license: GPLv3
name: behavior_ViewSivaSivaContentsRow
type: behavior
version: 0.3

--> Variables
-
local LocalArray


--> Events
-
on touchStart pID
   -- using touch msgs on android, because something is blocking mouseUps when scroller is active;
   mouseDown
end touchStart

on touchEnd pID
   -- using touch msgs on android, because something is blocking mouseUps when scroller is active;
   -- answer the params
   mouseUp
end touchEnd

on mouseDown
   -- set the row_Hilite of me to true
   if the controlKey is "Down" and "Siva-Siva-App" is among the lines of the active_Projects of me then
      menu_PopUp "Global | SivaSiva | Contents | Row | Menu"
   end if
   pass mouseDown
end mouseDown

on mouseRelease
   -- answer the params
   set the row_Hilite of me to false
   pass mouseRelease
end mouseRelease

on mouseUp
   put the short name of the target into cName
   switch cName
      case "portal-link-label"
         put the row_Name of me into portalName
         -- set the portal_Name of me to portalName -- trapped by scrolling_View above
         break
      case "portal-link-image"
         if the environment is "development" then
            put the image_File of me into imageFile
           -- put lcw_Ask ("Set the filename fo this image...", imageFile) into imageFile
          --  set the image_File of me to imageFile
         end if
         break
      default
         -- qput cName
   end switch
   set the row_Hilite of me to false
   pass mouseUp
end mouseUp

getprop row_Hilite
   return the blendlevel of me = 0
end row_Hilite

setprop row_Hilite someBoolean
   if someBoolean is true then
      set the blendlevel of me to 50
   else
      set the blendlevel of me to 0
   end if
end row_Hilite


--> Props
-
getprop row_Name
   return the row_Name of me
   -- return LocalArray ["rowName"]
end row_Name

setprop row_Name rowName
   local pSivasivaData
   put portal_GetRowData (rowName) into rowData
   set the row_Data of me to rowData
   
   -- make it permanent
   set the row_Name of me to rowName
   -- put rowName into LocalArray ["rowName"]
end row_Name

getprop row_Data
   put the title_Text of me into rowData ["imageText"]
   put the image_File of me into imageFile
   set the itemdelimiter to slash
   put item -1 of imageFile into shortImageFile
   put shortImageFile into rowData ["shortImageFile"]
   return rowData
end row_Data

setprop row_Data rowData
   put rowData ["imageText"] into imageText
   put rowData ["shortImageFile"] into shortFile
   
   lock screen
   set the title_Text of me to imageText
   put sivasiva_PortalImageFile (shortFile) into rowImageFile
   set the image_File of me to rowImageFile
   unlock screen
   
   delete variable LocalArray ["rowName"]
end row_Data

getprop title_Text
   put _fieldObject() into fieldObject
   put the text of fieldObject into someText
   return someText
end title_Text

setprop title_Text someText
   put _fieldObject() into fieldObject
   lock screen
   set the text of fieldObject to someText
   _centreVertically fieldObject
   unlock screen
   return fieldObject
end title_Text

getprop image_File
   put _imageObject() into imageObject
   put the filename of imageObject into someFileOrUrl
   return someFileOrUrl
end image_File

setprop image_File someFileOrUrl
   put _imageObject() into imageObject   
   set the filename of imageObject to someFileOrUrl 
   return imageObject
end image_File


--> Props | Display
-
getprop lock_Text
   put _fieldObject() into fieldObject
   put the locktext of fieldObject into someBoolean
   return someBoolean
end lock_Text

setprop lock_Text someBoolean
   put _fieldObject() into fieldObject
   set the locktext of fieldObject to someBoolean
   set the traversalOn of fieldObject to (someBoolean is false)
   return fieldObject
end lock_Text

getprop text_Margins
   put _fieldObject() into fieldObject
   return the margins of fieldObject
end text_Margins

setprop text_Margins someHow
   put _fieldObject() into fieldObject
   switch someHow
      case "center"
      case "centre"
         _centreVertically fieldObject
         break
      default
         set the margins of fieldObject to 8
   end switch
end text_Margins

private command _centreVertically fieldObject
   lock screen
   put the height of fieldObject into realHeight
   put item 1 of the margins of fieldObject into baseMargin
   
   set the margins of fieldObject to baseMargin
   put the formattedheight of fieldObject into fHeight
   put realHeight into availableHeight
   put availableHeight - fHeight into topSpace
   put round (topSpace/2) + baseMargin into topSpace
   put baseMargin,topSpace,baseMargin,baseMargin into newMargins
   set the margins of fieldObject to newMargins
   unlock screen
end _centreVertically


--> Events
-
on resizeControl
   LayoutControl
   pass resizeControl
end resizeControl


--> Geometry
-
on LayoutControl pRect
   -- let's centre the two halfs and place them in the middle
   if pRect is empty then put the rect of me into pRect
   
   put _fieldObject() into fieldObject
   put _imageObject() into imageObject
   put _graphicObject() into graphicObject
   
   put round (the width of fieldObject / 2) into halfFieldWidth
   put round (the width of imageObject / 2) into halfImageWidth
   
   -- subrtract any borders
   put the inner_Rect [pRect] of me into innerRect
   
   -- do some calculations
   put rect_GetCentre (pRect) into centreLoc
   put item 1 of centreLoc into centreX
   put item 2 of centreLoc into centreY
   put centreX - halfFieldWidth + 0 into centreFieldX
   put centreX + halfImageWidth - 1 into centreImageX
   
   put centreFieldX,centreY into fieldLoc
   put centreImageX,centreY into imageLoc
   
   lock screen
   /*
   get the loc of graphicObject
   get the loc of fieldObject
   get the loc of imageObject
   */
   
   set the loc of graphicObject to centreLoc
   set the loc of fieldObject to fieldLoc
   set the loc of imageObject to imageLoc
   unlock screen
end LayoutControl


--> Objects
-
getprop portal_Row
   return the long id of me
end portal_Row

getprop view_Object
   return the long id of me
end view_Object

private function _fieldObject
   return the long id of field 1 of me
end _fieldObject

private function _imageObject
   return the long id of image 1 of me
end _imageObject

private function _graphicObject
   return the long id of graphic 1 of me
end _graphicObject

