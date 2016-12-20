import templates from "./templates.js"
import "ical.js"
import panchangam from "./panchagam.js"

/**
 * Calendar display
 */

export function loadPanchangamFromURL(url) {
    console.log("Loading panchangam from URL", url)
    fetch(url).then(function (response) {
        return response.text()
    }).then(function (ics) {
        console.log("Calendar arrived, parsing...")
        let loaded = panchangam.load(ics)
        if (loaded) {
            localStorage.setItem("calendar", ics)
        }
        displayCalendar(panchangam.root);
    });
}

export function loadPanchangamFromMemory() {
    console.log("Loading panchangam from memory")

    let ics = localStorage.getItem("calendar")

    if (!ics) {
        return false
    }

    let loaded = panchangam.load(ics)

    if (!loaded) {
        return false
    }

    displayCalendar(panchangam.root)

    return true
}

function displayCalendar(root) {

    console.log("displaying calendar...")

    function displayDay(day) {
        console.log("day", day)
        var context = {
            calname: panchangam.calendarName,
            date: day.date,
            headline: day.summary,
            description: day.description,
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

    }

    // find today.
    var today = Date.now();
    var day = panchangam.informationForDate(today);
    console.log(day)
    displayDay(day);

    // display rest of the month.
    var events = panchangam.informationForMonth(today)
    displayMonth(events);

    bindMenuControls()
    bindDayControls()
    bindMonthControls()
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

    // Modals
    var openers = document.querySelectorAll("[data-modal-open]");
    [].forEach.call(openers, function(element) {
        element.addEventListener("click", function() {
            var target = document.querySelector("#" + element.getAttribute("data-modal-open"));
            target.classList.add("is-active")
        })
    })

    var closers = document.querySelectorAll("[data-modal-close]");
    [].forEach.call(closers, function(element) {
        element.addEventListener("click", function() {
            var target = document.querySelector("#" + element.getAttribute("data-modal-close"));
            target.classList.remove("is-active")
        })
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

export function bindCitySelector() {
    document.querySelectorAll("[data-ics]").forEach(function (item) {
        item.addEventListener("click", function (el) {
            var url = item.getAttribute("data-ics");
            console.log(url);
            loadPanchangamFromURL(url);
        })
    })
}

function bindMonthControls() {

}

function bindDayControls() {

}

export function showScreen(screen, state) {
    console.log("show screen:", screen)
    state = state || {}
    state.currentScreen = screen;
    var html = templates[screen](state);
    document.body.innerHTML = html;
}

