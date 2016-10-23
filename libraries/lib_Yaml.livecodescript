script "lib_Yaml"
--> MetaData
-
license: GPLv3
name: lib_Yaml
type: library
version: 0.1

/*
This stack has been moved from a frontscript to a library.

I dont think it is actually used and can be safely removed?
*/

--> Working On
-
function arrayToYaml pArray, pIndentLevel
   local tYaml
   local tIndentLevel
   
   put pIndentLevel into tIndentLevel
   if tIndentLevel is empty then
      put kIndent into tIndentLevel
      put "ArrayName :" & cr into tYaml
   end if
   if pArray is an array then
      repeat for each key tKey in pArray
         if pArray[tKey] is an array then
            put indent(tIndentLevel) & tKey && ":" && pArray[tKey] & cr after tYaml
            add kIndent to tIndentLevel
            -- recurse to work through multidimensional arrays
            put arrayToYaml(pArray[tKey], tIndentLevel) after tYaml
            subtract kIndent from tIndentLevel
         else
            put indent(tIndentLevel) & tKey && ":" && pArray[tKey] & cr after tYaml
         end if
      end repeat
   else
      throw "not an array"
   end if
   return tYaml
end arrayToYaml

/*
indent

Used internally by arrayToYaml
*/
private function indent pIndentLevel
   local tIndentLevel
   
   -- return the proper number of spaces for indentation
   repeat pIndentLevel times
      put space after tIndentLevel
   end repeat
   return tIndentLevel
end indent

/*
indentationLevel

Return the indentation level of the supplied line
NOTE: changes the input line in situ to remove the indentation
Used internally by yamlToArray
*/
private function indentationLevel @pLine
   local tIndentationLevel
   local tKey, tValue
   
   put 0 into tIndentationLevel
   repeat while char 1 of pLine is space
      add 1 to tIndentationLevel
      delete char 1 of pLine
   end repeat
   return tIndentationLevel
end indentationLevel

/*
yamlToArray

Convert yaml format text to a LiveCode array
*/
function yamlToArray pYaml
   local tArray
   local tIndentation, tPrevIndent
   local tWorkingLine
   local tYamlHeading
   local tKey, tValue
   
   repeat for each line tLine in pYaml
      put tLine into tWorkingLine
      set the itemdelimiter to ":"
      put item 1 of tWorkingLine into tKey
      repeat while char -1 of tKey is in ": "
         delete char -1 of tKey
      end repeat
      put word 1 to -1 of item 2 of tWorkingLine into tValue
      put indentationLevel(tKey) into tIndentation
      if tPrevIndent is empty then
         -- first time through
         put tIndentation into tPrevIndent
         put tKey into tYamlHeading
         put tValue into tArray[tYamlHeading]
      else
         switch
            case tIndentation < tPrevIndent
               -- remove the last array index
               RemoveLastIndexFrom tYamlHeading
               RemoveLastIndexFrom tYamlHeading
               put tIndentation into tPrevIndent
               if tYamlHeading is empty then
                  do "put tValue into tArray[" & tKey & "]"
               else
                  do "put tValue into tArray" & yamlPathToArrayPath(tYamlHeading) & "[" & tKey & "]"
               end if
               break
            case tIndentation is tPrevIndent
               RemoveLastIndexFrom tYamlHeading
               if tYamlHeading is empty then
                  do "put tValue into tArray" & "[" & tKey & "]"
               else
                  do "put tValue into tArray" & yamlPathToArrayPath(tYamlHeading) & "[" & tKey & "]"
               end if
               put comma & tKey after tYamlHeading
               break
            case tIndentation > tPrevIndent
               -- add an array index
               if tYamlHeading is empty then
                  do "put tValue into tArray[" & tKey & "]"
               else
                  do "put tValue into tArray" & yamlPathToArrayPath(tYamlHeading) & "[" & tKey & "]"
               end if
               put comma & tKey after tYamlHeading
               put tIndentation into tPrevIndent
               break
         end switch
      end if
   end repeat
   return tArray
end yamlToArray

private command RemoveLastIndexFrom @pIndexString
   set the itemdelimiter to comma
   delete item -1 of pIndexString
end RemoveLastIndexFrom

private function yamlPathToArrayPath pYamlPath
   local tArrayPath
   
   set the itemdelimiter to comma
   repeat for each item tPath in pYamlPath
      put "[" & tPath & "]" after tArrayPath
   end repeat
   return tArrayPath
end yamlPathToArrayPath

/*
yamlFileToArray

Point to a yaml file, return a LiveCode array
*/
function yamlFileToArray pFilePath
   local tYaml
   
   put url ("file:" & pFilePath) into tYaml
   return yamlToArray(tYaml)
end yamlFileToArray

/*
*/
command testArrayToYaml
   local tArray
   
   put "hello" into tArray["hi"]
   put "bucko" into tArray["greeting"]["name"]
   put 1234 into tArray["greeting"]["mynumber"]
   put "goodbye" into tArray["bye"]
   put "510-555-1212" into tArray["greeting"]["phonenumber"]["landline"]
   put "510-555-1212" into tArray["greeting"]["phonenumber"]["cell"]
   put arrayToYaml(tArray)
end testArrayToYaml

command testYamlToArray
   local tYaml
   
   put "greeting :" & cr into tYaml
   put "    myNumber : 1234" & cr after tYaml
   put "    phonenumber :" & cr after tYaml
   put "        landline : 510-555-4567" & cr after tYaml
   put "            extension : 42" & cr after tYaml
   put "        cell : 510-555-1234" & cr after tYaml
   put "    name : bucko" & cr after tYaml
   put "hi : hello" & cr after tYaml
   put "bye : goodbye" & cr after tYaml
   put arrayToYaml(yamlToArray(tYaml)) & cr after msg
end testYamlToArray
