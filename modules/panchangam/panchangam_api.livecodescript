script "panchangam_api"
constant kCALENDAR_CHECK_KEY = 1
constant kCALENDAR_META_KEY = 2
constant kCALENDAR_EVENTS_KEY = 3

--- entry point for debugging/trying panchangam routines
command debugPanchangam
   put getCityCalendarData("hawaii") into tDataA
   put getAllEvents(tDataA) into tCalendarA
   put getEventsForDate(tCalendarA, "2016-06-10") into tDateA
   breakpoint
end debugPanchangam

--- fetches the json file for a given city
-- @param city, the city name (part of file name)
-- @returns data, an associative array with the calendar data
private function fetchCityJSON pCity
   -- todo: this is a hack, only fetches bundled json. Needs update to fetch from server.
   put url ("binfile:" & sivasiva_GetModuleFolder("panchangam") & pCity & ".json") into tJson 
   put jsonimport(tJson) into tDataA
   return tDataA
end fetchCityJSON

--- get the calendar data for a city
-- @param city, the city name
-- @return data, an associative array with the calendar data
-- @throws an error if the calendar data is malformed
private function getCityCalendarData pCity
   put fetchCityJson(pCity) into tDataA
   if isCalendarData(tDataA) then
      return tDataA
   else
      throw "panchangamerr, not calendar data"
   end if
end getCityCalendarData

--- double checks if calendar data is welformed
-- @param data, the calendar data
-- @return true, if the calendar data is welformed
-- @return false, if the calendar data is malformed
private function isCalendarData pDataA
   if the number of lines in the keys of pDataA is not 3 then
      return false
   end if
   
   if pDataA[kCALENDAR_CHECK_KEY] is not "vcalendar" then
      return false
   end if
   
   return true
end isCalendarData

--- decodes a calendar entry into a more useful array
-- Calendar data in the json follows a format such as:
--
-- ["uid", {}, "text", "46e782ed-930e-4ce8-ae76-f0dbbdd33a48"]
--
-- This function checks to see if this is the correct format and returns an
-- array in the format:
--
-- tDataA["uid"] = "46e782ed-930e-4ce8-ae76-f0dbbdd33a48"
--
-- @param entry, the json entry in array form.
-- @return data, an asssociative array with the entry data
-- @throw error in case the entry is malformed.
private function decodeCalendarEntry pEntryA
   if the number of lines in the keys of pEntryA is not 4 then
      throw "panchangamerr, malformed calendar entry"
   end if
   
   put pEntryA[4] into tDataA[pEntryA[1]]
   return tDataA
end decodeCalendarEntry

--- get a vevent
-- turns a vevent into an associative array
-- @param vevent, array with the vevent
-- @return data, an associative array with the vevent in a friendlier format
-- @throw error, in case of malformed vevent.
function decodeEvent pEventA
   if the number of lines in the keys of pEventA is not 3 then
      throw "panchangamerr, malformed event. not enough elements"
   end if
   
   if pEventA[1] is not "vevent" then
      throw "panchangamerr, malformed event. not an event"
   end if
   
   local tRetValA, tDataA
   
   repeat for each key k in pEventA[2]
      put decodeCalendarEntry(pEventA[2][k]) into tDataA
      union tRetValA with tDataA
   end repeat
   return tRetValA
end decodeEvent

--- get all events for a given calendar
-- @param calendar, array with calendar data
-- @return data, associative array of all events
function getAllEvents pCalendarA
   if isCalendarData(pCalendarA) is false then
      throw "panchangamerr, malformed calendar"
   end if
   
   repeat with x = 1 to the number of lines in the keys of pCalendarA[kCALENDAR_EVENTS_KEY]
      put decodeEvent(pCalendarA[kCALENDAR_EVENTS_KEY][x]) into tRetValA[x]
   end repeat
   
   return tRetValA
end getAllEvents

--- get all events for a given day
-- @param calendar, friendly associative array of calendar data (as returned by getAllEvents)
-- @param day, in the format of 2011-11-05
-- @return array, indexed array with all events for a given day
function getEventsForDate pCalendarA, pDate
   put 0 into tTotal
   repeat with x = 1 to the number of lines in the keys of pCalendarA
      put pCalendarA[x] into tEventA
      if tEventA["dtstart"] is pDate then
         add 1 to tTotal
         put tEventA into tRetValA[tTotal]
      end if
   end repeat
   return tRetValA
end getEventsForDate
