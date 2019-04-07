script "behavior_Calendar"

--> MetaData

local sHinduCalendarA -- calendar array
local sUserCalendarA -- array of user private reminders by numerical keys
local sCityName -- city name as used in URL

# note that the later ICS files are duplicating data from the primary day description.
# this is a concession to calendars requiring an "event" be present for anything to 
# appear on a top level display of days, week list. 
# an agreement was reached some years back to expose the "loka" of the day,
# and certain festivals, based on some internal algorithm used at the monastery
#But in the Siva Siva app we can just ignore this extra data by skipping all those redundant events data
# the "target" event is always the first one for the day.  We parse/extract everything from that
# this can be verified two ways: 
# 1) If the DTSTART of the event has incremented by one day, then this is the first and primary entry that we can parse.
# 2) if the DTSTART of the event is the same as the last one we just parsed... we can ignore it.
# 3) The other algorithm, and perhaps programatically easier: is  
# 4) if the Event Summary  either  word 1=  "Sun " or contains "Retreat Star-"  we can extract
# Best practices really should rely on the standard labels and not user data; so the DTSTART algorithm
#  would be less likely to break... that said, I have been parsing this calendar data for over 20 years 
# and Shanmuganathswami has never changed those strings so we can depend on them.
# we can use Andre's lib... but this is simple enough to write your own text parser, once you see the pattern
# the general algorithm is: get the first event, extract the Summary for the MoonDay, extract the Julian date 
# use LC's internal "weekdays" tools to get the day of the week.. .then put these together for line 1
# then we pull out a few of the items in the description for the top view
# then push the entire description, as is, into the "complete look at the day"
# once we get that going we can tweak the text styles/formatting. 

command parseUserICSfile  pCityName,pYearRange -- loads the calendar script local
  -- pCityName = readable English name from city list
  -- pYearRange = the calendar year range
  -- called from preOpenCard, insertDayInfo, and Submit btn
  if pCityName = "" then loadCityName -- loads script local
  if pCityName = "" and sCityName = "" then
    doAnswer "Could not find your city. Tap the location pin to choose one.","OK"
    exit parseUserICSfile
  else if sCityName = "" then
    put pCityName into sCityName
  end if
  put  pathToCalendarICS(pYearRange,pCityName,"bin") into tBinPath -- binary array file
  if there is a file tBinPath then -- preOpenCard or insertDayInfo
    get url ("binfile:" & tBinPath)
    put arrayDecode(it) into sHinduCalendarA
  else  -- no file or user is reloading, get download:
    put pathToCalendarICS(pYearRange,pCityName,"ics") into tICSPath
    put convertCityToURL(pCityName,pYearRange) into tURL
    try
      put url tURL into url ("binfile:/" & tICSPath)
    catch tErr -- sys err
      doAnswer "Could not retrieve calendar file." &cr& tErr,"OK"
      exit to top
    end try
    --   PUT THE MILLISECONDS INTO TSTART
    put vObjectSplit("VEvent", tICSPath)  into tCalendarArrayA -- much faster to read file directly
    if tCalendarArrayA[1] contains "https:" then -- web 404 or redirect
      doAnswer "Could not retrieve calendar file.","OK"
      delete file tICSPath
      exit to top
    end if
    put 0 into tDayNo
    put "" into sHinduCalendarA
    repeat with x = 1 to ((item 2 of the extents of tCalendarArrayA)+1)
      put tCalendarArrayA[x] into tEvent 
      # key info is the Summary or "title" of the event
      # and the date... we extract for each event in the whole file
      # but date follows ISO standard  yyyymmdd  no delimiters.
      put GetvObjectPropertyValue(tEvent, "Summary")  into tMoonDay
      put  GetvObjectPropertyValue(tEvent, "DTSTART")  into tDate
      # Let's first check and skip what we don't want to pay attention to:
      if (word 1 of tMoonDay = "Sun") OR  (tMoonDay contains "Retreat Star-") then # we will continue parsing the event
        add 1 to tDayNo
        # first get our moon day designation and date
        if not (tMoonDay contains "Sun") then
          put the itemDelimiter into tIDel
          set the itemdel to "-"
          put item 2 of tMoonDay into tMoonDay
          set the itemDelimiter to tIDel
        end if
        put tMoonDay into sHinduCalendarA[tDayNo][moonDay]
        put tDate into sHinduCalendarA[tDayNo][icsdateString]
        put extractLongDate(tDate) into sHinduCalendarA[tDayNo][longDate]
        
        put GetvObjectPropertyValue(tEvent, "Description") into tRawDescription
        put extractFullEntry(tRawDescription,tMoonDay,tDayNo) into sHinduCalendarA[tDayNo][allDayData]
        
      end if
    end repeat
    --   PUT THE MILLISECONDS - TSTART -- 335 ms
    put arrayEncode(sHinduCalendarA) into url ("binfile:" & tBinPath)
    delete file tICSPath
    deleteOldCalendars
  end if
