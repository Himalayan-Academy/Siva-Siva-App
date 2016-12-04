script "model_SivaSivaPrefs"
--> MetaData
-
license: GPLv3
name: model_SivaSivaPrefs
type: model
version: 0.1

/*
Not refactored yet.
Should use the model_Array of stack "model_SivaSivaPrefs" ???
Begun moving this stack to a model.
Was 'preferences"

Preferences are stored in platform specific ways. We should take advantage of these.
There are various forms of preference:
-  application specific
-  user preferences
-  tool or uttility preferences
*/

--> Variables
-

/**
* Preferences Library (aka User Settings)
*
* This library provides commands and functions to store user defined settings
*
*/  

-->Testing (BR)
-- 

command checkPrefsFilePath # from msg box
   _makeSurePreferencesFileExists
end checkPrefsFilePath

--> Prefs
-
command setPref pKey, pValue
   _makeSurePreferencesFileExists
   put url ("binfile:" & pathForPreferencesFile()) into tJSON
   put jsonImport(tJSON) into tPreferencesA
   
   if "/" is not in pKey then
      // simple lookup, checking for root level key
      put pValue into tPreferencesA[pKey]
   else
      // complex lookup, passed a path.
      
      // first trim
      if char -1 of pKey is "/" then delete char -1 of pKey
      if char 1 of pKey is "/" then delete char 1 of pKey
      
      // Assemble statement (irgh)
      put "['" before char 1 of pKey
      put "']" after char -1 of pKey
      replace "/" with "']['" in pKey
      replace "'" with quote in pKey
      get "put pValue into tPreferencesA" & pKey
      
      // this executes a command such as put pValue into tPreferencesA["key"]["child"]["grandchild"]
      do it
   end if
   put jsonExport(tPreferencesA) into tJSON
   put tJSON into url  ("binfile:" & pathForPreferencesFile())
end setPref

function getPref pKey
   _makeSurePreferencesFileExists
   put url ("binfile:" & pathForPreferencesFile()) into tJSON
   put jsonImport(tJSON) into tPreferencesA
   if "/" is not in pKey then
      // quick lookup, direct root level key.
      if the keys of tPreferencesA is empty or pKey is not among the lines of the keys of tPreferencesA then
         return false
      else
         return tPreferencesA[pKey]
      end if
   else
      // complex lookup, treated as a path to get inner child of settings.
      
      // first trim
      if char -1 of pKey is "/" then delete char -1 of pKey
      if char 1 of pKey is "/" then delete char 1 of pKey
      
      // now lookup
      set the itemdel to "/"
      repeat for each item k in pKey
         get tPreferencesA[k] 
         put it into tPreferencesA // reduce tPreferencesA by making children root and discarding the rest
      end repeat
      if tPreferencesA is empty then
         return false
      else
         return tPreferencesA
      end if
   end if
end getPref

function pathForPreferencesFile
   if the environment is mobile then 
      return specialfolderpath("documents") & "/sivasiva_preferences.json"
   else
      return specialfolderpath("temporary") & "/sivasiva_preferences.json"
   end if
end pathForPreferencesFile

private command _makeSurePreferencesFileExists
   if there is not a file pathForPreferencesFile() then
      put the defaultfolder into tDF
      set the itemdel to "/"      
      set the defaultfolder to ( (item 1 to -2 of the effective filename of me) & "/model_SivaSivaPrefs/")  --JG fix: don't use "this stack", it can be anywhere
          if there is a file "model_SivaSivaPrefs.json" then
         get url ("binfile:model_SivaSivaPrefs.json")
         put it into url ("binfile:" & pathForPreferencesFile())
         set the defaultfolder to tDF
      else
         set the defaultfolder to tDF
         throw "error: can't find a valid preferences file"
      end if
   end if
end _makeSurePreferencesFileExists
