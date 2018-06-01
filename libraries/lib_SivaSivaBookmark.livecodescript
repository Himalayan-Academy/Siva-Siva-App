script "lib_SivaSivaBookmark"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaBookmark
type: library
version: 0.1


--> Portal | Bookmark
-
command portal_DisplayBookmarks
   -- just a test for now
   put portal_GetHomeView() into portalView
   put "Frequently Asked Questions,Listen,Mantras,Practice" into portalList
   set the portal_RowNames of portalView to portalList
end portal_DisplayBookmarks

command portal_PushBookmark
   
end portal_PushBookmark

command portal_PopBookmark
   
end portal_PopBookmark

command portal_DeleteBookmark
   
end portal_DeleteBookmark


--> Portal | Bookmark | Model
-
/*
This model is cached in a LocalArray of this stack, 
but stored for future reference in anapplication specific json file in the documents folder of the mobile app.
*/

function portal_GetBookmarkArray
   
end portal_GetBookmarkArray

function portal_SetBookmarkArray
   
end portal_SetBookmarkArray

command sivasiva_FetchBookmarkArray
   put "model_SivaSivaBookmarks" into stackName
   put stackName & ".json" into shortFile-- could use ".array"
   put the model_Array [shortFile] of stack "model_SivaSiva" into sivasivaData
   return sivasivaData
end sivasiva_FetchBookmarkArray

command sivasiva_StoreBookmarkArray
   
end sivasiva_StoreBookmarkArray
