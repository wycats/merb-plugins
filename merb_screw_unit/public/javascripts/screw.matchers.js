Screw.Matchers = (function($) {
  var jquerize = function(obj) {
    if(typeof obj == "string") return iframeWindow.$(obj);
    else return obj;
  }
  
  return matchers = {
    expect: function(actual) {
      return {
        to: function(matcher, expected, not) {
          var matched = matcher.match(expected, actual);
          if (not ? matched : !matched) {
            throw(matcher.failure_message(expected, actual, not));
          }
        },
        
        to_not: function(matcher, expected) {
          this.to(matcher, expected, true);
        }
      }
    },
    
    exist: {
      match: function(expected, actual) {
        return actual.length > 0;
      },
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(actual) + (not ? ' to not ' : ' to ') + "exist";
      }
    },

    contain_text: {
      match: function(expected, actual) {
        return jquerize(actual).filter(":contains(\"" + expected + "\")").length > 0;
      },
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(jquerize(actual)) + (not ? ' to not have ' : ' to have ') + $.print(expected);
      }
    },
    
    have: {
      match: function(expected, actual) {
        return jquerize(actual).find(expected).length > 0;
      },
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(jquerize(actual)) + (not ? ' to not have ' : ' to have ') + $.print(expected);
      }
    },
    
    be_visible: {
      match: function(expected, actual) {
        return jquerize(actual).is(":visible");
      },
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(jquerize(actual)) + (not ? ' to not ' : ' to ') + "be visible";
      }
    },
    
    equal: {
      match: function(expected, actual) {
        if (expected instanceof Array) {
          for (var i = 0; i < actual.length; i++)
            if (!Screw.Matchers.equal.match(expected[i], actual[i])) return false;
          return actual.length == expected.length;
        } else if (expected instanceof Object) {
          for (var key in expected)
            if (expected[key] != actual[key]) return false;
          for (var key in actual)
            if (actual[key] != expected[key]) return false;
          return true;
        } else {
          return expected == actual;
        }
      },
      
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(actual) + (not ? ' to not equal ' : ' to equal ') + $.print(expected);
      }
    },
    
    match: {
      match: function(expected, actual) {
        if (expected.constructor == RegExp)
          return expected.exec(actual.toString());
        else
          return actual.indexOf(expected) > -1;
      },
      
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(actual) + (not ? ' to not match ' : ' to match ') + $.print(expected);
      }
    },
    
    be_empty: {
      match: function(expected, actual) {
        if (jquerize(actual).length == undefined) 
          throw($.print(jquerize(actual)) + " does not respond to length");
        
        return actual.length == 0;
      },
      
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(jquerize(actual)) + (not ? ' to not be empty' : ' to be empty');
      }
    }
  }
})(jQuery);