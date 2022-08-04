script "behavior_ImagePuzzles"
local sTargetOwner, sTarget,sPuzzleLevel, sCard, sControl
local sTitleImage, sStarImage, sMainImage, sBrandImages, sBrandImageNumber
local sIsHome,sImageForTiles, sLocPuzzleFrame
local sTiles,sMsg, sMyHome
local sJournalData, sRealm, 

on preOpenStack
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
      set the fullscreenmode of this stack to empty
      iphoneSetAudioCategory "playback" 
   end if
end preOpenStack

on preopenCard
   put the short name of this card into sCard
   
   setCardCoords "portrait"
   updateUI
   switch sCard
      case "Title" 
         setDefaultImage
         break
      case "mainImagePuzzle" 
         resizeStack
         break
   end switch
end preopencard

on goToMainPuzzle
   local tShortName
   
   switch sCard
      case "Title"
         wait 500 milliseconds
         visual effect "dissolve" very slow
         go to card 2
         show img "orion_nebula"
        
         up_InfoPanel
         
         break
         
   end switch
   
end goToMainPuzzle

command up_InfoPanel
   clearImageTiles
   show img "orion_nebula"
   set the layer of image "orion_nebula" of card "mainImagePuzzle" of me to bottom
   show grp "makeTiles"
end up_InfoPanel

command down_InfoPanel
   hide grp "makeTiles"
   clearImageTiles
   hide image "orion_nebula"
end down_InfoPanel


on mouseup
   local tTips, tImagePuzzlesGuide
   
   put the short name of the owner of the target into sTargetOwner
   put the short name of the target into sTarget
   
   switch sTarget
      
      case "goImagePuzzle"
         
         visual effect "dissolve"  slow
         wait 300 milliseconds
         go card "mainImagePuzzle"
         break
         
      case "Make a Puzzle"
         down_InfoPanel
         fetchImage sRealm
         makePuzzle
         break
         
      case "categoryImages"
         toggleCategoryPanel
         break
         
      case "Devas"
         put "Realm of God" into sRealm
         fieldShowCategory
         break
      case "Your Soul"
         put "Realm of Soul" into sRealm
         fieldShowCategory
         break
      case "Life"
         put "Realm of Life" into sRealm
         fieldShowCategory
         break
      case "Nature"
         put "Realm of Nature" into sRealm
         fieldShowCategory
         break
      case "HelpButton"
         
         put url ("file:"& path_Modules()& "games/imagepuzzles/image-puzzles-guide.html") into tImagePuzzlesGuide
         set the htmltext of fld "helpField" to tImagePuzzlesGuide
         
         
         show grc "helpBkg"
         show btn "helpDismiss"
         show grp "helpField"
         lock screen
         deleteMobileControl "helpField"
         # recreate:
         set the height of fld "helpField" to the formattedHeight of fld "helpField"
         set the top of fld "helpField" to the top of grp "helpField"
         send "CreateScroller helpField" to fld "helpField"
         
         unlock screen
         break
         
      case "helpDismiss"
         hide btn "helpDismiss"
         hide grp "helpField"
         hide grc "helpBkg"
         break
      case "Clear"
         show btn "helpButton"
         clearImageTiles
         break
         
      case "Store"
         local uImageGanesh1
         put (the rect of  img "mah36lin.jpg") into uImageGanesh1["rect"]
         put the imageData of  img "mah36lin.jpg" into uImageGanesh1["image"]
         set the uImage_puzzle1 of this stack to uImageGanesh1
         break
         
   end switch
end mouseup

------------- 
local tImageWidth, tImageHeight, tImageData
local tInitialLeft, tInitialTop, tTileNumber, tCrossCount
local tTileWidth,tTileheight,tTilePick, tRightEdge,tBottomEdge
local tLeftCoord,tTopCoord
local tImage, tImageFile
local tNextTileName, tTileLocation,tTileList
local  sCurrentPuzzle, tformattedHeight, tLeft

