script "behavior_InitSivaSivaProject"
--> MetaData

license: GPLv3
name: behavior_InitSivaSivaProject
type: behavior
version: 0.2
by: David Bovill
but radically refactored by BR and Andre
 
/*
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

global  sConfigA
local LocalArray,sOnlineStatus
global sConfigA

--> Events

on preOpenStack
   set the fullscreenmode of this stack to "showAll"
   -- start using this stack
    # duplicates what's on the lib_SivaSiva, but we need to fire right away
   
   init_AppConfiguration -- load all libraries and configure app
   pass preOpenStack
end preOpenStack

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

/*
We aim to remove the need for this section eventually.
When the code is tested and stable we can stop loggin the initialisation routines
*/

command init_Logging
   --  relies on stack names so ensure the stackfiles is set properly
   -- we have to ensure the general purpose logging handlers are loaded first
   start using stack "model_SivaSivaLog"
   log_Clear
   
   /*
   -- set nested behavior for logging. This is needed as scriptonly stack do not remember their behaviors
   -- we could remove this step if we move this code back to the card script
   log_Append "Before behavior_SivaSivaLogging"
   put exists (stack "behavior_SivaSivaLogging") into stackExists
   if stackExists then
      put the name of stack "behavior_SivaSivaLogging" into loggingBehaviorObject
      set the behavior of stack "behavior_InitSivaSivaProject" to loggingBehaviorObject -- not "me". We have to set the nested bheavior of the "behavior_InitSivaSivaProject" here.
      log_Append "Set behaviors"
   end if
   log_Append stackExists
   */
   
   log_SetLevelList "all"
   log_Append "End of init_Logging"
end init_Logging


--> SivaSiva | Init

function init_GetStatus
   put "lib_SivaSiva" is among the lines of the stacksinuse into someBoolean
   return someBoolean
end init_GetStatus

command init_LoadStackFilesFromConfiguration
   -- AAG: loads the stackfiels from json 
   -- put  jsonimport(field "json") into sConfigA
   
   put sConfigA["stackfiles"] into tStackFilesA
   repeat for each key k in tStackFilesA
      put tStackFilesA[k] into tTempA
      if tTempA["name"] is not in the stackfiles of stack "Siva-Siva-App" then
         put tTempA["name"]&comma& tTempA["file"] & cr after tBuffer
      end if
   end repeat
   put the stackfiles of stack "Siva-Siva-App" into tStartingList
   if char -1 of tStartingList is not among the items of format("\n,\r") then
      put cr after tStartingList
   end if
   
   set the stackfiles of stack "Siva-Siva-App" to (tStartingList & tBuffer)
   
end init_LoadStackFilesFromConfiguration

command init_AppConfiguration
   -- called by the "preOpenStack" of the Siva-Siva-App's first card script
   -- if init_GetStatus() is true then return false
   -- the first thing we must do is know where the top-level project is
   start using stack "model_SivaSivaFiles"
   -- then
   init_Logging
   
   -- due to bug in the files on Android we must use config to load libraries
   start using stack "model_SivaSivaConfig"
   
   init_LoadJsonConfig
   
   -- reload the stackfiles property
   init_LoadStackFilesFromConfiguration
   
   
   -- then start using all required libraries
   init_LoadLibraries
   
   
   
   -- set things up for mobile geometry
   if the environment is "mobile" then 
      init_MobileGeometry
   end if
   
   -- get long id's for global custom controls on card "custom-controls
   
   init_StoreControlsIds
   
   # now create local data and media hierachy
   
   init_CreateLocalFolders
   

   portal_SetCurrentStack "Siva-Siva-App"
   send openPortalStack to me in 200 milliseconds
   send  testConnection to me in 500 milliseconds
 
end init_AppConfiguration

on init_StoreControlsIds
     put the long id of group "share-ui" of card "share-ui" of stack "lib_CustomControls" into sConfigA["shareControl"]
end init_StoreControlsIds

on testConnection
   connectivity_PingServer
end testConnection

command openPortalStack
   open stack "Siva-Siva-Portal"
   portal_Link "home"
   
   # app will halt at this point  so now is a good
   # time to check for updates on a new session
   # check for news first
   news_Fetch
   newcontent_Check
end openPortalStack

