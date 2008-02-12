# http://hassox.blogspot.com/2008/01/merb-supports-rspec-text-stories.html
# based on merb_stories
# Author: Daniel Neighman
# Web:    http://hassox.blogspot.com
module Merb
  module Test
    class RspecStory
      #Helper has not been ported to 0.9.0 as of 2/10/08
      #include Merb::Test::Helper
      include Merb::Test::Rspec::ControllerMatchers
    end
  end
end