on makePuzzle
   lock screen
   set the uTileList of this card to empty
   put empty into tTileList
   put empty into tImageData["image"] 
   
   put the long id of grc "puzzleFrame" into sLocPuzzleFrame
   put the long id of last image into tImage
   
   hide sLocPuzzleFrame
   
   set the topleft of tImage to 0,0
   set the name of the last image to "currentpuzzle"
   put the long id of image "CurrentPuzzle" into sCurrentPuzzle
   
   setRectOfCurrentGrc tImage
   
   
   if the height of  tImage > CardHeight()-100 then 
      resizeToHeight tImage, CardHeight()-100
   else
      resizeToWidth tImage, CardWidth()-20
   end if 
   
   set the rect of sLocPuzzleFrame to  the rect of sCurrentPuzzle -- img "currentpuzzle"
   
   put the width of img "currentpuzzle"  into tImageWidth
   put the height of img "currentpuzzle"   into tImageHeight
   put the left of image "currentPuzzle" into  tInitialLeft
   put the top of image "currentPuzzle" into tInitialTop
   
   put 9 into sPuzzleLevel
   
   put 1 into tTileNumber
   
   put sqrt(sPuzzleLevel) into tCrossCount
   
   put tImageWidth/tCrossCount into tTileWidth
   put tImageheight/tCrossCount into tTileHeight
   put (tTileWidth+tInitialLeft) into tRightEdge # initialize first tile location
   put (tTileHeight+tInitialTop) into tBottomEdge
   put tInitialLeft into tLeftCoord
   put tInitialTop into tTopCoord
   
   # do one row at a time horizontall
   
   
   repeat tCrossCount Times
      # Each iteration we drop down one row (see below)
      
      repeat tCrossCount times #1 row across
         copy img "CurrentPuzzle" to this card
         
         set the rect of it to the rect of sLocPuzzleFrame 
         
         set the imagedata of it to the imagedata of image "currentpuzzle" 
         set the rect of img "currentpuzzle"  to the rect of sLocPuzzleFrame 
         
         put "tile_" & tTileNumber into tNextTileName
         set the name of the last Image to tNextTileName
         crop image tNextTileName  to tLeftCoord, tTopCoord, tRightEdge, tBottomEdge
         
         put the loc of image tNextTileName into tTileLocation
         
         # where the tile are based the card
         # but get to the location of the grp ]]
         
         add round((CardWidth()-tImageWidth)/2 ) to item 1 of tTileLocation   
         add round(20+safeTopMargin()) to item 2 of tTileLocation
         
         set the uTileLocation of image tNextTileName to tTileLocation
         
         # put tTileLocation & cr after tLocations  #MONITOR
         put tNextTileName & cr after tTileList
         set the behavior of image tNextTileName to the long id of btn "tileScript"
         
         add tTileWidth to tLeftCoord
         add tTileWidth to tRightEdge
         add 1 to tTileNumber
      end repeat
      
      #initialize locations for the next row
      
      # first drop down one tile height
      add tTileHeight to  tTopCoord 
      
      # move back to the left edge
      put tInitialLeft into tLeftCoord
      
      # reset right edge
      put (tTileWidth+tInitialLeft) into tRightEdge
      
      # set a new bottom coordinate
      # based on the current top of this row of tiles
      put (tTileHeight  + tTopCoord) into tBottomEdge
      
   end repeat
   
   set the uTileList of this card to tTileList
   delete img "CurrentPuzzle"
   
   topCenterMe sLocPuzzleFrame, 20
   unlock screen
   
   show grc "puzzleFrame"
   
   distributeTiles
   
   # put tLocations & cr & cr & tCoords #MONITOR
end makePuzzle


on distributeTiles
   local tTilesShelf,tShelfWidth
   local tShelfheight,tX,tY
   
   put the uTileList of this card into sTiles
   repeat for each line x in sTiles
      # set up random locations that fall inside the Scattered Tile Zone area
      # left position by 120 pixels  
      # height position by 180 pixel
      
      put (the width of this card) -120 into tShelfWidth
      put (the height of this card) -180 into tShelfheight
      
      put random(tShelfWidth) + (tTilesShelf[1])+60 into tX
      put random(tShelfHeight) + (tTilesShelf[2])+25 into tY
      
      #set the loc of img x to tX,tY
      
      try
         move img x to  tX,tY in 80 milliseconds
      end try
   end repeat
   
   
end distributeTiles