command  init_LoadLibraries  
   put init_ListStacksToUse() into stackNames   
   repeat for each item stackName in stackNames
      if there is a stack stackName then
         start using stack stackName
      else
         -- AAG: fix loading of stacks
         put the defaultFolder into tDF
         set the itemdel to "/"
         set the defaultFolder to item 1 to -2 of the effective filename of stack "Siva-Siva-App"
         set the itemdel to comma
         put stackName && "loading"
         switch
            case ("behavior" is in stackName)
               put "behaviors/" & stackName & ".livecodescript" into stackName
               break
            case ("model" is in stackName)
               put "models/" & stackName & ".livecodescript" into stackName
               break  
            case ("lib" is in stackName)
               put "libraries/" & stackName & ".livecodescript" into stackName
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
   
   -- if we can get the files working on Android we should use the handlers below instead
   put project_ListFolderStacks ("libraries") into stackPaths
   project_UseStacks stackPaths
   put project_ListFolderStacks ("models") into stackPaths
   project_UseStacks stackPaths
end init_LoadLibraries

function init_ListStacksToUse
   -- we start using both "library" stacks and "model" stacks
   -- due to bug in the files on Android we must use config to load libraries
   

   put sConfigA ["models"] & comma & sConfigA ["libraries"] into stackNames
   -- put "lib_SivaSiva,lib_SivaSivaPortal,lib_MobileControls,model_SivaSiva,model_SivaSivaConfig" into stackNames
   return stackNames
end init_ListStacksToUse
 
command init_MobileGeometry
   -- see "initializeInterfaceDefaults"
   -- set the fullscreenmode of this stack to "showAll"
   mobileSetAllowedOrientations "portrait,portrait upside down" -- lock to both portrait orientations, change later for certain modules
   if the platform = "iphone" then
      iphoneSetAudioCategory "playback" -- play when suspended or screen locked; Android doesn't need this
   end if
end init_MobileGeometry

command init_CreateLocalFolders
   # We want have folders correponding to app pkg content and also to the web server
   # virtually all local content that is specific to the app will be in assets and modules
   # global libraries, modules, behaviors only update when the app is updated
   # for media we just map to the web server media folder for all types
   
   put specialFolderPath("documents") & "/"  into tLocalFolderRoot # everything goes here
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
   
   put "audio,books,art,slideshows,video" into tTopMediaFolders
   
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


-->Project | Start

command project_UseStacks stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_Library stackPath, shortFolder
   end repeat
   return stackPaths
end project_UseStacks


command isBehaviorActive
   answer "Yes, the behavior was found." with "Yes" or "No"
end isBehaviorActive


-->Project | Start | Load

/*
Here we split out individual loading of required components.
For legibility and logging.
They must be public handlers for this to work.
*/

command load_Library stackPath, pShortFolder
   start using stack stackPath
end load_Library

command load_FrontScript stackPath
   insert the script of stack stackPath into front
end load_FrontScript

command load_BackScript stackPath
   insert the script of stack stackPath into back
end load_BackScript


--> Deps

-- function sivasiva_ListStackPaths someFolder  
put mobile_ListLongFiles (someFolder, "Siva-Siva-App") into longFiles
repeat for each line stackFilePath in longFiles
   if there is a stack stackFilePath then
      put stackFilePath & CR after stackFilePaths
   end if
end repeat
delete char -1 of stackFilePaths
return stackFilePaths
end sivasiva_ListStackPaths

-- function mobile_ListLongFiles someFolder, homeStackName
put mobile_ListShortFiles (someFolder, homeStackName) into shortFiles
repeat for each line shortFile in shortFiles
   if char 1 of shortFile is "." then next repeat
   put someFolder & shortFile & CR after longFiles
end repeat
delete char -1 of longFiles
return longFiles
end mobile_ListLongFiles

-- function mobile_ListShortFiles someFolder, homeStackName
-- bug: this function includes hack to fix Livecode bug on Android by setting the defaultstack
-- requires Livecode 8.1 or greater
if there is not a folder someFolder then return empty

put the defaultstack into oStack
set the defaultstack to homeStackName
-- put files (someFolder) into shortFiles -- this is not working on Android with LC 8.2 rc2
put the files into shortFiles -- this fixes things
set the defaultstack to oStack

-- answer there is a folder someFolder & CR & shortFiles
return shortFiles
end mobile_ListShortFiles

