document.addEventListener("DOMContentLoaded", function() {

    console.log("boot loaded.")

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
     *  Start app...
     */

    window.onpopstate = function(event) {
        console.log("popstate: ", event)
    }

    //showScreen("region-select")
    bindRegionSelector()

    console.log("fim")

});