command fetchImage sRealm
   local tImgSQL, tImageFileID, tCurrentPuzzle
   lock screen
   if sRealm is empty then
      put "Realm of God" into sRealm
   end if
   
   put the uRandomImageSelect of this card into tImgSQL
   replace ":1" with sRealm in tImgSQL
   dbSetSQL tImgSQL
   put dbGet ("file_id", JnanamDB()) into tImageFileID
   put textDecode ( tImageFileID[1]["file_id"], "UTF8")  into tImageFileID     
   put "img/photography/"  & tImageFileID & "/" & tImageFileID & "_med.jpg" into tCurrentPuzzle
   --put "img/photography/app-img_2-surya_namaskar_00043_552w-portrait/app-img_2-surya_namaskar_00043_552w-portrait_med.jpg"  into tCurrentPuzzle
  
   set the paintCompression to "JPEG"
   import paint from file  (sivasiva_AssetFolder() & tCurrentPuzzle)
   put the long id of last image into tImage
   
   
   setImageToFullCardLoc tImage
   --put getRectOfCurrentGrc()
   set itemdel to "x"
   if  item 1 getRectOfCurrentGrc() < item 2 getRectOfCurrentGrc() AND \
         item 1 getRectOfCurrentGrc() < 400 then
      delete last image 
      fetchImage
   end if
   
   unlock screen
end fetchImage

on fieldShowCategory
   put sRealm &":" &cr & "Pictures Will Appear." into fld "category"
   show fld "category"
   wait 4 second
  hide fld "category"  with visual effect "dissolve" very slowly
end fieldShowCategory


on clearImageTiles
   hide grc "puzzleFrame"
   try 
      delete sCurrentPuzzle
   end try
   try
      repeat with x = 1 to 200
         delete image ("tile_" & x)
      end repeat
   end try
   
end clearImageTiles

/*
See behavior_TileScript for all the 
image "tile_#" of "me".
See grab me 

*/

function setTileGlow
   local sTileGlow
   put "255,255,255" into sTileGlow["color"]
   put "normal" into sTileGlow["blendMode"]
   put "255" into sTileGlow["opacity"]
   put "box1pass" into sTileGlow["filter"]
   put "40" into sTileGlow["size"] 
   put "80" into sTileGlow["spread"] 
   return  sTileGlow
end setTileGlow


on checkCompletion 
   local  tTargetLocs,tImgLocs
   
   put the uTileList of this card into sTiles 
   repeat for each line x in sTiles 
      put the uTileLocation of img x & cr after tTargetLocs 
      put the loc of img x & cr after tImgLocs 
   end repeat 
   
   put  tTargetLocs  & cr &cr & tImgLocs  & cr after fld "log"
   
   --breakpoint
   sort tTargetLocs numeric by item 2 of each 
   sort tImgLocs numeric by item 2 of each 
   sort tTargetLocs numeric by item 1 of each 
   sort tImgLocs numeric by item 1 of each 
   if tTargetLocs = tImgLocs then 
      #stopTimer 
      put "Congratulations! You did it!" into sMsg
      fireCompletedAction sMsg
   end if 
   set the layer of grp "makeTiles" to top
end checkCompletion 

command fireCompletedAction sMsg
   local tStatus
   --breakpoint
   put sMsg into fld "status"
   set the layer fld "status" to top
   show fld "status"
   
   put the long id of fld "status" into tStatus
   bottomCenterMe tStatus, 30
   
   wait 2 second 
   hide fld "status"  with visual effect "dissolve" very slowly
   put empty into fld "status"
end fireCompletedAction


function getLocation tCoords
   local theX, theY
   put trunc ( (item 3 of tCoords - item 1 of tCoords)/2)  + trunc ( ( item 1 of tCoords) ) into theX
   put trunc ( (item 4 of tCoords - item 2 of tCoords)/2)  + trunc (item 2 of tCoords) into theY
   return (theX,theY)
end getLocation


/*
Get brand image; see Siva 
See open card
*/

command setDefaultImage pContext
   --breakpoint
   
   #  see lib_SivaSiva | setUpBrandImage  
   
   local pImage, tPaths, tTotalBrandImages
   
   put the long id of img "title" of card "Title" into sTitleImage
   put _brandImages() into sBrandImages
   
   put the number of lines of sBrandImages into tTotalBrandImages
   put random(tTotalBrandImages) into sBrandImageNumber
   put line sBrandImageNumber of sBrandImages into pImage
   set the filename of img "title" to photoImagePath(pImage)
   setImageToFullCardLoc sTitleImage,"portrait"
   centerMe sTitleImage
   
   # optimize disk operations *after* the display is finished updating
   
   put the number of lines of sBrandImages into tTotalBrandImages
   setPref "preferences/modules/portal/totalBrandImages", tTotalBrandImages
end setDefaultImage 



function PhotoImagePath pImage
   local tPath
   put path_Assets() & "img/photography/" & pImage & "/" \
         & pImage & "_med.jpg" into tPath
   return tPath
end PhotoImagePath


