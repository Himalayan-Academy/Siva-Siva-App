Script "stack_aagDBLib_"

/*
# Name: stack "aagDBLib"
# ID: stack "aagDBLib"
*/


# ## AAG DB LIB
#
# Version 1.18
# by Andre Alves Garzia ({mailto:support@andregarzia.com})
#
# ### Objective
# Creating a little ORM library to be used on mobile applications.
# This library is inspired by RevIgniter, Rails and others.
#
# URL: {http://www.andregarzia.com/page/en/dblib}
# Online API Documentation: {http://www.andregarzia.com/aux/dblibapi}
# Guide: {http://www.andregarzia.com/aux/dblibguide}
# Support Forum: {http://andregarzia.com/forum}. This is the main venue for getting your questions answered and providing feedback.
#
# Licensing terms:
#
# These scripts are licensed to you if you agree to be bound to one of the following
# License types at your choice.  
#
# 1) GPL 3
# You may use DB Lib as FREE Software as outlined in the terms of the GPL3 or any 
# higher version of the GPL as found here: http://www.gnu.org/licenses/gpl-3.0.html
#
# 2) Commercial license:
# If you do not want to disclose the sources of your application you have the option to purchase a commercial license
# by paying a fee. You can buy a commercial license from my website at http://andregarzia.com/pages/en/dblib
# Such a commercial license releases you from the requirements of the copyleft GPL license, which include: distribution of all 
# source code, including your own product; licensing of your own product under the GPL license; prominent mention of the 
# derbrill copyright and the GPL license; and disclosure of modifications to the library.
#
# VERSION CHANGES:
#
# v1.18:
# - Added support for multiple columns with the same name.
# - Added support for placeholders in dbSetSQL




local dbId
local dbA
local dbData


# Sets the default _Database Connection ID_ for the calls.
# *Parameter:* You pass the connection id number.
on dbSetDefaultConnectionID pID
    put pID into dbID
end dbSetDefaultConnectionID

# Escapes a string for SQLite usage. 
# From SQLite documentation, all that is required to escape a string is to escape the single quotes.
# *Parameter:* You pass a string.
# *Returns:* The escaped string.
# _This escaping routine is here because it might be needed but it is not currently used_
function dbEscapeSqlite pText
   replace "'" with "'''" in pText
   return pText
end dbEscapeSqlite

# Quotes and escapes a string for SQLite usage.
# This function will use _dbEscapeSQLite()_ to escape a string and return it surrounded by single quotes.
# *Parameter:* You pass a string.
# *Returns:* The escaped and quoted string.
# _This escaping routine is here because it might be needed but it is not currently used_
private function q pText
    return "'" & dbEscapeSqlite(pText) & "'"
end q

# This function returns the last SQL executed by dbGet, dbInsert, dbUpdate and dbDelete
function dbLastSQL
   return dbData["last sql"]
end dbLastSQL

private function placeholder pValue
   local tCurrentPlaceholder, 
   if pValue is "NULL" then
      return "NULL"
   end if
   if the keys of dbA["placeholders"] is empty then
      put 1 into dbA["next placeholder"]
   end if
   
   put dbA["next placeholder"] into tCurrentPlaceholder
   put pValue into dbA["placeholders"][tCurrentPlaceholder]
   add 1 to dbA["next placeholder"]
   return (":" & tCurrentPlaceholder)
end placeholder

# This command receives a comma separated list of column names 
# that you want to be included in your next database call.
# By default, database queries include all columns. This behavior can be changed with this command.
# *Parameters: a comma separated list of columns
command dbColumns pColumns
    put pColumns into dbA["columns"]
end dbColumns

# This clears the current query. As you use commands such as _dbColumns, dbWhere, dbLimit_,
# you refine your query parameters before calling it. Sometimes, you want to reset all back to empty.
command dbResetQuery
   put empty into dbA
end dbResetQuery

# This will return the current query parameters. You can use _dbRestoreQueryParameters_ to 
# restore it later. This is useful when you're creating routines and don't want other queries to 
# pollute your current parameters.
# *Returns:* An array with the current parameters.
function dbPreserveQueryParameters
   return dbA
end dbPreserveQueryParameters

# This will restore the query parameters replacing the current parameters. You can use _dbPreserveQueryParameters_
# to save the query parameters to an array.
# *Parameters:* An array with the query parameters.
command dbRestoreQueryParameters pDataA
   put pDataA into dbA
end dbRestoreQueryParameters