end parseUserICSfile

function getCityList 
   put path_Modules() & "calendar/latestCityList.txt" into tCitiesListFile
   return ( url ("file:" & tCitiesListFile ))
end getCityList

function convertCityToURL pCityName,pYearRange
   put "https://www.minimela.com/panchangam/" into tURL
   if pYearRange = "" then -- use a range that includes today
      put calcYearRange() into pYearRange
   end if
   put pYearRange & slash after tURL
   get last word of pCityName
   set the casesensitive to true
   if len(it) = 2 and toUpper(it) = it then
      put "usa/" after tURL
   else
      put "world/" after tURL
   end if
   
   # there is where we can place a 
   # special your for Kadaval
   
   if pCityName contains "Kapaa" then
      put "Hawaii" into pCityName
   end if 
   # nickname for kadavul is kealia
   if pCityName contains "Kealia" then
      replace "https://www.minimela.com/panchangam/" with "http://dev.himalayanacademy.com/media/apps/panchangam/" in tURL
   end if
   replace space with "_" in pCityName
   put pCityName & ".ics" after tURL
   put toLower(tURL) into tURL
   return tURL
end convertCityToURL


# the range is always from month of April which is Tamil New Years
# The data items has the month item 2, eg.  2019,2,1,0,0
# if the selected date in ahead of the range, 
# we offer to download the next year.
function calcYearRange pDate -- get the year range that contains pDate; if empty, use today
  if pDate = "" then put the date into pDate
  convert pDate to dateitems
  if item 2 of pDate >= 5 then
    put item 1 of pDate & "-" & item 1 of pDate + 1 into tRange
  else
    put item 1 of pDate - 1 & "-" & item 1 of pDate into tRange 
  end if
  return tRange
end calcYearRange

function getCalendarDayInfo pDay -- return data for a single array key (one day), or all days
  -- pDay = array key integer
  if pDay <> "" then -- called from click in current_days fld
    return sHinduCalendarA[pDay]
  else
    return sHinduCalendarA
  end if
end getCalendarDayInfo

function extractFullEntry pDescription,pMoonDay,pDayNo
  replace "\n" with cr in pDescription
  
  # we want to get a few items from here for the top view
  # pass Nakshatra "moonstar" to the top keys
  put line (lineOffset("nakshatra", pDescription)) of pDescription into sHinduCalendarA[pDayNo][nakshatra]
  put line (lineOffset("tithi", pDescription)) of pDescription into sHinduCalendarA[pDayNo][tithi]
  put word (wordOffset("pakshe", pDescription))-1 of pDescription into sHinduCalendarA[pDayNo][paksha]
  # For now we will add the date at the top
  put pMoonDay  & cr & sHinduCalendarA[pDayNo][longDate] & cr & cr before pDescription
  return pDescription
end extractFullEntry 


function extractLongDate tEntryDate
   # Get from YYYYMMDD to Livecode Date string
   put char 5 to 6 of tEntryDate & "/" &\  # month 
         char 7 to 8 of tEntryDate & "/" & \  # day 
         char 3 to 4 of tEntryDate into tLongDate   # year 
   convert tLongDate to long date
   return tLongDate
end extractLongDate


/** vObjectSplit **
* A function. It returns an array of vObjects. You can use 'put vObjectSplit("vCard", tAllCards) into tArrayA'
* then access the vCards as tArrayA[x].
*
* @param   pObjectType   The object type to be acquired (Ie: vCard)
* @param   pObject       The object container.
*
* @return  An array of vObjects
**/