private function _brandImages 
   local tBrandImages
   put "app-img_who-is-siva_1200x800_med" & cr & \
         "app-img_06-sadasiva_opt-80_552w-portrait" & cr & \
         "app-img_01-sadyojata_opt-80_552w-portrait" & cr & \
         "app-img_02-vamadeva_opt-80_552w-portrait" & cr & \
         "app-img_03-aghora_opt-80_552w-portrait" & cr & \
         "app-img_04-tatpurusha_opt-80_552w-portrait" & cr & \
         "app-img_05-ishana_opt-80_552w-portrait" & cr & \
         "app-img_hap-0140_552w-portrait" & cr & \
         "app-img_sinha_9_552w-portrait" & cr & \
         "app-img_siva_552w-portrait"& cr & \
         "app-img_kadavul_nataraja_shrine_552w-portrait" & cr & \
         "app-img_img_1444_736h-landscape_med" & cr & \
         "app-img_ganagta02_l_552w-portrait" & cr & \
         "app-img_dscn1092_552w-portrait" & cr & \
         "app-img_book_siva_yogi_big_736h-square" & cr & \
         "app-img_book_siva_face_736h-square" & cr & \
         "app-img_agamasivadancing_736h-square" & cr & \
         "app-img_70s_siva_poster_552w-portrait" & cr & \
         "app-img_44_sharma_siva_552w-portrait" & cr & \
         "app-img_34_linga_liberation_552w-portrait" & cr & \
         "app-img_sinha_10_552w-portrait" & cr & \
         "app-img_sinha_3_552w-portrait" & cr & \
         "app-img_sinha_6_552w-portrait" & cr & \
         "app-img_sinha_8_552w-portrait"  \
         into tBrandImages
   return tBrandImages
end _brandImages

function PhotoImagePath pImage
   local tPath
   put path_Assets() & "img/photography/" & pImage & "/" \
         & pImage & "_med.jpg" into tPath
   return tPath
end PhotoImagePath

on closestack
   portal_SetLastStack "imagepuzzles"
end closestack

---------------------------
## UI Scripting

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack


on updateUI
   local tTitle, tInfoPanel, tStatus
   local tControl, tMakeTiles, tGoImagePuzzle
   local tHelpButton, tHelpBkg, tHelpFieldGrp, tHelpField, tHelpDismiss
   Local tFooter
   
   switch sCard
      
      case "Title"
         
         put the long id of img "title" of card "Title" into sTitleImage
         setImageToFullCardLoc sTitleImage,"portrait",0,0
         centerMe sTitleImage,0,0
         
         put the long id of grp "title" into tTitle
         bottomCenterMe tTitle, 70
         
         put the long id of btn "helpButton" into tHelpButton
         bottomRightMe tHelpButton, 25, 130
         
         put the long id of grc "helpBkg" into tHelpBkg
         set the width of tHelpBkg to (CardWidth() + 20)
         topLeftMe tHelpBkg, -10, 60
         
         put the long id of grp "helpField" into tHelpFieldGrp
         set the width of tHelpFieldGrp to (CardWidth() - 30)
         topLeftMe tHelpFieldGrp, 15, 110 
         
         put the long id of fld "helpField" into tHelpField
         set the width of tHelpField to (CardWidth() - 30)
         topLeftMe tHelpField, 15, 110
         
         put the long id of button "helpDismiss" into tHelpDismiss
         topRightMe tHelpDismiss, 0, 11
         
         break
         
         
         
      case "mainImagePuzzle"
         
         put the long id of img "orion_nebula" of card "mainImagePuzzle" into sStarImage
         setImageToFullCardLoc sStarImage,"portrait",0,0
         centerMe sStarImage,0,0
         
         put the long ID of group "makeTiles" of me into tMakeTiles
         bottomCenterMe tMakeTiles, 180
         
         put the long id of fld "status" into tStatus
         bottomCenterMe tStatus, 30
         
         put the long id of grp "footerNavigation" into tFooter
         send "updateUI" to tFooter
         
         break
         
         
   end switch
   
   
   
end updateUI

command journal_AddEntry -- save a bookmark to db
   local tData, tTitle
   
   put 1 into tData["card"] -- store the last user cd   
   put "Image Puzzles" into tTitle
   Journal_RecordEntry "imagepuzzles",tTitle,tData -- send to journal
   dialog_CustomMsg "Saved to Journal"
end journal_AddEntry

on journalResume pData,pEntryA -- sent from journal stack
   local tCd
   put pData["card"] into tCd
   go to card tCd
   
end journalResume

