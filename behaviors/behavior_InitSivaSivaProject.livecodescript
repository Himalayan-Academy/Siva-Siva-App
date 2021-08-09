script "behavior_InitSivaSivaProject"
--> MetaData
/*
license: GPLv3
name: behavior_InitSivaSivaProject
type: behavior
version: 0.2
by: David Bovill
but radically refactored by BR and Andre


Here we keep all initilisation code for the Siva-Siva-App.
This code originates from the Siva-Siva-App home card script.
We therefore set the behavior of the home card (first card) to this stacks script.

We use a behavior to take advantage of version control that we get with scriptonly stacks.

== Future ==
When this code is fully robust and tested, and no longer changing / evolving,
we can move it back to the card script. That way we avoid nested bahaviors

The preOpenStack handler (which is sent to the card), initialises all project defaults.
This includes loading all necessary libraries.

This card could be exactly the same as the loader stack, and not be shown on mobile.
Now we place the "sivasivahome" stacks contents, and separate any development testing and authoring into a new project "sivasiva_Tools"

We can now experiment with:

1) Using the new "Sivasiva Home" view to navigate to all module portal screens by setting it's "portal_Array"
2) Standardising navigation across all modules
3) Book marking and "hoisting"
4) Integration with the responsive "Sivasiva Browser" view.
*/

--> Variables

global sConfigA
local LocalArray,sHome,sOnlineStatus,sNow,sThen
local sInitialized = false

--> Events

on preOpenStack
   if not sInitialized then
      set the fullscreenmode of this stack to "showAll"
      -- start using this stack
      # duplicates what's on the lib_SivaSiva, but we need to fire right away
      --breakpoint
      put the milliseconds into sThen
      put specialFolderPath("resources") into sHome
      logging "---- init_AppConfiguration ----"
      init_AppConfiguration -- load all libraries and configure app
      put true into sInitialized
      pass preOpenStack
   end if
end preOpenStack

command init_AppConfiguration
   local someJSON, tPlatform, tAction, pData, tStart
   -- called by the "preOpenStack" of the Siva-Siva-App's first card script
   put the milliseconds into tStart
   
   set the logMessage to "log"
   
   put url ("binfile:" & sHome& "/" & "Siva-Siva-App.json") into someJSON 
   put jsonImport (someJSON) into sConfigA
   
   # we have simple path scripts in the main backscript.  We load the first
   # this till deprecate all of David codes non-sense code in 
   
   logging "finish loading json"
   
   init_LoadStackFilesFromConfiguration
   
   start using stack "lib_SivaSiva"
   
   logging "start loading libraries"
   
   init_LoadLibraries
   --breakpoint
   logging "end loading libraries"
   
   -- get long id's for global custom controls on card "custom-controls
   logging "start StoreControlsIds"
   init_StoreControlsIds
   logging "end StoreControlsIds"
   # now create local data and media hierachy
   
   logging "start CreateLocalFolders"
   init_CreateLocalFolders
   logging "end CreateLocalFolders"
   
   logging "start Fonts"
   init_Fonts
   logging "end  Fonts"
   
   fetchNavigationMap # we need it for the tree menu, but call once
   
   -- cacheGlobalNavImages
   
   set the socketTimeoutInterval to 2000   # we wait 2 seconds before informing user about connection issues.
   
   portal_SetLastStack "Siva-Siva-App"
   
   logging "open Portal Stack"
   send "openPortalStack" to me in 50 milliseconds
   set the effectrate to 500
   
   tsNetLibUrlReuseConnection false
   set the socketTimeoutInterval to 2000
   
   send "tracking_UploadData" to stack "model_SivaSivaTracking" in 2 seconds
   put platform() into tPlatform
   put "init/launch"into tAction
   put the screenrect into pData["screenRect"]
   put the machine into pData["device"]["hardware"]
   if platform() = "android" then
      put mobileBuildInfo("MODEL") into  pData["device"]["model"]
      put mobileBuildInfo("MANUFACTURER") into  pData["device"]["madeby"]
   end if
   mobileRectSet
   send  "tracking_RecordActivity SivaSivaApp,tAction,pData" to stack "model_SivaSivaTracking" in 3 seconds
   
   
   -- AAG enable or disable network tracer
   if the cNetworkTracerEnabled of stack "Siva-Siva-App" is true then
      ntEnableNetworkTracer
   else
      ntDisableNetworkTracer
   end if
   logging "---- time spent initializing app:" && (the milliseconds - tStart) &"ms ----"
