/**
 * Panchagam Javascript ES6 Module
 * 
 * Author: Andre Alves Garzia <andre@andregarzia.com>
 * 
 * OBJECTIVE:
 * Provide high level functions to manipulate panchagams. Should be able to:
 * 
 *  [] Query calendar for day and month
 *  [] Get information for a given day
 * 
 * NOTES:
 * This module works with generated iCalendar files from Kauai Aadheenam which have some
 * assumptions regarding multiple vEvents for a given date.
 * 
 * DEPENDENCIES:
 * All dependencies are available on NPM and were installed with JSPM.
 *  
 *  - Moment-timezone
 *  - Lodash
 *  - iCal.js
 *  
 */

import _ from "lodash"
import "ical.js"
import moment from "moment-timezone"

const panchangam = {
    calendar_data: {},
    calendar_root: {},

    /**
     * load 
     * 
     * Receives an iCalendar string and loads it into memory
     * 
     * @param {any} ics
     * @returns
     */
    load: function(ics) {
        try {
            this.calendar_data = ICAL.parse(ics)
            this.calendar_root = new ICAL.Component(this.calendar_data)
            return true
        } catch(n) {
            console.error("Erro loading panchangam", n)
            return false
        }
    },

    /**
     * informationForDate
     * 
     * Receives a date and find all vEvents on the current loaded calendar that matches it and transform them into single value.
     * 
     * @param {any} date
     * @returns
     */
    informationForDate: function(date) {
        date = moment(date).format('YYYY-MM-DD')
        var events = this.calendar_root.getAllSubcomponents('vevent')

        // find all events for date
        var found_events = _.filter(events, function (event) {
            var summary = event.getFirstPropertyValue("summary");

            // Skip *loka Day
            var skippables = ["loka Day", "VRATA"];
            for (var i = 0; i <= skippables.length; i++) {
                if (summary.indexOf(skippables[i]) !== -1) {
                    return false;
                }
            }

            var dtstart = event.getFirstPropertyValue("dtstart").toString();
            return dtstart == date;

        });        
       
        var date_information = this.consolidateMultipleEventsIntoOne(found_events)

        return date_information
    },

    /**
     * Receives an array of events and consolidates it into friendlier single object.
     * 
     * @param {any} events
     * @returns
     */
    consolidateMultipleEventsIntoOne: function(events) {
        var date_information = {}

        date_information.date = events[0].getFirstPropertyValue("dtstart").toJSON()
        date_information.date.timezone = this.timezone
        date_information.summary = events[0].getFirstPropertyValue("summary")
        date_information.description = events[0].getFirstPropertyValue("description")
        date_information.extra_information = _.flatMap(events.slice(1), function (v) {
            return v.getFirstPropertyValue("summary")
        });

        date_information.next_retreat = this.findNextRetreat(date_information.date)

        return date_information
    },

    /**
     * findNextRetreat
     * 
     * Receives a date and returns an object with detailed information about the next retreat date.
     * 
     * @param {any} date
     * @returns
     */
    findNextRetreat: function(date) {
        date = moment(date);
        var events = this.calendar_root.getAllSubcomponents('vevent');
        var interval;

        var next_retreat = _.find(events, function(event) {
            var summary = event.getFirstPropertyValue("summary");
            var dtstart = event.getFirstPropertyValue("dtstart").toString();
            var event_date = moment(dtstart);
            interval = event_date.diff(date, "days");


            if (event_date.diff(date) <= 0) {
                // event is in the past, not needed.
                return false;
            }

            if (summary.indexOf("Retreat") !== -1) {
                return true;
            }
        });

        var return_value = {
            date: next_retreat.getFirstPropertyValue("dtstart").toString(),
            summary: next_retreat.getFirstPropertyValue("summary"),
            interval: interval
        }; 

        return return_value;
    },

    /**
     * informationForMonth
     * 
     * Receives a month (YYYY-MM) and returns all vEvents for it.
     * 
     * @param {any} month
     * @returns
     */
    informationForMonth: function(month) {
        month = moment(month).format('YYYY-MM');
        var events = this.calendar_root.getAllSubcomponents('vevent');

        // Find all the events for a given month.
        var found_events = _.filter(events, function (event) {

             // Skip *loka Day
            var summary = event.getFirstPropertyValue("summary");

            var skippables = ["loka Day", "VRATA"];
            for (var i = 0; i <= skippables.length; i++) {
                if (summary.indexOf(skippables[i]) !== -1) {
                    return false;
                }
            }

            var dtstart = event.getFirstPropertyValue("dtstart").toString().substr(0, 7);
            return dtstart == month;

        });

        // Group events for the same day

        found_events = _.transform(found_events, function(result, event) {
            var day = panchangam.getEventDate(event).day - 1

            if (!result[day]) {
                result[day] = [];
            }

            result[day].push(event)
        }, [])

        console.log("grouped events", found_events)

        // Transform them...
         var final_events = _.transform(found_events, function(result, e) {
            result.push(panchangam.consolidateMultipleEventsIntoOne(e))
        }, [])

        return final_events
    },

    getEventDate: function(event) {
        return event.getFirstPropertyValue("dtstart").toJSON()
    },

    getEventProperty: function(event, prop) {
        return event.getFirstPropertyValue(prop)
    },

    /**
     * getRoot
     * 
     * Just a getter for the iCalendar root.
     * @returns
     */
    get root() {
        return this.calendar_root
    },

    get calendarName() {
        return this.calendar_root.getFirstPropertyValue("x-wr-calname")
    },

    get timezone() {
        return this.calendar_root.getFirstPropertyValue("x-wr-timezone")
    }
}

export default panchangam



