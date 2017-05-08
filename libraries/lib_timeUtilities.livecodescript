script "lib_timeUtilities"
/*
Title: lib_timeUtilities
Author: Andre Alves Garzia (andre@andregarzia.com)
Date: April of 2017

Objective: Create library with auxiliary functions for manipulating and displaying dates.

Usage so far:
- journal module: uses this library to display journal items.
*/


/**
Returns human readable string with elapsed time from date (approximated)
@param pDate - the date to be used as reference.
*/
function timeutils_elapsedTime pFromDate, pUntilDate
   if pUntilDate is empty then
      put the seconds into pUntilDate
   end if
   
   convert pFromDate to seconds
   put pUntilDate - pFromDate into tDifference
   
   if tDifference < 0 then
      put "from now" into tSuffix
      put tDifference * -1 into tDifference
   else
      put "ago" into tSuffix
   end if
   
   -- how many months
   put (60 * 60 * 24 * 30) into tHowManySecondsInAMonth
   if tDifference >= tHowManySecondsInAMonth then
      get tDifference div tHowManySecondsInAMonth
      put it && "months" && tSuffix after tResult
      put tDifference mod tHowManySecondsInAMonth into tDifference
      return tResult
   end if
   
   -- how many days
   put (60 * 60 * 24) into tHowManySecondsInADay
   if tDifference >= tHowManySecondsInADay then
      get tDifference div tHowManySecondsInADay
      put it && "days" && tSuffix after tResult
      put tDifference mod tHowManySecondsInADay into tDifference
      return tResult
   end if
   
   -- how many hours
   put (60 * 60) into tHowManySecondsInAHour
   if tDifference >= tHowManySecondsInAHour then
      get tDifference div tHowManySecondsInAHour
      put it & "h " after tResult
      put tDifference mod tHowManySecondsInAHour into tDifference
   end if
   
   -- how many minutes
   put 60 into tHowManySecondsInAMinute
   if tDifference >= tHowManySecondsInAMinute then
      get tDifference div tHowManySecondsInAMinute
      put it & "m" && tSuffix after tResult
      put tDifference mod tHowManySecondsInAMinute into tDifference
      return tResult
   end if
   
   -- how many seconds?
   put 1 into tHowManySecondsInASecond
   if tDifference >= tHowManySecondsInASecond then
      get tDifference div tHowManySecondsInASecond
      put it & "s " after tResult
   end if
   put tSuffix after tResult
   return tResult
end timeutils_elapsedTime

--> Functions below taken from Robert Caillau: http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/

function timeutils_ISOtoSeconds ft
   
   -- converts a date-time in format YYYY-MM-DD hh:mm:ss into the number of seconds since midnight 1 January 1970
   replace "-" with "," in ft; replace ":" with "," in ft; replace space with "," in ft; put ft&",0" into ft
   convert ft to seconds
   return ft
end timeutils_ISOtoSeconds



function timeutils_SecondsToISO fs
   
   -- converts a number of seconds since midnight of 1 Januray 1970 to a date of format YYYY-MM-DD hh:mm:ss
   
   convert fs to dateitems
   
   repeat with i=2 to 6
      
      if item i of fs < 10 then put "0" before item i of fs
      
   end repeat
   
   return item 1 of fs&"-"&item 2 of of fs&"-"&item 3 of fs&space&item 4 of fs &":"&item 5 of fs &":"&item 6 of fs
   
end timeutils_SecondsToISO



function timeutils_ISODateTime
   
   -- returns the date and time as   YYYY-MM-DD HH:MM:SS W
   
   -- where W is the number of the day in the week (1=Monday, 7=Sunday)
   
   
   
   -- The dateitems conversion returns a USA weekday number.
   
   -- Convert this to standard weekday number:
   
   -- Day:               M  T  W  T  F  S  S    Day of the week
   
   -- nr:                2  3  4  5  6  7  1    USA number, what we get from the dateitems
   
   -- real:              1  2  3  4  5  6  7    Standard number, what we want
   
   --                                           we will need to use modular arithmetic, so consider:
   
   -- real -1:           0  1  2  3  4  5  6    this looks like the result of a mod 7 operation
   
   -- nr+5:              7  8  9 10 11 12  6    and this gives real-1 after a mod 7
   
   -- (nr+5) mod 7 +1:   1  2  3  4  5  6  7    done!
   
   
   
   put the long time into t; convert t to dateitems  -- this works no matter what the user's preferences are.
   
   -- Dateitems results in YYYY,MM,DD,HH,MM,SS,WD
   
   -- the numbers returned must also be prefixed with "0" if less than 10.
   
   put item 1 of t into lY
   
   put item 2 of t into lM;  if lM  < 10 then put "0" before lM
   
   put item 3 of t into lD;  if lD  < 10 then put "0" before lD
   
   put item 4 of t into lHH; if lHH < 10 then put "0" before lHH
   
   put item 5 of t into lMM; if lMM < 10 then put "0" before lMM
   
   put item 6 of t into lSS; if lSS < 10 then put "0" before lSS
   
   put item 7 of t into lW;  put (lW +5)mod 7 +1 into lW
   
   return lY&"-"&lM&"-"&lD&" "&lHH&":"&lMM&":"&lSS&" "&lW
   
end timeutils_ISODateTime