end init_AppConfiguration



command init_LoadStackFilesFromConfiguration
   local tStackFilesA, tTempA, tBuffer, tStartingList
   -- AAG: loads the stackfiles from json 
   -- put  jsonimport(field "json") into sConfigA
   
   put sConfigA["stackfiles"] into tStackFilesA
   repeat for each key k in tStackFilesA
      put tStackFilesA[k] into tTempA
      if (tTempA["name"] & comma) is not in the stackfiles of stack "Siva-Siva-App" then
         put tTempA["name"]&comma& tTempA["file"] & cr after tBuffer
      end if
   end repeat
   put the stackfiles of stack "Siva-Siva-App" into tStartingList
   if char -1 of tStartingList is not among the items of format("\n,\r") then
      put cr after tStartingList
   end if
   
   set the stackfiles of stack "Siva-Siva-App" to (tStartingList & tBuffer)
   
end init_LoadStackFilesFromConfiguration



command init_Fonts
   start using font file (path_Assets() & "fonts/NotoSans-Regular.ttf")
   start using font file (path_Assets() & "fonts/NotoSans-Medium.ttf")
   start using font file (path_Assets() & "fonts/NotoSans-Bold.ttf")
   start using font file (path_Assets() & "fonts/NotoSans-BoldItalic.ttf")
   start using font file (path_Assets() & "fonts/NotoSans-Black.ttf")
   start using font file (path_Assets() & "fonts/NotoSans-BlackItalic.ttf")
end init_Fonts


on init_StoreControlsIds
   put the long id of group "viewLogging" of card "viewLogControl" of stack "lib_CustomControls" into sConfigA["viewLogging"]
   put the long id of group "share-ui" of card "share-ui" of stack "lib_CustomControls" into sConfigA["shareControl"]
   put the long id of group "answerDlgGrp" of card "answerDlgGrp" of stack "lib_CustomControls" into sConfigA["answerDialog"]
   put the long id of group "bottomToast" of card "dialog_CustomMsg" of stack "lib_CustomControls" into sConfigA["bottomToast"]
   put the long id of group "searchControls" of card "search" of stack "lib_CustomControls" into sConfigA["search"]
   put the long id of group "sound-is-playing" of card "sound-is-playing" of stack "lib_CustomControls" into sConfigA["soundIsPlaying"]
end init_StoreControlsIds

command openPortalStack
   send "init_DocumentFiles" to me in 5 seconds
   open stack "Siva-Siva-Portal"
   if the environment is not "development" then
      hide stack "Siva-Siva-App"
   end if
   # app will halt at this point  so now is a good
   # time to check for updates on a new session
   # check for news first
   news_Fetch
   newcontent_Check
end openPortalStack

command  init_LoadLibraries
   local stackNames, tDF
   
   put init_ListStacksToUse() into stackNames   
   filter items of stackNames without"animationEngine*" # should load onlyl when when needed
   
   repeat for each item stackName in stackNames
      logging "loading" && stackName
      if there is a stack stackName then
         start using stack stackName
      else
         -- AAG: fix loading of stacks
         put the defaultFolder into tDF
         set the itemdel to "/"
         set the defaultFolder to item 1 to -2 of the effective filename of stack "Siva-Siva-App"
         set the itemdel to comma
         --put stackName && "loading"
         switch
            # Always do the libraries first as the may be deps in them required by
            # other behaviors and models
            case ("lib" is in stackName)
               put "libraries/" & stackName & ".livecodescript" into stackName
               break
               --case ("behavior" is in stackName)
               --put "behaviors/" & stackName & ".livecodescript" into stackName
               --break
            case ("model" is in stackName)
               put "models/" & stackName & ".livecodescript" into stackName
               break  
            default
               put "modules/" & stackName & ".livecode" into stackName
               break   
         end switch   
         if there is a file stackName then
            start using stackName
         else
            answer error "can't find" && stackName
         end if  
         set the defaultFolder to tDF       
      end if
   end repeat
   -- answer the stacksinuse
   return true
   
