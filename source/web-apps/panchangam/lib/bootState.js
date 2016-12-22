import locationSelectState from "./locationSelectState.js"
import calendarDisplayState from "./calendarDisplayState.js"

function bootstrap() {

    console.log("Boot loaded.")

    var ics = localStorage.getItem("calendar");

    if (!ics) {
        locationSelectState.makeActive()
    } else {
        calendarDisplayState.makeActive(null, ics)
    }

}

export default {
    makeActive: bootstrap
}