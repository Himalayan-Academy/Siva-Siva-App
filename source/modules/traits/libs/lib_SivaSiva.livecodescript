script "lib_SivaSiva"
--> MetaData
-
license: GPLv3
name: lib_SivaSiva
type: library
version: 0.1

local LocalArray


--> Working On
-
function sivasiva_ParseXhtml xHtml
   revXmlDeleteAllTrees
   put revCreateXMLTree (xHtml, true, true, false) into xmlID
   --
   put revXMLNodeContents (xmlID, "/html/head/title") into bookArray ["bookTitle"]
   repeat with chapterNum = 1 to 64
      put format ("table%03d", chapterNum) into tableID
      put sivasiva_ExtractChapterArray (xmlID, tableID) into chapterArray
      put chapterArray into bookArray [chapterNum]
   end repeat
   --
   revDeleteXmlTree xmlID
   return bookArray
end sivasiva_ParseXhtml

function sivasiva_ExtractChapterArray xmlID, tableID
   put revXMLRootNode (xmlID) into pStartNode
   put revXMLMatchingNode (xmlID, pStartNode, "table", "id", tableID, -1) into tableNode
   put revXMLText (xmlID, tableNode, true) into chapterArray ["tableXML"]
   put revXMLParent (xmlID, tableNode) into tableDivNode
   
   put table_ConstructArrayFromTree (xmlID, tableNode) into tableArray
   put tableArray into chapterArray ["tableArray"]
   
   put tableDivNode into chapterTitleNode
   xml_FindNextSibling xmlID, chapterTitleNode, "class", "Trait-Heading", "/p"
   put the result into titleParaNode  
   get revXMLNodeContents (xmlID, titleParaNode)
   put word 2 to -1 of it into chapterArray ["chapterTitle"]
   
   put revXMLNextSibling (xmlID, chapterTitleNode) into traitNode
   put revXMLText (xmlID, traitNode, true) into chapterArray ["descriptionXML"]
   
   put revXMLFirstChild (xmlID, traitNode, true) into traitDefinitionNode
   put revXMLNodeContents (xmlID, traitDefinitionNode) into traitDefinition
   if traitDefinition is empty then
      put revXMLText (xmlID, traitDefinitionNode, true) into traitDefinition
      delete line 1 of traitDefinition
      delete line -1 of traitDefinition
   end if
   text_DecodeUTF8 traitDefinition
   put word 1 to -1 of traitDefinition into chapterArray ["traitDefinition"]
   
   put revXMLNumberOfChildren (xmlID, traitNode, "p", 1) into maxChildNum
   put revXMLChildNames (xmlID, traitNode, CR, "p", true) into childNames
   repeat with lineNum = 2 to maxChildNum
      put traitNode & "/" & line lineNum of childNames into childNode
      get revXMLNodeContents (xmlID, childNode)
      put it & CR after quoteText
   end repeat
   delete char -1 of quoteText
   text_DecodeUTF8 quoteText
   put word 1 to -1 of quoteText into chapterArray ["quoteText"]
   
   put traitNode into photoNode
   xml_FindNextSibling xmlID, photoNode, "class", "Photo-frame-for-trait", "/div"
   put the result into imageDivNode  
   put imageDivNode & "/img" into imageNode
   put revXMLAttribute (xmlID, imageNode, "src") into traitImageSource
   if item 1 of traitImageSource = "xmlerr" then
      put revXMLText (xmlID, photoNode, true) into chapterArray ["traitImageXML"]
      get revXMLChildContents (xmlID, photoNode, empty, slash, false, -1)
      put photoNode & "/" & line 1 of it into imageNode
      put revXMLAttribute (xmlID, imageNode, "src") into traitImageSource
   end if
   put traitImageSource into chapterArray ["traitImageSource"]
   
   put photoNode into assignmentNode
   xml_FindNextSibling xmlID, assignmentNode, "class", "Assignment-line", "/p"
   put revXMLText (xmlID, assignmentNode, true) into assignmentXML
   put assignmentXML into chapterArray ["assignmentXML"]
   delete line 1 of assignmentXML
   delete line -1 of assignmentXML
   put word 1 to -1 of line 1 of assignmentXML into chapterArray ["assignment"]["assignmentLine"]
   put word 1 to -1 of line 2 of assignmentXML into chapterArray ["assignment"]["assignmentText"]
   put word 1 to -1 of line 4of assignmentXML into chapterArray ["assignment"]["assignmentThoughts"]
   
   put assignmentNode into storyNode
   xml_FindNextSibling xmlID, storyNode, "class", "Story-synopsis-text-white-text", "/p"
   get revXMLText (xmlID, storyNode, true) 
   delete line 1 of it
   delete line -1 of it
   put word 1 to -1 of it into storyXML
   put storyXML into chapterArray ["storyHTML"]
   
   return chapterArray