end init_LoadLibraries

function init_ListStacksToUse
   local stackNames
   -- we start using both "library" stacks and "model" stacks
   -- due to bug in the files on Android we must use config to load libraries
   #Libries must come first because there are dependencies in the
   # lib_SivaSiva 
   
   put sConfigA ["libraries"] & comma & sConfigA ["models"]  into stackNames
   -- put "lib_SivaSiva,lib_SivaSivaPortal,lib_MobileControls,model_SivaSiva,model_SivaSivaConfig" into stackNames
   return stackNames
end init_ListStacksToUse


command init_CreateLocalFolders
   local tLocalFolderRoot, tTopLocalFolders, tTopAssetsFolders, tTopModulesFolders
   local tTopMediaFolders, tTopAudioFolders, tTopAudioAuthorFolders, tTopAudioSongFolders
   local tTopAudioGenreFolders
   # We want have folders correponding to app pkg content and also to the web server
   # virtually all local content that is specific to the app will be in assets and modules
   # global libraries, modules, behaviors only update when the app is updated
   # for media we just map to the web server media folder for all types
   
   put path_Documents()  into tLocalFolderRoot 
   
   # everything goes here path_Documents() alway has a slash 
   # these top level will contain almost everything.
   # jnanam.sqlite and sivasivapreferences are outside on the top level.
   
   put "assets,modules,media" into tTopLocalFolders
   
   repeat for each item x in tTopLocalFolders
      check_CreateFolder (tLocalFolderRoot & x) 
   end repeat
   
   # Second Level... 
   # first assets
   # but note that there are sub folders here 
   # which we are not setting up for now.   
   put sivasiva_ListAssetsFolders() into tTopAssetsFolders
   repeat for each line x in tTopAssetsFolders
      check_CreateFolder (tLocalFolderRoot & "assets/" & x) 
   end repeat
   
   # Second Level... 
   # modules
   
   put sivasiva_ListModuleFolders() into tTopModulesFolders
   repeat for each line x in tTopModulesFolders
      check_CreateFolder (tLocalFolderRoot & "modules/" & x) 
   end repeat
   
   
   # next we build the matching hierarchy for the web media folder
   # most important will be books and audio
   
   put "audio,books,art,slideshows,stories,video" into tTopMediaFolders
   
   repeat for each item x in tTopMediaFolders
      check_CreateFolder (tLocalFolderRoot & "media/" & x) 
   end repeat
   
   # each media type maps to a different hierarchy
   # books is easy  1 folder per file ID, so we don't need to create anything here
   # audio is more complex
   
   put "inspired-talks,books,chants,songs,shum" into tTopAudioFolders
   
   repeat for each item x in tTopAudioFolders
      check_CreateFolder (tLocalFolderRoot & "media/audio/" & x) 
   end repeat
   
   #Audio books, chants and shum map to subfolders 1 for each file id in the item table
   
   # for inspired talks, we have three authors
   # the listen module needs to pass the year 
   # and check_Create that year folder as needed
   
   put "bodhinatha,gurudeva,sadasivanatha" into tTopAudioAuthorFolders
   
   repeat for each item x in tTopAudioAuthorFolders
      check_CreateFolder (tLocalFolderRoot & "media/audio/inspired-talks/" & x) 
   end repeat
   
   # for songs we have a mor complex hierarchy
   
   put "bhajan,bhakti-gitam,natchintanai,stotram,tirumurai" into tTopAudioSongFolders
   
   repeat for each item x in tTopAudioSongFolders
      check_CreateFolder (tLocalFolderRoot & "media/audio/songs/" & x) 
   end repeat
   
   put "ganesha,guru,muruga,other,siva,vedic" into tTopAudioGenreFolders
   
   # used by both bhajan and Bhakti-gitam
   
   repeat for each item x in tTopAudioGenreFolders
      check_CreateFolder (tLocalFolderRoot & "media/audio/songs/bhajan/" & x) 
      check_CreateFolder (tLocalFolderRoot & "media/audio/songs/bhakti-gitam/" & x) 
   end repeat
   
