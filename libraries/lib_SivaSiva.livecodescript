script "lib_SivaSiva"

global sConfigA
local sThereIsNewContent,sOnlineStatus,sLoaderImage,sNewNews,sStopRunningAudio
local sSivaSivaNavigation

constant kSHARED_LIBS_FOLDER = "libraries/"
constant kSHARED_ASSETS_FOLDER = "assets/"
constant kMODULES_FOLDER = "modules/"
constant kBRAND_IMAGE_CHANGE= 3600  # for production change to 1 hour 3600 sec
constant cMoveSpeed = 400 -- DTB
constant cGroupMoveDistance = 400 -- DTB
constant cRemoteNewsFile="siva-app-news.html"


ON ___INIT
end ___INIT


on libraryStack
   mobileRectSet
   fetchNavigationMap
   if the uBuildMode of  stack "Siva-Siva-App" is "release" then
      set the logMessage to empty
   else
      set the logMessage to "log"
   end if
   
end libraryStack

# disable ntinfo
command ntInfo
   # nothing	
end ntInfo

--> GENERIC GLOBAL MOBILE

function isMobile
   return the environment is "mobile"
end isMobile
  
/* this command is deprecated it has a useful model for timing
on setUpBrandImage
   # we can use this scheduler to fetch News which was previously 
   # piling up the pending messages queue
   News_Fetch
   
   local tNextChangeUp, tBrandImage, tTotalBrandImages, tLastRunDate
   # we have to save the number, this was on next start up
   # it will change
   --breakpoint
   
   # we don't want to go to disk every thing we hit the card
   # therefore check the cache, if we have reach tNextChangeUp time
   # exit to top
   
   put getcache("NextBrandImageChange") into tNextChangeUp
   convert tNextChangeUp to seconds
   if tNextChangeUp > (the seconds) then
      # BM: if we exit to top, then the image never gets loaded unless changed
      exit setUpBrandImage
   end if
   
   put getPref ("preferences/modules/portal/brandImageNumber") into tBrandImage
   put getPref ("preferences/modules/portal/totalBrandImages") into tTotalBrandImages
   put getPref ("preferences/global/lastRunDate") into tLastRunDate
   if tLastRunDate = "false" then  put the internet date  into tLastRunDate
   convert tLastRunDate to seconds
   
   # new install, no prefs OR total is reached  
   
   if (tBrandImage = "false") OR (tBrandImage = 0) OR (tBrandImage>tTotalBrandImages)  then
      put 1 into  tBrandImage
   else 
      # or  1 hour has passed
      if (the seconds) > tNextChangeUp then 
         add 1 to  tBrandImage
      end if
   end if
   put the seconds +  kBRAND_IMAGE_CHANGE into tNextChangeUp
   convert tNextChangeUp to internet date
   setPref "preferences/global/lastRunDate", tNextChangeUp
   setCache "NextBrandImageChange",tNextChangeUp
   
   
   setPref "preferences/modules/portal/brandImageNumber",  tBrandImage
   # tTotalBrandImages is set on the home card
   
   # cache 
   setCache "BrandImage", tBrandImage
   
   
   
end setUpBrandImage
*/



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

########################
ON ___FETCH_NEWS
end ___FETCH_NEWS

command News_Fetch
   local tLocalNewsFile, tServerNews, tTargetLine, tLocalNewsDate, tLatestNewsDate
   --breakpoint
   if connectivity_PingServer() = "false" then 
      exit news_Fetch
   end if
   
   # path to news 
   put path_Documents()&"assets/info/siva-app-news.html" into tLocalNewsFile
   
   # fetch the latest news on server
   put url ("https://www.himalayanacademy.com/media/apps/sivasiva/"& cRemoteNewsFile) into tServerNews
   
   # check for the existence of news file locally
   # get date data 
   put format ("<p id=\"datestamp\">") into tTargetLine
         
   if ( there is a file( tLocalNewsFile) ) then # parse it for the date
      put  url ("file:"& tLocalNewsFile) into tLocalNewsDate
      put line (lineoffset(tTargetLine,tLocalNewsDate)) of tLocalNewsDate  into tLocalNewsDate
      put stripHTMLTags(tLocalNewsDate) into tLocalNewsDate
      convert tLocalNewsDate to seconds
   else
      put empty into tLocalNewsDate
   end if 
   put line (lineoffset(tTargetLine,tServerNews)) of tServerNews  into tLatestNewsDate
   put stripHTMLTags(tLatestNewsDate) into tLatestNewsDate
   convert tLatestNewsDate to seconds
   
   # compare dates
   
   if tLocalNewsDate = tLatestNewsDate then
      # do nothing
      # we don't want the user to see the message ever time they open app.
      # even if they not read it. 
      # TODO We should set a pref that tells that app of they did read the news
      # from the Setting Statck
      # otherwise to leave the flat the true
      news_NoNews
      
   else 
      # save it
      put tServerNews into url ("file:"&tLocalNewsFile)
      put "true" into sNewNews
   end if
   
   showNewNotification sNewNews
   if   sNewNews is empty then
      put "yes, empty"
   end if