end sivasiva_ExtractChapterArray

function sivasiva_ExtractDataFromXml someXml, someXPath, someKey
   put revCreateXMLTree (someXml, true, true, false) into treeID
   --       
   put revXMLEvaluateXPath (treeID, someXPath) into tableNodePaths
   
   -- hack
   revDeleteXMLTree treeID
   return tableNodePaths
   
   put 1 into indexNum
   repeat for each line testPath in tableNodePaths
      put revXMLDataFromXPathQuery (treeID, testPath) into testResult
      if word 1 to -1 of testResult is not empty then
         put testResult into tableContentArray [indexNum][someKey]
         add 1 to indexNum
      end if
   end repeat
   --
   revDeleteXMLTree treeID
   return tableContentArray
end sivasiva_ExtractDataFromXml

function sivasiva_ExtractTables someXml, p
   put revCreateXMLTree (someXml, true, true, false) into treeID
   --       
   put "//*[@class='Virtue-table-style TableOverride-1']" into someXPath
   put revXMLEvaluateXPath (treeID, someXPath) into tableNodePaths
   
   put 1 into indexNum
   repeat for each line testPath in tableNodePaths
      put revXMLDataFromXPathQuery (treeID, testPath) into testResult
      if word 1 to -1 of testResult is not empty then
         put testResult into tableContentArray [indexNum]["table"]
         add 1 to indexNum
      end if
   end repeat
   --
   revDeleteXMLTree treeID
   return tableContentArray
end sivasiva_ExtractTables

function sivasiva_ExtractDivs someXml
   put revCreateXMLTree (someXml, true, true, false) into treeID
   --
   put "//*[@class='Basic-Graphics-Frame _idGenObjectStyleOverride-2']" into someXPath
   put revXMLEvaluateXPath (treeID, someXPath) into classNodePaths
   
   put 1 into indexNum
   repeat for each line testPath in classNodePaths
      -- put any line of classNodePaths into testPath
      put revXMLDataFromXPathQuery (treeID, testPath) into testResult
      if word 1 to -1 of testResult is not empty then
         put line 1 of testResult into contentArray [indexNum]["description"]
         put line 2 to -1 of testResult into quoteText
         put quoteText into contentArray [indexNum]["quote"]
         add 1 to indexNum
      end if
   end repeat
   --
   revDeleteXMLTree treeID
   return contentArray
end sivasiva_ExtractDivs

function sivasiva_GetChapterArray chapterName
   put sivasiva_FetchChapterTitleArray() into chapterTitleArray
   put sivasiva_FetchBookArray() into bookArray
   put chapterTitleArray [chapterName] into chapterNum
   put bookArray [chapterNum] into chapterArray
   return chapterArray
end sivasiva_GetChapterArray

function sivasiva_FetchChapters
   put project_FetchValue ("orderedChapterTitleIndex", "SivaSiva") into orderedChapterTitleIndex
   return orderedChapterTitleIndex
end sivasiva_FetchChapters

command sivasiva_SaveChapters orderedChapterTitleIndex
   project_SaveValue "orderedChapterTitleIndex", orderedChapterTitleIndex, "SivaSiva"
   return the result
end sivasiva_SaveChapters

function sivasiva_FetchChapterTitleArray 
   put project_FetchValue ("chapterTitleArray", "SivaSiva") into chapterTitleArray
   return chapterTitleArray
end sivasiva_FetchChapterTitleArray

command sivasiva_SaveChapterTitleArray chapterTitleArray
   project_SaveValue "chapterTitleArray", chapterTitleArray, "SivaSiva"
   return the result
end sivasiva_SaveChapterTitleArray

-- function sivasiva_FetchOldBookArray
put project_FetchValue ("contentArray", "SivaSiva") into bookArray
return bookArray
end sivasiva_FetchOldBookArray

function sivasiva_FetchBookArray
   put project_FetchValue ("bookArray", "SivaSiva") into bookArray
   return bookArray
end sivasiva_FetchBookArray

command sivasiva_SaveBookArray bookArray
   project_SaveValue "bookArray", bookArray, "SivaSiva"
   return the result
end sivasiva_SaveBookArray

command book_ParseDivArray someArray, @indexedArray, @attributesArray
   put someArray ["@attributes"] into attributesArray
   delete variable someArray ["@attributes"]
   
   put keys(someArray) into someIndex
   sort numeric someIndex by token 3 of each
   put the number of lines of someIndex into maxNum
   
   repeat for each line someKey in someIndex
      set the cursor to busy
      put someArray [someKey] into recordArray
      put token 3 of someKey into indexNum
      put recordArray into indexedArray [indexNum]
   end repeat
   return someIndex
end book_ParseDivArray

