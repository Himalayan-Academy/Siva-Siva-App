script "behavior_InitSivaSivaProject"
--> MetaData

license: GPLv3
name: behavior_InitSivaSivaProject
type: behavior
version: 0.2
by: David Bovill

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
-
local LocalArray


--> Events

on preOpenStack
   set the fullscreenmode of this stack to "showAll"
   -- start using this stack
   
   init_AppConfiguration -- load all libraries and configure app
   pass preOpenStack
end preOpenStack

function dev -- Thanks to Jacqueline Landman Gay @ HyperActive Software for this one.
   return the environment is "development"
end dev

function isMobile -- jg, for convenience
   return the environment is "mobile"
end isMobile



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

-- command init_LoadStackFilesFromConfiguration
--    -- AAG: loads the stackfiels from json 
--    put  jsonimport(field "json") into sConfigA

--    put sConfigA["stackfiles"] into tStackFilesA
--    repeat for each key k in tStackFilesA
--       put tStackFilesA[k] into tTempA
--       if tTempA["name"] is not in the stackfiles of stack "stackfiles tester" then
--          put tTempA["name"], tTempA["file"] & cr after tBuffer
--       end if
--    end repeat
--    put the stackfiles of stack "stackfiles tester" into tStartingList
--    if char -1 of tStartingList is not among the items of format("\n,\r") then
--       put cr after tStartingList
--    end if

--    set the stackfiles of stack "stackfiles tester" to (tStartingList & tBuffer)
-- end init_LoadStackFilesFromConfiguration

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
   --init_LoadStackFilesFromConfiguration
   
   
   -- then start using all required libraries
   init_LoadLibraries
   

   
   -- set things up for mobile geometry
   if the environment is "mobile" then 
      init_MobileGeometry
   end if
   portal_SetCurrentStack "Siva-Siva-App"
   send openPortalStack to me in 200 milliseconds
end init_AppConfiguration

command openPortalStack
   open stack "Siva-Siva-Portal"
   portal_Link "home"
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
   -- project_StartBackScriptsInFolder
   -- project_StartFrontScriptsInFolder
end init_LoadLibraries

function init_ListStacksToUse
   -- we start using both "library" stacks and "model" stacks
   -- due to bug in the files on Android we must use config to load libraries
   
   global sConfigA
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


-->Project | Start

command project_UseStacks stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_Library stackPath, shortFolder
   end repeat
   return stackPaths
end project_UseStacks