# This command allows you to refine your query. Use it before calling functions such as: _dbGet, dbUpdate, dbDelete_.
#
# If a code like:
#     put dbGet("contacts") into tDataA
#     returns all the contacts. Then a code like:
# 
#     dbWhere "country", "Brazil" 
#     dbWhere "sex", "male" 
#     put dbGet("contacts") into tDataA 
#     
# Will return all contacts that are male and from Brazil.
#
# The default operator for this is _=_. 
#     dbWhere "country", "Brazil" 
# Translates to:
#     WHERE country = 'Brazil' 
# If you want to change the operator, then call it like:
#     dbWhere "age >", "21" 
# Translates to:
#     WHERE age > 21 
#
# You can have as many _dbWhere_ calls as you want. When you finally call a function that touches
# the database, it will use all those _where clauses_.
#
# _Remember: after calling a function that touches the database such as dbGet(), all the query parameters are reset_
#
# *Parameters:* a column and a value to look for.
# *Parameters:* a column, an operator for the comparison and a value to look for.
#
# As a convention, the standard operator for multiple dbWhere calls is AND
# so if you call
#
#     dbWhere "country", "Brazil" 
#     dbWhere "age >", "21" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE country = 'Brazil' AND age > 21 
#
# Now, if you want  to use OR    instead of AND, you just pass an third extra parameter with
# the operator you want, like:
#
#     dbWhere "country", "Brazil" 
#     dbWhere "age >", "21", "OR" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE country = 'Brazil' OR age > 21 
#
# If you want to check if a column is null use a command like:
#
#      dbWhere "country", "NULL" 
#
# If you want to check if a column is not null use a command like:
#
#     dbWhere "country", "NOT NULL" 
#
command dbWhere pColumn, pValue, pConcatenationOperator
   local tOperator
   if the number of words in pColumn > 1 then
      put word 2 of pColumn into tOperator
      put word 1 of pColumn into pColumn
   else
      put "=" into tOperator
   end if
   
   if pValue is "null" then
      put "IS" into tOperator
      put "NULL" into pValue
   end if
   
   if pValue is "not null" then
      put "IS NOT" into tOperator
      put "NULL" into pValue
   end if
   
   if pConcatenationOperator is empty then
      put "AND" into pConcatenationOperator
   end if
   
   
   
   if dbA["where columns"][pColumn] is empty then
      if dbA["where"] is empty then
         put "WHERE" && pColumn && tOperator && placeholder(pValue) before dbA["where"]
      else
         put " " & pConcatenationOperator  && pColumn && tOperator && placeholder(pValue) after dbA["where"]
      end if
   else 
      # AAG: Support for multiple columns
      --       replace dbA["where columns"][pColumn] with (pColumn && tOperator && placeholder(pValue)) in dbA["where"]
      put " " & pConcatenationOperator  && pColumn && tOperator && placeholder(pValue) after dbA["where"]
   end if
   
   set the itemdel to space
   put item -3 to -1 of dbA["where"]  into dbA["where columns"][pColumn] 
end dbWhere

# This command allows you to refine your query. Use it before calling functions such as: _dbGet, dbUpdate, dbDelete_.
#
# It allows you to specify the "IN" part of a WHERE clause.
#
# If a code like:
#     put dbGet("contacts") into tDataA 
# returns all the contacts. 
# Then a code like:
#     dbIn "country", "Brazil","US","France" 
#     put dbGet("contacts") into tDataA 
# Will return all contacts that are from Brazil or the US or France.
#
# You can have as many _dbIn_ calls as you want. When you finally call a function that touches
# the database, it will use all those _where clauses_.
#
# _Remember: after calling a function that touches the database such as dbGet(), all the query parameters are reset_
#
# *Parameters:* a column and values to look for.
# *Parameters:* a column, values to look for and a concatenation operator.
#
# As a convention, the standard operator for multiple _dbIn_ calls is AND
# so if you call
#
#     dbIn "country", "Brazil","US","France" 
#     dbIn "country", "Germany","Argentina" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE country IN('Brazil', 'US', 'France') and country IN('Germany','Argentina') 
#
# Now, if you want  to use OR    instead of AND, you just pass an last extra parameter with
# the operator you want, like:
#
#     dbIn "country", "Brazil","US","France" 
#     dbIn "country", "Germany","Argentina","OR" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE country IN('Brazil', 'US', 'France') or country IN('Germany','Argentina') 
#
command dbIn pColumn
   local pConcatenationOperator, tOperator, pValue
   
   put param(the paramcount) into pConcatenationOperator
   
   if pConcatenationOperator is not among the items of "AND,OR" then
      put empty into pConcatenationOperator
   end if
   
   if pConcatenationOperator is empty then
      put "AND" into pConcatenationOperator
   end if
   
   put "IN" into tOperator
   
   
   if dbA["where columns"][pColumn] is empty then
      if dbA["where"] is empty then
         put "WHERE" && pColumn && "IN("  before dbA["where"]
      else
         put " " & pConcatenationOperator  && pColumn &&  "IN(" after dbA["where"]
      end if
      repeat with x = 2 to the paramcount
         put placeholder(param(x)) & comma after dbA["where"]
      end repeat
      delete char -1 of dbA["where"]
      put ")" after dbA["where"]
   else 
      replace dbA["where columns"][pColumn] with (pColumn && tOperator && placeholder(pValue)) in dbA["where"]
   end if
   
   set the itemdel to space
   put item -3 to -1 of dbA["where"]  into dbA["where columns"][pColumn]
