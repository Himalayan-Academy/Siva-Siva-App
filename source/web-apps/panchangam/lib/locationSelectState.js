
import region_select from "./templates/region-select.hbs!";
import city_select from "./templates/city-select.hbs!";
import locationData from './location-data'
import calendarDisplayState from "./calendarDisplayState.js"




function bindCitySelector() {
    document.querySelectorAll("[data-ics]").forEach(function (item) {
        item.addEventListener("click", function (el) {
            var url = item.getAttribute("data-ics");
            console.log(url);
            calendarDisplayState.makeActive(url);
        })
    })
}
function bindRegionSelector() {
    document.querySelectorAll("[data-region]").forEach(function (item) {
        item.addEventListener("click", function () {
            var region = item.getAttribute("data-region");
            showCitySelector(region);
        })
    })
}

function showRegionSelector() {
    document.body.innerHTML = region_select()
    bindRegionSelector()
}

function showCitySelector(region) {
    document.body.innerHTML = city_select(locationData[region])
    bindCitySelector()
}


let regionSelectState = {
    makeActive: function(region) {
        if (region) {
            showCitySelector(region)
        } else {
            showRegionSelector()
        }
    }
}

export default regionSelectState