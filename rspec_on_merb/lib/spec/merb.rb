dir = File.dirname(__FILE__)
require 'application'

silence_warnings { RAILS_ENV = "test" }
require 'active_record/base'
require 'active_record/fixtures'
require 'spec'
require 'test/unit'

require File.expand_path("#{dir}/merb/matchers")
require File.expand_path("#{dir}/merb/fakes")
require File.expand_path("#{dir}/merb/dsl")

require File.expand_path("#{dir}/dsl")
require File.expand_path("#{dir}/matchers")

#require File.expand_path("#{dir}/merb/version")
require File.expand_path("#{dir}/merb/extensions")
#require File.expand_path("#{dir}/merb/matchers")

Test::Unit.run = true
