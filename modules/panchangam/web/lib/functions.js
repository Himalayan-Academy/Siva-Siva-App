import moment from "moment-timezone"
import _ from "lodash"
import templates from "./templates.js"
import Handlebars from 'handlebars/handlebars.runtime';
import "ical.js"
import "whatwg-fetch"



/**
 * Auxiliary Handlebar helpers
 */

Handlebars.registerHelper("prettyDate", function (date) {
    var date = date.year + "-" + date.month + "-" + date.day;
    var returnValue = moment.tz(date, "YYYY-MM-DD", date.timezone).format("MMM Do YYYY, dddd");
    return returnValue;
});

Handlebars.registerHelper("replaceNewLines", function (str) {
    var breakTag = "<br>";
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2');
});

Handlebars.registerHelper("debug", function(optionalValue) {
  console.log("Current Context");
  console.log("====================");
  console.log(this);
 
  if (optionalValue) {
    console.log("Value");
    console.log("====================");
    console.log(optionalValue);
  }
});

/**
 * Calendar display
 */

function switchLocation(url) {
    url = "hawaii.ics";
    fetch(url).then(function (response) {
        return response.text()
    }).then(function (ics) {
        console.log("Calendar arrived, parsing...")
        console.log(ics.length)
        console.log(ics.substr(ics.length - 200));
        try {
            var jcalData = ICAL.parse(ics)
            console.log("jcaldata", jcalData)
            var root = new ICAL.Component(jcalData);
            console.log("root", root)
            console.log(root.getAllProperties())
            displayCalendar(root);
        } catch (n) {
            console.log("Error parsing panchangam:", n.name);
            console.log(n.message);
            console.error(n)
        }
    });
}

function displayCalendar(root) {

    function findEventsForDate(date) {
        date = moment(date).format('YYYY-MM-DD');
        console.log("today:", date)
        var events = root.getAllSubcomponents('vevent');

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

        console.log("found " + found_events.length + " events for this day");

        return found_events
    }

    function findNextRetreat(date) {
        date = moment(date);
        var events = root.getAllSubcomponents('vevent');
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
                console.log("retreat star", event);
                console.log("interval", interval)
                return true;
            }
        });

        var return_value = {
            date: next_retreat.getFirstPropertyValue("dtstart").toString(),
            summary: next_retreat.getFirstPropertyValue("summary"),
            interval: interval
        }; 

        return return_value;
    }

    function findEventsForMonth(month) {
        month = moment(month).format('YYYY-MM');
        console.log("month:", month)
        var events = root.getAllSubcomponents('vevent');

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

        console.log("found " + found_events.length + " events for this month");
        return found_events
    }

    function displayDay(events) {
        var context = {
            calname: root.getFirstPropertyValue("x-wr-calname"),
            date: events[0].getFirstPropertyValue("dtstart").toJSON(),
            headline: events[0].getFirstPropertyValue("summary"),
            extra: _.flatMap(events.slice(1), function (v) {
                return v.getFirstPropertyValue("summary")
            })
        }

        context.next_retreat = findNextRetreat(events[0].getFirstPropertyValue("dtstart"));

        context.date.timezone = root.getFirstPropertyValue("x-wr-timezone");
        console.log(context);

        console.log("displaying day")
        console.log(templates)
        var template = templates.today;
        var html = template(context);
        document.body.innerHTML = html;
    }

    function displayMonth(events) {
        var context = _.reduce(events, function (result, value, key) {

            var day = value.getFirstPropertyValue("dtstart").toJSON().day;

            if (!result[day]) {
                result[day] = {};
            }

            result[day].date = value.getFirstPropertyValue("dtstart").toJSON();
            result[day].date.timezone = root.getFirstPropertyValue("x-wr-timezone");
            result[day].description = (result[day].description || " ") + value.getFirstPropertyValue("description");
            if (!result[day].summary) {
                result[day].summary = value.getFirstPropertyValue("summary")
            }

            return result;
        }, {});

        console.log(context);

        console.log("displaying month")
        var template = templates.month;
        var html = template(context);
        document.body.innerHTML = document.body.innerHTML + html;
        bindMenuControls()
        bindMonthControls()
        history.pushState(context, "Panchangam", "#panchangam")
    }


    // find today.
    var today = Date.now();
    var events = findEventsForDate(today);
    displayDay(events);

    // display rest of the month.
    events = findEventsForMonth(today)
    displayMonth(events);
}

function bindMenuControls() {
    // Menu Toggle
    document.querySelector('.nav-toggle').addEventListener("click", function () {
        this.classList.toggle("is-active");
        document.querySelector('.nav-menu').classList.toggle('is-active');
    });

    // Location toggle
    document.querySelector('#switch-location').addEventListener("click", function () {
        showScreen("region_select");
        bindRegionSelector();
    });

    // go back
    document.querySelector("#go-back-button").addEventListener("click", function () {
        history.go(-1);
    })
}

/**
 * Region and City select
 */

export function bindRegionSelector() {
    document.querySelectorAll(".region-selector").forEach(function (item) {
        item.addEventListener("click", function (el) {
            var region = item.getAttribute("data-region");
            console.log(region);
            showScreen("city_select_usa", { region: region });
            bindCitySelector()
        })
    })
}

function bindCitySelector() {
    document.querySelectorAll("[data-ics]").forEach(function (item) {
        item.addEventListener("click", function (el) {
            var url = item.getAttribute("data-ics");
            console.log(url);
            switchLocation(url);
        })
    })
}

function bindMonthControls() {

}

export function showScreen(screen, state) {
    console.log("show screen:", screen)
    state = state || {}
    state.currentScreen = screen;
    var html = templates[screen](state);
    document.body.innerHTML = html;

    history.pushState(state, "Panchangam", "#" + screen);

}

