script "behavior_ViewTemplateCard"
--> MetaData
-
author: David Bovill
copyright: OPN Technologies LLP
name: behavior_ViewTemplateCard
type: behavior


/*
Was "Card View Behavior" and moved to this script-only behavior.

This behavior makes a view template easy to resize and test it's geometry.
It also provides the default behavior for the views menu.
You can of course override this on the cards script, or set another behavior there.
*/


--> Events
-
on mouseDown whichModifier
   if the long id of the target is not the long id of me then pass mouseDown
   switch
      case whichModifier = 3
         _doViewMenu
         break
      case the shiftKey is "Down"
         put "OK"
         break
      default
         set the dragAction to "link"
         -- set the dragImage to 3137
         set the dragData ["private"] to "View|Layout|Placeholder"
   end switch
end mouseDown

on dragEnd
   put the dragDestination into targetObject
   if exists (targetObject) is false then pass dragEnd
   
   if the shiftKey is "Down" then
      put the view_Above of targetObject into targetObject
      if exists (targetObject) is false then pass dragEnd
   end if
   
   -- put the dragdata ["private"] into sourceViewName
   -- set the control_Type of targetObject to sourceViewName
   put the dragSource into sourceCardObject
   if exists (sourceCardObject) is false then pass dragEnd
   
   put the template_View of sourceCardObject into sourceView
   if exists (sourceView) is false then pass dragEnd
   
   set the view_Replacement of targetObject to sourceView
end dragEnd

on resizeStack
   refresh
   pass resizeStack
end resizeStack

on refresh
   put the card_Margin of me into cardMargin
   if cardMargin is empty then put 24 into cardMargin
   put _templateView() into templateView
   if exists (templateView) is false then return empty
   
   put the template_CardRect [cardMargin] of templateView into templateRect
   set the rect of templateView to templateRect
   return templateRect
end refresh


--> Handlers
-
private command _doViewMenu
   put the long id of control 1 of me into mView
   put the view_Name of mView into viewName
   if exists (mView) is false then return empty
   put "Global |" && menu_TitleFromViewName (viewName) into mTitle
   menu_PopUp mTitle, empty, mView
   return the result
end _doViewMenu


--> Menu | Props
-
getprop menu_Target [mTitlePath]
   put menu_GetTargetObject() into targetObject
   switch word 1 of targetObject
      case "card"
         return templateView (targetObject)
      default
         put the view_Object of targetObject into mTarget
         return mTarget
         
         pass menu_Target
   end switch
end menu_Target

-- getprop menu_Table [pMenuTitle]
   if the controlKey is "Up" then pass menu_Table
   
   -- custom: true
   put the long id of the target into targetObject
   if pMenuTitle is empty then put the menu_Title of targetObject into pMenuTitle
   if pMenuTitle is empty then return empty
   put the menu_Controller [pMenuTitle] of targetObject into mController
   put menu_GetTable (pMenuTitle, mController) into mTable
   
   -- add the submenu table line 
   put menu_ConstructSubmenuTableLine ("View", "Global | View | Property | Menu", pMenuTitle, targetObject, mController) into submenuTableLine
   if submenuTableLine is not among the lines of mTable then
      put submenuTableLine & CR after submenuTableLines
   end if
   put menu_ConstructSubmenuTableLine ("Script", "Global | View | Script | Menu", pMenuTitle, targetObject, mController) into submenuTableLine
   if submenuTableLine is not among the lines of mTable then
      put submenuTableLine & CR after submenuTableLines
   end if
   put menu_ConstructSubmenuTableLine ("Test", "Global | View | Test | Geometry | Menu", pMenuTitle, targetObject, mController) into submenuTableLine
   if submenuTableLine is not among the lines of mTable then
      put submenuTableLine & CR after submenuTableLines
   end if
   
   delete char -1 of submenuTableLines
   if submenuTableLines is not empty then
      put CR & "-" & CR & submenuTableLines after mTable
   end if
   return mTable
end menu_Table


--> Template
-
getprop view_IsTemplate
   return the long id of the target = _templateView()
end view_IsTemplate

getprop view_Template
   if word 1 the target = "card" then return _templateView()
   pass view_Template
end view_Template

getprop template_Object
   if word 1 the target = "card" then return _templateView()
   pass template_Object
end template_Object

getprop template_View
   if word 1 the target = "card" then return _templateView()
   pass template_View
end template_View

getprop template_CardRect [pMargin]
   if pMargin is empty then
      put the card_Margin of me into pMargin
   end if
   put the rect of me into someRect
   if pMargin is not 0 then
      rect_SubtractMargins someRect, pMargin
   end if
   return someRect
end template_CardRect

