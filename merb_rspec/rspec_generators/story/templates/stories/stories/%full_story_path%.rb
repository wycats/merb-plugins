require File.join(File.dirname(__FILE__), "../<%= "../" * path_levels %>helper")

with_steps_for :<%= step_name %> do
  run File.expand_path(__FILE__).gsub(".rb",""), :type => Merb::Test::RspecStory
end