script "preferences"
/**
* Preferences Library (aka User Settings)
*
* This library provides commands and functions to store user defined settings
*
*/

command setPref pKey, pValue
   _makeSurePreferencesFileExists
   put url ("binfile:" & pathForPreferencesFile()) into tJSON
   put jsonImport(tJSON) into tPreferencesA
   put pValue into tPreferencesA[pKey]
   put jsonExport(tPreferencesA) into tJSON
   put tJSON into url  ("binfile:" & pathForPreferencesFile())
end setPref

function getPref pKey
   _makeSurePreferencesFileExists
   put url ("binfile:" & pathForPreferencesFile()) into tJSON
   put jsonImport(tJSON) into tPreferencesA
   if the keys of tPreferencesA is empty or pKey is not among the lines of the keys of tPreferencesA then
      return false
   else
      return tPreferencesA[pKey]
   end if
end getPref

function pathForPreferencesFile
   if the environment is mobile then 
      return specialfolderpath("documents") & "/preferences.json"
   else
      return specialfolderpath("temporary") & "/preferences.json"
   end if
end pathForPreferencesFile

private command _makeSurePreferencesFileExists
   if there is not a file pathForPreferencesFile() then
      put the defaultfolder into tDF
      set the itemdel to "/"
      set the defaultfolder to item 1 to -2 of the effective filename of this stack
      if there is a file "preferences.json" then
         get url ("binfile:preferences.json")
         put it into url ("binfile:" & pathForPreferencesFile())
         set the defaultfolder to tDF
      else
         set the defaultfolder to tDF
         throw "error: can't find a valid preferences file"
      end if
   end if
end _makeSurePreferencesFileExists
