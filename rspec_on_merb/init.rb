dir = File.expand_path(File.dirname(__FILE__))
require "rubygems"
require "merb"
require "spec"
require 'active_record'

require "#{dir}/spec/spec_helper"

Dir["#{dir}/lib/custom/**/*"].each do |file|
  require file unless File.directory?(file)
end