function vObjectSplit pObjectType,pFileName -- FROM FILE: 291ms
  put "BEGIN:" & toUpper(pObjectType) into tHeader
  put "END:" & toUpper(pObjectType) into tFooter
  --   PUT THE MILLISECONDS INTO TSTART
  open file pFileName for UTF8 read 
  read from file pFileName for 8 lines -- initial data block, extract city name and discard
  put line lineoffset("X-WR-CALNAME:",it) of it into tCity
  delete char 1 to offset(colon,tCity) of tCity
  --   put tCity into fld "cityName" of grp "city-picker-view"
  
  repeat
    if the shiftkey is down then -- dev
      close file pFileName
      breakpoint
    end if
    read from file pFileName until tHeader
    if it = "" or it contains "END:VCALENDAR" then exit repeat
    put it into tText
    read from file pFileName until tFooter
    put it after tText
    filter tText without empty
    put tText & numToChar(4) after tRetVal
  end repeat
  close file pFileName
  --   PUT THE MILLISECONDS - TSTART
  delete char -1 of tRetVal
  split tRetVal by numToChar(4)
  return tRetVal
end vObjectSplit

/** GetvObjectPropertyValue **
* A function. It returns the value of a given property of an object.
*
* @param  pObject   The object to be searched.
* @param  pPropName The property to find.
*
* @return the value of the property.
**/

function GetvObjectPropertyValue pObject, pPropName
  if pObject contains pPropName then
    put lineoffset(cr & pPropName & ";", cr & pObject) into tPropLocation
    if tPropLocation is "0" then put lineoffset(cr & pPropName & ":", cr & pObject) into tPropLocation
    if tPropLocation is "0" then put lineoffset("." & pPropName & ";", pObject) into tPropLocation
    if tPropLocation is "0" then put lineoffset("." & pPropName & ":", pObject) into tPropLocation
    
    set the itemdel to ":"
    get line tPropLocation of pObject
    get item 2 to -1 of it
    replace "*" with empty in it
    return it
  else
    return false
  end if
end GetvObjectPropertyValue
 
function pathToCalendarICS pYearRange,pCityName,pType -- return path to ICS file
  -- pYearRange = two years separated by hyphen
  -- pType = "ics" or "bin" (a binary LC array already parsed)
   -- called from parseUserICSfile, preOpenCard, and Submit btn
   put pCityName into sCityname
  if pYearRange = "" then put calcYearRange() into pYearRange
  if pCityName = "" then put getPref ("preferences/modules/calendar/city") into pCityName
  replace space with "_" in pCityName
  return path_Documents() & "modules/calendar/" & pCityName & pYearRange & "." & pType
end pathToCalendarICS

function calendarExists pRequestDate,pCityName -- return a year range if a file contains the date requested
  -- pRequestDate = a date in LC format
  -- sent from insertDayInfo
  put calcYearRange(pRequestDate) into tYearRange
  put  pathToCalendarICS(tYearRange,pCityName,"bin") into tBinPath
  if there is no file tBinPath then return false
  return tYearRange
end calendarExists
  
on calendarDownload -- download a calendar one year later than this year's
  -- sent from doAnswer in insertDayInfo when current date is in range but not in the current calendar; get next year
  put last trueword of calcYearRange(the date) into tYear
  put tYear & "-" & tYear + 1 into tYearRange
  if sCityName = "" then loadCityName -- loads script local
  if sCityName = "" then
    doAnswer "Could not find your city. Tap the location pin to choose one.","OK"
    exit calendarDownload
  end if
  parseUserICSfile sCityName,tYearRange -- does the download, loads the array
  dialog_CustomMsg "Download complete"
end calendarDownload

function calcStartDay pStartDay -- returns integer for first month entry
  -- pStartDay = Julian date
  -- called by insertDayInfo
  put char 1 to 6 of pStartDay into tMonth
  repeat with x = 1 to item 2 of the extents of sHinduCalendarA
    if sHinduCalendarA[x]["icsDateString"] begins with tMonth then
      return x
    end if
  end repeat
  return false
end calcStartDay

