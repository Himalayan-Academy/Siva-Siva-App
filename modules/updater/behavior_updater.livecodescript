script "behavior_updater"
on preOpenCard
   set the width of field "status" to the width of this card 
   set the loc of field "status" to the (the width of this card /2, the height of this card/2)
   set the loc of widget "Spinner" to the loc of field "status"
   set the bottom of widget "Spinner" to the top of field "status" - 20
   hide widget "spinner"
end preOpenCard

command st pText
   put pText into field "status"
end st

on openCard
   st "Checking for updates..."
   if shouldDownloadNewAssets() then
      setDownloadStatusCallback "updateUI", the long id of this stack
      show widget "spinner"
      st "Downloading updates..."
      downloadAssets
   else
      st "Up To Date."
   end if
end openCard

on updateUI pStatus
   switch word 1 of pStatus
      case "loading"
         st ("Downloading:" && floor((word 2 of pStatus / word 3 of pStatus) * 100) &"%")
         break
      case "expanding"
         st ("Expanding:" && floor((word 2 of pStatus / word 3 of pStatus) * 100) &"%")
         break
      case "downloaded"
         hide widget "spinner"
         st "Expanding assets..."
         verifyAndExpandAssets
         break
      default
         st pStatus
   end switch
end updateUI
