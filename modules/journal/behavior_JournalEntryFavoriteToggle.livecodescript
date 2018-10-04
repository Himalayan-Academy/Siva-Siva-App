script "behavior_JournalEntryFavoriteToggle"
on mouseUp
   put the cEntry of the target into tA
   setFavorite tA
end mouseUp


on setFavorite pA
   if pA["is_favorite"] is 0 then
      put 1 into tValue
   else
      put 0 into tValue
   end if
   put tValue into pA["is_favorite"]
   Journal_SetFavoriteFlag pA["journal_id"], tValue
   if pA["is_favorite"] is 0 then
      set the foreColor of the target to getConfigForLayout("listView", "favoriteDisabledIconColor")
   else
      set the foreColor of the target to getConfigForLayout("listView", "favoriteEnabledIconColor")
   end if
end setFavorite