function getDateRecordNum pDate -- find the array key for a particular date
  -- pDate = a date in LC format
  convert pDate to long date
  repeat with x = 1 to item 2 of the extents of sHinduCalendarA
    if sHinduCalendarA[x]["longdate"] = pDate then
      return x
    end if
  end repeat
  return false
end getDateRecordNum

on loadCityName -- retrieve city name from prefs or from existing array, load script local
  -- called from calendarDownload, parseUserICSfile
  put getPref ("preferences/modules/calendar/city") into tCityName
  if tCityName = "" and sHinduCalendarA is an array then -- try the array
    put sHinduCalendarA[1]["allDayData"] into tData
    put word 3 to -1 of line lineoffset("calculated for",tData) of tData into tData
    delete word -2 to -1 of tData
    put tData into tCityName -- empty if array is missing
  end if
  put tCityName into sCityName -- script local
end loadCityName

function inRange pRequestDate -- calc if request date is within this or next year
  -- pRequestDate = date in LC format
  -- called by insertDayInfo
  put calcYearRange(pRequestDate) into tRequestRange
  put calcYearRange(the date) into tTodayRange
  put (trueword 1 of tTodayRange)+1 & "-" & (trueword 2 of tTodayRange) +1 into tNextYearRange
  return (tRequestRange = tTodayRange) or (tRequestRange = tNextYearRange)
end inRange

on deleteOldCalendars -- remove files older than today's calendar
  -- called from parseUserICSfile when a new calendar is downloaded
  put path_Documents() & "modules/calendar/" into tDir
  put files(tDir) into tFList
  filter tFList without ".*"
  put trueword 2 of calcYearRange(the date) into tCurYear
  repeat for each line l in tFList
    if trueword 2 of l >= tCurYear then next repeat
    put tDir & slash & l into tFilePath
    delete file tFilePath
  end repeat
end deleteOldCalendars

command __UserCalendar -- DEFERRED 2/28/18 in favor of future database
end __UserCalendar

on showReminderDialog -- show the user entry dialog group
  -- called from Edit btn -- INACTIVE FOR NOW
  if the vis of fld "allDataForOneDay" then
    put line 2 of fld "allDataForOneDay" into tDate
  else
    put getUserDate(tDate) into tDate -- returns seconds
  end if
  convert tDate to short date
  put "Reminder for" && tDate into fld "lbl-dialogDate" of grp "userEntryGrp"
  if sUserCalendarA = "" then loadUserArray
  put getDateRecordNum(tDate) into tRecordNum
  put sUserCalendarA[tRecordNum]["entry"] into fld "lbl-dialogEntry"  of grp "userEntryGrp"-- any existing entry
  put "Time:" && sUserCalendarA[tRecordNum]["time"] into fld "lbl-dialogTime"  of grp "userEntryGrp"-- any existing entry
  show grp "userEntryGrp"
end showReminderDialog

on doAEditResponse -- respond to user edit dialog, add entry to private user array
  -- sent from userEntryGrp when user enters a custom reminder -- DEFERRED
  get the dialogData
  if it contains "cancel" then
    exit to top
  else  -- add the entry to the user array
    put word 3 to -1 of fld "lbl-dialogDate" of grp "userEntryGrp" into tDate
    put word 2 to -1 of fld "lbl-dialogTime" of grp "userEntryGrp" into tTime
    put fld "lbl-dialogEntry" of grp "userEntryGrp" into tEntry
    put getDateRecordNum(tDate) into tRecordNum
    updateUserArray tRecordNum,tTime,tEntry
    insertDayInfo tDate
  end if
end doAEditResponse

on updateUserArray pRecordNum,pTime,pEntry -- add a user entry; save array to disk
  -- ptRecordNum = numerical key matching main calendar date key
  -- pTime = time of event
  -- pEntry = user entry, combined with any previous text for the reminder
  -- called by doEditResponse -- INACTIVE FOR NOW
  if sUserCalendarA = "" then loadUserArray
  put pTime into sUserCalendarA[pRecordNum]["time"]
  put pEntry into sUserCalendarA[pRecordNum]["entry"]
  put path_Documents() & "modules/calendar/" & "userCalendar.bin" into tBinPath -- binary array file
  put arrayEncode(sUserCalendarA) into url ("binfile:" & tBinPath) -- save to disk
end updateUserArray

