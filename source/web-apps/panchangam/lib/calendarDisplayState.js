import panchangam from "./panchagam.js";
import month from "./templates/month.hbs!";
import today from "./templates/today.hbs!";

let calendarDisplayState = {
    makeActive: function (url, ics) {
        if (url) {
            // fetch and display...
            console.log("Loading panchangam from URL", url)
            fetch(url).then((response) => {
                return response.text()
            }).then((ics) => {
                this.loadAndDisplay(ics)
            });
        }

        if (ics) {
            // display iCalendar
            this.loadAndDisplay(ics)
        }
    },

    loadAndDisplay: function (ics) {
        console.log("Calendar arrived, parsing...")
        let loaded = panchangam.load(ics)
        if (loaded) {
            localStorage.setItem("calendar", ics)
        }
        this.displayCalendar(panchangam.root);
    },


    displayCalendar: function (root) {

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
            var html = today(context);
            document.body.innerHTML = html;
        }

        function displayMonth(events) {
            console.log("month", events)

            console.log("displaying month")
            var html = month(events);
            document.body.innerHTML = document.body.innerHTML + html;

        }

        // find today.
        var now = Date.now();
        var day = panchangam.informationForDate(now);
        console.log(day)
        displayDay(day);

        // display rest of the month.
        var events = panchangam.informationForMonth(now)
        displayMonth(events);

        this.bindMenuControls()
    },

    bindMenuControls: function () {
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
        [].forEach.call(openers, function (element) {
            element.addEventListener("click", function () {
                var target = document.querySelector("#" + element.getAttribute("data-modal-open"));
                target.classList.add("is-active")
            })
        })

        var closers = document.querySelectorAll("[data-modal-close]");
        [].forEach.call(closers, function (element) {
            element.addEventListener("click", function () {
                var target = document.querySelector("#" + element.getAttribute("data-modal-close"));
                target.classList.remove("is-active")
            })
        })
    }
}

export default calendarDisplayState;