end dbIn

# This command allows you to refine your query. Use it before calling functions such as: _dbGet, dbUpdate, dbDelete_.
#
# It allows you to specify the "NOT IN" part of a WHERE clause.
#
# If a code like:
#     put dbGet("contacts") into tDataA 
# returns all the contacts. 
# Then a code like:
#     dbNotIn "country", "Brazil","US","France" 
#     put dbGet("contacts") into tDataA 
# Will return all contacts that are NOT from Brazil or the US or France.
#
# You can have as many _dbNotIn_ calls as you want. When you finally call a function that touches
# the database, it will use all those _where clauses_.
#
# _Remember: after calling a function that touches the database such as dbGet(), all the query parameters are reset_
#
# *Parameters:* a column and values to look for.
# *Parameters:* a column, values to look for and a concatenation operator.
#
# As a convention, the standard operator for multiple _dbNotIn_ calls is AND
# so if you call
#
#     dbNotIn "country", "Brazil","US","France" 
#     dbNotIn "country", "Germany","Argentina" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE country NOT IN('Brazil', 'US', 'France') and country NOT IN('Germany','Argentina') 
#
# Now, if you want  to use OR    instead of AND, you just pass an last extra parameter with
# the operator you want, like:
#
#     dbNotIn "country", "Brazil","US","France" 
#     dbNotIn "country", "Germany","Argentina","OR" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE country NOT IN('Brazil', 'US', 'France') or country NOT IN('Germany','Argentina') 
#
command dbNotIn pColumn
   local pConcatenationOperator, tOperator
   
   put param(the paramcount) into pConcatenationOperator
   
   if pConcatenationOperator is not among the items of "AND,OR" then
      put empty into pConcatenationOperator
   end if
   
   if pConcatenationOperator is empty then
      put "AND" into pConcatenationOperator
   end if
   
   put "NOT IN" into tOperator
   
   
   if dbA["where"] is empty then
      put "WHERE" && pColumn && "NOT IN("  before dbA["where"]
   else
      put " " & pConcatenationOperator  && pColumn &&  "NOT IN(" after dbA["where"]
   end if
   repeat with x = 2 to the paramcount
      put placeholder(param(x)) & comma after dbA["where"]
   end repeat
   delete char -1 of dbA["where"]
   put ")" after dbA["where"]
   
   set the itemdel to space
   put item -3 to -1 of dbA["where"]  into dbA["where columns"][pColumn]
end dbNotIn



# This command allows you to add an opening parenthesis to the where clause.
#
# This is useful when you need to group your where clauses. For example, suppose you want to search
# for emails that contain 'runrev.com' and the age is less 18 or more than 35. If you use a code like:
#
#     dbLike "email", "runrev.com"
#     dbWhere "age <", 18, "AND"
#     dbWhere "age >", 35, "OR"
#
# You will end put with the following WHERE clause:
#
#     WHERE 'email' LIKE '%runrev.com%' AND 'age' < 18 OR 'AGE' > 35
#
# Which is ambiguous and will return the wrong value, it will search for email like runrev and age less than 18
# or just age greater than 35 so if some record has age 40, it will match even if the email is not from runrev.com.
#
# If you add parenthesis as in this code:
#
#     dbLike "email", "runrev.com"
#     dbOpenParenthesis
#     dbWhere "age <", 18, "AND"
#     dbWhere "age >", 35, "OR"
#     dbCloseParenthesis
#
# You will end put with the following WHERE clause:
#
#     WHERE 'email' LIKE '%runrev.com%' AND ( 'age' < 18 OR 'AGE' > 35 ) 
#
# This SQL will execute as you expect because you are being clear on how the matches should go.
# Remember to add the close parenthesis with dbCloseParenthesis as well.
#
on dbOpenParenthesis
   if dbA["where"] is not empty then
      put " ( " after dbA["where"]
   end if
end dbOpenParenthesis

# This command allows you to add an closing parenthesis to the where clause.
#
# This is useful when you need to group your where clauses. For example, suppose you want to search
# for emails that contain 'runrev.com' and the age is less 18 or more than 35. If you use a code like:
#
#     dbLike "email", "runrev.com"
#     dbWhere "age <", 18, "AND"
#     dbWhere "age >", 35, "OR"
#
# You will end put with the following WHERE clause:
#
#     WHERE 'email' LIKE '%runrev.com%' AND 'age' < 18 OR 'AGE' > 35
#
# Which is ambiguous and will return the wrong value, it will search for email like runrev and age less than 18
# or just age greater than 35 so if some record has age 40, it will match even if the email is not from runrev.com.
#
# If you add parenthesis as in this code:
#
#     dbLike "email", "runrev.com"
#     dbOpenParenthesis
#     dbWhere "age <", 18, "AND"
#     dbWhere "age >", 35, "OR"
#     dbCloseParenthesis
#
# You will end put with the following WHERE clause:
#
#     WHERE 'email' LIKE '%runrev.com%' AND ( 'age' < 18 OR 'AGE' > 35 ) 
#
# This SQL will execute as you expect because you are being clear on how the matches should go.
# Remember to add the close parenthesis with dbCloseParenthesis as well.
#
on dbCloseParenthesis
   if dbA["where"] is not empty then
      put " ) " after dbA["where"]
   end if