on loadUserArray
  EXIT LOADUSERARRAY -- DEFERRED
  put path_Documents() & "modules/calendar/" & "userCalendar.bin" into tBinPath -- binary array file
  if there is a file tBinPath then
    get url ("binfile:" & tBinPath)
    put arrayDecode(it) into sUserCalendarA
  end if  
end loadUserArray

command __UIUXHandlers
end __UIUXHandlers

on insertDayInfo pStartDay -- show the calendar events for the month that includes pStartDay
   -- pStartDay = date to start at in LC format (only the month gets used); if empty, use first month in calendar array
   -- called by Submit btn, calendarDownload, preOpenCard
   # upgrade later to 3 months; 1 month for now
   # does not include user reminders
   
   if pStartDay = "" then -- use first month in calendar
      put sHinduCalendarA[1]["longDate"] into pStartDay
   end if
   put pStartDay into tRequestDate -- for scrolling later
   convert pStartDay to dateitems
   convert tRequestDate to dateitems
   put char 1 to 3 of line (item 2 of pStartDay) of the monthnames && item 1 of pStartDay into tDisplayMonth
   delete item 4 to -1 of pStartDay
   set the numberformat to "00"
   add 0 to item 2 of pStartDay
   add 0 to item 3 of pStartDay
   set the numberFormat to "0.######"
   replace comma with empty in pStartDay
   put calcStartDay(pStartDay) into pStartDay -- returns integer for first of month
   if pStartDay = false then -- not in current calendar array  --### CHECK IF DATE IS IN A DIFFERENT FILE YEAR
      put calendarExists(tRequestDate) into tDateRange
      if tDateRange <> false then
         parseUserICSfile sCityname,tDateRange -- load the script local
         send "insertDayInfo tRequestDate" to me in 0 seconds
      else  -- downloads calendar if requested and in range
         if not connectivity_PingServer() then
            --doAnswer "Next year's data is unavailable. Please enable network/internet connection.","OK,Cancel","calendarDownload"
            dialog_CustomMsg "Next year's data is unavailable. Please enable network/internet connection."
            exit insertDayInfo
         else
            if inRange(tRequestDate) then -- current year or next year
               doAnswer tDisplayMonth && "is not in the current calendar. Download the next year?","OK,Cancel","calendarDownload"
            else -- date is not within 2 year range
               doAnswer "Dates must be in the current or next calendar year.","OK"
            end if
         end if
      end if
      exit insertDayInfo
   end if
   # TO DO add retreat day "Siddhanta" and "Tour" with we get Kealia = Panchangam
   put the uDayTemplate of fld "current_days" into tOneDayTemplate 
   --  if sUserCalendarA = "" then loadUserArray -- DEFERRED
   repeat with tDayNum = pStartDay to pStartDay+31
      --  put extractLongDate(sHinduCalendarA[tDayNum]["icsDateString"]) into tCurDay
      put sHinduCalendarA[tDayNum]["longDate"] into tCurDay
      convert tCurDay to dateItems
      if sHinduCalendarA[tDayNum] = "" or item 1 to 2 of tCurDay <> item 1 to 2 of tRequestDate then next repeat -- no entry, or shorter month
      put tOneDayTemplate into tOneDayDisplay
      
      put  "moonday,longdate,nakshatra,paksha,tithi" into tTop
      repeat for each item x in tTop
         replace ("##"&x&"##") with sHinduCalendarA[tDayNum][x] in tOneDayDisplay
      end repeat
      replace "##metadata##" with tDayNum in tOneDayDisplay -- insert day number as embedded metadata for click date lookups
      replace "##reminder1## ##reminder1-time##" with empty in tOneDayDisplay -- user entries
      --    replace "##reminder1##" with sUserCalendarA[tDayNum]["entry"] in tOneDayDisplay -- user entry - DEFER
      --    replace "##reminder1-time##" with sUserCalendarA[tDayNum]["time"] in tOneDayDisplay  -- user entry - DEFER
      put tOneDayDisplay after tAllDaysTopInfo
   end repeat
   
   put tDisplayMonth into fld "monthDisplay"
   set the htmltext of fld "current_days" to tAllDaysTopInfo
   
   put "current_days" into tMainCalendar
   send "CreateScroller tMainCalendar" to fld "current_days"
   
   scrollToDate tRequestDate -- exits if not current display month
   set the acceleratedRendering of this stack to "true"
   /*
   # uDayTemplate custom prop of the field: -- jg: the ##metadata## placeholder contains the day number for array lookups 
   <p metadata="##metadata##" spacebelow="4"><b>##moonday##&#9;##LongDate##</b></p>
   <p metadata="##metadata##" leftindent="8">##nakshatra##</p>
   <p metadata="##metadata##" leftindent="8">##paksha##, ##tithi##</p>
   <p metadata="##metadata##" leftindent="8"></p>
   <p metadata="##metadata##" leftindent="8">##reminder1## ##reminder1-time##</p>
   <p align="center" spacebelow="22"><font color="#7F7F7F">________________________________________</p>
   */