end news_Fetch

command showNewNotification pBool
   --news_NoNews # user has read the news, but is off line...
   if exists(fld "notification") then
      visMessageToUser pBool
      put  "You have news!" & cr & "View in Settings." into fld "notification"
   end if
end showNewNotification

function news_Check
   return sNewNews
end news_Check

command news_NoNews
   put "false" into sNewNews
end news_NoNews


command newcontent_Check
   local tBool
   # Ping server for updates?
   put "false" into tBool # for now
   put tBool into sThereIsNewContent 
end newcontent_Check

#use this in appropriate places where you may want updates later
# e.g. About this App; Privacy Policy are common use cases.

function newcontent_IsThere
   return sThereIsNewContent
end newcontent_IsThere

##########################
on ___PATHS
end ___PATHS

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
   local tPath
   put specialFolderPath("documents") into tPath
   put "/" after tPath 
   # remember not to precede path strings to follow with a slash in your 
   # final slashes are added here
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
   local tPath
   put path_HomeLocal() into tPath
   put "assets/" after tPath
   return tPath
end path_Assets

function path_Modules
   local tPath
   put path_HomeLocal() into tPath
   put "modules/" after tPath
   return tPath
end path_Modules

function path_Models
   local tPath
   put path_HomeLocal() into tPath
   put "models/" after tPath
   return tPath
end path_Models

command fetchNavigationMap
   local tPath, tJSON
   put path_HomeLocal() into tPath
   put "models/model_SivaSiva/model_SivaSiva.json" after tPath
   put url ("file:" & tPath) into tJSON
   put JSONToArray(tJSON) into sSivaSivaNavigation
end fetchNavigationMap

function getNavigationMap
   return sSivaSivaNavigation
end getNavigationMap


--------------------------------
-- path_IsFileOnDisk/path_FileForURL
-- DESCRIPTION:
-- Called from any stack that wants to use local media
-- or download it if not available
-- see init script which sets up folders in /media to match
-- the web server; CMS in app is the same:
-- files are in a folder with the  fileID from the database.
-- Caveat: if the entry in the dbase has bad chars this creates a folder name that will break 
-- the data manager digger.... LC hangs on the directly walk, recursive dig through folders
-- and subfolders
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
   local tFilePath
   put path_FileFromURL(pURL) into tFilePath
   if there is a file tFilePath then
      return (true,tFilePath)
   end if
   return false
end path_isFileOnDisk

function path_FileFromURL pURL
   local tDF, tBadFolderName, tFile, tFolderCount, tFolderToCreate, tCheckURL
   put path_Documents() into tDF
   
   # Clean up a bad bug in one folder name that may still exist in early installations.
   # bad data entry with end of line in a folder name at the end
   put "gr_1998-12-06_religious-lethargy" & cr into tBadFolderName
   put (tDF &"/media/audio/inspired-talks/gurudeva/1998/") before tBadFolderName
   if there is a folder  tBadFolderName then
      delete folder tBadFolderName
   end if
   # the right one will be re-created later 
   
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



######################
on ___CONNECTIVITY
end ___CONNECTIVITY

constant kRequiresConnection="Website,Look,The Master Course,All Our On-line Books,Hinduism Today Magazine,Educational Insights"

function requiresConnection pLink
   if pLink is among the items of kRequiresConnection then
      return connectivity_PingServer()
   end if
end requiresConnection


Local sPingURL,sServerAttempts # sURLStatusLog



function connectivity_PingServer   
   get url "https://www.himalayanacademy.com/ping.txt"
   if it is "true" then
      return true
   else
      return false 
      ntInfo "offline!"
   end if
end connectivity_PingServer


# Use this in the module so we don't ping the server constantly.