end dbCloseParenthesis

# This command allows you to refine your query. Use it before calling functions such as: _dbGet, dbUpdate, dbDelete_.
#
# If a code like:
#     put dbGet("contacts") into tDataA 
# returns all the contacts. Then a code like:
#     dbLike "email", "runrev.com" 
#     put dbGet("contacts") into tDataA 
# Will return all contacts with emails from runrev.com
#
# The default matching routine for this _contains_.  
#     dbLike "email", "runrev.com" 
# Translates to:
#     WHERE email LIKE '%runrev.com%' 
# If you want to change the matching routines, then call it like:
#     dbLike "name", "john", "after" 
# Translates to:
#     WHERE name LIKE 'john%' 
# This will return all contacts with names starting with John. You can also use 
# 'exact' as the matching routine to strip the wildcards and match the exact value.
#
# You can have as many dbLike calls as you want. When you finally call a function that touches
# the database, it will use all those _where clauses_.
#
# _Remember: after calling a function that touches the database such as dbGet(), all the query parameters are reset_
#
# *Parameters:* a column and a value to look for.
# *Parameters:* a column, a value to look for and where to put the wildcard.
#
# As a convention, the standard operator for multiple dbWhere calls is AND
# so if you call
#
#     dbLike "email", "runrev.com" 
#     dbLike "first_name", "Kevin" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE email LIKE '%runrev.com%' AND first_name LIKE '%Kevin%' 
#
# Now, if you want  to use OR    instead of AND, you just pass an fourth extra parameter with
# the operator you want, like:
#
#     dbLike "email", "runrev.com" 
#     dbLike "first_name", "Kevin", "after", "OR" 
#     put dbGet("contacts") into tR 
#
# Translates to the following SQL:
#
#     SELECT * FROM contacts WHERE email LIKE '%runrev.com%' OR first_name LIKE 'Kevin%' 
#
command dbLike pColumn, pValue, pMatch, pConcatenationOperator
   local tOperator
   switch pMatch
      case "before"
         put "%" before pValue
         break
      case "after"
         put "%" after pValue
         break
      case "exact"
         break
      default
         put "%" before pValue
         put "%" after pValue
         break
   end switch
   
   if pConcatenationOperator is empty then
      put "AND" into pConcatenationOperator
   end if
   
   put "LIKE" into tOperator
   if dbA["where columns"][pColumn] is empty then
      if dbA["where"] is empty then
         put "WHERE" && pColumn && tOperator && placeholder(pValue) before dbA["where"]
      else
         put " " & pConcatenationOperator  && pColumn && tOperator && placeholder(pValue) after dbA["where"]
      end if
   else 
      # AAG: Support for multiple columns of the same name.
      --       replace dbA["where columns"][pColumn] with (pColumn && tOperator && placeholder(pValue)) in dbA["where"]
      put " " & pConcatenationOperator  && pColumn && tOperator && placeholder(pValue) after dbA["where"]
   end if
   
   set the itemdel to space
   put item -3 to -1 of dbA["where"]  into dbA["where columns"][pColumn]
end dbLike

# This command allows you to specify the SQL statement to use in the next function that touches
# the database.
# Sometimes you need to write a complex SQL statement that is beyond what we offer with routines
# such as _dbWhere, dbLike, dbLimit_, in this cases you can still use our handy database functions
# but specify the SQL statement yourself. 
#
# For example:
#     dbSetSQL "SELECT * FROM page, tags WHERE tags.page_id = page.id" 
#     put dbGet() into tPagesAndTagsArray 
# 
# Our commands and functions cover most of the common uses for application database usage
# but if you need more, you can always write your own SQL. The golden rule is: _if you know what a join is, then you can write it better than the library_.
#
# *Parameters:* A SQL Statement.
# *Parameters:* An optional placeholders array
command dbSetSQL pSQL, pPlaceHoldersA
   put pSQL into dbA["sql"]
   if the keys of pPlaceHoldersA is not empty then
      put pPlaceHoldersA into dbA["placeholders"]
   end if
end dbSetSQL

# This command executes the given SQL script on the default connection or the given connection.
#
# *Parameters:* A SQL Statement.
# *Parameters:* A SQL Statement and a connection id.
#
command dbExecuteSQL pSQL, pDatabaseConnectionID
   local theError
   if pDatabaseConnectionID is empty then
      put dbID into pDatabaseConnectionID
   end if
   
   revExecuteSQL pDatabaseConnectionID, pSQL
   
   put the result into theError
   put empty into dbA
   return theError