command project_StartBackScriptsInFolder projectFolder
   put projectFolder & "backscripts" & slash into standardFolder
   put sivasiva_ListStackPaths (standardFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_BackScript stackPath
   end repeat
   return stackPaths
end project_StartBackScriptsInFolder

command project_StartFrontScriptsInFolder projectFolder
   put projectFolder & "frontscripts" & slash into standardFolder
   put sivasiva_ListStackPaths (standardFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_FrontScript stackPath
   end repeat
   return stackPaths
end project_StartFrontScriptsInFolder

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

/*
BR April 19, 2017  here is Andre's old loader stack script
which was put into the backscript on start up

*/

--  constant kSHARED_LIBS_FOLDER = "shared/libs/"
-- constant kSHARED_ASSETS_FOLDER = "shared/assets/"
-- constant kMODULES_FOLDER = "modules/"

-- global sConfigA

-- command preOpenStack
--   -- For common actions in all modules. Modules can have custom
--   -- behaviors as well, just be sure to dispatch preOpenStack to
--   -- stack "loader" in the module's version of this handler.
--   set the defaultstack to the topstack
--   if isMobile() then 
--     set the fullscreenmode of this stack to "showAll"
--   end if
--   set the loc of this stack to the screenloc
--   if "API" is in the backscripts then scaleStackIfNeeded -- otherwise fails on loader launch
-- end preOpenStack

-- command loadAppConfiguration
--   setBasePath -- jg

--   if there is not a file "config.json" then
--     answer  "Can't find configuration json file!!!" with "OK"
--     exit to top
--   end if

--   get url "binfile:config.json"
--   put jsonImport(it) into sConfigA
--   logInfo"App configuration loaded..."
--   put true into sConfigA["initialized"]
--   _initializeDependencies
--   if not dev() then close me
--   goHome
-- end loadAppConfiguration

-- function getConfiguration pKey
--    return sConfigA[pKey]
-- end getConfiguration

-- function getModuleConfiguration pModule
--    return sConfigA["modules"][pModule]
-- end getModuleConfiguration

-- command loadModuleConfiguration pModule pData
--    put pData into sConfigA["modules"][pModule]
-- end loadModuleConfiguration

-- private command  _initializeDependencies
--   lock screen
--   set the itemdel to "/"
--   setBasePath -- jg
--   // load libraries
--   repeat for each key x in sConfigA["libraries"]
--     put  sConfigA["libraries"][x] into tLibrary
--     logInfo"Loading library" && tLibrary
--     start using (getPathForSharedLibraries() & tLibrary)
--   end repeat

--   // load behavior stacks
--   // be aware that those stacks are just loaded but not applied.
--   repeat for each key x in sConfigA["behaviors"]
--     put  sConfigA["behaviors"][x] into tStackPath
--     put token -1 of tStackPath into tStackName
--     replace ".livecode" with empty in tStackName

--     logInfo"Loading behavior" && tStackPath
--     --go stack (getPathForSharedLibraries() & tStackPath)
--     get the short name of stack (getPathForSharedLibraries() & tStackPath)
--     # still not available as a behavior in the ID  
--     # later we will have to set stack files  
--     # best practices TBD
--   end repeat

--   // load backscripts
--   repeat for each key x in sConfigA["backscripts"]
--     put  sConfigA["backscripts"][x] into tStackPath
--     put token -1 of tStackPath into tStackName
--     replace ".livecode" with empty in tStackName

--     logInfo"Loading backscript" && tStackPath
--     --go stack (getPathForSharedLibraries() & tStackPath)
--     --insert the script of stack tStackName into back
--     insert the script of stack (getPathForSharedLibraries() & tStackPath) into back
--   end repeat

--   // load frontscripts
--   repeat for each key x in sConfigA["frontscripts"]
--     put  sConfigA["frontscripts"][x] into tStackPath
--     put token -1 of tStackPath into tStackName
--     replace ".livecode" with empty in tStackName

--     logInfo"Loading frontscript" && tStackPath
--     --go stack (getPathForSharedLibraries() & tStackPath)
--     --insert the script of stack tStackName into front
--     insert the script of stack (getPathForSharedLibraries() & tStackPath) into front
--   end repeat
-- end _initializeDependencies

-- --command openExternalBehaviorStacks
-- --   # Behaviors are not available if the stack is not open
-- --   # we cannot set stack files for mobile
-- --   # must open them explicity here, good to do when we start up:
-- --   --put getPathForSharedLibraries() & "mobilecontrols.livecodescript" into tBehaviorStackPath
-- --   logRaw "info",tBehaviorStackPath
-- --  go invisible stack  tBehaviorStackPath

-- --end openExternalBehaviorStacks


-- command logRaw pLevel, pMessage
--   if the environment is not "development" then
--     // for now, lets not log stuff in Mobile -- jg needs to see these
--     if (the hilite of btn "jg android log" of cd 1 of stack "loader") then
--       put specialFolderPath("documents") & "/mobilelog.txt" into tFile
--       open file tFile for append
--       write pMessage & cr to file tFile
--       close file tFile
--       exit logRaw
--     end if
--   end if

--   put item -2 of line -3 of the executioncontexts into tCalledHandler
--   put item -1 of line -3 of the executioncontexts into tLineNumber
--   put the short name of (item 1 of line -3 of the executioncontexts) into tObjectReference

--   if char 1 of tCalledHandler is "_" then
--     put " (PRIVATE)" into tPrivateFlag
--   else
--     put empty into tPrivateFlag
--   end if

--   if pLevel is among the items of sConfigA["log_level"] then
--     put (the short date && the short time && \
      --           "[" & pLevel & "]" && \
      --           tObjectReference & "#" &tLineNumber && ">>>" && tCalledHandler  & tPrivateFlag && \
      --           ":" && pMessage & cr) \
      --           after url ("binfile:" & sConfigA["log_file"])
--   end if
-- end logRaw

-- command logInfo pMessage
--    logRaw "info", pMessage
-- end logInfo

-- command logError pMessage
--    logRaw "error", pMessage
-- end logError

-- command logFatal pMessage
--    logRaw "fatal", pMessage
-- end logFatal

-- ######## Utilities and Helper functions

-- ########### Utilities and Helper Functions ##########

-- function localPath  --###jg: will fail on desktop if loader stack isn't the defaultstack; ok on mobile
--   put specialFolderPath("resources") into  tPath
--   put "/" after tPath
--   return tPath
-- end localPath

-- function documentsPath
--   put specialFolderPath("documents") into  tPath
--   put "/" after tPath
--   return tPath
-- end documentsPath



-- command testMessagePath pMessage
--    answer pMessage with "OK"
-- end testMessagePath


-- command setBasePath
--    set the defaultfolder to getPathToLoaderStack()
-- end setBasePath

-- function getPathToLoaderStack
--   --  return item 1 to -2 of the effective filename of stack "loader" -- jg: fails on mobile
--   put the defaultstack into tOrigStack
--   set the defaultstack to me
--   put specialFolderPath("resources") into tSourcePath -- jg: works on desktop & mobile
--   set the defaultstack to tOrigStack
--   return tSourcePath
-- end getPathToLoaderStack

-- function getPathForSharedLibraries
--    return (getPathToLoaderStack() & "/" & kSHARED_LIBS_FOLDER)
-- end getPathForSharedLibraries

-- function getPathToSharedAssetsFolder
--    return (getPathToLoaderStack() & "/" & kSHARED_ASSETS_FOLDER)
-- end getPathToSharedAssetsFolder

-- function getPathToModulesFolder
--   return (getPathToLoaderStack() & "/" & kMODULES_FOLDER)
-- end getPathToModulesFolder


-- ## For Android test builds ##
-- ## okay to remove later ##

-- on savingStandalone -- pre-processss
--   -- if not an Android app, turn off android logging
--   put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
--   set the hilite of btn "jg android log" of cd 1 of me to tIsAndroid
--   set the vis of fld "logfld" of cd 1 of me to tIsAndroid
-- end savingStandalone

-- on standaloneSaved pFolder -- post-process
--   -- increase build number for next time, turn logging back on
--   -- Will be saved at next manual save, otherwise we don't want it anyway.
--   put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
--   if tIsAndroid then
--     put the cRevStandaloneSettings["android,version code"] of me into tBuildNum
--     add 1 to tBuildNum
--     set the cRevStandaloneSettings["android,version code"] of me to tBuildNum

--     set the hilite of btn "jg android log" of cd 1 of me to tIsAndroid
--     set the vis of fld "logfld" of cd 1 of me to false
--   end if
-- end standaloneSaved


-- on jgAndroidLog  --jg: temporary for testing; sent from Home btn in Home stack  --### REMOVE
--   if (the platform = "android") and (the hilite of btn "jg android log" of me) then 
--     put specialFolderPath("documents") & "/mobilelog.txt" into tFile
--     answer "Clear or view log:" with "Cancel" or "Clear" or "View"
--     if it = "view" then
--       answer url ("file:" & tFile)
--     else if it = "clear" then
--       put empty into url ("file:" & tFile)
--     end if
--   end if
-- end jgAndroidLog
