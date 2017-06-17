script "lib_SivaSiva"
## VARS 

global sConfigA
local sDownloadNewContent

constant kSHARED_LIBS_FOLDER = "libraries/"
constant kSHARED_ASSETS_FOLDER = "assets/"
constant kMODULES_FOLDER = "modules/"




--> GENERIC GLOBAL MOBILE

function isMobile
	return the environment is "mobile"
end isMobile

--> POST INSTALL CONTENT DOWNLOAD HANDLERS
--
/*
BR, June 6, 2017: some function should trigger the app to fetch any new content that can be legally download
with requiring a review process by Apple.  This could be on initial installation  and also for discreet updates to 
specific, non-executable, security save content.

Talk with Andre about methods.  
We probably put a 
        sivasiva_content.config
file on the server.
Some JSON with info on what to download
Fetch this somewhere in the app 
if the JSON tells us we have now content,
then proceed.  
OR use a simple ping file like

new-siva-content.txt  

with single word "true" or "false"

check this first.

*/

command sivasiva_checkNewContent
   # Ping server for updates?
   put "false"  into pBool # for now
   put pBool into sDownloadNewContent 
end sivasiva_checkNewContent

#use this in appropriate places where you may want updates later
# e.g. About this App; Privacy Policy are common use cases.

function sivasiva_IsThereNewContent  
   return sDownloadNewContent
end sivasiva_IsThereNewContent

  --> MOBILE ORIENTATION CHANGE HANDLERS
##

command sivasiva_InitOrientation orientationType
   -- try to avoid and specifically set fullscreenmode and mobile_SetAllowedOrientation for each module
   
   if the environment is not "mobile" then
      return false
   else
      set the fullscreenmode of this stack to "showAll" -- better for wider screens
      mobile_SetAllowedOrientation orientationType
   end if
end sivasiva_InitOrientation

command mobile_SetAllowedOrientation orientationType
   if the environment is not "mobile" then return empty
   
   switch orientationType
      case "portrait"
         put "portrait,portrait upside down" into allowedOrientations
         break
      case "landscape"
         put "landscape left,landscape right" into allowedOrientations
         break
      default -- allow all, ignoring face up/down
         put "portrait,portrait upside down,landscape left,landscape right" into allowedOrientations
   end switch
   mobileSetAllowedOrientations allowedOrientations
   return allowedOrientations
end mobile_SetAllowedOrientation

--> ### GLOBAL PATHS  GET AND SET

function path_HomeLocal
  if isMobile() then
    return specialFolderPath("resources") & slash
  else -- desktop
    set the itemdel to slash
    return (item 1 to -2 of the filename of stack "Siva-Siva-App") & slash
  end if
end path_HomeLocal

function path_Documents
   put specialFolderPath("documents") into  tPath
   put "/" after tPath
   return tPath
end path_Documents

function path_Assets
   put path_HomeLocal() into  tPath
   put "assets/" after tPath
   return tPath
end path_Assets

function path_Modules
   put path_HomeLocal() into  tPath
   put "modules/" after tPath
   return tPath
end path_Modules



#########  ALL The FOLLOWING not in USE
## If something here gets active, please move up above this comment.



--> Portal | Navigation | API
-- BR we should probably move all the nav function here from the  lib_

/*
This section is for default navigation handlers.
They can be overridden in a stack by placing copies of these handlers in the stack
for instance on the card
*/

command sivasiva_GoHomePortal
   portal_Link "home"
end sivasiva_GoHomePortal

command sivasiva_QueueContent btnObject, hiliteBoolean
   -- sivasiva_AddBookMark
   if the environment is "mobile" then
      dispatch "sivasiva_ToggleOrientation" to the target
   else
      dispatch "sivasiva_ToggleOrientation" to the target
   end if
end sivasiva_QueueContent

command sivasiva_AddFavorites
   portal_DisplayBookmarks
end sivasiva_AddFavorites

command sivasiva_SettingsGear
   display_Log
end sivasiva_SettingsGear

command display_Log
   portal_GoStack "Log"
end display_Log
 
function pingServer
   # call from any where to inform user and disable activities
   # that require internet access to our server or any the external service
   put url "https://www.himalayanacademy.com/ping.txt" into tOnline 
    return tOnLine
end pingServer

command sivasiva_SetStatusBarVis visBoolean
        if visBoolean then
            mobileShowStatusBar
        else
            mobileHideStatusBar
        end if        
 end sivasiva_SetStatusBarVis
    
    
 --> ANDRE'S ORIGINAL SCRIPTS
 
 /*
BR April 19, 2017  here is Andre's old loader stack script
which was put into the backscript on start up

*/



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

