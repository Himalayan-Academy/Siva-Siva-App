script "lib_SivaSiva"
## VARS 

global sConfigA
local sThereIsNewContent,sOnlineStatus,sLoaderImage,sNewNews

constant kSHARED_LIBS_FOLDER = "libraries/"
constant kSHARED_ASSETS_FOLDER = "assets/"
constant kMODULES_FOLDER = "modules/"


--> GENERIC GLOBAL MOBILE

function isMobile
   return the environment is "mobile"
end isMobile

command sivasiva_SetStatusBarVis visBoolean
   if visBoolean then
      mobileShowStatusBar
   else
      mobileHideStatusBar
   end if        
end sivasiva_SetStatusBarVis

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

command news_Fetch
   # path to news 
   put path_Documents()&"assets/info/siva-app-news.html" into tLocalNewsFile
   
   # fetch the latest news on server
   put url "https://www.himalayanacademy.com/media/apps/sivasiva/siva-app-news.html" into tServerNews
   
   # check for the existence of news file locally
   # get date data 

   
   if ( there is a file( tLocalNewsFile) ) then # parse it for the date
      set the htmltext of templateField() to url ("file:/"& tLocalNewsFile)
      put line 1 of templateField() into tLocalNewsDate
      convert tLocalNewsDate to seconds
   else
      put empty into tLocalNewsDate
   end if 
   
   set the htmltext of templateField() to tServerNews
   put line 1 of templateField() into tLatestNewsDate
   convert tLatestNewsDate to seconds
   
   # compare dates
   
   if tLocalNewsDate = tLatestNewsDate then
      put "false" into sNewNews
      # do nothing
   else 
       # save it
      put tServerNews into url ("file:/"&tLocalNewsFile)
     dispatch "dialog_CustomMsg" to the topstack with "You have news!"
      put "true" into sNewNews
   end if
   # reset the templateField just in case
   set the htmlText of templateField() to empty
end news_Fetch

function news_Check
   return sNewNews
end news_Check

command news_UserReadNews
   put "false" into sNewNews
end news_UserReadNews

command newcontent_Check
   # Ping server for updates?
   put "false"  into pBool # for now
   put pBool into sThereIsNewContent 
end newcontent_Check

#use this in appropriate places where you may want updates later
# e.g. About this App; Privacy Policy are common use cases.

function newcontent_IsThere
   return sThereIsNewContent
end newcontent_IsThere




on ______PATHS_NAV
end ______PATHS_NAV
   
--> ### GLOBAL PATHS  GET AND SET / NAVIGATON

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
   # remember not to precede path strings to follow with a slash in your 
   # handlers, double //   works on desktop but not on mobile, especially not on Android   
   if  not isMobile() then
      # We may have a desktop version in which case we want all content related to the app to go into a proper folder
      # in the Users/SomeUser/Documents
      put "SivaSivaApp/" after tPath 
      if not (there is a folder tPath) then  # need for first run ... 
         create folder tPath
      end if
   end if  
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

--------------------------------
-- path_IsFileOnDisk/path_FileForURL
-- DESCRIPTION:
-- Called from any stack that wants to use local media
-- or download it if not available
-- see init script which sets up folders in /media to match
-- the web server; CMS in app is the same:
-- files are in a folder with the  fileID from the database.
-- if the content is unique to SivaSiva app, then it goes to
-- /assets or /modules # the module that needs it
-- All other content maps to DocRoot/media
-- PARAMS:
-- you must pass the full path from DOCROOT
-- must not begin with "http:" 
-- see  getMediaURL function in lib_SivaSivaMedia
-- which is use to get a fully qualified URL, or path relative docroot


# these are used by by different modules in conjunction 
# with the behavior_Download to play/use local media or 
# download it if the context offers that option. 
# these functions are agnostic about that 
# we want to end up with paths beginning with
# /media (from public_html) or /assets, /modules (from /media/apps/sivasiva)

function path_isFileOnDisk pURL  
  put path_FileFromURL(pURL) into tFilePath
   if there is a file tFilePath then
      return (true,tFilePath)
   end if
   return false
end path_isFileOnDisk