end dbExecuteSQL



# This command sets the limit for the query.
#
#     dbLimit 10 
#     put dbGet("contacts") into tDataA 
#
# Will return up to ten contacts.
#
# *Parameters:* A valid number for the limit.
# *Parameters:* A valid offset
command dbLimit pNum, pOffset
   put "LIMIT" && pNum into dbA["limit"]
   if pOffset is not empty then
      put " OFFSET" && pOffset after dbA["limit"]
   end if
end dbLimit

# Sets the ordering for a query.
# 
#     dbOrder 'age' 
#     put dbGet("contacts") into tDataA 
#
# Will return the contacts array ordered by age.
# *Parameters:* A valid column or clause for the ordering.
command dbOrderBy pOrderBy
   put "ORDER BY" && pOrderBy into dbA["order by"]
end dbOrderBy

# Sets the grouping options for a query.
# 
#     dbGroupBy 'country' 
#     dbColumn 'count(1) as qty'
#     put dbGet("contacts") into tDataA 
#
# Will return the contacts array grouped by country.
# *Parameters:* A valid column or clause for the grouping.
command dbGroupBy pData, pHaving
   put "GROUP BY" && pData into dbA["group by"]
   if pHaving is not empty then
      put " HAVING" && pHaving after dbA["group by"]
   end if
end dbGroupBy

# Returns all data from a given table as an array.
#
# You can use commands such as _dbWhere, dbLike, dbLimit, dbOrderBy_ to set 
# parameters to be used by this function.
#
# If a code like:
#     put dbGet("contacts") into tDataA 
# returns all the contacts. Then a code like:
#     dbWhere("country", "Brazil") 
#     dbWhere("sex", "male") 
#     put dbGet("contacts") into tDataA 
# Will return all contacts that are male and from Brazil.
#
# This functions works on the default connection id set with _dbSetDefaultConnectionID_ unless
# you pass an extra connection id parameter.
#
# *Parameters:* A table name.
# *Parameters:* A table name and a connection id.
#
function dbGet pTable, pDatabaseConnectionID
   local theArray, tPlaceholdersA, theCursor, theError
   if pDatabaseConnectionID  is empty then
      put dbID into pDatabaseConnectionID
   end if
   put empty into theArray
   if pDatabaseConnectionID is an integer then
      if dbA["columns"] is empty then
         put "*" into dbA["columns"]
      end if
      if dbA["sql"] is empty then
         put "SELECT" && dbA["columns"] && "FROM" && pTable && dbA["where"] && dbA["group by"] && dbA["order by"] && dbA["limit"]  into dbA["sql"]
      end if
      put dbA["placeholders"] into tPlaceholdersA
      put dbA["sql"] into dbData["last sql"]
      put revQueryDatabase( pDatabaseConnectionID, dbA["sql"],"tPlaceholdersA") into theCursor
      put empty into dbA
      if theCursor is an integer then
         ConvertSQLCursorToArray theCursor, theArray
         put the result into theError
         
         if theError is empty then
            revCloseCursor theCursor
            return theArray
         else
            ## Close the database cursor
            revCloseCursor theCursor
            return theError
         end if
      end if
      
   end if
end dbGet

# This command came from a RunRev lesson.
private command ConvertSQLCursorToArray pCursor, @pOutArrayA
    local i
    local theFields
    local theError
    
    ## Get the names of all the columns in the database cursor
    put revDatabaseColumnNames(pCursor) into theFields
    if theFields begins with "revdberr," then
        put item 2 to -1 of theFields into theError
    end if
    
    if theError is empty then
        put 0 into i
        ## Loop through all rows in cursor
        repeat until revQueryIsAtEnd(pCursor)
            add 1 to i
            
            ## Move all fields in row into next dimension of the array
            repeat for each item theField in theFields
               put revDatabaseColumnNamed(pCursor, theField) into pOutArrayA[i][ theField ]

            end repeat
            
            revMoveToNextRecord pCursor
        end repeat
    end if
    
    return theError
    
end ConvertSQLCursorToArray


# nodoc
private function arrayToFieldNames pA
   local tKeys
    put the keys of pA into tKeys
    sort tKeys
    replace cr with ", "  in tKeys
    return tKeys
end arrayToFieldNames

# nodoc
private function arrayToFieldValues pA
   local tKeys, tBuf
   put the keys of pA into tKeys
   sort tKeys
   repeat for each line tK in tKeys
      put placeholder(pA[tK]) & ", " after tBuf 
   end repeat
   delete char -2 to -1 of tBuf
   return tBuf
end arrayToFieldValues

