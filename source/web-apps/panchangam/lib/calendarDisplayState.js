import panchangam from "./panchagam.js";
import month from "./templates/month.hbs!";
import monthNavigation from "./templates/month-navigation.hbs!";
import today from "./templates/today.hbs!";
import dayDetailsModal from "./templates/day-details.hbs!";
import locationSelectState from "./locationSelectState.js";
import jump from 'jump.js';
import 'whatwg-fetch'

let calendarDisplayState = {
    todayDisplayElement: function() {
        return document.querySelector("#today-display")
    },
    monthDisplayElement: function() {
        return document.querySelector("#month-display")
    },
    monthNavigationElement: function() {
        return document.querySelector("#month-navigation")
    },
    dateModalDisplayElement: function() {
        return document.querySelector("#date-info-modal-display")
    },
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

        var displayDay = (day) => {
            console.log("day", day)
            var context = {
                calname: panchangam.calendarName,
                date: day.date,
                headline: day.summary,
                description: day.description,
                extra: day.extra_information,
                next_retreat: day.next_retreat
            }

            console.log("displaying day")
            var html = today(context);
            document.querySelector("#today-display").innerHTML = html;
        }

        var displayMonth = (events) => {
            console.log("displaying month")
            var html = month(events);
            document.querySelector("#month-display").innerHTML = html;

        }

        var displayMonthNavigation = (month) => {
            var html = monthNavigation(month);
            document.querySelector("#month-navigation").innerHTML = html;
        }

        // find today.
        var now = Date.now();
        var day = panchangam.informationForDate(now);
        displayDay(day);

        displayMonthNavigation(day)

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
            locationSelectState.makeActive()
        });

        // go back
        document.querySelector("#go-back-button").addEventListener("click", function () {
            history.go(-1);
        });

        document.querySelector("#today-scroll-trigger").addEventListener("click", function (evt) {
            evt.preventDefault();
            jump(this.getAttribute("href"));
        });

        // Modals
        var openers = document.querySelectorAll("[data-modal-open]");
        [].forEach.call(openers, function (element) {
            element.addEventListener("click", function () {
                var date = element.getAttribute("data-date");
                console.log("date", date)
                var info = panchangam.informationForDate(date);
                var dateHtml = dayDetailsModal(info);
                var target = document.querySelector("#" + element.getAttribute("data-modal-open"));
                target.innerHTML = dateHtml;
                target.classList.add("is-active");

                var closers = document.querySelectorAll("[data-modal-close]");
                [].forEach.call(closers, function (element) {
                    element.addEventListener("click", function () {
                        var target = document.querySelector("#" + element.getAttribute("data-modal-close"));
                        target.classList.remove("is-active")
                    })
                });
            })
        })

        // scroll header
        document.body.onscroll = function() {
           if (window.pageYOffset > (window.innerHeight - 100)) {
               document.querySelector("#month-navigation-container").classList.remove("is-hidden");
           } else {
               document.querySelector("#month-navigation-container").classList.add("is-hidden");
           }
        }


    }
}

export default calendarDisplayState;