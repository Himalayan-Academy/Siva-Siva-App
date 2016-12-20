import {bindCitySelector, showScreen, loadPanchangamFromURL, loadPanchangamFromMemory} from './functions.js';
import Router from 'minimal-router'
import locationData from './location-data'

const router = new Router();

export function bootstrap() {

    console.log("Boot loaded.")
    console.log("Setting routes...")

    router.setPrefix('#');

    router.add('region-select', '/region', function () {
        showScreen("region_select")
    })

    router.add('region-specific', '/region/:region', function ({params, query}) {
        var region = params.region;
        console.log("Specific region", region)
        showScreen("city_select_usa", locationData[region]);
        bindCitySelector()
    })


    router.add('/calendar/:city', function ({params, query}) {
        const city = params.city;
        loadPanchangamFromURL(city)
        // ... do something with city and sort
    });

    router.add('/calendar/:city/:year', function ({params, query}) {
        const city = params.city;
        const year = params.year;
        // ... do something with city and sort
    });

    router.add('/calendar/:city/:year/:month', function ({params, query}) {
        const city = params.city;
        const year = params.year;
        const month = params.month;

        // ... do something with city and sort
    });

    router.add('/calendar/:city/:year/:month/:day', function ({params, query}) {
        const city = params.city;
        const year = params.year;
        const month = params.month;
        const day = params.day
        // ... do something with city and sort
    });

    // Listen browser event for back navigation
    window.onpopstate = function (event) {
        // dispatch current url to route
        var path = document.location.hash;
        if (document.location.search.length) {
            path += '?' + document.location.search;
        }
        router.dispatch(path);
    };

    // Navigate to other routes
    const navigate = function (routeName, query, params) {
        const url = router.formatUrl(routeName, query, params);
        console.log("url", url)
        history.pushState(null, null, url);
        router.dispatch(url);
    };

    console.log("end of boot sequence")

    if (!location.hash) {

        var ics = localStorage.getItem("calendar");

        if (!ics) {
            navigate("region-select")
        } else {
            loadPanchangamFromMemory()
        }
    }

}