# Returns the id for the last inserted, updated or deleted record on a given table.
# This is for SQLite only.
#
# *Parameters:* A table name.
#
function dbLastRowid pTable
   local tA
   dbSelect "SELECT ROWID from" && pTable && "order by ROWID DESC limit 1"
   put dbGet() into tA
   return tA[1]["rowid"]
end dbLastRowid

# This function returns the default database connection id set by dbSetDefaultConnectionID
#
function dbGetDefaultConnectionID
   return dbID
end dbGetDefaultConnectionID

# This function inserts a new record into the database.
# It uses an array where each element is a field value with the same keys as the field names
# on the database schema.
#
#     put "Andre" into tDataA["firstName"] 
#     put "Garzia" into tDataA["lastName"] 
#     put "andre@andregarzia.com" into tDataA["email"] 
#     put dbInsert("contacts", tDataA) into tResult 
#
# Will insert a new record with the values from the array. This function works on the default connection id unless
# you specify an extra parameter with the desired connection id.
#
# *Parameters:* A table name and a data array.
# *Parameters:* A table name, a data array and a connection id.
#
# *Returns:* the result from the inner revExecuteSQL call.
#
function dbInsert pTable, pDataA, pDatabaseConnectionID
   local tPlaceholdersA, theError
   if pDatabaseConnectionID is empty then
      put dbID into pDatabaseConnectionID
   end if
   if dbA["sql"] is empty then
      put "INSERT INTO" && pTable & "(" & arrayToFieldNames(pDataA) & ") VALUES (" & arrayToFieldValues(pDataA) & ")" into dbA["sql"]
   end if
   put dbA["placeholders"] into tPlaceholdersA
   put dbA["sql"] into dbData["last sql"]
   revExecuteSQL pDatabaseConnectionID, dbA["sql"], "tPlaceholdersA"
   put the result into theError
   put empty into dbA
   return theError
end dbInsert


# This function performs batch inserts. You pass the table name, the batch data array and an optional database
# connection id. The batch data array is an array like the one used by the datagrid. On its first level it has numeric
# keys going from 1 to N. In each element in the second level it has a data array.
#
# For Example:
#
# put "andre" into tDataA[1]["first_name"]
# put "garzia" into tDataA[1]["last_name"]
# put "support@andregarzia.com" into tDataA[1]["email"]
#
# put "claudia" into tDataA[2]["first_name"]
# put "donovan" into tDataA[2]["last_name"]
# put "claudia@example.com" into tDataA[2]["email"]
#
# get dbBatchInsert("contacts", tDataA)
#
# The return value is the number of records added or an error string that starts with __dberr,__.
#
function dbBatchInsert pTable, pBatchDataA, pDatabaseConnectionID
   local tKeys, tDataA,  tTotal 
   
   if pDatabaseConnectionID is empty then
      put dbID into pDatabaseConnectionID
   end if
   
   put the keys of pBatchDataA into tKeys
   sort numeric ascending tKeys
   repeat for each line x in tKeys
      put pBatchDataA[x] into tDataA
      get dbInsert(pTable, tDataA, pDatabaseConnectionID)
      if it is not a number then
         return "dberr, error adding record" && x &":" && it
      end if
      add it to tTotal 
   end repeat
   return tTotal
end dbBatchInsert

# nodoc
private function arrayToUpdateSQL pA
   local tKeys, tBuf
   put the keys of pA into tKeys
   sort tKeys
   repeat for each line tK in tKeys
      put tK && "=" && placeholder(pA[tK]) & ", " after tBuf 
   end repeat
   delete char -2 to -1 of tBuf
   return tBuf
end arrayToUpdateSQL

# Updates a record in the database.
# 
# Use a _dbWhere_ or a  _dbLike_ to specify which record. 
# For example:
#
#     put "contato@andregarzia.com" into tNewDataA["email"] 
#     dbWhere "email", "andre@andregarzia.com" 
#     put dbUpdate("contacts", tNewDataA) into tResult
# 
# This will change the email for that user. It is analogous to executing the following SQL:
#     UPDATE contacts SET email = 'contato@andregarzia.com' WHERE email = 'andre@andregarzia.com' 
#
#     REMEMBER:     If you don't specify a _dbWhere_ or a  _dbLike_ then the library will return an
# error for this call starting with "dberr,". This is to protect you from accidently updating all records
# on a given table because you forgot to specify a filter.
#
# This function works on the default connection id unless
# you specify an extra parameter with the desired connection id.
#
# *Parameters:* a table name and a data array.
# *Parameters:* a table name, a data array and a connection id.
# 
# *Returns:* the result from the inner revExecuteSQL call.
#
function dbUpdate pTable, pDataA, pDatabaseConnectionID
   local tPlaceholdersA, theError, 
   if pDatabaseConnectionID is empty then
      put dbID into pDatabaseConnectionID
   end if
   if dbA["sql"] is empty and dbA["where"] is not empty then
      put "UPDATE" && pTable && "SET" && arrayToUpdateSQL(pDataA) && dbA["where"] into dbA["sql"]
   else
      put empty into dbA
      return "dberr, please set a where clause"
   end if
   put dbA["placeholders"] into tPlaceholdersA
   put dbA["sql"] into dbData["last sql"]
   revExecuteSQL pDatabaseConnectionID, dbA["sql"], "tPlaceholdersA"
   put the result into theError
   put empty into dbA
   return theError
