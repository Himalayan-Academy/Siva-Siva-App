"bundle";
System.registerDynamic("lib/templates/region-select.hbs!github:davis/plugin-hbs@1.2.3.js", ["github:components/handlebars.js@4.0.5/handlebars.runtime.js"], true, function ($__require, exports, module) {
  var define,
      global = this || self,
      GLOBAL = global;
  var Handlebars = $__require("github:components/handlebars.js@4.0.5/handlebars.runtime.js");
  module.exports = Handlebars.template({ "compiler": [7, ">= 4.0.0"], "main": function (container, depth0, helpers, partials, data) {
      return " <section class=\"section has-lotus-background is-fullheight\">\r\n        <div class=\"container\">\r\n            <div class=\"heading has-translucent-box has-padding-10\">\r\n                <h1 class=\"title\">Select your location</h1>\r\n                <h2 class=\"subtitle\">\r\n                    Please, select your location to view the correct Panchangam\r\n                </h2>\r\n            </div>\r\n            <a href=\"#/region/usa\" class=\"button is-primary is-large region-selector\">USA</a>\r\n            <a href=\"#/region/world\" class=\"button is-primary is-large region-selector\">World</a>\r\n        </div>\r\n    </section>";
    }, "useData": true });
  return module.exports;
});
(function() {
var define = System.amdDefine;
"format amd";
(function webpackUniversalModuleDefinition(root, factory) {
  if (typeof exports === 'object' && typeof module === 'object')
    module.exports = factory();
  else if (typeof define === 'function' && define.amd)
    define("github:components/handlebars.js@4.0.5/handlebars.runtime.js", [], factory);
  else if (typeof exports === 'object')
    exports["Handlebars"] = factory();
  else
    root["Handlebars"] = factory();
})(this, function() {
  return (function(modules) {
    var installedModules = {};
    function __webpack_require__(moduleId) {
      if (installedModules[moduleId])
        return installedModules[moduleId].exports;
      var module = installedModules[moduleId] = {
        exports: {},
        id: moduleId,
        loaded: false
      };
      modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
      module.loaded = true;
      return module.exports;
    }
    __webpack_require__.m = modules;
    __webpack_require__.c = installedModules;
    __webpack_require__.p = "";
    return __webpack_require__(0);
  })([function(module, exports, __webpack_require__) {
    'use strict';
    var _interopRequireWildcard = __webpack_require__(1)['default'];
    var _interopRequireDefault = __webpack_require__(2)['default'];
    exports.__esModule = true;
    var _handlebarsBase = __webpack_require__(3);
    var base = _interopRequireWildcard(_handlebarsBase);
    var _handlebarsSafeString = __webpack_require__(17);
    var _handlebarsSafeString2 = _interopRequireDefault(_handlebarsSafeString);
    var _handlebarsException = __webpack_require__(5);
    var _handlebarsException2 = _interopRequireDefault(_handlebarsException);
    var _handlebarsUtils = __webpack_require__(4);
    var Utils = _interopRequireWildcard(_handlebarsUtils);
    var _handlebarsRuntime = __webpack_require__(18);
    var runtime = _interopRequireWildcard(_handlebarsRuntime);
    var _handlebarsNoConflict = __webpack_require__(19);
    var _handlebarsNoConflict2 = _interopRequireDefault(_handlebarsNoConflict);
    function create() {
      var hb = new base.HandlebarsEnvironment();
      Utils.extend(hb, base);
      hb.SafeString = _handlebarsSafeString2['default'];
      hb.Exception = _handlebarsException2['default'];
      hb.Utils = Utils;
      hb.escapeExpression = Utils.escapeExpression;
      hb.VM = runtime;
      hb.template = function(spec) {
        return runtime.template(spec, hb);
      };
      return hb;
    }
    var inst = create();
    inst.create = create;
    _handlebarsNoConflict2['default'](inst);
    inst['default'] = inst;
    exports['default'] = inst;
    module.exports = exports['default'];
  }, function(module, exports) {
    "use strict";
    exports["default"] = function(obj) {
      if (obj && obj.__esModule) {
        return obj;
      } else {
        var newObj = {};
        if (obj != null) {
          for (var key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key))
              newObj[key] = obj[key];
          }
        }
        newObj["default"] = obj;
        return newObj;
      }
    };
    exports.__esModule = true;
  }, function(module, exports) {
    "use strict";
    exports["default"] = function(obj) {
      return obj && obj.__esModule ? obj : {"default": obj};
    };
    exports.__esModule = true;
  }, function(module, exports, __webpack_require__) {
    'use strict';
    var _interopRequireDefault = __webpack_require__(2)['default'];
    exports.__esModule = true;
    exports.HandlebarsEnvironment = HandlebarsEnvironment;
    var _utils = __webpack_require__(4);
    var _exception = __webpack_require__(5);
    var _exception2 = _interopRequireDefault(_exception);
    var _helpers = __webpack_require__(6);
    var _decorators = __webpack_require__(14);
    var _logger = __webpack_require__(16);
    var _logger2 = _interopRequireDefault(_logger);
    var VERSION = '4.0.5';
    exports.VERSION = VERSION;
    var COMPILER_REVISION = 7;
    exports.COMPILER_REVISION = COMPILER_REVISION;
    var REVISION_CHANGES = {
      1: '<= 1.0.rc.2',
      2: '== 1.0.0-rc.3',
      3: '== 1.0.0-rc.4',
      4: '== 1.x.x',
      5: '== 2.0.0-alpha.x',
      6: '>= 2.0.0-beta.1',
      7: '>= 4.0.0'
    };
    exports.REVISION_CHANGES = REVISION_CHANGES;
    var objectType = '[object Object]';
    function HandlebarsEnvironment(helpers, partials, decorators) {
      this.helpers = helpers || {};
      this.partials = partials || {};
      this.decorators = decorators || {};
      _helpers.registerDefaultHelpers(this);
      _decorators.registerDefaultDecorators(this);
    }
    HandlebarsEnvironment.prototype = {
      constructor: HandlebarsEnvironment,
      logger: _logger2['default'],
      log: _logger2['default'].log,
      registerHelper: function registerHelper(name, fn) {
        if (_utils.toString.call(name) === objectType) {
          if (fn) {
            throw new _exception2['default']('Arg not supported with multiple helpers');
          }
          _utils.extend(this.helpers, name);
        } else {
          this.helpers[name] = fn;
        }
      },
      unregisterHelper: function unregisterHelper(name) {
        delete this.helpers[name];
      },
      registerPartial: function registerPartial(name, partial) {
        if (_utils.toString.call(name) === objectType) {
          _utils.extend(this.partials, name);
        } else {
          if (typeof partial === 'undefined') {
            throw new _exception2['default']('Attempting to register a partial called "' + name + '" as undefined');
          }
          this.partials[name] = partial;
        }
      },
      unregisterPartial: function unregisterPartial(name) {
        delete this.partials[name];
      },
      registerDecorator: function registerDecorator(name, fn) {
        if (_utils.toString.call(name) === objectType) {
          if (fn) {
            throw new _exception2['default']('Arg not supported with multiple decorators');
          }
          _utils.extend(this.decorators, name);
        } else {
          this.decorators[name] = fn;
        }
      },
      unregisterDecorator: function unregisterDecorator(name) {
        delete this.decorators[name];
      }
    };
    var log = _logger2['default'].log;
    exports.log = log;
    exports.createFrame = _utils.createFrame;
    exports.logger = _logger2['default'];
  }, function(module, exports) {
    'use strict';
    exports.__esModule = true;
    exports.extend = extend;
    exports.indexOf = indexOf;
    exports.escapeExpression = escapeExpression;
    exports.isEmpty = isEmpty;
    exports.createFrame = createFrame;
    exports.blockParams = blockParams;
    exports.appendContextPath = appendContextPath;
    var escape = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#x27;',
      '`': '&#x60;',
      '=': '&#x3D;'
    };
    var badChars = /[&<>"'`=]/g,
        possible = /[&<>"'`=]/;
    function escapeChar(chr) {
      return escape[chr];
    }
    function extend(obj) {
      for (var i = 1; i < arguments.length; i++) {
        for (var key in arguments[i]) {
          if (Object.prototype.hasOwnProperty.call(arguments[i], key)) {
            obj[key] = arguments[i][key];
          }
        }
      }
      return obj;
    }
    var toString = Object.prototype.toString;
    exports.toString = toString;
    var isFunction = function isFunction(value) {
      return typeof value === 'function';
    };
    if (isFunction(/x/)) {
      exports.isFunction = isFunction = function(value) {
        return typeof value === 'function' && toString.call(value) === '[object Function]';
      };
    }
    exports.isFunction = isFunction;
    var isArray = Array.isArray || function(value) {
      return value && typeof value === 'object' ? toString.call(value) === '[object Array]' : false;
    };
    exports.isArray = isArray;
    function indexOf(array, value) {
      for (var i = 0,
          len = array.length; i < len; i++) {
        if (array[i] === value) {
          return i;
        }
      }
      return -1;
    }
    function escapeExpression(string) {
      if (typeof string !== 'string') {
        if (string && string.toHTML) {
          return string.toHTML();
        } else if (string == null) {
          return '';
        } else if (!string) {
          return string + '';
        }
        string = '' + string;
      }
      if (!possible.test(string)) {
        return string;
      }
      return string.replace(badChars, escapeChar);
    }
    function isEmpty(value) {
      if (!value && value !== 0) {
        return true;
      } else if (isArray(value) && value.length === 0) {
        return true;
      } else {
        return false;
      }
    }
    function createFrame(object) {
      var frame = extend({}, object);
      frame._parent = object;
      return frame;
    }
    function blockParams(params, ids) {
      params.path = ids;
      return params;
    }
    function appendContextPath(contextPath, id) {
      return (contextPath ? contextPath + '.' : '') + id;
    }
  }, function(module, exports) {
    'use strict';
    exports.__esModule = true;
    var errorProps = ['description', 'fileName', 'lineNumber', 'message', 'name', 'number', 'stack'];
    function Exception(message, node) {
      var loc = node && node.loc,
          line = undefined,
          column = undefined;
      if (loc) {
        line = loc.start.line;
        column = loc.start.column;
        message += ' - ' + line + ':' + column;
      }
      var tmp = Error.prototype.constructor.call(this, message);
      for (var idx = 0; idx < errorProps.length; idx++) {
        this[errorProps[idx]] = tmp[errorProps[idx]];
      }
      if (Error.captureStackTrace) {
        Error.captureStackTrace(this, Exception);
      }
      if (loc) {
        this.lineNumber = line;
        this.column = column;
      }
    }
    Exception.prototype = new Error();
    exports['default'] = Exception;
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    var _interopRequireDefault = __webpack_require__(2)['default'];
    exports.__esModule = true;
    exports.registerDefaultHelpers = registerDefaultHelpers;
    var _helpersBlockHelperMissing = __webpack_require__(7);
    var _helpersBlockHelperMissing2 = _interopRequireDefault(_helpersBlockHelperMissing);
    var _helpersEach = __webpack_require__(8);
    var _helpersEach2 = _interopRequireDefault(_helpersEach);
    var _helpersHelperMissing = __webpack_require__(9);
    var _helpersHelperMissing2 = _interopRequireDefault(_helpersHelperMissing);
    var _helpersIf = __webpack_require__(10);
    var _helpersIf2 = _interopRequireDefault(_helpersIf);
    var _helpersLog = __webpack_require__(11);
    var _helpersLog2 = _interopRequireDefault(_helpersLog);
    var _helpersLookup = __webpack_require__(12);
    var _helpersLookup2 = _interopRequireDefault(_helpersLookup);
    var _helpersWith = __webpack_require__(13);
    var _helpersWith2 = _interopRequireDefault(_helpersWith);
    function registerDefaultHelpers(instance) {
      _helpersBlockHelperMissing2['default'](instance);
      _helpersEach2['default'](instance);
      _helpersHelperMissing2['default'](instance);
      _helpersIf2['default'](instance);
      _helpersLog2['default'](instance);
      _helpersLookup2['default'](instance);
      _helpersWith2['default'](instance);
    }
  }, function(module, exports, __webpack_require__) {
    'use strict';
    exports.__esModule = true;
    var _utils = __webpack_require__(4);
    exports['default'] = function(instance) {
      instance.registerHelper('blockHelperMissing', function(context, options) {
        var inverse = options.inverse,
            fn = options.fn;
        if (context === true) {
          return fn(this);
        } else if (context === false || context == null) {
          return inverse(this);
        } else if (_utils.isArray(context)) {
          if (context.length > 0) {
            if (options.ids) {
              options.ids = [options.name];
            }
            return instance.helpers.each(context, options);
          } else {
            return inverse(this);
          }
        } else {
          if (options.data && options.ids) {
            var data = _utils.createFrame(options.data);
            data.contextPath = _utils.appendContextPath(options.data.contextPath, options.name);
            options = {data: data};
          }
          return fn(context, options);
        }
      });
    };
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    var _interopRequireDefault = __webpack_require__(2)['default'];
    exports.__esModule = true;
    var _utils = __webpack_require__(4);
    var _exception = __webpack_require__(5);
    var _exception2 = _interopRequireDefault(_exception);
    exports['default'] = function(instance) {
      instance.registerHelper('each', function(context, options) {
        if (!options) {
          throw new _exception2['default']('Must pass iterator to #each');
        }
        var fn = options.fn,
            inverse = options.inverse,
            i = 0,
            ret = '',
            data = undefined,
            contextPath = undefined;
        if (options.data && options.ids) {
          contextPath = _utils.appendContextPath(options.data.contextPath, options.ids[0]) + '.';
        }
        if (_utils.isFunction(context)) {
          context = context.call(this);
        }
        if (options.data) {
          data = _utils.createFrame(options.data);
        }
        function execIteration(field, index, last) {
          if (data) {
            data.key = field;
            data.index = index;
            data.first = index === 0;
            data.last = !!last;
            if (contextPath) {
              data.contextPath = contextPath + field;
            }
          }
          ret = ret + fn(context[field], {
            data: data,
            blockParams: _utils.blockParams([context[field], field], [contextPath + field, null])
          });
        }
        if (context && typeof context === 'object') {
          if (_utils.isArray(context)) {
            for (var j = context.length; i < j; i++) {
              if (i in context) {
                execIteration(i, i, i === context.length - 1);
              }
            }
          } else {
            var priorKey = undefined;
            for (var key in context) {
              if (context.hasOwnProperty(key)) {
                if (priorKey !== undefined) {
                  execIteration(priorKey, i - 1);
                }
                priorKey = key;
                i++;
              }
            }
            if (priorKey !== undefined) {
              execIteration(priorKey, i - 1, true);
            }
          }
        }
        if (i === 0) {
          ret = inverse(this);
        }
        return ret;
      });
    };
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    var _interopRequireDefault = __webpack_require__(2)['default'];
    exports.__esModule = true;
    var _exception = __webpack_require__(5);
    var _exception2 = _interopRequireDefault(_exception);
    exports['default'] = function(instance) {
      instance.registerHelper('helperMissing', function() {
        if (arguments.length === 1) {
          return undefined;
        } else {
          throw new _exception2['default']('Missing helper: "' + arguments[arguments.length - 1].name + '"');
        }
      });
    };
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    exports.__esModule = true;
    var _utils = __webpack_require__(4);
    exports['default'] = function(instance) {
      instance.registerHelper('if', function(conditional, options) {
        if (_utils.isFunction(conditional)) {
          conditional = conditional.call(this);
        }
        if (!options.hash.includeZero && !conditional || _utils.isEmpty(conditional)) {
          return options.inverse(this);
        } else {
          return options.fn(this);
        }
      });
      instance.registerHelper('unless', function(conditional, options) {
        return instance.helpers['if'].call(this, conditional, {
          fn: options.inverse,
          inverse: options.fn,
          hash: options.hash
        });
      });
    };
    module.exports = exports['default'];
  }, function(module, exports) {
    'use strict';
    exports.__esModule = true;
    exports['default'] = function(instance) {
      instance.registerHelper('log', function() {
        var args = [undefined],
            options = arguments[arguments.length - 1];
        for (var i = 0; i < arguments.length - 1; i++) {
          args.push(arguments[i]);
        }
        var level = 1;
        if (options.hash.level != null) {
          level = options.hash.level;
        } else if (options.data && options.data.level != null) {
          level = options.data.level;
        }
        args[0] = level;
        instance.log.apply(instance, args);
      });
    };
    module.exports = exports['default'];
  }, function(module, exports) {
    'use strict';
    exports.__esModule = true;
    exports['default'] = function(instance) {
      instance.registerHelper('lookup', function(obj, field) {
        return obj && obj[field];
      });
    };
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    exports.__esModule = true;
    var _utils = __webpack_require__(4);
    exports['default'] = function(instance) {
      instance.registerHelper('with', function(context, options) {
        if (_utils.isFunction(context)) {
          context = context.call(this);
        }
        var fn = options.fn;
        if (!_utils.isEmpty(context)) {
          var data = options.data;
          if (options.data && options.ids) {
            data = _utils.createFrame(options.data);
            data.contextPath = _utils.appendContextPath(options.data.contextPath, options.ids[0]);
          }
          return fn(context, {
            data: data,
            blockParams: _utils.blockParams([context], [data && data.contextPath])
          });
        } else {
          return options.inverse(this);
        }
      });
    };
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    var _interopRequireDefault = __webpack_require__(2)['default'];
    exports.__esModule = true;
    exports.registerDefaultDecorators = registerDefaultDecorators;
    var _decoratorsInline = __webpack_require__(15);
    var _decoratorsInline2 = _interopRequireDefault(_decoratorsInline);
    function registerDefaultDecorators(instance) {
      _decoratorsInline2['default'](instance);
    }
  }, function(module, exports, __webpack_require__) {
    'use strict';
    exports.__esModule = true;
    var _utils = __webpack_require__(4);
    exports['default'] = function(instance) {
      instance.registerDecorator('inline', function(fn, props, container, options) {
        var ret = fn;
        if (!props.partials) {
          props.partials = {};
          ret = function(context, options) {
            var original = container.partials;
            container.partials = _utils.extend({}, original, props.partials);
            var ret = fn(context, options);
            container.partials = original;
            return ret;
          };
        }
        props.partials[options.args[0]] = options.fn;
        return ret;
      });
    };
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    exports.__esModule = true;
    var _utils = __webpack_require__(4);
    var logger = {
      methodMap: ['debug', 'info', 'warn', 'error'],
      level: 'info',
      lookupLevel: function lookupLevel(level) {
        if (typeof level === 'string') {
          var levelMap = _utils.indexOf(logger.methodMap, level.toLowerCase());
          if (levelMap >= 0) {
            level = levelMap;
          } else {
            level = parseInt(level, 10);
          }
        }
        return level;
      },
      log: function log(level) {
        level = logger.lookupLevel(level);
        if (typeof console !== 'undefined' && logger.lookupLevel(logger.level) <= level) {
          var method = logger.methodMap[level];
          if (!console[method]) {
            method = 'log';
          }
          for (var _len = arguments.length,
              message = Array(_len > 1 ? _len - 1 : 0),
              _key = 1; _key < _len; _key++) {
            message[_key - 1] = arguments[_key];
          }
          console[method].apply(console, message);
        }
      }
    };
    exports['default'] = logger;
    module.exports = exports['default'];
  }, function(module, exports) {
    'use strict';
    exports.__esModule = true;
    function SafeString(string) {
      this.string = string;
    }
    SafeString.prototype.toString = SafeString.prototype.toHTML = function() {
      return '' + this.string;
    };
    exports['default'] = SafeString;
    module.exports = exports['default'];
  }, function(module, exports, __webpack_require__) {
    'use strict';
    var _interopRequireWildcard = __webpack_require__(1)['default'];
    var _interopRequireDefault = __webpack_require__(2)['default'];
    exports.__esModule = true;
    exports.checkRevision = checkRevision;
    exports.template = template;
    exports.wrapProgram = wrapProgram;
    exports.resolvePartial = resolvePartial;
    exports.invokePartial = invokePartial;
    exports.noop = noop;
    var _utils = __webpack_require__(4);
    var Utils = _interopRequireWildcard(_utils);
    var _exception = __webpack_require__(5);
    var _exception2 = _interopRequireDefault(_exception);
    var _base = __webpack_require__(3);
    function checkRevision(compilerInfo) {
      var compilerRevision = compilerInfo && compilerInfo[0] || 1,
          currentRevision = _base.COMPILER_REVISION;
      if (compilerRevision !== currentRevision) {
        if (compilerRevision < currentRevision) {
          var runtimeVersions = _base.REVISION_CHANGES[currentRevision],
              compilerVersions = _base.REVISION_CHANGES[compilerRevision];
          throw new _exception2['default']('Template was precompiled with an older version of Handlebars than the current runtime. ' + 'Please update your precompiler to a newer version (' + runtimeVersions + ') or downgrade your runtime to an older version (' + compilerVersions + ').');
        } else {
          throw new _exception2['default']('Template was precompiled with a newer version of Handlebars than the current runtime. ' + 'Please update your runtime to a newer version (' + compilerInfo[1] + ').');
        }
      }
    }
    function template(templateSpec, env) {
      if (!env) {
        throw new _exception2['default']('No environment passed to template');
      }
      if (!templateSpec || !templateSpec.main) {
        throw new _exception2['default']('Unknown template object: ' + typeof templateSpec);
      }
      templateSpec.main.decorator = templateSpec.main_d;
      env.VM.checkRevision(templateSpec.compiler);
      function invokePartialWrapper(partial, context, options) {
        if (options.hash) {
          context = Utils.extend({}, context, options.hash);
          if (options.ids) {
            options.ids[0] = true;
          }
        }
        partial = env.VM.resolvePartial.call(this, partial, context, options);
        var result = env.VM.invokePartial.call(this, partial, context, options);
        if (result == null && env.compile) {
          options.partials[options.name] = env.compile(partial, templateSpec.compilerOptions, env);
          result = options.partials[options.name](context, options);
        }
        if (result != null) {
          if (options.indent) {
            var lines = result.split('\n');
            for (var i = 0,
                l = lines.length; i < l; i++) {
              if (!lines[i] && i + 1 === l) {
                break;
              }
              lines[i] = options.indent + lines[i];
            }
            result = lines.join('\n');
          }
          return result;
        } else {
          throw new _exception2['default']('The partial ' + options.name + ' could not be compiled when running in runtime-only mode');
        }
      }
      var container = {
        strict: function strict(obj, name) {
          if (!(name in obj)) {
            throw new _exception2['default']('"' + name + '" not defined in ' + obj);
          }
          return obj[name];
        },
        lookup: function lookup(depths, name) {
          var len = depths.length;
          for (var i = 0; i < len; i++) {
            if (depths[i] && depths[i][name] != null) {
              return depths[i][name];
            }
          }
        },
        lambda: function lambda(current, context) {
          return typeof current === 'function' ? current.call(context) : current;
        },
        escapeExpression: Utils.escapeExpression,
        invokePartial: invokePartialWrapper,
        fn: function fn(i) {
          var ret = templateSpec[i];
          ret.decorator = templateSpec[i + '_d'];
          return ret;
        },
        programs: [],
        program: function program(i, data, declaredBlockParams, blockParams, depths) {
          var programWrapper = this.programs[i],
              fn = this.fn(i);
          if (data || depths || blockParams || declaredBlockParams) {
            programWrapper = wrapProgram(this, i, fn, data, declaredBlockParams, blockParams, depths);
          } else if (!programWrapper) {
            programWrapper = this.programs[i] = wrapProgram(this, i, fn);
          }
          return programWrapper;
        },
        data: function data(value, depth) {
          while (value && depth--) {
            value = value._parent;
          }
          return value;
        },
        merge: function merge(param, common) {
          var obj = param || common;
          if (param && common && param !== common) {
            obj = Utils.extend({}, common, param);
          }
          return obj;
        },
        noop: env.VM.noop,
        compilerInfo: templateSpec.compiler
      };
      function ret(context) {
        var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];
        var data = options.data;
        ret._setup(options);
        if (!options.partial && templateSpec.useData) {
          data = initData(context, data);
        }
        var depths = undefined,
            blockParams = templateSpec.useBlockParams ? [] : undefined;
        if (templateSpec.useDepths) {
          if (options.depths) {
            depths = context !== options.depths[0] ? [context].concat(options.depths) : options.depths;
          } else {
            depths = [context];
          }
        }
        function main(context) {
          return '' + templateSpec.main(container, context, container.helpers, container.partials, data, blockParams, depths);
        }
        main = executeDecorators(templateSpec.main, main, container, options.depths || [], data, blockParams);
        return main(context, options);
      }
      ret.isTop = true;
      ret._setup = function(options) {
        if (!options.partial) {
          container.helpers = container.merge(options.helpers, env.helpers);
          if (templateSpec.usePartial) {
            container.partials = container.merge(options.partials, env.partials);
          }
          if (templateSpec.usePartial || templateSpec.useDecorators) {
            container.decorators = container.merge(options.decorators, env.decorators);
          }
        } else {
          container.helpers = options.helpers;
          container.partials = options.partials;
          container.decorators = options.decorators;
        }
      };
      ret._child = function(i, data, blockParams, depths) {
        if (templateSpec.useBlockParams && !blockParams) {
          throw new _exception2['default']('must pass block params');
        }
        if (templateSpec.useDepths && !depths) {
          throw new _exception2['default']('must pass parent depths');
        }
        return wrapProgram(container, i, templateSpec[i], data, 0, blockParams, depths);
      };
      return ret;
    }
    function wrapProgram(container, i, fn, data, declaredBlockParams, blockParams, depths) {
      function prog(context) {
        var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];
        var currentDepths = depths;
        if (depths && context !== depths[0]) {
          currentDepths = [context].concat(depths);
        }
        return fn(container, context, container.helpers, container.partials, options.data || data, blockParams && [options.blockParams].concat(blockParams), currentDepths);
      }
      prog = executeDecorators(fn, prog, container, depths, data, blockParams);
      prog.program = i;
      prog.depth = depths ? depths.length : 0;
      prog.blockParams = declaredBlockParams || 0;
      return prog;
    }
    function resolvePartial(partial, context, options) {
      if (!partial) {
        if (options.name === '@partial-block') {
          partial = options.data['partial-block'];
        } else {
          partial = options.partials[options.name];
        }
      } else if (!partial.call && !options.name) {
        options.name = partial;
        partial = options.partials[partial];
      }
      return partial;
    }
    function invokePartial(partial, context, options) {
      options.partial = true;
      if (options.ids) {
        options.data.contextPath = options.ids[0] || options.data.contextPath;
      }
      var partialBlock = undefined;
      if (options.fn && options.fn !== noop) {
        options.data = _base.createFrame(options.data);
        partialBlock = options.data['partial-block'] = options.fn;
        if (partialBlock.partials) {
          options.partials = Utils.extend({}, options.partials, partialBlock.partials);
        }
      }
      if (partial === undefined && partialBlock) {
        partial = partialBlock;
      }
      if (partial === undefined) {
        throw new _exception2['default']('The partial ' + options.name + ' could not be found');
      } else if (partial instanceof Function) {
        return partial(context, options);
      }
    }
    function noop() {
      return '';
    }
    function initData(context, data) {
      if (!data || !('root' in data)) {
        data = data ? _base.createFrame(data) : {};
        data.root = context;
      }
      return data;
    }
    function executeDecorators(fn, prog, container, depths, data, blockParams) {
      if (fn.decorator) {
        var props = {};
        prog = fn.decorator(prog, props, container, depths && depths[0], data, blockParams, depths);
        Utils.extend(prog, props);
      }
      return prog;
    }
  }, function(module, exports) {
    (function(global) {
      'use strict';
      exports.__esModule = true;
      exports['default'] = function(Handlebars) {
        var root = typeof global !== 'undefined' ? global : window,
            $Handlebars = root.Handlebars;
        Handlebars.noConflict = function() {
          if (root.Handlebars === Handlebars) {
            root.Handlebars = $Handlebars;
          }
          return Handlebars;
        };
      };
      module.exports = exports['default'];
    }.call(exports, (function() {
      return this;
    }())));
  }]);
});
;

})();
System.registerDynamic("lib/templates/city-select.hbs!github:davis/plugin-hbs@1.2.3.js", ["github:components/handlebars.js@4.0.5/handlebars.runtime.js"], true, function ($__require, exports, module) {
  var define,
      global = this || self,
      GLOBAL = global;
  var Handlebars = $__require("github:components/handlebars.js@4.0.5/handlebars.runtime.js");
  module.exports = Handlebars.template({ "1": function (container, depth0, helpers, partials, data) {
      var helper;

      return "                    <tr><td><a href='#' data-ics=\"" + container.escapeExpression((helper = (helper = helpers.url || (depth0 != null ? depth0.url : depth0)) != null ? helper : helpers.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {}, { "name": "url", "hash": {}, "data": data }) : helper)) + "\">" + container.escapeExpression((helper = (helper = helpers.name || (depth0 != null ? depth0.name : depth0)) != null ? helper : helpers.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {}, { "name": "name", "hash": {}, "data": data }) : helper)) + "</a></td></tr>\r\n";
    }, "compiler": [7, ">= 4.0.0"], "main": function (container, depth0, helpers, partials, data) {
      var stack1;

      return "<section class=\"section has-lotus-background is-fullheight\">\r\n        <div class=\"container\">\r\n            <div class=\"heading has-translucent-box has-padding-10\">\r\n                <h1 class=\"title\">Select your city</h1>\r\n                <h2 class=\"subtitle\">\r\n                    Please, select your location to view the correct Panchangam\r\n                </h2>\r\n            </div>\r\n            <table class=\"table\">\r\n                <thead>\r\n                <tr>\r\n                    <th>City</th>\r\n                </tr>\r\n                </thead>\r\n                <tbody>\r\n" + ((stack1 = helpers.each.call(depth0 != null ? depth0 : {}, depth0, { "name": "each", "hash": {}, "fn": container.program(1, data, 0), "inverse": container.noop, "data": data })) != null ? stack1 : "") + "                </tbody>\r\n            </table>\r\n        </div>\r\n    </section>";
    }, "useData": true });
  return module.exports;
});
System.register("lib/location-data.js", [], function (_export) {
    "use strict";

    var locationData;
    return {
        setters: [],
        execute: function () {
            locationData = {
                usa: [{
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/albany_ny.ics",
                    name: "Albany NY"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/albuquerque_nm.ics",
                    name: "Albuquerque NM"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/alsea_or.ics",
                    name: "Alsea OR"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/amarillo_tx.ics",
                    name: "Amarillo TX"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/anchorage_ak.ics",
                    name: "Anchorage AK"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/asheville_nc.ics",
                    name: "Asheville NC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/athens_ga.ics",
                    name: "Athens GA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/atlanta_ga.ics",
                    name: "Atlanta GA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/auburn_al.ics",
                    name: "Auburn AL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/austin_tx.ics",
                    name: "Austin TX"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/baltimore_md.ics",
                    name: "Baltimore MD"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/baton_rouge_la.ics",
                    name: "Baton Rouge LA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/bettendorf_ia.ics",
                    name: "Bettendorf IA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/birmingham_al.ics",
                    name: "Birmingham AL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/bixby_ok.ics",
                    name: "Bixby OK"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/bloomfield_nj.ics",
                    name: "Bloomfield NJ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/bloomington_il.ics",
                    name: "Bloomington IL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/bloomington_in.ics",
                    name: "Bloomington IN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/boca_raton_fl.ics",
                    name: "Boca Raton FL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/boise_id.ics",
                    name: "Boise ID"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/boone_nc.ics",
                    name: "Boone NC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/boston_ma.ics",
                    name: "Boston MA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/bowling_green_ky.ics",
                    name: "Bowling Green KY"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/branchville_nj.ics",
                    name: "Branchville NJ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/broomfield_co.ics",
                    name: "Broomfield CO"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/buffalo_ny.ics",
                    name: "Buffalo NY"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/cary_nc.ics",
                    name: "Cary NC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/champaign_il.ics",
                    name: "Champaign IL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/chantilly_va.ics",
                    name: "Chantilly VA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/chapel_hill_nc.ics",
                    name: "Chapel Hill NC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/charlotte_nc.ics",
                    name: "Charlotte NC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/charlottesville_va.ics",
                    name: "Charlottesville VA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/chicago_il.ics",
                    name: "Chicago IL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/cincinnati_oh.ics",
                    name: "Cincinnati OH"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/cleveland_oh.ics",
                    name: "Cleveland OH"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/columbia_sc.ics",
                    name: "Columbia SC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/columbus_oh.ics",
                    name: "Columbus OH"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/dallas_tx.ics",
                    name: "Dallas TX"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/davenport_ia.ics",
                    name: "Davenport IA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/denver_co.ics",
                    name: "Denver CO"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/des_moines_ia.ics",
                    name: "Des Moines IA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/detroit_mi.ics",
                    name: "Detroit MI"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/downers_grove_il.ics",
                    name: "Downers Grove IL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/easton_md.ics",
                    name: "Easton MD"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/edison_nj.ics",
                    name: "Edison NJ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/el_paso_tx.ics",
                    name: "El Paso TX"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/etobicoke_on.ics",
                    name: "Etobicoke ON"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/eugene_or.ics",
                    name: "Eugene OR"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/fairfax_va.ics",
                    name: "Fairfax VA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/flemington_nj.ics",
                    name: "Flemington NJ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/fort_lauderdale_fl.ics",
                    name: "Fort Lauderdale FL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/fort_wayne_in.ics",
                    name: "Fort Wayne IN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/frederick_md.ics",
                    name: "Frederick MD"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/fresno_ca.ics",
                    name: "Fresno CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/gainesville_fl.ics",
                    name: "Gainesville FL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/greenville_sc.ics",
                    name: "Greenville SC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/hartford_ct.ics",
                    name: "Hartford CT"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/hattiesburg_ms.ics",
                    name: "Hattiesburg MS"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/hawaii.ics",
                    name: "HawaII"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/honolulu_hi.ics",
                    name: "Honolulu HI"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/houston_tx.ics",
                    name: "Houston TX"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/indianapolis_in.ics",
                    name: "Indianapolis IN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/irvine_ca.ics",
                    name: "Irvine CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/jacksonville_fl.ics",
                    name: "Jacksonville FL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/kansas_city_ks.ics",
                    name: "Kansas City KS"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/knoxville_tn.ics",
                    name: "Knoxville TN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/lanham_md.ics",
                    name: "Lanham MD"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/lansing_mi.ics",
                    name: "Lansing MI"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/las_vegas_nv.ics",
                    name: "Las Vegas NV"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/los_angeles_ca.ics",
                    name: "Los Angeles CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/louisville_ky.ics",
                    name: "Louisville KY"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/madison_wi.ics",
                    name: "Madison WI"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/memphis_tn.ics",
                    name: "Memphis TN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/miami_fl.ics",
                    name: "Miami FL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/michigan_city_in.ics",
                    name: "Michigan City IN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/midland_tx.ics",
                    name: "Midland TX"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/milwaukee_wi.ics",
                    name: "Milwaukee WI"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/minneapolis_st_paul_mn.ics",
                    name: "Minneapolis St Paul MN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/mobile_al.ics",
                    name: "Mobile AL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/modesto_ca.ics",
                    name: "Modesto CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/monroe_nj.ics",
                    name: "Monroe NJ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/montpelier_vt.ics",
                    name: "Montpelier VT"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/nashville_tn.ics",
                    name: "Nashville TN"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/new_orleans_la.ics",
                    name: "New Orleans LA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/new_york_city_ny.ics",
                    name: "New York City NY"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/newport_beach_ca.ics",
                    name: "Newport Beach CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/normal_il.ics",
                    name: "Normal IL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/norman_ok.ics",
                    name: "Norman OK"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/nutley_nj.ics",
                    name: "Nutley NJ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/omaha_ne.ics",
                    name: "Omaha NE"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/orlando_fl.ics",
                    name: "Orlando FL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/peoria_il.ics",
                    name: "Peoria IL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/philadelphia_pa.ics",
                    name: "Philadelphia PA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/phoenix_az.ics",
                    name: "Phoenix AZ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/phoenixville_pa.ics",
                    name: "Phoenixville PA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/pittsburgh_pa.ics",
                    name: "Pittsburgh PA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/pleasanton_ca.ics",
                    name: "Pleasanton CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/portland_or.ics",
                    name: "Portland OR"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/rapid_city_sd.ics",
                    name: "Rapid City SD"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/reno_nv.ics",
                    name: "Reno NV"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/richmond_va.ics",
                    name: "Richmond VA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/rochester_ny.ics",
                    name: "Rochester NY"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/sacramento_ca.ics",
                    name: "Sacramento CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/salt_lake_city_ut.ics",
                    name: "Salt Lake City UT"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/san_antonio_tx.ics",
                    name: "San Antonio TX"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/san_diego_ca.ics",
                    name: "San Diego CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/san_francisco_ca.ics",
                    name: "San Francisco CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/san_jose_ca.ics",
                    name: "San Jose CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/san_ramon_ca.ics",
                    name: "San Ramon CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/santa_clara_ca.ics",
                    name: "Santa Clara CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/santa_fe_nm.ics",
                    name: "Santa Fe NM"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/scottsdale_az.ics",
                    name: "Scottsdale AZ"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/seattle_wa.ics",
                    name: "Seattle WA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/spokane_wa.ics",
                    name: "Spokane WA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/springfield_or.ics",
                    name: "Springfield OR"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/st_helena_ca.ics",
                    name: "St Helena CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/st_louis_mo.ics",
                    name: "St Louis MO"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/stamford_ct.ics",
                    name: "Stamford CT"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/syracuse_ny.ics",
                    name: "Syracuse NY"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/tampa_fl.ics",
                    name: "Tampa FL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/volcano_hi.ics",
                    name: "Volcano HI"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/walnut_creek_ca.ics",
                    name: "Walnut Creek CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/washington_dc.ics",
                    name: "Washington DC"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/wheaton_il.ics",
                    name: "Wheaton IL"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/whittier_ca.ics",
                    name: "Whittier CA"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/usa/winter_garden_fl.ics",
                    name: "Winter Garden FL"
                }],
                world: [{
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/abu_dhabi_ae.ics",
                    name: "Abu Dhabi Ae"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/abu_road_india.ics",
                    name: "Abu Road India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/adana_turkey.ics",
                    name: "Adana Turkey"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/adelaide_s_australia.ics",
                    name: "Adelaide S Australia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/ahmedabad_india.ics",
                    name: "Ahmedabad India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/al-khubar_saudi_arabia.ics",
                    name: "Al-Khubar Saudi Arabia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/almaty_kazakhstan.ics",
                    name: "Almaty Kazakhstan"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/ambala_india.ics",
                    name: "Ambala India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/amsterdam_netherlands.ics",
                    name: "Amsterdam Netherlands"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/athens_greece.ics",
                    name: "Athens Greece"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/auckland_new_zealand.ics",
                    name: "Auckland New Zealand"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/bali_indonesia.ics",
                    name: "Bali Indonesia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/bangalore_india.ics",
                    name: "Bangalore India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/bangkok_thailand.ics",
                    name: "Bangkok Thailand"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/barcelona_spain.ics",
                    name: "Barcelona Spain"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/beijing_china.ics",
                    name: "Beijing China"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/berlin_germany.ics",
                    name: "Berlin Germany"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/birming_uk.ics",
                    name: "Birming Uk"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/bordeaux_france.ics",
                    name: "Bordeaux France"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/bradford_uk.ics",
                    name: "Bradford Uk"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/bremen_germany.ics",
                    name: "Bremen Germany"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/brisbane_australia.ics",
                    name: "Brisbane Australia"
                }, { url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/brunei.ics", name: "Brunei" }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/brussels_belgium.ics",
                    name: "Brussels Belgium"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/bucaramanga_columbia.ics",
                    name: "Bucaramanga Columbia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/budapest_hungary.ics",
                    name: "Budapest Hungary"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/cairo_egypt.ics",
                    name: "Cairo Egypt"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/calgary_ab_canada.ics",
                    name: "Calgary Ab Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/canberra_australia.ics",
                    name: "Canberra Australia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/cape_town_south_africa.ics",
                    name: "Cape Town South Africa"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/carcare_switzerland.ics",
                    name: "Carcare Switzerland"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/chandigarh_india.ics",
                    name: "Chandigarh India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/chennai_india.ics",
                    name: "Chennai India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/chernigov_ukraine.ics",
                    name: "Chernigov Ukraine"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/chidambaram_india.ics",
                    name: "Chidambaram India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/cologne_germany.ics",
                    name: "Cologne Germany"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/colombo_sri_lanka.ics",
                    name: "Colombo Sri Lanka"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/copenhagen_denmark.ics",
                    name: "Copenhagen Denmark"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/darwin_australia.ics",
                    name: "Darwin Australia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/doha_qatar.ics",
                    name: "Doha Qatar"
                }, { url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/dubai_ae.ics", name: "Dubai Ae" }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/dublin_ire.ics",
                    name: "Dublin Ire"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/durban_south_africa.ics",
                    name: "Durban South Africa"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/dushanbe_tajikastan.ics",
                    name: "Dushanbe Tajikastan"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/dwarka_india.ics",
                    name: "Dwarka India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/edmonton_canada.ics",
                    name: "Edmonton Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/ellora_india.ics",
                    name: "Ellora India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/gaborone_botswana.ics",
                    name: "Gaborone Botswana"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/galway_ireland.ics",
                    name: "Galway Ireland"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/geneva_switzerland.ics",
                    name: "Geneva Switzerland"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/georgetown_guyana.ics",
                    name: "Georgetown Guyana"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/gosnells_aust.ics",
                    name: "Gosnells Aust"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/grevenbroich_germany.ics",
                    name: "Grevenbroich Germany"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/gunzburg_germany.ics",
                    name: "Gunzburg Germany"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/halifax_canada.ics",
                    name: "Halifax Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/hamm_germany.ics",
                    name: "Hamm Germany"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/ho_chi_minh.ics",
                    name: "Ho Chi Minh"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/hobart_tasmania.ics",
                    name: "Hobart Tasmania"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/hong_kong_china.ics",
                    name: "Hong Kong China"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/hyderabad_india.ics",
                    name: "Hyderabad India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/imphal_india.ics",
                    name: "Imphal India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/istanbul_turkey.ics",
                    name: "Istanbul Turkey"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/jakarta_indonesia.ics",
                    name: "Jakarta Indonesia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/jalandhar_india.ics",
                    name: "Jalandhar India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/johannesburg_za.ics",
                    name: "Johannesburg Za"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kandy_sri_lanka.ics",
                    name: "Kandy Sri Lanka"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/karachi_pakistan.ics",
                    name: "Karachi Pakistan"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kathmandu_nepal.ics",
                    name: "Kathmandu Nepal"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kedarnath_india.ics",
                    name: "Kedarnath India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kharagpur_india.ics",
                    name: "Kharagpur India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kiev_ukraine.ics",
                    name: "Kiev Ukraine"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kingston_jamaica.ics",
                    name: "Kingston Jamaica"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kinshasa_zaire.ics",
                    name: "Kinshasa Zaire"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kl_malaysia.ics",
                    name: "Kl Malaysia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kolkata_india.ics",
                    name: "Kolkata India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kottayam_india.ics",
                    name: "Kottayam India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/kuwait_city_kuwait.ics",
                    name: "Kuwait City Kuwait"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/lelystad_netherlands.ics",
                    name: "Lelystad Netherlands"
                }, { url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/lima_peru.ics", name: "Lima Peru" }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/ljubljana_solvenia.ics",
                    name: "Ljubljana Solvenia"
                }, { url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/london_uk.ics", name: "London Uk" }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/lucknow_india.ics",
                    name: "Lucknow India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/lusaka_zambia.ics",
                    name: "Lusaka Zambia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/madrid_spain.ics",
                    name: "Madrid Spain"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/madurai_india.ics",
                    name: "Madurai India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/malmo_sweden.ics",
                    name: "Malmo Sweden"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/manama_bahrain.ics",
                    name: "Manama Bahrain"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/manokwari_indonesia.ics",
                    name: "Manokwari Indonesia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/medellin_colombia.ics",
                    name: "Medellin Colombia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/melbourne_aust.ics",
                    name: "Melbourne Aust"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/mexico_city_mexico.ics",
                    name: "Mexico City Mexico"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/milan_italy.ics",
                    name: "Milan Italy"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/moncton_nb_canada.ics",
                    name: "Moncton Nb Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/montevideo_uruguay.ics",
                    name: "Montevideo Uruguay"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/montreal_canada.ics",
                    name: "Montreal Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/moscow_russia.ics",
                    name: "Moscow Russia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/mosul_iraq.ics",
                    name: "Mosul Iraq"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/mumbai_india.ics",
                    name: "Mumbai India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/mundare_canada.ics",
                    name: "Mundare Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/munich_germany.ics",
                    name: "Munich Germany"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/muscat_oman.ics",
                    name: "Muscat Oman"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/nadi_fiji_islands.ics",
                    name: "Nadi Fiji Islands"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/nairobi_kenya.ics",
                    name: "Nairobi Kenya"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/nasik_india.ics",
                    name: "Nasik India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/new_delhi_india.ics",
                    name: "New Delhi India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/oslo_norway.ics",
                    name: "Oslo Norway"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/padua_italy.ics",
                    name: "Padua Italy"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/paramaribo_suriname.ics",
                    name: "Paramaribo Suriname"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/paris_france.ics",
                    name: "Paris France"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/perth_aust.ics",
                    name: "Perth Aust"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/pietermaritzburg_za.ics",
                    name: "Pietermaritzburg Za"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/poortugaal_netherlands.ics",
                    name: "Poortugaal Netherlands"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/port_harcourt_nigeria.ics",
                    name: "Port Harcourt Nigeria"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/port_louis_mauritius.ics",
                    name: "Port Louis Mauritius"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/port-of-spain_trinidad_and_tobago.ics",
                    name: "Port-Of-Spain Trinidad And Tobago"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/porto_portugal.ics",
                    name: "Porto Portugal"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/pune_india.ics",
                    name: "Pune India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/pyinmana_myanmar.ics",
                    name: "Pyinmana Myanmar"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/pyrenees-orientales_france.ics",
                    name: "Pyrenees-Orientales France"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/rameswaram_india.ics",
                    name: "Rameswaram India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/ranikhet_india.ics",
                    name: "Ranikhet India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/regina_sk_canada.ics",
                    name: "Regina Sk Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/riga_latvia.ics",
                    name: "Riga Latvia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/rio_de_janeiro_brazil.ics",
                    name: "Rio De Janeiro Brazil"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/riyadh_saudi_arabia.ics",
                    name: "Riyadh Saudi Arabia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/rome_italy.ics",
                    name: "Rome Italy"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/saint-denis_reunion.ics",
                    name: "Saint-Denis Reunion"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/santiago_chile.ics",
                    name: "Santiago Chile"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/sao_paulo_brazil.ics",
                    name: "Sao Paulo Brazil"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/saskatoon_canada.ics",
                    name: "Saskatoon Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/seoul_korea.ics",
                    name: "Seoul Korea"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/shanghai_china.ics",
                    name: "Shanghai China"
                }, { url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/singapore.ics", name: "Singapore" }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/somerset_west_za.ics",
                    name: "Somerset West Za"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/sri_sailam_india.ics",
                    name: "Sri Sailam India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/stockholm_sweden.ics",
                    name: "Stockholm Sweden"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/surabaya_indonesia.ics",
                    name: "Surabaya Indonesia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/suva_fiji_islands.ics",
                    name: "Suva Fiji Islands"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/sydney_australia.ics",
                    name: "Sydney Australia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/tallinn_estonia.ics",
                    name: "Tallinn Estonia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/tehran_iran.ics",
                    name: "Tehran Iran"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/thane_maharashtra_in.ics",
                    name: "Thane Maharashtra In"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/tirupati_india.ics",
                    name: "Tirupati India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/tokyo_japan.ics",
                    name: "Tokyo Japan"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/toronto_canada.ics",
                    name: "Toronto Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/trichirappalli_india.ics",
                    name: "Trichirappalli India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/trieste_italy.ics",
                    name: "Trieste Italy"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/trivandrum_india.ics",
                    name: "Trivandrum India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/udaipur_india.ics",
                    name: "Udaipur India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/vancouver_canada.ics",
                    name: "Vancouver Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/varanasi_india.ics",
                    name: "Varanasi India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/vienna_austria.ics",
                    name: "Vienna Austria"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/vizianagaram_india.ics",
                    name: "Vizianagaram India"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/warsaw_poland.ics",
                    name: "Warsaw Poland"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/winnipeg_mb_canada.ics",
                    name: "Winnipeg Mb Canada"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/winterthur_switzerland.ics",
                    name: "Winterthur Switzerland"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/yangon_myanmar.ics",
                    name: "Yangon Myanmar"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/yogyakarta_indonesia.ics",
                    name: "Yogyakarta Indonesia"
                }, {
                    url: "http://dev.himalayanacademy.com/media/apps/panchangam/calendars/2016-2017/world/zagreb_croatia.ics",
                    name: "Zagreb Croatia"
                }]
            };

            _export("default", locationData);
        }
    };
});
System.register("lib/locationSelectState.js", ["lib/templates/region-select.hbs!github:davis/plugin-hbs@1.2.3.js", "lib/templates/city-select.hbs!github:davis/plugin-hbs@1.2.3.js", "lib/location-data.js", "lib/calendarDisplayState.js"], function (_export) {
    "use strict";

    var region_select, city_select, locationData, calendarDisplayState, regionSelectState;

    function bindCitySelector() {
        document.querySelectorAll("[data-ics]").forEach(function (item) {
            item.addEventListener("click", function (el) {
                var url = item.getAttribute("data-ics");
                console.log(url);
                calendarDisplayState.makeActive(url);
            });
        });
    }

    function showRegionSelector() {
        document.body.innerHTML = region_select();
    }

    function showCitySelector(region) {
        document.body.innerHTML = city_select(locationData[region]);
        bindCitySelector();
    }

    return {
        setters: [function (_libTemplatesRegionSelectHbsGithubDavisPluginHbs123Js) {
            region_select = _libTemplatesRegionSelectHbsGithubDavisPluginHbs123Js["default"];
        }, function (_libTemplatesCitySelectHbsGithubDavisPluginHbs123Js) {
            city_select = _libTemplatesCitySelectHbsGithubDavisPluginHbs123Js["default"];
        }, function (_libLocationDataJs) {
            locationData = _libLocationDataJs["default"];
        }, function (_libCalendarDisplayStateJs) {
            calendarDisplayState = _libCalendarDisplayStateJs["default"];
        }],
        execute: function () {
            regionSelectState = {
                makeActive: function makeActive(region) {
                    if (region) {
                        showCitySelector(region);
                    } else {
                        showRegionSelector();
                    }
                }
            };

            _export("default", regionSelectState);
        }
    };
});
System.register("lib/calendarDisplayState.js", [], function (_export) {
    "use strict";

    var calendarDisplayState;
    return {
        setters: [],
        execute: function () {
            calendarDisplayState = {
                makeActive: function makeActive() {}
            };

            _export("default", calendarDisplayState);
        }
    };
});
System.register("lib/bootState.js", ["lib/locationSelectState.js", "lib/calendarDisplayState.js"], function (_export) {
    "use strict";

    var locationSelectState, calendarDisplayState;

    function bootstrap() {

        console.log("Boot loaded.");

        var ics = localStorage.getItem("calendar");

        if (!ics) {
            locationSelectState.makeActive();
        } else {
            calendarDisplayState.makeActive(null, ics);
        }
    }

    return {
        setters: [function (_libLocationSelectStateJs) {
            locationSelectState = _libLocationSelectStateJs["default"];
        }, function (_libCalendarDisplayStateJs) {
            calendarDisplayState = _libCalendarDisplayStateJs["default"];
        }],
        execute: function () {
            _export("default", {
                makeActive: bootstrap
            });
        }
    };
});
System.register("lib/main.js", ["lib/bootState.js"], function (_export) {
  "use strict";

  var bootState;
  return {
    setters: [function (_libBootStateJs) {
      bootState = _libBootStateJs["default"];
    }],
    execute: function () {

      console.log("bootstrapping...");
      bootState.makeActive();
    }
  };
});
//# sourceMappingURL=build.js.map