command display_IndexedBookArray someArray, bookTitle
   local indexedArray, attributesArray
   
   book_ParseDivArray someArray, indexedArray, attributesArray
   put attributesArray ["class"] into divClass
   put attributesArray ["id"] into divID
   
   put divClass & comma & divID into bookTitle
   
   put "Global | SivaSiva | Book | Parse | Menu" into titleMenu
   put "Global | SivaSiva | Book | Parse | Line | Menu" into titleLineMenu
   display_Array indexedArray, bookTitle, titleMenu, titleLineMenu
   put the result into displayView
   set the tree_SortType of displayView to "numeric"
end display_IndexedBookArray

function sivasiva_GetTestXML someXml
   /*
   <div id="_idContainer034" class="Basic-Graphics-Frame _idGenObjectStyleOverride-2">
   <p class="_trait-definition-text-g2"> Abstemiousness means being moderate in eating and drinking. I strengthen it by exercising willpower when I am tempted to eat too much. Eating a vegetarian diet has a moderating impact not only on the body, but on the environment as well. The opposite is gluttony. </p>
   <p class="_-Gurudeva-quote-text"><span class="RelatoD-bold-green">Gurudeva observed:</span> “Overeating repels one from spiritual sadhana, because the body becomes slothful and lazy, having to digest so much food and run it through its system.…A vegetarian diet creates the right chemistry for spiritual life. Other diets create a different chemistry, which affects your endocrine glands and your entire system all day long. A vegetarian diet helps your system all day long. Food is chemistry, and chemistry affects consciousness; and if our goal is higher consciousness, we have to provide the chemistry that evokes it.”</p>
   </div>
   */
   
   put script_GetCommentAboveMe() into someXML
   put shell_XmlTidy (someXML) into someXML
   put offset ("<", someXML) into startCharNum
   if startCharNum > 0 then
      delete char 1 to (startCharNum -1) of someXML
      -- delete line 1 to 3 of someXML
   end if
   xml_AddHeaderLine someXML
   return someXML
end sivasiva_GetTestXML

function sivasiva_GetXML
   put LocalArray ["xmlFile"] into xmlFile
   if there is not a file xmlFile then
      answer file "Select an xml file..."
      put it into xmlFile
      if xmlFile is empty then exit to top
      put xmlFile into LocalArray ["xmlFile"]
   end if
   
   put url ("file:" & xmlFile) into someXML
   return someXML
end sivasiva_GetXML


-->
function sivasiva_GetXML
   put LocalArray ["xmlFile"] into xmlFile
   if there is not a file xmlFile then
      answer file "Select an xml file..."
      put it into xmlFile
      if xmlFile is empty then exit to top
      put xmlFile into LocalArray ["xmlFile"]
   end if
   
   put url ("file:" & xmlFile) into someXML
   return someXML
end sivasiva_GetXML

function sivasiva_GetTestXML someXml
   /*
   <div id="_idContainer034" class="Basic-Graphics-Frame _idGenObjectStyleOverride-2">
   <p class="_trait-definition-text-g2"> Abstemiousness means being moderate in eating and drinking. I strengthen it by exercising willpower when I am tempted to eat too much. Eating a vegetarian diet has a moderating impact not only on the body, but on the environment as well. The opposite is gluttony. </p>
   <p class="_-Gurudeva-quote-text"><span class="RelatoD-bold-green">Gurudeva observed:</span> “Overeating repels one from spiritual sadhana, because the body becomes slothful and lazy, having to digest so much food and run it through its system.…A vegetarian diet creates the right chemistry for spiritual life. Other diets create a different chemistry, which affects your endocrine glands and your entire system all day long. A vegetarian diet helps your system all day long. Food is chemistry, and chemistry affects consciousness; and if our goal is higher consciousness, we have to provide the chemistry that evokes it.”</p>
   </div>
   */
   
   put script_GetCommentAboveMe() into someXML
   put shell_XmlTidy (someXML) into someXML
   put offset ("<", someXML) into startCharNum
   if startCharNum > 0 then
      delete char 1 to (startCharNum -1) of someXML
      -- delete line 1 to 3 of someXML
   end if
   xml_AddHeaderLine someXML
   return someXML
end sivasiva_GetTestXML