function connectivity_CheckResult pResultVariable
   
   if pResultVariable is not empty then
      ntInfo "HTTP error:" && pResultVariable
      return false
   end if
   
   if word -2 of line 1 of libURLLastRHHeaders() is not 200 then
      ntInfo "Last HTTP code:" && word -2 of line 1 of libURLLastRHHeaders()
      return false
   end if
   
   return true
end connectivity_CheckResult

function checkURLAvailable pSelectedURL
   local tHeaders, tSentHeaders, tResult, tBytes
   
   # BM: not sure about this call, where are these values obtained?
   put  tsNetHeadSync(pSelectedURL, tSentHeaders, tResult, tBytes)  into tHeaders  # into tHeaders
   
   ## get url pSelectedURL
   if  (tResult is 200) then
      return true
   else
      ntInfo tResult && pSelectedURL
      return false
   end if
end checkURLAvailable

## Deprecated:

--function connectivity_NotAvailable cardOrStackObject
--   if sOnlineStatus = "true" then # nothing to do here.. no checks required
--      return "true"
--   else
--      repeat for each item x in kONLINECONTENT
--         if (cardOrStackObject contains x) then
--            dialog_CustomMsg "Offline or Low Bandwidth"
--            return "offline"
--            # FYI we are letting users open the "Listen" stack even though
--            exit repeat
--         end if
--      end repeat
--   end if
--   # risking queuing up multiple requests
--end connectivity_NotAvailable




##################################
ON ___SETTERS_GETTERS
end ___SETTERS_GETTERS

# Description: 
# Frequenly there is a common  need to have a variable be set 
# that is available when on stack closes - where you sets a variable
# and when an next stack opens. 
# you have three choices, Get a global
# So set prop, getprop
# set "Getters" and "Setters"


local sJournalFlag,sJournalData
local sCacheA

command clearCache
   if not isMobile() then
      put empty into sCacheA
   end if
end clearCache

on displayCache
   if not isMobile() then
      local tOutput
      repeat for each key x in sCacheA
         put x & ": " & sCacheA[x] & cr after tOutput
      end repeat
      put tOutput
   end if
end displayCache

command setCache pKey, pValue
   put pValue into sCacheA[pKey]
end setCache

function getCache pKey
   if pKey is empty then
      return sCacheA # return the whole array if needed
   else
      return sCacheA[pKey] # return just the requested value
   end if
end getCache

command setJournalFlag pFlag
   put pFlag into sJournalFlag
end setJournalFlag

function getJournalFlag
   return sJournalFlag
end getJournalFlag

command setJournalData pData
   put pData into sJournalData
end setJournalData

function getJournalData
   return sJournalData
end getJournalData

local sMobileRect

command mobileRectSet # called after init
   put the effective working screenRect into sMobileRect
end mobileRectSet

function mobileRectGet
   return sMobileRect
end mobileRectGet

#################
ON ___UTILITIES
end ___UTILITIES


function removeQuotes pString
   # Needed when passing some raw string to json for some functions like analytics
   # quotes will break theAPI/Jdon
   replace quote with "" in pString
   replace "'" with "" in pString
   return pString
end removeQuotes
 
function stripHTMLTags pString
   local newHtml
   replace cr with empty in pString -- in case of multi-line tags
   replace "<" with cr & "<" in pString
   replace ">" with ">" & cr in pString
   filter pString without "*<*"
   filter pString without "*>*"
   repeat for each line LNN in pString
      put word 1 to -1 of LNN  & cr after newHtml
   end repeat
   filter newHtml without empty
   --now there are no leading/trailing spaces, no empty lines
   replace cr with space in newHtml
   return newHtml
end stripHTMLTags

on backkey # need for android
   if not (portal_GetLastStack() = "Siva-Siva-Portal") then
      portal_GoStack "Siva-Siva-Portal"
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
   local tTitleCasedString
   put toLower(pString) into pString # normalize all chars first
   
   # assume words separated by spaces
   
   repeat for each word x in pString
      put toUpper(char 1 of x) into char  1 of x
      put x & space after tTitleCasedString
   end repeat
   delete char -1 of tTitleCasedString
   return tTitleCasedString
   
end text_TitleCase


