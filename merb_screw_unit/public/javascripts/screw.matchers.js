Screw.Matchers = (function($) {
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
    
    have: {
      match: function(expected, actual) {
        return actual.find(expected).length > 0;
      },
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(actual) + (not ? ' to not have ' : ' to have ') + $.print(expected);
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
        if (actual.length == undefined) throw(actual.toString() + " does not respond to length");
        
        return actual.length == 0;
      },
      
      failure_message: function(expected, actual, not) {
        return 'expected ' + $.print(actual) + (not ? ' to not be empty' : ' to be empty');
      }
    }
  }
})(jQuery);