getprop card_Margin
   put the card_Object of the target into cardObject
   if exists(cardObject) is false then return empty
      
   lock messages
   if cardMargin is a number then set the card_Margin of cardObject to cardMargin   
   put the card_Margin of cardObject into cardMargin
   unlock messages
   return cardMargin
end card_Margin

setprop card_Margin cardMargin
   set the card_Margin of me to cardMargin
   refresh
end card_Margin

private function _templateView 
   if exists (control 1 of me) then
      put the long id of control 1 of me into templateObject
      return templateObject
   else
      return empty
   end if
end _templateView

getprop view_BehaviorStackName
   put the view_Name of the target into vName
   put "behavior_" & vName into stackName
   return stackName
end view_BehaviorStackName


--> Deps
-
command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end rect_SubtractMargins

command margin_Normalize @someMargin, @leftM, @topM, @rightM, @bottomM
   -- fixed bug in setting bottomM when 4th item is empty
   if the number of items of someMargin < 4 then
      put item 1 of someMargin into defaultMargin
      put defaultMargin into leftM
      
      put item 2 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into topM
      else
         put actualMargin into topM
      end if
      
      put item 3 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into rightM
      else
         put actualMargin into rightM
      end if
      
      put item 4 of someMargin into actualMargin
      if actualMargin is empty then
         put topM into bottomM
      else
         put actualMargin into bottomM
      end if
   else
      put item 1 of someMargin into leftM
      put item 2 of someMargin into topM
      put item 3 of someMargin into rightM
      put item 4 of someMargin into bottomM
   end if
   put leftM,topM,rightM,bottomM into someMargin
end margin_Normalize