end dbUpdate

# Deletes a record from the database.
# 
# Use a _dbWhere_ or a  _dbLike_ to specify which record. 
# For example:
#
#     dbWhere "email", "andre@andregarzia.com" 
#     put dbDelete("contacts") into tResult
# 
# This will delete that user. It is analogous to executing the following SQL:
#     DELETE FROM contacts WHERE email = 'andre@andregarzia.com' 
#
#     REMEMBER:     If you don't specify a _dbWhere_ or a  _dbLike_ then the library will return an
# error for this call starting with "dberr,". This is to protect you from accidently deleting all records
# on a given table because you forgot to specify a filter.
#
# This function works on the default connection id unless
# you specify an extra parameter with the desired connection id.
#
# *Parameters:* a table name and a data array.
# *Parameters:* a table name, a data array and a connection id.
# 
# *Returns:* the result from the inner revExecuteSQL call.
#
function dbDelete pTable, pDatabaseConnectionID, pTruncate
   local  tPlaceholdersA, theError
   if pDatabaseConnectionID  is empty then
      put dbID into pDatabaseConnectionID
   end if
   if (dbA["sql"] is empty and dbA["where"] is not empty) or pTruncate is true then
      put "DELETE FROM" && pTable && dbA["where"] && dbA["limit"] into dbA["sql"]
   else
      put empty into dbA
      return "dberr, please set a where clause."
   end if
   put dbA["placeholders"] into tPlaceholdersA
   put dbA["sql"] into dbData["last sql"]
   revExecuteSQL pDatabaseConnectionID, dbA["sql"], "tPlaceholdersA"
   put the result into theError
   put empty into dbA
   return theError
end dbDelete

# This command will look into the current card for fields, buttons and groups
# with the same name as the fields on a given database table. If it finds the correct controls
# it picks their values and assemble an array to be used by the database touching functions.
#
# If you have a card with a field called "firstName", a field called "lastName" and a menu button 
# called "country" which are all fields on your _contacts_ table and you use:
#
#     put dbCardToArray("contacts") into tDataA 
#
# it is the same as writing:
#
#     put unidecode(the unicodetext of field "firstName", "unicode") into tDataA["firstName"] 
#     put unidecode(the unicodetext of field "lastName", "unicode") into tDataA["lastName"] 
#     put the label of button "country" into tDataA["country"] 
#
# So it follows these rules:
# 1 - it looks for a field, it there is one, then it picks the unicodetext property and unidecodes it into the array.
# 2 - it looks for a button and places the label into the array.
# 3 - it looks for a group and places the value from the custom property _dbvalue_ into the array.
#
# __REMEMBER:__ if you're using groups for your mobile controls, just script a _setprop dbvalue_ and
# a _getprop dbvalue_ for the group to be able to exchange data with this command.
#
# *Parameters:* a table name.
# *Parameters:* a table name and a connection id.
# 
# *Returns:* an array
function dbCardToArray pTable, pDatabaseConnectionID
   local tDataA, tFields
   if pDatabaseConnectionID is empty then
      put dbID into pDatabaseConnectionID
   end if
   put empty into tDataA
   put revDatabaseColumnNames(pDatabaseConnectionID, pTable) into tFields
   repeat for each item tF in tFields
      -- look for field
      if there is a field tF and the locktext of field tF is false then
         --         put field tF into  tDataA[tF]
         --         put unidecode(the unicodetext of field tF, "unicode") into tDataA[tF]
         put unidecode(the unicodetext of fld tF, "utf8") into tDataA[tF]
         next repeat
      end if
      -- look for button
      if there is a button tF then
         put the label of button tF into tDataA[tF]
         next repeat
      end if
      -- look for a group
      if there is a group tF then
         put the dbValue of group tF into tDataA[tF]
         next repeat
      end if
   end repeat
   return tDataA
end dbCardToArray

