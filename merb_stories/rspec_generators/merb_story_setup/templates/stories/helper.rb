require 'rubygems'
require 'spec/rake/spectask'
require File.join(File.dirname(__FILE__), "..", "spec", "spec_helper")
require 'spec/mocks'
require 'spec/story'

class Merb::Test::RspecStory
  # Include your custom helpers here
end

Dir['stories/steps/**/*.rb'].each do |steps_file|
  require steps_file
end