/*
getprop card_TopViews [viewName]
   put the card_Object of the target into cardObject
   put the object_TopControls of cardObject into topControls
   repeat for each line someControl in topControls
      put the view_Name of someControl into testViewName
      if viewName is empty and testViewName is not empty then
         put someControl & CR after topCardViews
      else if viewName = testViewName then
         put someControl & CR after topCardViews
      end if
   end repeat
   delete char -1 of topCardViews
   return topCardViews
end card_TopViews

getprop card_View [vNames]
   -- a guess (makes views "sticky")
   -- first it looks "inside" the target view
   -- next it looks "up" the target view hirarchy
   -- then it looks down from the card view
   
   if vNames is empty then
      return line 1 of the card_TopViews of the target
   else
      put the long id of the target into targetObject
      
      if word 1 of targetObject is not "card" then
         -- first search inside the target view
         put the view_LazyFindInside [vNames] of targetObject into foundView
         if exists(foundView) then return foundView
         
         -- next search up from the target view
         put the view_Above [vNames] of targetObject into foundView
         if exists(foundView) then return foundView
         
      end if
      
      put the card_Object of targetObject into cardObject
      
      -- lets do a strict match for each vName in turn for every view from the card down
      put the card_ViewMatch [vNames] of cardObject into foundView
      if exists(foundView) then return foundView
      
      -- finally lets search lazily from the card down
      put the view_LazyFindInside [vNames] of cardObject into foundView
      if exists(foundView) then
         return foundView
      else
         return empty
         
         get the card_TopViews of the target
         return line 1 of it
      end if
   end if
end card_View

getprop card_ViewMatch [vNames]
   -- maybe change for "view_Match"
   put the card_Object of the target into cardObject
   put the view_Match [vNames] of cardObject into cardViewMatch
   return cardViewMatch
end card_ViewMatch

private function lazyViewNameMatch vNameOrStem, vName
   -- test to see if a view_Name is a lazy match with a vNameOrStem
   -- as long as vNameOrStem is an item within the view_Name it returns true
   view_NormalizeName vNameOrStem
   view_NormalizeName vName
   
   set the itemdelimiter to "|"
   delete item 1 of vName
   delete item 1 of vNameOrStem
   if char -1 of vNameOrStem = "|" then delete char -1 of vNameOrStem
   return vNameOrStem is among the items of vName
   
   --old
   -- if the last match fails the match chops of last item and tries again until a match succeeds
   -- so "Tree" will match the vName "View|Tree|Simple Tree"
   repeat the number of items of vName
      if vName = vNameOrStem then
         return true
      end if
      delete item - 1 of vName
   end repeat
   return false
end lazyViewNameMatch

function object_ExtractStack someObject
   set the wholematches to true
   put word (wordOffset ("stack", someObject)) to -1 of someObject into stackObject
   return stackObject
end object_ExtractStack

function object_GetGroupControls someGroup, nested
   put empty into myControls
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      if nested is not true and word 1 of controlObject is "group" then
         add the number of layers in controlObject to controlNum
      end if
      put controlObject & CR after myControls
   end repeat
   delete last char of myControls
   return myControls
end object_GetGroupControls

command object_StackNameOffsets someObject, @mainStackStart, @mainStackEnd, @substackStart, @substackEnd
    -- now modified to look for substacks
     
    put the number of chars of someObject into lastQuoteCharNum
    put lastQuoteCharNum - 1 into mainStackEnd
    put text_OffsetBefore(quote, someObject, lastQuoteCharNum) + 1 into mainStackStart
    
    put someObject into testSubStack
    delete char (mainStackStart - 7) to -1 of testSubStack
     
    -- put offset(space & "stack" && quote, testSubStack) into substackStart
    put offset("stack" && quote, testSubStack) into substackStart
    -- put wordoffset("stack" && quote, testSubStack) into substackStart
     
    if substackStart = 0 then
        put 0 into substackEnd
        return char (mainStackStart - 7) to -1 of someObject
    else
        put 8 - 1 into tweek
        put substackStart + tweek into tSkip
        put offset(quote, testSubStack, tSkip) into substackEnd
        
        put substackStart + tweek into substackStart
        put substackEnd + tSkip - 1 into substackEnd
        return char (substackStart - 7) to -1 of someObject
    end if
end object_StackNameOffsets

getprop object_TopControls
   put the long ID of the target into targetObject
   return object_GetGroupControls(targetObject, false)
end object_TopControls


getprop stack_Name
    return the short name of the defaultstack
     
    -- old version
    put the long id of the target into targetObject
    put object_ExtractStack(targetObject) into stackObject
    return the short name of stackObject
end stack_Name

private function strictViewNameMatch vNameOrStem, vName
   if char -1 of vNameOrStem is "|" then
      put true into isStem
      delete char -1 of vNameOrStem
   else
      put false into isStem
   end if
   view_NormalizeName vNameOrStem
   view_NormalizeName vName
   
   set the itemdelimiter to "|"
   delete item 1 of vName
   delete item 1 of vNameOrStem
   
   switch
      case vNameOrStem is empty
         -- return the first named view
         return true
      case isStem is true and (item 1 to (the number of items of vNameOrStem) of vName = vNameOrStem)
         -- stem match
         return true
      case isStem is false and vName = vNameOrStem
         -- exact match
         return true
      default
         -- no match (so lets try recursing)
         return false
   end switch
end strictViewNameMatch

function text_OffsetAfter string, someText, startChar
    -- version 9.0
    if startChar < 0 then put 0 into startChar
    delete char 1 to startChar of someText
    get offset(string, someText)
    if it is 0 then return 0
    else return it + startChar
end text_OffsetAfter

function text_OffsetBefore someString, someText, beforeHere
   if beforeHere is not empty then
      delete char beforeHere to -1 of someText
   end if
   put 1 into offsetNum
   put 0 into lastOffset
   repeat
      get text_OffsetAfter (someString, someText, lastOffset)
      if it is 0 then
         return lastOffset
      else
         put it into lastOffset
         add 1 to offsetNum
      end if
   end repeat
end text_OffsetBefore

function text_TokenOffset someString, someContainer
   repeat with tokenNum = 1 to the number of tokens in someContainer
      put token tokenNum of someContainer into someToken
      -- opn_Notify someToken, true
      if someToken = someString then
         return tokenNum
      end if
   end repeat
   return 0
end text_TokenOffset

getprop view_Above
    put the long id of the target into someObject
    delete word 1 to 4 of someObject
    if exists(someObject) is false then return empty
    put the view_Object of someObject into someView
    return someView
end view_Above

getprop view_Inside [vNameOrStem]
   -- works with any control or card
   put the long id of the target into targetObject
   
   -- first lets check the target to see if there is a match
   put the view_Name of targetObject into vName
   if lazyViewNameMatch (vNameOrStem, vName) is true then return targetObject
   
   -- now lets recurse the children
   put the object_TopControls of targetObject into topControls
   repeat for each line topControl in topControls
      put the view_Inside [vNameOrStem] of topControl into foundView
      if exists(foundView) then return foundView
   end repeat
   return empty
end view_Inside

getprop view_LazyFindInside [vNames]
   replace "/" with CR in vNames
   put line 1 of vNames into vName
   put the view_Inside [vName] of the target into foundView
   if exists(foundView) is false then return empty
   
   put the view_SlightlyLazyMatchInside [vNames] of foundView into matchedView
   return matchedView
end view_LazyFindInside

getprop view_LazyMatchInside [vNames]
   -- a recursive function
   -- a match where if the target is matched by the top vName
   -- then it looks for a match for the next vName in the index among the top controls (one level down)
   -- and continues for all lines of vNames
   -- any mismatch and it returns the last (deepest) match found
   -- calling this property on a control which has no view_Name or the wrong view_Name returns empty
   
   put the long id of the target into targetObject
   replace "/" with CR in vNames   
   put line 1 of vNames into viewNameOrStem
   
   -- first lets check the top level object
   put the view_Name of targetObject into vName
   if vName is empty then return empty
   if lazyViewNameMatch(viewNameOrStem, vName) is true then
      -- found a match so lets move down a view and a vName
      delete line 1 of vNames
      if vNames is empty then
         -- no more vNames to search so lets return the found object
         return targetObject
      else
         put the object_TopControls of targetObject into topControls
         repeat for each line testControl in topControls
            put the view_LazyMatchInside [vNames] of testControl into foundView
            if exists(foundView) then return foundView
         end repeat
         return empty
      end if
   end if
end view_LazyMatchInside

getprop view_Match [vNames]
   -- lets do a strict match for each vName in turn for every view from the card down
   -- does not search top to bottom but in control order
   -- consider changeing to top down search (slower)
   put the long id of the target into targetObject
   if word 1 of targetObject is not among the items of "card,stack" then
      put the view_Name of targetObject into vName
      if vName is not empty and strictViewNameMatch (matchName, vName) is true then
         return targetObject
      end if
   end if
   
   -- should go down from the top (most unusual match)
   repeat for each line matchName in vNames
      repeat with controlNum = 1 to the number of controls in targetObject
         put the long id of control controlNum of targetObject into someControl
         put the view_Name of someControl into vName
         if vName is empty then next repeat
         if strictViewNameMatch (matchName, vName) is true then
            return someControl
         end if
      end repeat
   end repeat
   return empty
end view_Match

getprop view_MatchInside [vNames]
   -- a recursive function
   -- a strict match where if the target is matched by the top vName
   -- then it looks for a match for the next vName in the index among the top controls (one level down)
   -- and continues for all lines of vNames
   -- any mismatch and it returns false (stem matches are allowed)
   -- calling this property on a control which has no view_Name or the wrong view_Name returns empty
   
   put the long id of the target into targetObject
   replace "/" with CR in vNames
   put line 1 of vNames into viewNameOrStem
   
   -- first lets check the top level object
   put the view_Name of targetObject into vName
   if vName is empty then return empty
   if strictViewNameMatch(viewNameOrStem, vName) is true then
      -- found a match
      delete line 1 of vNames
      if vNames is empty then
         -- no more vNames to search so lets return the found object
         return targetObject
      else
         put the object_TopControls of targetObject into topControls
         repeat for each line testControl in topControls
            put the view_MatchInside [vNames] of testControl into foundView
            if exists(foundView) then return foundView
         end repeat
         return empty
      end if
   end if
end view_MatchInside

getprop view_Name
   -- a value of the target (property is not inherited by objects below)  
   put the uRIP ["name"] of the target into vName
   switch
      case the dgProps ["style"] of the target is among the items of "table,form"
         -- it is a datagrid
         if vName is empty then
            -- in case it is not named (ie a vanilla Rev control)
            return "View|Rev|Datagrid"
         else
            return vName
         end if
         break
      case the uRIP ["type"] of the target is among the items of "view,view template"
         return vName
      default
         return empty
   end switch
end view_Name

on view_NormalizeName @viewPath
   if viewPath is empty then return empty
   put word 1 to -1 of viewPath into viewPath
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of viewPath
      put word 1 to -1 of item itemNum of viewPath into someItem
      put someItem into item itemNum of viewPath
   end repeat
   if item 1 of viewPath is not "View" then put "View|" before viewPath
   return viewPath
end view_NormalizeName

setprop view_Profile profileName
   put the view_Object of the target into viewObject
   if exists(viewObject) is false then return empty
   
   lock screen  
   set the cREVGeneral ["profile"] of viewObject to profileName
   repeat with cNum = 1 to the number of controls of viewObject
      set the cREVGeneral ["profile"] of control cNum of viewObject to profileName
   end repeat
   unlock screen
end view_Profile

getprop view_SlightlyLazyMatchInside [vNames]
   -- first lets look for a strict match
   put the view_MatchInside [vNames] of the target into strictMatch
   if exists(strictMatch) then return strictMatch
   
   -- then get slightly lazy
   repeat (the number of lines of vNames - 1)
      put the view_LazyMatchInside [vNames] of the target into lazyMatch
      if exists(lazyMatch) then return lazyMatch
      delete line -1 of vNames
   end repeat
   return empty
end view_SlightlyLazyMatchInside
*/