# This command will loop the keys of an array looking for controls with the same name in the current
# card. If it finds a field, button or group with the same name, it will try to replace the current value
# for the control with the value from the array.
#
# If you have a card with a field called "firstName", a field called "lastName" and a menu button 
# called "country" which are all fields on your _contacts_ table and you use:
#
#     dbArrayToCard tDataA 
#
# it is the same as writing:
#
#     set the unicodetext of field "firstName" to uniencode(tDataA["firstName"], "unicode") 
#     set the unicodetext of field "lastName" to uniencode(tDataA["lastName"], "unicode") 
#     set the label of button "country" to tDataA["country"] 
#
# So it follows these rules:
# 1 - it looks for a field, it there is one, then it sets the unicodetext property.
# 2 - it looks for a button and sets the label.
# 3 - it looks for a group and sets the value from the custom property _dbvalue_.
#
# __REMEMBER:__ if you're using groups for your mobile controls, just script a _setprop dbvalue_ and
# a _getprop dbvalue_ for the group to be able to exchange data with this command.
#
# *Parameters:* an array.
# *Parameters:* an array and a connection id.
# 
command dbArrayToCard pDataA
   local tDataA, tF
   repeat for each key tK in pDataA
      -- check for field
      if there is a field tK then
         --         put pDataA[tK] into field tK
         --         set the unicodetext of fld tK to uniencode(pDataA[tK], "unicode")
         set the unicodetext of fld tK to uniencode(pDataA[tK], "utf8")
         
         next repeat
      end if
      -- check for button
      if there is a button tK then
         set the label of button tK to pDataA[tK]
         next repeat
      end if
      -- look for a group
      if there is a group tF then
         set the dbValue of group tF to tDataA[tF]
         next repeat
      end if
   end repeat
end dbArrayToCard

# nodoc
private function arrayToPlainText pA, pIndent
   local tBuf
   repeat for each key tK in pA
      if the keys of pA[tK] is empty then
         put pIndent & tK & ":" && pA[tK] & cr after tBuf
      else
         put pIndent & tK & ":" & cr after tBuf
         put arrayToPlainText(pA[tK], (tab & pIndent)) after tBuf
      end if
   end repeat
   return tBuf
end arrayToPlainText


# This commands creates a new SQLite file at the given path and optionaly executes a given SQL
#
# This can be used with CREATE TABLE calls or dumps from any SQLite client.
#
# *Parameters:* The full location of the file including the file name and extension.
# *Parameters:* The full location of the file including the file name and extension and an optional SQL script to run.
#
# If the initial SQL script is given then the result of running it is placed on _the result_. You should also check that
# variable for errors starting with _dberr_.
#
command dbCreateNewSQLiteFile pLocation, pInitialSQL
   local tQuery, tID
   -- check if file exists
   if there is a file pLocation then
      return "dberr, file already exists"
   end if
   
   -- create new file
   put empty into url ("binfile:" & pLocation)
   
   -- if there is some initial SQL then execute it.
   if pInitialSQL is not empty then
      put dbPreserveQueryParameters() into tQuery
      dbResetQuery
      
      -- opening new db file
      get revOpenDatabase("sqlite", pLocation,,,)
      if it is not a number then
         dbRestoreQueryParameters tQuery
         return "dberr, could not open file at" && pLocation &"." && it
      else
         put it into tID
      end if
      
      -- executing SQL
      dbExecuteSQL pInitialSQL, tID
      dbRestoreQueryParameters tQuery
      return the result
      
   end if
   
   dbRestoreQueryParameters tQuery
   
end dbCreateNewSQLiteFile

# This command will copy the SQLite files from the engines folder to the documents.
#
# You can pass an optional file extension for the SQLite files. If you don't pass one, then
# _.db_ is assumed to be the file extension.
#
# Files added to your Standalone using the "Copy Files" tab end up in the engine folder.
# This folder is not writable so it is not a good location for your database files.
#
# This command will copy the files from the engine folder to the documents folder. This folder
# is writable and backed up to iCloud on iPhone.
#
# For example, suppose you have your SQLite file called _contacts.db_ and you added this file
# to your Standalone using the *copy files* tab of the *Standalone builder settings*, calling this:
#
#      dbMoveAllSQLiteFilesFromEngineToDocuments ".db"     
#
# Will copy this file to the documents folder. Then after that you can simply access it using:
#
#     the documents folder & "/contacts.db" 
#
# Be aware that if there is already a file in the destination with the same name, this command WILL NOT
# overwrite it. 
#
command dbMoveAllSQLiteFilesFromEngineToDocuments pExtension
   local tDF, tFilesList, tEngineLocation, tDocumentsLocation
   if the environment is not "mobile" then
      return "dberr, this command only works on mobile."
   end if
   put the defaultfolder into tDF
   set the defaultfolder to the engine folder
   
   put the files into tFilesList
   
   if pExtension is empty then
      put ".db" into pExtension
   end if
   
   filter tFilesList with ("*" & pExtension & "*")
   
   repeat for each line f in tFilesList
      put the defaultfolder & "/" & f into tEngineLocation
      put the documents folder & "/" & f into tDocumentsLocation
      if there is a file tDocumentsLocation then
         -- do not overwrite!
         next repeat
      end if
      put url ("binfile:" & tEngineLocation) into url ("binfile:" & tDocumentsLocation)
      if the result is not empty then
         return "dberr," && the result
      end if
   end repeat
   
   set the defaultfolder to tDF
end dbMoveAllSQLiteFilesFromEngineToDocuments
