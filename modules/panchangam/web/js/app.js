/**
 * Auxiliary Handlebar helpers
 */

Handlebars.registerHelper( "date", function ( date ){
    return date.month + "/" + date.day + "/" + date.year;
});

Handlebars.registerHelper("replaceNewLines", function(str){
    var breakTag = "<br>";
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ breakTag +'$2');
});


/**
 * Calendar display
 */

function switchLocation(url) {
    fetch(url).then(function(response) {
        return response.text()
    }).then(function(ics){
        var jcalData = ICAL.parse(ics);
        var root = new ICAL.Component(jcalData);
        console.log(root.getAllProperties())
        displayCalendar(root);
    });
}


function displayCalendar(root) {

    function findEventsForDate(date) {
        date = moment(date).format('YYYY-MM-DD');
        console.log("today:", date)
        var events = root.getAllSubcomponents('vevent');

        var found_events = _.filter(events, function(event) {
            var dtstart = event.getFirstPropertyValue("dtstart").toString();
            return dtstart == date;

        });

        console.log("found " + found_events.length + " events for this day");

        return found_events
    }

    function findEventsForMonth(date) {
        month = moment(date).format('YYYY-MM');
        console.log("month:", month)
        var events = root.getAllSubcomponents('vevent');

        var found_events = _.filter(events, function(event) {
            var dtstart = event.getFirstPropertyValue("dtstart").toString().substr(0,7);
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
            extra: _.flatMap(events.slice(1), function(v) {
                return v.getFirstPropertyValue("summary")
            })
        }

        var template = document.querySelector("#today-template").innerHTML;
        var templateScript = Handlebars.compile(template);
        var html = templateScript(context);
        document.body.innerHTML = html;
    }

    function displayMonth(events) {
        var context = _.reduce(events, function(result, value, key) {

            var day = value.getFirstPropertyValue("dtstart").toJSON().day;

            if (!result[day]) {
                result[day] = {};
            }

            result[day].date = value.getFirstPropertyValue("dtstart").toJSON();
            result[day].description = (result[day].description || " ") + value.getFirstPropertyValue("description");
            if (!result[day].summary) {
                result[day].summary = value.getFirstPropertyValue("summary")
            }

            return result;
        }, {});

        console.log(context);

        var template = document.querySelector("#month-template").innerHTML;
        var templateScript = Handlebars.compile(template);
        var html = templateScript(context);
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
        showScreen("region-select");
        bindRegionSelector();
    });

    // go back
    document.querySelector("#go-back-button").addEventListener("click", function() {
        history.go(-1);
    })
}

/**
 * Region and City select
 */

function bindRegionSelector() {
    document.querySelectorAll(".region-selector").forEach(function(item) {
        item.addEventListener("click", function(el) {
            var region = item.getAttribute("data-region");
            console.log(region);
            showScreen("city-select", {region: region});
            bindCitySelector()
        })
    })
}

function bindCitySelector() {
    document.querySelectorAll("[data-ics]").forEach(function(item) {
        item.addEventListener("click", function(el) {
            var url = item.getAttribute("data-ics");
            console.log(url);
            switchLocation(url);
        })
    })
}

function bindMonthControls() {

}

function showScreen(screen, state) {
    state = state || {}
    state.currentScreen = screen;
    var template = document.querySelector("#" + screen +"-template").innerHTML;
    var templateScript = Handlebars.compile(template);
    var html = templateScript(state);
    document.body.innerHTML = html;

    history.pushState(state, "Panchangam", "#" + screen);

}

/**
 *  Start app...
 */

window.onpopstate = function(event) {
    console.log("popstate: ", event)
}

showScreen("region-select")
bindRegionSelector()