# Returns a list of files with the full paths
function listFilesWithPaths pFolder, pRecurse
   local tTotalFiles, tCurrentFiles, tFolders, tList
   
   set the directory to pFolder
   put filteredFilesWithPaths() into tCurrentFiles
   if not pRecurse then return tCurrentFiles
   if tCurrentFiles is not empty then put tCurrentFiles & \
         return after tTotalFiles
   put filteredFolders() into tFolders
   repeat for each line tFolder in tFolders
      put listFilesWithPaths((pFolder & slash & tFolder), \
            pRecurse) into tCurrentFiles
      if tCurrentFiles is not empty then put tCurrentFiles & \
            return after tTotalFiles
   end repeat
   delete the last char of tTotalFiles
   put tTotalFiles into tList
   return filterDots(tlist)
end listFilesWithPaths

# Returns a list of files in the current directory including
# each file's full path.
function filteredFilesWithPaths
   local tFiles, tFilesWithPaths
   
   put filteredFiles() into tFiles
   repeat for each line tFile in tFiles
      put the directory & slash & tFile & return after \
            tFilesWithPaths
   end repeat
   delete the last char of tFilesWithPaths
   
   return tFilesWithPaths
end filteredFilesWithPaths

# Filters the strings "." and ".." from a list
function filterDots pList
   local tList
   
   put pList into tList
   filter tList without "."
   filter tList without ".."
   filter tList without ".*"
   
   return tList
end filterDots
# Returns a filtered list of files in the current directory
function filteredFiles
   return filterDots(the files)
end filteredFiles

# Returns a filtered list of folders in the current directory
function filteredFolders
   return filterDots(the folders)
end filteredFolders


##################################


/* Thanks to Ralph DiMola ! for this function

 This function does a lot but takes care of the bad screen rect on startup.
It also allows for either sliding up the screen or shrinking the screen. It
also allows for the iPhone X safe area. If you get the aspect ratio in the
IDE like the iPhone X you can see how the app will look in the safe area. I
roll my own control placement using getCardRect to define the screen area. I
also always set the pixelScale to 1. This was written on day 2 of using
LiveCode so it's not pretty. The nuts and bolts of the bad rect on startup
is the line==> "if R2<0 and not the KeyboardOffset of this stack is a number
then */
*/The bad rect thing started way back in the middle of the version 6s I think
This might not help if you use the built in geometry tools, but for what
it's worth getCardRect has never failed me .... */


function getCardRect
   
   /* Hi all ... if this is helpful to anyone, I've been able to work out 
   the exact pixel values for the safe area for iPhone X using Xcode 9.0
   
   iPhone X overall dimensions
   2436 x 1125 pixels
   
   Overall safe area
   2172 x 1062 pixels
   
   Left & right insets (accounts for the notch and curved corners, plus a margin)
   132 pixels each
   
   Bottom inset (accounts for the bottom nav bar)
   63 pixels
   
   Top inset zero pixels
   
   Portrait dimensions	Landscape dimensions
   1125px ◊ 2436px (375pt ◊ 812pt @3x)	2436px ◊ 1125px (812pt ◊ 375pt @3x)
   
   Portrait right side up:
   Left: 0
   Top: 44 Pts 132 Pixels
   Right: 0
   Bottom: 34 Pts 102 Pixels
   
   Portrait upside down: NOT SUPPORTED
   
   Landscape left and right:
   Left: 16 Pts 48 Pixels
   Top: 32 Pts 96 Pixels
   Right: 16 Pts 48 Pixels
   Bottom: 23 Pts 69 Pixels
   
   
   */
   
   local R1 , R2 , R3 , R4 , tR2 , tR4
   
   --return the rect of this card
   if the environment is not "mobile" then
      put item 1 of the rect of this card into R1
      put item 2 of the rect of this card into R2
      put item 3 of the rect of this card into R3
      put item 4 of the rect of this card into R4
   else -- Mobile
      --put the screenrect into tRectTemp
      if the ignorekeyboard of this stack then
         put item 1 of the rect of this card into R1
         put item 2 of the rect of this card into R2
         put item 3 of the rect of this card into R3
         put item 4 of the rect of this card into R4
         --answer "Here 1"
      else -- Dont Ignore Keyboard
         --answer "Here 2"
         put 0 into R1
         put item 3 of the effective working screenrect - item 1 of the effective working screenrect into R3
         if the ShrinkKeyboard of this stack then
            --answer "Here 3"
            put 0 into R2
            put item 4 of the effective working screenrect - item 2 of the effective working screenrect into R4
         else -- Dont Shrink Keyboard Slide Up if Instructed
            --answer "Here 4"
            put item 2 of the rect of this card into R2
            put item 4 of the rect of this card into R4
            if the KeyboardOffset of this stack is not empty and the KeyboardOffset of this stack is a number then -- Slide Up
               --answer "Here 5"
               --put (item 2 of the effective working screenrect - the KeyboardOffet of this stack) into tR2
               --put (item 4 of the effective working screenrect - the KeyboardOffet of this stack) into tR4
               put R2 - the KeyboardOffset of this stack into tR2
               put R4 - the KeyboardOffset of this stack into tR4
               if tR4 > tR2 then
                  --answer "Here 6",tR2,tR4
                  put tR2 into R2
                  put tR4 into R4
               end if -- Offset out of range
            end if -- Keyboard Offset
         end if -- Shrink Keyboard
      end if --Ignore Keyboard
   end if -- Mobile
   if R2<0 and not the KeyboardOffset of this stack is a number then
      --answer "Here 7",R2,R4
      put abs(R2) + R4 into R4
      put 0 into R2
   end if
   --return (R1,R2,R3,R4)
   if the platform = "iPhone" or Dev () then
      switch
         case the width of this card = 1125 and the height of this card = 2436 -- Portrait iPhone X
            return (R1,R2+132,R3,R4-102)
            break
         case the width of this card = 2436 and the height of this card = 1125  -- Landscape iPhone X
            return (R1+48,R2+96,R3-48,R4-69)
            break
         case Dev() and the width of this card / the height of this card >= .455 and  \
               the width of this card / the height of this card <= .467  -- Portrait iPhone X
         return (R1,R2+(132*(the height of this card / 2436)),R3,R4-(102*(the height of this card / 2436)))
         break
      case Dev() and the height of this card / the width of this card >= .455 and  \
            the height of this card / the width of this card <= .467  -- Landscape iPhone X
      return (R1+(48*(the width of this card / 2436)),R2+(96*(the height of this card /1125)),R3-(48*(the width of this card / 2436)),R4-(69*(the height of this card / 1125)))
      break
   default
      return (R1,R2,R3,R4)
