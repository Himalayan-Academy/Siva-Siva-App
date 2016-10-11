script "lib_SivaSivaDevelopment"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaDevelopment
type: library
version: 0.1

/*
Place your development handlers here!

This stack is for handlers that are useful in development but are not to be used in the final deployed mobile app.
This library will eventually be moved into a separate authoring project.
*/


--> Working on
-
command testMessagePath pMessage -- is this needed?
   answer pMessage with "OK"
end testMessagePath


--> From API
-
command scaleStackIfNeeded
   if the environment is "development" and (item 4 of the effective working screenRect < 800 )  then
      set the scalefactor of this stack to .75
      set the height of this stack to 736
   end if
end scaleStackIfNeeded

command errorDialog pExecutionError
   if not isMobile() then
      --put pExecutionError
      put item 4 of line 1 of pExecutionError into tBrokenStatement
      put item 2 of line 1 of pExecutionError into tLineNumber
      put line (item 1 of line 1 of pExecutionError) of the scriptExecutionErrors  into tErrorDescription 
      # scriptExecutionErrors  seems to be a global prop in the IDE, no longer the cErrorList custom property of a binary stack
      logError tErrorDescription & ":" && tBrokenStatement && "on line" && tLineNumber
   end if
end errorDialog
