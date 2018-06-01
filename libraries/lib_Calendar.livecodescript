script "lib_Calendar"

--> MetaData

local sCalendarArrayA,sICSStoreOriginal
local sHinduCalendarA, 

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

command parseUserICSfile
   
   put path_Documents() into tDataLoc
   put "modules/calendar/myCalendar.ics" after tDataLoc
   if not (there is a file tDataLoc) then 
      put url "https://ww into w.minimela.com/panchangam/2017-2018/usa/minneapolis_st_paul_mn.ics" into url ("binfile:/" & tDataLoc)
   end if
   
   put url ("file:/" & tDataLoc) into sICSStoreOriginal
   
   # either way, now we have it
   # go for it.
   
   put vObjectSplit("VEvent", sICSStoreOriginal) into sCalendarArrayA
   
   --answer "First object is:" & cr & sCalendarArrayA[1]
   
   --start using stack "vObjectlib"  # we don't need the whole library
   --two functions get the job done. vObjectSplit and GetvObjectPropertyValue 
   put 0 into kDayNo
   repeat with x = 1 to ((item 2 of the extents of sCalendarArrayA)+1)
      put sCalendarArrayA[x] into tEvent 
      # key info is the Summary or "title" of the event
      # and the date... we extract for each event in the whole file
      # but date follows ISO standard  yyyymmdd  no delimiters.
      put GetvObjectPropertyValue(tEvent, "Summary")  into tMoonDay
      put  GetvObjectPropertyValue(tEvent, "DTSTART")  into tDate
      # Let's first check and skip what we don't want to pay attention to:
      if   (word 1 of tMoonDay = "Sun") OR  (tMoonDay contains "Retreat Star-") then
         
         add 1 to kDayNo
         
         # we will continue parsing the event
         #-- use as a test run,
         
         # put tMoonDay  & " | " & tDate & cr after tOutput  
         # comment the rest below for the test
         
         # first get our moon day designation and date
         if not (tMoonDay contains "Sun") then
            put the itemDelimiter into tIDel
            set the itemdel to "-"
            put item 2 of tMoonDay into tMoonDay
            set the itemDelimiter to tIDel
         end if
         put tMoonDay into sHinduCalendarA[kDayNo][moonDay]
         put tDate into sHinduCalendarA[kDayNo][icsdateString]
         put extractLongDate(tDate) into sHinduCalendarA[kDayNo][longDate]
         
         put  GetvObjectPropertyValue(tEvent, "Description") into tRawDescription
         put extractFullEntry(tRawDescription,tMoonDay,kDayNo) into sHinduCalendarA[kDayNo][allDayData]
         
      end if
   end repeat
   
end parseUserICSfile

function getCalendarData
   return sHinduCalendarA
end getCalendarData

function extractFullEntry pDescription,tMoonDay,kDayNo
   
   replace "\n" with cr in pDescription
   
   # we want to get a few items from here for the top view
   # pass Nakshatra "moonstar" to the top keys"
   put line (lineOffset("nakshatra", pDescription)) of pDescription into sHinduCalendarA[kDayNo][nakshatra]
   put line (lineOffset("tithi", pDescription)) of pDescription into sHinduCalendarA[kDayNo][tithi]
   put  wordOffset("pakshe", pDescription) into tPaksha
   put  word (tPaksha-1)  of pDescription into sHinduCalendarA[kDayNo][paksha]
   
   # For now we will add the date at the top
   put tMoonDay  & cr &\
         sHinduCalendarA[kDayNo][longDate] & cr & cr before pDescription
   --put pDescription; exit to top
   return pDescription
end extractFullEntry

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
function vObjectSplit pObjectType, pObject
   put "BEGIN:" & pObjectType into tHeader
   put "END:" & pObjectType into tFooter
   repeat with x = 1 to the number of lines in pObject
      put line x of pObject into tLine
      if tLine contains tHeader then put x into tBeginBlock
      if tLine contains tFooter then put x into tEndBlock
      if tEndBlock is not empty then
         put line tBeginBlock to tEndBlock of pObject & numToChar(4) after tRetVal
         put empty into tEndBlock
         put empty into tBeginBlock
      end if
   end repeat
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
      put lineoffset(cr & upper(pPropName) & ":", cr & pObject) into tPropLocation
      if tPropLocation is "0" then     put lineoffset(cr & upper(pPropName) & ";", cr & pObject) into tPropLocation
      if tPropLocation is "0" then     put lineoffset("." & upper(pPropName) & ";", pObject) into tPropLocation
      if tPropLocation is "0" then     put lineoffset("." & upper(pPropName) & ":", pObject) into tPropLocation
      
      set the itemdel to ":"
      get line tPropLocation of pObject
      get the item 2 to -1 of it
      return it
   else
      return false
   end if
end GetvObjectPropertyValue

command __UIUXHandlers
end __UIUXHandlers

# Local Loading for dev only

on insertDayInfo
   
   # used in development... we can upgrade later to 3 months
   # does not include user reminders
   # and does not have any method to display the "allData" for the day that is clicked on
   put the uDayTemplate of fld "current-Days" into tOneDayTemplate 
   repeat with tDaysToShow = 1 to 10
      put empty into tOneDayDisplay
      put tOneDayTemplate into tOneDayDisplay
      
      put  "moonday,longdate,nakshatra,paksha,tithi" into tTop
      repeat for each item x in tTop
         replace ("##"&x&"##") with sHinduCalendarA[tDaysToShow][x] in tOneDayDisplay
      end repeat
      
      replace "##reminder1## ##reminder1-time##" with "" in tOneDayDisplay
      put tOneDayDisplay after tAllDaysTopInfo
      
   end repeat
   
   #Dev Only!  
   # We are only ending up with data for one day... just to see hwo it looks:
   
   put sHinduCalendarA[10][allDayData] into fld "allDataForOneDay"
   
   set the htmltext of fld "current-Days" to tAllDaysTopInfo
   
   # store in Custom prop of the field
   
   --   <p spacebelow="4"><b>##moonday##&#9;##LongDate##</b></p>
   --   <p leftindent="8">##nakshatra##</p>
   --   <p leftindent="8">##paksha##, ##tithi##</p>
   --   <p leftindent="8"></p>
   --   <p leftindent="8">##reminder1## ##reminder1-time##</p>
   --   <p leftindent="8">________________________</p>
   --   <p leftindent="8"></p>
   --   <p></p>
end insertDayInfo


command __UNUSED
end __Unused

end __UNUSED
   ####### --------- UNUSED FROM THE MONASTERY CALENDAR PROCESSORS  
## IF WE GET THE KA ICS AVAILABLE WE MAY USE THESE LATER.

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
