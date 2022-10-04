Script "stack_DevelopmentTools_"

/*
# Name: stack "DevelopmentTools"
# ID: stack "DevelopmentTools"
*/


local sDF, sZipFile

command updateUI
   put empty into field "debug"
   put empty into field "status"
   set the thumbpos of scrollbar "progress" to 0
end updateUI

private command _preserveDefaultFolder
   put the defaultFolder into sDF
   set the itemdel to slash
   set the defaultfolder to item 1 to -2 of the effective filename of stack "Siva-Siva-App"
end _preserveDefaultFolder

private command _restoreDefaultFolder
   set the defaultfolder to sDF
end _restoreDefaultFolder

command createAndUploadReadDataFiles
   local tReadFile, tDateFile
   local tSQL, tConnectionID, tTitle, tFileID, tValue
   local tBookData, tKeyList, tLanguage, tArray
   local tLson, tDate
   
   _preserveDefaultFolder
   
   put "select *" && \
         "from item" && \
         "where ( (media_type = 'text/book') OR (media_type = 'text/booklet') ) AND (approved_for_public = 'YES')" \
         into tSQL
   put JnanamDB() into tConnectionID
   dbSetSQL tSQL
   put dbGet("item", tConnectionID) into tBookData
   
   put "file_id,title,author,category,subject,approved_for_public,init_id,media_type,sub_title," & \
         "keywords,sales_blurb,description,language,isbn,product_details,edition,publisher,composer," & \
         "genre,content,contributor,copyright_holder,copyright,creator,date_taken,entered_by,file_type," & \
         "rights,source,use_permit_released,allowed_groups,tags" into tKeyList
   
   repeat for each element tBook in tBookData
      put textDecode(tBook["title"], "UTF8") into tTitle
      put textDecode(tBook["file_id"], "UTF8") into tFileID
      put textDecode(tBook["language"], "UTF8") into tLanguage
      if tLanguage is "" then
         put "English" into tLanguage
      end if
      
      repeat for each item tKey in tKeyList
         put textDecode(tBook[tKey], "UTF8") into tValue
         replace "\n" with cr in tValue
         put tValue into tArray[tLanguage][tTitle][tKey]
      end repeat
      put "portal_GoURL" into tArray[tLanguage][tTitle]["link"]["portal command"]
      put "https://www.himalayanacademy.com/media/books/" & tFileID & "/web/" into \
            tArray[tLanguage][tTitle]["link"]["portal param"] 
   end repeat
   
   put specialfolderpath("home") & "/Downloads/read.lson" into tReadFile
   put specialfolderpath("home") & "/Downloads/read.date" into tDateFile
   
   put arrayencode(tArray, "7.0") into tLson
   put tLson into URL ("binfile:" & tReadFile)
   put the internet date into tDate
   put tDate into URL ("binfile:" & tDateFile)
   
   put "Uploading read.lson" into field "status"
   get shell(the merge of "rsync -v [[tReadFile]] devhap@dev.himalayanacademy.com:public_html/media/books/read.lson")
   put it into field "debug"
   
   put "Uploading read.date" into field "status"
   get shell(the merge of "rsync -v [[tDateFile]] devhap@dev.himalayanacademy.com:public_html/media/books/read.date")
   put "-------" & cr & cr & it after field "debug"
   
   put "Done." into field "status"
   set the thumbpos of scrollbar "progress" to 0
   
   _restoreDefaultFolder
end createAndUploadReadDataFiles

command updateBranchInformation
   _preserveDefaultFolder
   put shell("git rev-parse --abbrev-ref HEAD") into field "branch name"
   _restoreDefaultFolder
end updateBranchInformation

command packAndUploadExternalAssets
   local tManifestFile, tChecksum
   
   _preserveDefaultFolder
   
   -- guards
   if there is not a folder "assets-external" then
      answer error "Missing external assets folder."
      exit to top
   end if
   
   -- create zip folder
   put tempName() & ".zip" into sZipFile
   revZipOpenArchive sZipFile, "write"
   
   if the result is not empty then
      answer error the result
      _restoreDefaultFolder
      exit to top
   end if 
   
   put "Zipping..." into field "status"
   put empty into field "debug"
   
   set the defaultFolder to "assets-external"
   get shell("find . -type f | wc -l") 
   set the endValue of scrollbar "Progress" to it
   set the thumbPos of scrollbar "Progress" to 0
   set the startValue of scrollbar "Progress" to 0
   
   _addFolderToZip "."
   
   revZipCloseArchive sZipFile
   
   put "Done Zipping" into field "status"
   
   put sZipFile into tManifestFile
   replace ".zip" with ".manifest" in tManifestFile
   put shell("md5 -q" && sZipFile) into tChecksum
   put the merge of "assets-external.zip [[tChecksum]]" into url ("binfile:" & tManifestFile)
   put url ("binfile:" & sZipFile) into url ("binfile:" & specialfolderpath("home") & "/Downloads/assets.zip")
   put url ("binfile:" & tManifestFile) into url ("binfile:" & specialfolderpath("home") & "/Downloads/assets.txt")
   
   put "Uploading assets.zip" into field "status"
   get shell(the merge of "rsync -v [[sZipFile]] devhap@dev.himalayanacademy.com:public_html/media/apps/sivasiva/assets.zip")
   put it into field "debug"
   
   put "Uploading assets.txt" into field "status"
   get shell(the merge of "rsync -v [[tManifestFile]] devhap@dev.himalayanacademy.com:public_html/media/apps/sivasiva/assets.txt")
   put "-------" & cr & cr & it after field "debug"
   
   put "Done." into field "status"
   set the thumbpos of scrollbar "progress" to 0
   _restoreDefaultFolder
end packAndUploadExternalAssets

private command _addFolderToZip pFolder
   local tFolders, tFiles
   
   put folders(pfolder) into tFolders
   filter lines of tFolders without ".."
   
   if tFolders is not empty then
      repeat for each line tFolder in tFolders
         set the cursor to busy
         _addFolderToZip (pFolder & "/" & tFolder)
      end repeat
   end if
   
   put files(pFolder) into tFiles
   
   if tFiles is not empty then
      repeat for each line tFile in tFiles
         set the cursor to busy
         put (pFolder & "/" & tFile) & cr before field "debug"
         revZipAddItemWithFile sZipFile, (pFolder & "/" & tFile), (pFolder & "/" & tFile)
         get the thumbPos of scrollbar "progress"
         add 1 to it
         set the thumbPos of scrollbar "Progress" to it
      end repeat
   end if
end _addFolderToZip

