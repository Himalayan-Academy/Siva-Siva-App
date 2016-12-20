import moment from "moment-timezone"
import _ from "lodash"
import templates from "./templates.js"
import "ical.js"
import panchangam from "./panchagam.js"

/**
 * Calendar display
 */

function switchLocation(url) {
    url = "hawaii.ics";
    fetch(url).then(function (response) {
        return response.text()
    }).then(function (ics) {
        console.log("Calendar arrived, parsing...")
        panchangam.load(ics)
        displayCalendar(panchangam.root);
    });
}

function displayCalendar(root) {

    console.log("displaying calendar...")

    function displayDay(day) {
        console.log("day", day)
        var context = {
            calname: panchangam.calendarName,
            date: day.date,
            headline: day.summary,
            extra: day.extra_information,
            next_retreat: day.next_retreat
        }

        console.log(context);

        console.log("displaying day")
        console.log(templates)
        var template = templates.today;
        var html = template(context);
        document.body.innerHTML = html;
    }

    function displayMonth(events) {
        console.log("month", events)

        console.log("displaying month")
        var template = templates.month;
        var html = template(events);
        document.body.innerHTML = document.body.innerHTML + html;
        bindMenuControls()
        bindMonthControls()
        history.pushState(events, "Panchangam", "#panchangam")
    }

    // find today.
    var today = Date.now();
    var day = panchangam.informationForDate(today);
    console.log(day)
    displayDay(day);

    // display rest of the month.
    var events = panchangam.informationForMonth(today)
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