function path_FileFromURL pURL
   put path_Documents() into tDF
   set the itemdel to "/"
   # make relative:
   if  item 1 of pURL contains "http" then
      delete item 1 to 3 of pURL # now at Docroot (public_html) on the server
   end if
   
   # later we download app unique content as a zip file here and unpack it
   
   
   put item -1 of pURL into tFile
   
   put (the number of items of pURL)-1 into tFolderCount
   repeat with i = 1 to tFolderCount
      put item 1 to i of pURL into tFolderToCreate
      if there is no folder (tDF&"/"& tFolderToCreate) then
         create folder (tDF&"/"& tFolderToCreate)
      end if
   end repeat
   return tDF & tFolderToCreate & "/" & tFile   into tCheckURL
   put tCheckURL
   return tCheckURL # inclues filename after last interaion.
end  path_FileFromURL


on backkey # need for android
   if the short name of this stack is "journal" then
      send mouseup to widget "go-back"
   else
      
      send mouseup to widget "go-home-portal"
   end if
end backkey

--> ### GLOBAL CATEGORY AND REALM TRACKING
-- use of the journal requires we know certain things about
-- what the user did before and it is often related to some category
-- or "realm"   ; there is a challenge to track these in the local props or local vars of 
-- stacks that are opening and closely, so we do it here.


on setCurrentRealm pRealm
   put pRealm into sConfigA["currentRealm"]
end setCurrentRealm

--> TEXT UTILITIES 
# maybe this should be in it's own "Utils" library. 
# maybe later if we need one; can move then

function text_TitleCase pString
   put toLower(pString) into pString # normalize all chars first
   
   # assume words separated by spaces
   
   repeat for each word x in pString
      put toUpper(char 1 of x) into char  1 of x
      put x & space after tTitleCasedString
   end repeat
   delete char -1 of tTitleCaseString
   return tTitleCasedString
   
end text_TitleCase


# relates to navigation shoulf move with these handlers later:
# handles both stacks and portal names
constant kONLINECONTENT= "surprise,website,look,view_SivaSivaBrowser"


on ______CONNECTIVITY HANDLERS   
end ______CONNECTIVITY
   

Local sPingURL,sServerAttempts # sURLStatusLog

on connectivity_PingServer
   unload URL "https://www.himalayanacademy.com/ping.txt" 
  put 0 into sServerAttempts
   # Logging: put empty into sURLStatusLog
   put "https://www.himalayanacademy.com/ping.txt" into sPingURL
   load url sPingURL
   dispatch "connectivity_UpdateStatus" to stack "lib_SivaSiva"
end connectivity_PingServer

on connectivity_UpdateStatus
   if URLStatus(sPingURL) = "cached" then
      put "true" into sOnLinestatus
   else
      put URLStatus(sPingURL)  into tURLStatus
      if (sServerAttempts > 10) and URLStatus(sPingURL)<> "cached" then
         put tURLStatus into sOnLinestatus
         dialog_CustomMsg "Offline or Low Bandwidth"     
         # do stuff here to block access  or show indicators.
         # keep checking but don't hog the CPU... 
         send "connectivity_PingServer" to stack "lib_SivaSiva" in 1 seconds
      else
         # Logging
         --       put URLStatus(sPingURL) & cr after sURLStatusLog
         --       put sURLStatusLog
         add 1 to sServerAttempts
          dialog_CustomMsg "Connecting"
         send "connectivity_UpdateStatus" to stack "lib_SivaSiva" in 800 milliseconds
      end if
   end if
end connectivity_UpdateStatus

# Use this in the module so we don't ping the server constantly.

function connectivity_GetStatus
   return sOnLineStatus
end connectivity_GetStatus

function connectivity_NotAvailable cardOrStackObject
   if sOnlineStatus = "true" then # nothing to do here.. no checks required
      return "true"
   else
      repeat for each item x in kONLINECONTENT
         if (cardOrStackObject contains x) then
            dialog_CustomMsg "Offline or Low Bandwidth"
            return "offline"
            # FYI we are letting users open the "Listen" stack even though
            exit repeat
         end if
      end repeat
   end if
   # risking queuing up multiple requests
end connectivity_NotAvailable


on _____VISUALSandUI
end _____VISUALSandUI

on moveGrp pGrpName, pHorz, pVert, pSpeed -- use move instead of visual effect to prevent Android issues
  -- pass 0 pHorz for vertical move and 0 to pVert to horizontal move
  put pHorz,pVert into tPt
  move grp pGrpName relative tPt in pSpeed milliseconds
end moveGrp

# you cannot delete a control from it's own behavior
# so this:

command display_Log
   portal_GoStack "Log"
end display_Log
 

#########  ALL The FOLLOWING not in USE
## If something here gets active, please move up above this comment.


    
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


on errorDialog pExecutionError, pParseError

end errorDialog