function sivasiva_ExtractDivs someXml
   put revCreateXMLTree (someXml, true, true, false) into treeID
   --
   put "Basic-Graphics-Frame _idGenObjectStyleOverride-2" into divClassName
   
   put revXMLRootNode (treeID) into startNode
   put revXMLMatchingNode (treeID, startNode, "div", "class", divClassName, -1) into foundNode
   
   -- these get ids
   -- put revXMLMatchingNode (treeID, startNode, "div", "id", "_idContainer034", -1) into foundNode
   -- put "//*[@id='_idContainer034']" into someXPath
   -- put revXMLEvaluateXPath (treeID, someXPath) into idSectionNode
   
   put "//*[@class='Basic-Graphics-Frame _idGenObjectStyleOverride-2']" into someXPath
   put revXMLEvaluateXPath (treeID, someXPath) into classNodePaths
   
   -- opn_Notify (the number of lines of classNodePaths)
   
   put 1 into indexNum
   repeat for each line testPath in classNodePaths
      -- put any line of classNodePaths into testPath
      put revXMLDataFromXPathQuery (treeID, testPath) into testResult
      if word 1 to -1 of testResult is not empty then
         put line 1 of testResult into contentArray [indexNum]["description"]
         put line 2 to -1 of testResult into quoteText
         put quoteText into contentArray [indexNum]["quote"]
         add 1 to indexNum
      end if
   end repeat
   
   --
   revDeleteXMLTree treeID
   return contentArray
end sivasiva_ExtractDivs


--> SivaSiva
-
function sivasiva_FetchChapters
   put project_FetchValue ("orderedChapterTitleIndex", "SivaSiva") into orderedChapterTitleIndex
   return orderedChapterTitleIndex
end sivasiva_FetchChapters

command display_IndexedBookArray someArray, bookTitle
   local indexedArray, attributesArray
   
   book_ParseDivArray someArray, indexedArray, attributesArray
   put attributesArray ["class"] into divClass
   put attributesArray ["id"] into divID
   
   put divClass & comma & divID into bookTitle
   
   put "Global | SivaSiva | Book | Parse | Menu" into titleMenu
   put "Global | SivaSiva | Book | Parse | Line | Menu" into titleLineMenu
   display_Array indexedArray, bookTitle, titleMenu, titleLineMenu
   put the result into displayView
   set the tree_SortType of displayView to "numeric"
end display_IndexedBookArray

command book_ParseDivArray someArray, @indexedArray, @attributesArray
   put someArray ["@attributes"] into attributesArray
   delete variable someArray ["@attributes"]
   
   put keys(someArray) into someIndex
   sort numeric someIndex by token 3 of each
   put the number of lines of someIndex into maxNum
   
   repeat for each line someKey in someIndex
      set the cursor to busy
      put someArray [someKey] into recordArray
      put token 3 of someKey into indexNum
      put recordArray into indexedArray [indexNum]
   end repeat
   return someIndex
end book_ParseDivArray


--> Deps
-
command text_DecodeUTF8 @someText
   put unidecode (uniencode (someText,"UTF8")) into someText
end text_DecodeUTF8

command xml_FindNextSibling xmlID, @startNode, attName, attValue, pSubNodePath
   -- walk throug siblings until you find something
   put startNode into thisNode
   repeat 20 -- for safety
      put revXMLNextSibling (xmlID, thisNode) into nextNode
      put nextNode & pSubNodePath into maybeSubNode -- can be empty
      get revXMLAttribute (xmlID, maybeSubNode, attName)
      if it = attValue then
         put nextNode into startNode
         return maybeSubNode
      else
         put nextNode into thisNode
      end if
   end repeat
   
   -- often does not find an image
   return empty
end xml_FindNextSibling

function table_ConstructArrayFromTree xmlID, tableNode
   local tableArray
   
   -- parse the table header
   put tableNode & "/thead" into theadNode
   table_ParseSection tableArray, xmlID, theadNode, "theader"
   
   
   -- parse the table body
   put tableNode & "/tbody" into tbodyNode
   table_ParseSection tableArray, xmlID, tbodyNode, "tbody"
   
   /*
   put revXMLChildNames (xmlID, tbodyNode, CR, "tr", true) into childNames
   put the number of lines of childNames into maxChildNum
   repeat with lineNum = 1 to maxChildNum
      put tbodyNode & "/" & line lineNum of childNames into childNode
      put "/td/p" after childNode
      get revXMLNodeContents (xmlID, childNode)
      put it into tableArray ["tbody"][lineNum]
   end repeat
   */
   
   -- should do footer as well
   
   return tableArray
end table_ConstructArrayFromTree

private command table_ParseSection @tableArray, xmlID, theadNode, sectionName
   put revXMLChildNames (xmlID, theadNode, CR, "tr", true) into rowNames
   put the number of lines of rowNames into maxRowNum
   repeat with rowNum = 1 to maxRowNum
      put theadNode & "/" & line rowNum of rowNames into rowNode
      
      put revXMLChildNames (xmlID, rowNode, CR, "td", true) into columnNames
      put the number of lines of columnNames into maxColumnNum
      repeat with columnNum = 1 to maxColumnNum
         put rowNode & "/" & line columnNum of columnNames into columnNode
         
         -- a custom bit that assumes the entry is wrapped in <p>
         put columnNode & "/p" into childNode
         get revXMLNodeContents (xmlID, childNode)
         
         put word 1 to -1 of it into tableArray [sectionName][rowNum][columnNum]
      end repeat
   end repeat
end table_ParseSection
