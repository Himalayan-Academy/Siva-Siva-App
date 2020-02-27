Script "stack_aagDBLib_field_id_1006"

/*
# Name: field "vers" of card id 1002 of stack "aagDBLib"
# ID: field id 1006 of card id 1002 of stack "aagDBLib"
*/


constant kVersionFile = "DBLib.version"
constant kDownloadFile = "DBLib"

on mouseup
   if the environment is "development" and the altKey is down then
      ask "What is the new version?" with (word 1 of fld "vers" + 0.1)
      if it is not empty then
         put it into tVersion
         ask "What are the changes?"
         if it is not empty then
            -- write to custom prop
            put it into tChanges
            get the cVersionChanges of me
            set the cVersionChanges of me to format("%s\n-----\n\nVersion %s\n\n%s\n", it, tVersion, tChanges)
            -- write version file
            put the defaultfolder into tDF
            set the itemdel to "/"
            set the defaultfolder to item 1 to -2 of the effective filename of this stack
            put ("http://andregarzia.com/files/" & kDownloadFile & "-" & tVersion & ".zip") into tDownloadURL
            put format("%s\n%s\n%s", tVersion, tDownloadURL, tChanges) into url ("binfile:" & kVersionFile)
            -- add version history to readme file
            put the internet date into tDate
            put format("DB Lib %s: %s (built on: %s)\n", tVersion, tChanges, tDate) after url ("binfile:readme.txt")
            set the defaultfolder to tDF
            -- display new version
            put tVersion into me
            save this stack
         end if
      end if
      exit mouseUp
   end if
   get url ("http://andregarzia.com/files/" & kVersionFile)
   put line 1 of it into tVersion
   put line 2 of it into tDownloadURL
   put line 3 to -1 of it into tVersionChanges
   if the text of me < tVersion then
      answer question format("There is a new version %s.\n\n%s\n\nDownload it?", tVersion, tVersionChanges) with "Download" and "NO"
      if it is "Download" then
         answer folder "Where to save the new library zip file?"
         if it is not empty then
            set the itemdel to "/"
            put it & "/" & item -1 of tDownloadURL into tDownloadLocation
            libURLDownloadToFile tDownloadURL, tDownloadLocation, "downloadComplete"
         end if
      end if
   else
      answer info "You're running the most current version"
   end if
end mouseup

on downloadComplete pURL, pStatus
   answer info pStatus
end downloadComplete