end insertDayInfo

on goMonth pDir -- go to a designated month
  -- pDir = "next" or "prev"
  -- called from directional arrow btns
  put the metadata of line 1 of fld "current_days" into tDayNum
  put sHinduCalendarA[tDayNum]["longDate"] into tDate
  convert tDate to dateitems
  if pDir = "next" then
    add 1 to item 2 of tDate
  else
    subtract 1 from item 2 of tDate
  end if
  convert tDate to short date
  insertDayInfo tDate
end goMonth

on scrollToDate pDate -- scroll to a date if it's  in the current display
  -- pDate = a date in any LC format
  if pDate = "" then put the date into pDate
  convert pDate to dateitems
  set the itemdel to tab
  put item 2 of line 1 of fld "current_days" into tDisplayMonth
  set the itemdel to comma
  convert tDisplayMonth to dateitems
  if item 1 to 2 of pDate = item 1 to 2 of tDisplayMonth then -- target month
    convert pDate to long date
    put lineoffset(pDate,fld "current_days") into tLineNum
    if tLineNum = 0 then exit scrollToDate
    put the formattedheight of line 1 to tLineNum of fld "current_days" into tScroll
    set the scroll of fld "current_days" to tScroll - the effective textheight of fld "current_days"
    if isMobile() and "current_days" is among the lines of mobileControls() then
      mobileControlSet "current_days","vScroll",the vScroll of fld "current_days"
    end if
  end if
end scrollToDate

on datePicker -- UI for choosing a date to display in the event list
  -- called from datePick SVG
  put getUserDate() into tDate -- seconds
  if tDate > 0 then
    convert tDate to short date
    insertDayInfo tDate
  end if
end datePicker

function getUserDate pDefaultDate -- show a date picker, return the result in seconds
  -- pDefaultDate = date for initial display; today if empty
  if pDefaultDate = "" then put the date into pDefaultDate
  if isMobile() then
    put sHinduCalendarA[1]["longDate"] into tRangeStart -- the minimum date; can't load earlier calendars
    put calcYearRange() into tRangeEnd -- calcs from today
    put "4/30/" & last trueWord of tRangeEnd + 1 into tRangeEnd -- only allow 2 year span
    --    put item 2 of the extents of sHinduCalendarA into tEndDay
    --    put sHinduCalendarA[tEndDay]["longDate"] into tRangeEnd
    
    convert pDefaultDate to seconds
    convert tRangeStart to seconds
    convert tRangeEnd to seconds
    
    mobilePickDate "date", pDefaultDate, tRangeStart, tRangeEnd
    put the result into tDate
    if tDate = "cancel" or tDate = "" then
      put 0 into tDate
    end if
  else -- desktop, dev only, choose a date within 2 years of today, there's no error checking
    ask "Enter a date:" with pDefaultDate
    put it into tDate
    if tDate = "" then put 0 into tDate
    convert tDate to seconds
  end if
  return tDate
end getUserDate

on getTime pDefaultTime -- show a time picker, display in dialog in LC time format
  -- pDefaultTime = default display time, right now if empty
  -- called from fld "lbl-dialogTime" in user reminder dlog
  if pDefaultTime = "" then put the time into pDefaultTime -- default
  if isMobile() then    
    mobilePickDate "time"
    put the result into tTime
    if tTime = "cancel" or tTime = "" then
      put 0 into tTime
    end if
  else -- desktop, dev only, choose a date within 2 years of today, there's no error checking
    ask "Enter a time:" with pDefaultTime
    put it into tTime
    if tTime = "" then put 0 into tTime
    convert tTime to seconds
  end if
  convert tTime to short time
  put "Time:" && tTime into fld "lbl-dialogTime" of grp "userEntryGrp"
