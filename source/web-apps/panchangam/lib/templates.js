// Templates 
import Handlebars from 'handlebars/handlebars.runtime';
import moment from "moment-timezone"

import region_select from "./templates/region-select.hbs!";
import city_select from "./templates/city-select.hbs!";
import month from "./templates/month.hbs!";
import today from "./templates/today.hbs!"
import day_details from "./templates/day-details.hbs!";

var templates = {
    region_select,
    city_select_usa,
    month,
    today,
    day_details
}


/**
 * Auxiliary Handlebar helpers
 */

Handlebars.registerHelper("prettyDate", function (date) {
    var date = date.year + "-" + date.month + "-" + date.day;
    var returnValue = moment.tz(date, "YYYY-MM-DD", date.timezone).format("MMM Do YYYY, dddd");
    return returnValue;
});

Handlebars.registerHelper("shortDate", function (date) {
    var date = date.year + "-" + date.month + "-" + date.day;
    var returnValue = moment.tz(date, "YYYY-MM-DD", date.timezone).format("MMM Do, ddd");
    return returnValue;
});

Handlebars.registerHelper("replaceNewLines", function (str) {
    var breakTag = "<br>";
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2');
});

Handlebars.registerHelper('from_index', function(context,ndx) {
  return context.slice(ndx).join(" &bull; ");
});


Handlebars.registerHelper('retreatLabel', function(days) {
    if (days > 1) {
        return days + " days until"
    } else {
        return "Tomorrow is"
    }
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

export default templates;
