Script "stack_Siva-Siva-Portal_button_id_28648"

/*
# Name: button "fetch favorites" of card "fetchFavorites" of stack "Siva-Siva-Portal"
# ID: button id 28648 of card id 28647 of stack "Siva-Siva-Portal"
*/


on mouseup
   put path_Models() & "sqlQueries.txt" into tURL
   put URL ("file:/"&tURL) into tSqlQueries
   set the itemdelimiter to "|"
   put 0 into y
   repeat for each item x in tSqlQueries
      add 1 to y
      put line 2 of x into sSQLQueriesA[y][queryName]
      put line 4 to  -1 of x into  sSQLQueriesA[y][sqlQuery]
   end repeat
end mouseup