end init_CreateLocalFolders

command init_DocumentFiles
   local tLocalJson, tLocalArray, tLocalSeconds, tServerSeconds
   local tServer, tRemoteSeconds,tServerArray, tRemoteServer
   # Here is the installing app 
   if  there is a file (path_Documents()  & "modules/stories/stories.json") then
      # do nothing
      --      put "do nothing"
   else
      put url ("binfile:" & path_Modules() & "stories/stories.json") into \
            url  ("binfile:" &  path_Documents()  & "modules/stories/stories.json")
   end if
   
   # Here is getting the time difference > between the json on the server
   
   put url  ("binfile:" &  path_Documents()  & "modules/stories/stories.json") into tLocalJson
   put JSONToArray(tLocalJson) into tLocalArray
   put tLocalArray["lastUpDate"]["theTime"] into tLocalSeconds
   if tLocalSeconds is not a number then
      put 0 into tLocalSeconds
   end if
   
   --breakpoint
   try
      put url ("https://dev.himalayanacademy.com/media/stories/stories.json") into tServer
      put JSONToArray(tServer) into tServerArray
      put tServerArray["lastUpDate"]["theTime"] into tRemoteSeconds
   catch errorStatement
      
   end try 
   
   if tRemoteSeconds > tLocalSeconds then
      put tServer  into url  ("binfile:" &  path_Documents()  & "modules/stories/stories.json")
   end if
   
   
end init_DocumentFiles




-->Project | Start

command project_UseStacks stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_Library stackPath
   end repeat
   return stackPaths
end project_UseStacks


command isBehaviorActive
   answer "Yes, the behavior was found." with "Yes" or "No"
end isBehaviorActive

function dev -- Thanks to Jacqueline Landman Gay @ HyperActive Software for this one.
   return the environment is "development"
end dev

function isMobile -- jg, for convenience
   return the environment is "mobile"
end isMobile

command testBehavior 
   put specialFolderPath("resources")
end testBehavior


--> SivaSiva | Init | Logging


command Logging pLogMessage
   local tInterval
   
   put the milliseconds into sNow
   if sThen is not a number then
      put sNow into sThen
   end if
   put sNow - sThen into tInterval
   log (pLogMessage  &&  "(+"  &  tInterval &")")
   put sNow into sThen
end logging

-- this version is only available during intialization.
private command log pLog 
   set the itemdel to slash
   put item 1 to -2 of the effective filename of stack "Siva-Siva-App" into tPath
   
   set the itemdel to comma
   put parseContext(line -2 of the executionContexts) into tContextA
   if tContextA["handler"] is "Logging" then
      put parseContext(line -3 of the executionContexts) into tContextA
   end if
   if tContextA["behavior"] is empty then
      put tContextA["object"] into tObject
   else
      put tContextA["behavior"] into tObject
   end if
   put tContextA["handler"] into tHandler
   put tContextA["line"] into tLineNumber
   
   if the environment is "development" then
      put textEncode(the merge of "INIT : [[the short name of tObject]] ([[tHandler]]:[[tLineNumber]]) -> [[pLog]]" & cr, "utf8") after url ("binfile:" & tPath & "/siva-siva.log")
   else
      put textEncode(the merge of "INIT : [[the short name of tObject]] ([[tHandler]]:[[tLineNumber]]) -> [[pLog]]" & cr, "utf8")
   end if
end log

-- this function is here because it is needed for initialization.
private function parseContext pContextLine
   local tKey = "object", tContextA
   
   repeat for each item tItem in pContextLine
      if tContextA[tKey] is not empty then
         put comma after tContextA[tKey]
      end if
      put tItem after tContextA[tKey]
      
      switch tKey
         case "object"
            if exists(tContextA[tKey]) then
               put "handler" into tKey
            end if
            break
         case "handler"
            put "line" into tKey
            break
         case "line"
            put "behavior" into tKey
            break
      end switch
   end repeat
   return tContextA
end parseContext




