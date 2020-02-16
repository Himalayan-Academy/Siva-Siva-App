Script "stack_lexicon_card_id_1056"

/*
# Name: card id 1056 of stack "lexicon"
# ID: card id 1056 of stack "lexicon"
*/


on preOpenCard
   
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
   setCardCoords
   set the rect of widget "Browser" of me to safeRect()
   --set the rect of widget "Browser" of me to the rect of this card
   
   --put "this is preOpenStack"
   if the environment is not "development" then
      set the url of widget "Browser" to ("file://" & (specialFolderPath("resources") & "/modules/lexicon/web/index.html") )
   else
      set the url of widget "Browser" to ("file://" & (specialFolderPath("resources") & "/web/index.html") )
   end if
   
   if getPhoneModel() is "iPhoneX" then
      mobileShowStatusBar
   end if
end preOpenCard

on saveStackRequest
   set the url of widget "Browser" of me to empty
   send "preOpenCard" to me in 50 ms
end saveStackRequest

on resizeStack
   set the rect of widget "Browser" of me to the rect of this card
end resizeStack

on goHome
   if getPhoneModel() is "iPhoneX" then
      mobileHideStatusBar
   end if
   go first card
   portal_GoStack "Siva-Siva-Portal"
end goHome

on goSettings
   go first card
   portal_GoStack "settings"
end goSettings
   
on browserLoadRequested pUrl, pType
   put pURL, pType
end browserLoadRequested

on getWordList
   local tStart, tA, tBuf, tJS
   put the seconds into tStart
   dbColumns "lexicon_id,word"
   put dbGet("lexicon", JnanamDB()) into tA
   put "query took"&&(the seconds - tStart)
   put arraytojson(tA) into tBuf
   put "encode took"&&(the seconds - tStart)
   replace q("lexicon_id")& ":" with "id" & ":" & quote in tBuf
   replace comma & q("word") with quote & comma& "word" in tBuf
   put "replace took"&&(the seconds - tStart)
   
   --    put "[" into tBuf
   --    repeat for each key x in tA
   --       put tA[x]["lexicon_id"] into tID
   --       put tA[x]["word"] into tWord
   --       put "{id: '" & tID & "', word: " & q( tWord )& "}," after tBuf
   --    end repeat
   --    delete char -1 of tBuf
   --    put "]" after tBuf
   put "words:" && tBuf
   put the merge of "try {window.app.ports.wordListReceived.send([[tBuf]])} catch(n) {liveCode.debug('exception' + n.message)" into tJS
   put "merge took"&&(the seconds - tStart)
   
   --    put "console.log('it worked')" into tJS
   do tJS in widget "browser"
   --put the seconds - tStart into tEnd
   --put "getWordList took"&&(the seconds - tStart)
end getWordList

function q p
   return quote & p & quote
end q

function trim p
   repeat while char 1 of p is among the items of " "
      delete char 1 of p
   end repeat
   repeat while char -1 of p is among the items of " "
      delete char -1 of p
   end repeat
   return p
end trim

on getWordDefinition pWordID
   local tA,tB,tListA,tBuf,tJS
   dbWhere "lexicon_id", pWordID
   put dbGet("lexicon", JnanamDB()) into tA
   put tA[1]["lexicon_id"] into tB["id"]
   put tA[1]["definition"] into tB["definition"]
   put tA[1]["word"] into tB["word"]
   put tA[1]["see_also"] into tListA
   split tListA by comma
   if tListA[1] is not empty then 
      repeat with x = 1 to the number of lines in the keys of tListA
         put trim(tListA[x]) into tListA[x]
      end repeat
   else 
      put empty into tListA[1]
   end if
   put tListA into tB["seeAlso"]
   
   
   put ARRAYToJson(tB) into tBuf
   replace (q("id") & ":" & tB["id"]) with (q("id") & ":" & q(tB["id"])) in tBuf
   put the merge of "window.app.ports.wordDefinitionReceived.send([[tBuf]])" into tJS
   do tJS in widget "browser"
   --put tBuf
end getWordDefinition


# this was removed the Javascript handlers of the 
# browser -- "debug"
on debug p t 
   put "debug" && p && t
end debug
