// Templates 
import Handlebars from 'handlebars/handlebars.runtime';
import moment from "moment-timezone"

/**
 * Auxiliary Handlebar helpers
 */

export function setHandlebarsHelpers() {
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

    Handlebars.registerHelper("formatDate", function (date, format) {
        var date = date.year + "-" + date.month + "-" + date.day;
        var returnValue = moment.tz(date, "YYYY-MM-DD", date.timezone).format(format);
        return returnValue;
    });

    Handlebars.registerHelper("isoDate", function (date) {
        var date = date.year + "-" + date.month + "-" + date.day;
        var returnValue = moment.tz(date, "YYYY-MM-DD", date.timezone).format("YYYY-MM-DD");
        return returnValue;
    });

    Handlebars.registerHelper('isToday', function (passedDate, options) {
        var timezone = passedDate.timezone;
        var date = passedDate.year + "-" + passedDate.month + "-" + passedDate.day;
        var tentativeDate = moment.tz(date, timezone).format("YYYY-MM-DD")
        var today = moment.tz(Date.now(), timezone).format("YYYY-MM-DD")
        if (tentativeDate === today) {
            return options.fn(this);
        }

    });

    Handlebars.registerHelper("replaceNewLines", function (str) {
        var breakTag = "<br>";
        return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2');
    });

    Handlebars.registerHelper('from_index', function (context, ndx) {
        return context.slice(ndx).join(" &bull; ");
    });


    Handlebars.registerHelper('retreatLabel', function (days) {
        if (days > 1) {
            return days + " days until"
        } else {
            return "Tomorrow is"
        }
    });

    Handlebars.registerHelper("debug", function (optionalValue) {
        console.log("Current Context");
        console.log("====================");
        console.log(this);

        if (optionalValue) {
            console.log("Value");
            console.log("====================");
            console.log(optionalValue);
        }
    });
};

export default setHandlebarsHelpers;