end getTime

command __UNUSED
end __Unused

end __UNUSED
   ####### --------- UNUSED FROM THE MONASTERY CALENDAR PROCESSORS  
## IF WE GET THE KA ICS AVAILABLE WE MAY USE THESE LATER.

function crunchDescription tRawDescriptionn
   set the itemdel to "\"
   delete item 1 of tRawDescription
   delete char 1 of tRawDescription
   delete item -16 to -1 of tRawDescription
   replace "\nPradosha Vrata \n" with "; " in tRawDescription
   replace "\nTown Trip\n" with "; " in tRawDescription
   replace "\nTour Day\n" with "; " in tRawDescription
   replace "\nSiddhidatta Day\n" with "; " in tRawDescription
   replace "\n" with "; " in tRawDescription
   return tRawDescription
end crunchDescription


function crunchSummary tSummary
   
   replace "Retreat Star-" with "" in tSummary
   replace "Town Trip" with "T-Trip" in tSummary
   replace "Vrata (Fasting)" with "" in tSummary
   replace "Siddhidatta Day" with "SK" in tSummary
   replace "Pradosha Vrata"  with "Pradosha" in tSummary
   replace "Kadavul " with "" in tSummary
   replace " abhishekam" with "" in tSummary
   replace "Iraivan Day" with " Iraivan" in tSummary
   return tSummary
   
end crunchSummary

# we don't need this because we can get the weekday name from the long date
function getWeekDay tEntryDate
   put extractDate( tEntryDate) into tTransformDate
   convert tTransformDate to long date
   return item 1 of tTransformDate
   
end getWeekDay

command fetchFile
   answer file "find your .ics calendar file" with "OK"
   if it is empty then
      exit to top
   else
      put url ("binfile:/" & it)  into sICSStoreOriginal
   end if
 end fetchFile
 
 on showLocals
  get sHinduCalendarA
  get sCityName
  breakpoint
end showLocals

on clearLocals
   put empty into sHinduCalendarA
   put empty into sCityName
   put empty into sUserCalendarA
end clearLocals

## JG: compare load times:
## JG: read from file above is fastest
-- function vObjectSplit pObjectType, @pObject -- ORIG: 913ms
--   put "BEGIN:" & pObjectType into tHeader
--   put "END:" & pObjectType into tFooter
--   PUT THE MILLISECONDS INTO TSTART
--   repeat with x = 1 to the number of lines in pObject
--     put line x of pObject into tLine
--     if tLine contains tHeader then put x into tBeginBlock
--     if tLine contains tFooter then put x into tEndBlock
--     if tEndBlock is not empty then
--       put line tBeginBlock to tEndBlock of pObject & numToChar(4) after tRetVal
--       put empty into tEndBlock
--       put empty into tBeginBlock
--     end if
--   end repeat
--   PUT THE MILLISECONDS - TSTART
--   delete char -1 of tRetVal
--   split tRetVal by numToChar(4)
--   return tRetVal
-- end vObjectSplit

-- function vObjectSplit pObjectType, @pObject -- SEQUENTIAL SKIP: 637ms
--   put "BEGIN:" & pObjectType into tHeader
--   put "END:" & pObjectType into tFooter
--   put 0 into tSkip
--   --   PUT THE MILLISECONDS INTO TSTART
--   repeat 
--     if the shiftkey is down then -- dev
--       exit to top
--     end if
--     put lineoffset(tHeader, pObject,tSkip) into tBeginBlock
--     put lineoffset(tFooter, pObject,tSkip) into tEndBlock
--     if tBeginBlock = 0 or tEndBlock = 0 then exit repeat
--     put line (tBeginBlock + tSKip) to (tEndBlock + tSkip) of pObject & numToChar(4) after tRetVal
--     add tEndBlock to tSkip
--   end repeat
--   --   PUT THE MILLISECONDS - TSTART
--   delete char -1 of tRetVal
--   split tRetVal by numToChar(4)
--   return tRetVal
-- end vObjectSplit
