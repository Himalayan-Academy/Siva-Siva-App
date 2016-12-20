System.config({
  baseURL: "",
  defaultJSExtensions: true,
  transpiler: "babel",
  babelOptions: {
    "optional": [
      "runtime",
      "optimisation.modules.system"
    ]
  },
  paths: {
    "github:*": "jspm_packages/github/*",
    "npm:*": "jspm_packages/npm/*"
  },
  bundles: {
    "build.js": [
      "lib/main.js",
      "lib/bootstrap.js",
      "lib/location-data.js",
      "npm:minimal-router@1.0.5.js",
      "npm:minimal-router@1.0.5/lib/index.js",
      "npm:minimal-router@1.0.5/lib/Router.js",
      "lib/functions.js",
      "lib/panchagam.js",
      "npm:moment-timezone@0.5.10.js",
      "npm:moment-timezone@0.5.10/builds/moment-timezone-with-data.js",
      "npm:moment@2.17.1.js",
      "npm:moment@2.17.1/moment.js",
      "npm:ical.js@1.2.2.js",
      "npm:ical.js@1.2.2/build/ical.js",
      "github:jspm/nodelibs-process@0.1.2.js",
      "github:jspm/nodelibs-process@0.1.2/index.js",
      "npm:process@0.11.9.js",
      "npm:process@0.11.9/browser.js",
      "npm:lodash@4.17.2.js",
      "npm:lodash@4.17.2/lodash.js",
      "npm:babel-runtime@5.8.38/core-js/object/define-properties.js",
      "npm:core-js@1.2.7/library/fn/object/define-properties.js",
      "npm:core-js@1.2.7/library/modules/$.js",
      "lib/templates.js",
      "lib/templates/day-details.hbs!github:davis/plugin-hbs@1.2.3.js",
      "github:components/handlebars.js@4.0.5/handlebars.runtime.js",
      "lib/templates/today.hbs!github:davis/plugin-hbs@1.2.3.js",
      "lib/templates/month.hbs!github:davis/plugin-hbs@1.2.3.js",
      "lib/templates/city-select-usa.hbs!github:davis/plugin-hbs@1.2.3.js",
      "lib/templates/region-select.hbs!github:davis/plugin-hbs@1.2.3.js"
    ]
  },

  map: {
    "babel": "npm:babel-core@5.8.38",
    "babel-runtime": "npm:babel-runtime@5.8.38",
    "core-js": "npm:core-js@1.2.7",
    "handlebars": "github:components/handlebars.js@4.0.5",
    "hbs": "github:davis/plugin-hbs@1.2.3",
    "ical.js": "npm:ical.js@1.2.2",
    "lodash": "npm:lodash@4.17.2",
    "minimal-router": "npm:minimal-router@1.0.5",
    "moment-timezone": "npm:moment-timezone@0.5.10",
    "github:davis/plugin-hbs@1.2.3": {
      "handlebars": "github:components/handlebars.js@4.0.5"
    },
    "github:jspm/nodelibs-assert@0.1.0": {
      "assert": "npm:assert@1.4.1"
    },
    "github:jspm/nodelibs-buffer@0.1.0": {
      "buffer": "npm:buffer@3.6.0"
    },
    "github:jspm/nodelibs-path@0.1.0": {
      "path-browserify": "npm:path-browserify@0.0.0"
    },
    "github:jspm/nodelibs-process@0.1.2": {
      "process": "npm:process@0.11.9"
    },
    "github:jspm/nodelibs-util@0.1.0": {
      "util": "npm:util@0.10.3"
    },
    "github:jspm/nodelibs-vm@0.1.0": {
      "vm-browserify": "npm:vm-browserify@0.0.4"
    },
    "npm:assert@1.4.1": {
      "assert": "github:jspm/nodelibs-assert@0.1.0",
      "buffer": "github:jspm/nodelibs-buffer@0.1.0",
      "process": "github:jspm/nodelibs-process@0.1.2",
      "util": "npm:util@0.10.3"
    },
    "npm:babel-runtime@5.8.38": {
      "process": "github:jspm/nodelibs-process@0.1.2"
    },
    "npm:buffer@3.6.0": {
      "base64-js": "npm:base64-js@0.0.8",
      "child_process": "github:jspm/nodelibs-child_process@0.1.0",
      "fs": "github:jspm/nodelibs-fs@0.1.2",
      "ieee754": "npm:ieee754@1.1.8",
      "isarray": "npm:isarray@1.0.0",
      "process": "github:jspm/nodelibs-process@0.1.2"
    },
    "npm:core-js@1.2.7": {
      "fs": "github:jspm/nodelibs-fs@0.1.2",
      "path": "github:jspm/nodelibs-path@0.1.0",
      "process": "github:jspm/nodelibs-process@0.1.2",
      "systemjs-json": "github:systemjs/plugin-json@0.1.2"
    },
    "npm:ical.js@1.2.2": {
      "process": "github:jspm/nodelibs-process@0.1.2"
    },
    "npm:inherits@2.0.1": {
      "util": "github:jspm/nodelibs-util@0.1.0"
    },
    "npm:moment-timezone@0.5.10": {
      "moment": "npm:moment@2.17.1",
      "systemjs-json": "github:systemjs/plugin-json@0.1.2"
    },
    "npm:path-browserify@0.0.0": {
      "process": "github:jspm/nodelibs-process@0.1.2"
    },
    "npm:process@0.11.9": {
      "assert": "github:jspm/nodelibs-assert@0.1.0",
      "fs": "github:jspm/nodelibs-fs@0.1.2",
      "vm": "github:jspm/nodelibs-vm@0.1.0"
    },
    "npm:util@0.10.3": {
      "inherits": "npm:inherits@2.0.1",
      "process": "github:jspm/nodelibs-process@0.1.2"
    },
    "npm:vm-browserify@0.0.4": {
      "indexof": "npm:indexof@0.0.1"
    }
  }
});
