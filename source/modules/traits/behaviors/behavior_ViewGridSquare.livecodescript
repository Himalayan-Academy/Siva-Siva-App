script "behavior_ViewGridSquare"
--> MetaData
-
license: GPLv3
name: behavior_ViewGridSquare
type: behavior
version: 0.1

--> Variables
-
local LocalArray


--> Props
-
getprop grid_OuterMargin
   return the margins of me
end grid_OuterMargin

setprop grid_OuterMargin someMargins
   lock screen
   put the rect of me into oRect
   set the margins of me to someMargins
   LayoutControl oRect
   unlock screen
end grid_OuterMargin


--> Controls
-
getprop grid_View
   return the long id of me
end grid_View

getprop layout_View
   return the long id of me
end layout_View

getprop view_Object
   return the long id of me
end view_Object


--> Children
-
getprop grid_Control [gridNum]
   put _getGridControl (gridNum) into gridControl
   return gridControl
end grid_Control


--> Props
-
getprop tile_View [gridNum]
   put _getGridControl (gridNum) into gridControl
   put the view_Name of gridControl into vName
   return vName
end tile_View

setprop tile_View [gridNum] vName
   put _getGridControl (gridNum) into gridControl
   set the control_Type of gridControl to vName
end tile_View

getprop tiles_Across
   put LocalArray ["tiles_Across"] into tilesAcross
   if tilesAcross is not a number then
      put _defaultTilesAcross() into tilesAcross
      put tilesAcross into LocalArray ["tiles_Across"]
   end if
   return tilesAcross
end tiles_Across

setprop tiles_Across tilesAcross
   put tilesAcross ^ 2 into gridNum
   _setGridNum gridNum
end tiles_Across

getprop grid_Num   
   put the tiles_Across of me into tilesAcross
   return tilesAcross ^ 2
end grid_Num

setprop grid_Num gridNum
   _setGridNum gridNum
end grid_Num

command _setGridNum gridNum
   lock screen
   --
   put gridNum ^ 0.5 into tilesAcross
   if tilesAcross is not an integer then return empty
   
   put tilesAcross into LocalArray ["tiles_Across"]
   put the childControlIDs of me into childIDs
   put the number of lines of childIDs into oldGridNum -- more robust
   
   put the rect of me into oRect
   switch
      case oldGridNum > gridNum
         -- delete the ones at the end
         repeat with lineNum = (gridNum + 1) to oldGridNum
            put line lineNum of childIDs into childID
            delete control id childID
         end repeat
         break
      case gridNum > oldGridNum
         -- add new ones to the end
         put the short id of me into groupID
         put the rect of me into someRect
         repeat with childNum = (oldGridNum + 1) to gridNum
            put "n" & childNum into someName
            create_PlaceHolder someName, someRect, groupID
         end repeat
         break
      default -- oldGridNum = gridNum
         -- do nothing
   end switch
   LayoutControl oRect
   --
   unlock screen
   return gridNum
end _setGridNum


--> Events
-
on resizeControl
   LayoutControl
end resizeControl

on LayoutControl pRect
   lock screen
   local squareRect, squareCentre, squareWidth, halfSquareWidth
   if pRect is empty then put the rect of me into pRect
   put the group_InnerRect [pRect] of me into innerRect
   
   put the grid_Num of me into gridNum
   calculate_SquareRect innerRect, squareRect, squareCentre, squareWidth, halfSquareWidth, pSquareMargin
   
   put gridNum ^ 0.5 into rowNum
   put squareWidth/rowNum into nWidth
   put trunc (nWidth) into nWidth
   put nWidth * rowNum into squareWidth
   put rect_LocWidthHeight (squareCentre, squareWidth, squareWidth) into squareRect
   
   put grid_ConstructRectArray (squareRect, nWidth, gridNum) into rectArray
   
   put the short id of me into groupID
   put the childControlIDs of me into childIDs
   repeat with childNum = 1 to gridNum
      put rectArray [childNum] into childRect
      
      put line childNum of childIDs into childID
      if childID is empty then
         put "n" & childNum into someName
         create_PlaceHolder someName, childRect, groupID
      else
         set the rect of control id childID to childRect
      end if
   end repeat
   unlock screen
end LayoutControl

function grid_ConstructRectArray squareRect, nWidth, gridNum
   put item 1 of squareRect into squareLeft
   put item 2 of squareRect into squareTop
   put 1 into nNum
   put gridNum ^ 0.5 into rowNum
   repeat with yNum = 1 to rowNum
      put nWidth * yNum into nBottom
      put squareTop + nBottom into item 4 of nRect
      put squareTop + nBottom - nWidth into item 2 of nRect
      repeat with xNum = 1 to rowNum
         put nWidth * xNum into nRight
         put squareLeft + nRight into item 3 of nRect
         put squareLeft + nRight - nWidth into item 1 of nRect
         
         put nRect into rectArray [nNum]
         add 1 to nNum
      end repeat
   end repeat
   return rectArray
end grid_ConstructRectArray


--> Geometry
-
function rect_GetSquare someRect, pSquareMargin
   local squareRect, squareCentre, squareWidth, halfSquareWidth
   calculate_SquareRect someRect, squareRect, squareCentre, squareWidth, halfSquareWidth, pSquareMargin
   return squareRect
end rect_GetSquare

command calculate_SquareRect pRect, @squareRect, @squareCentre, @squareWidth, @halfSquareWidth, pSquareMargin
   rect_ExtractDimensions pRect, someX, someY
   put min (someX, someY) into squareWidth
   put round ( squareWidth / 2 ) into halfSquareWidth
   put 2 * halfSquareWidth into squareWidth
   
   put rect_GetCentre (pRect) into squareCentre
   put rect_LocWidthHeight (squareCentre, squareWidth, squareWidth) into squareRect
   
   rect_SubtractMargins squareRect, pSquareMargin
   return squareRect
end calculate_SquareRect


--> Private
-
private function _defaultTilesAcross
   -- let's get a sensible default
   put the childControlIDs of me into childIDs
   put the number of lines of childIDs into gridNum
   
   put gridNum ^ 0.5 into tilesAcross
   if tilesAcross is not an integer then return 8
   return tilesAcross
end _defaultTilesAcross

private function _getGridControl gridNum
   put the childControlIDs of me into childIDs
   put line gridNum of childIDs into childID
   if childID is empty then return empty
   put the long id of control id childID of me into gridControl
   return gridControl
end _getGridControl


--> Deps
-
getprop group_InnerRect [rectBounds]
   put the long id of the target into targetGroup
   if rectBounds is empty then put the rect of targetGroup into rectBounds
   
   put the margins of targetGroup into someMargins
   if the showborder of targetGroup is true then
      put the borderwidth of targetGroup into bWidth
      repeat with itemNum = 1 to the number of items of someMargins
         add bWidth to item itemNum of someMargins
      end repeat
   end if
   rect_SubtractMargins rectBounds, someMargins
   return rectBounds
end group_InnerRect