end switch
else
   return (R1,R2,R3,R4)
end if

end getCardRect

function dev -- Thanks to Jacqueline Landman Gay @ HyperActive Software for this one.
   return the environment is "development"
end dev

/*=========== LOGGING ======================
BR: 2020-02-23
1) we have created a log control in the stack "lib_CustomControls"
-- see card "viewLogControl" | group "viewLogging"
-- We have added this to the global array sConfigA["viewLogging"]
2) on the  card SivaSiva.livecode stack and a checkbox/button called "Enable Logging" which set the uBuildMode to "release" or "log"

--see "behavior_InitSivaSivaProject"  Where we hvae

if the uBuildMode of this stack is "release" then
   set the logMessage to empty
else
   set the logMessage to "log"
end if


hiliting  "enable Logging" will invoke to following where we have it.

3) on any "preOpenCard" handler use this (there is no over head to leaving this in the code)

if the logMessage <> empty then
   copyLogControl
end if

4) you can put log messages anywhere e.g.

log "the vis of sHomeText" # htere is no overhead to leaving these in the code

Logging will be turn on mobile.

You can also just leave it "off" on init and use the message for

set the logMessage to "log"  OR
set the logMessage to empty

Note of course, you save the binary with the log enable, the group is save with the card.
In theory this not  problem as long it is it hidden and Enable Logging it OFF for a release

*/


function examineArray pArray
   local tSort,tOutput
   put the keys of pArray into tSort
   sort  lines of tSort 
   repeat for each line x in tSort
      put x & tab & pArray[x] & cr after tOutput
   end repeat
   return tOutput
end examineArray


local   tLogResult

command copyLogControl
   
   # invoke this from msg
   # save stack and the group is saved
   # on mobile stack are not saved.
   
   local tLogControl
   # first instantiate the group to the local context
   put sConfigA["viewLogging"] into tLogControl
   if (exists(group "viewLogging" of this card) ) then 
      #  do nothing... assume vis of the group is off...
   else
      copy tLogControl to this card
   end if
end copyLogControl

on log pLog 
   put cr & pLog before tLogResult # latest on top
   showLogging
end log

on clearLog
   put empty into tLogResult
end clearlog

on showLogging
   if there is a grp "viewLogging" then
      set the layer grp "viewLogging" to top
      show grp "viewLogging"
      put tLogResult into fld "log"
   end if 
end showLogging





