dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/matchers/have_text")
require File.expand_path("#{dir}/matchers/redirect_to")
require File.expand_path("#{dir}/matchers/render_template")

module Spec
  module Merb
    module Matchers
    end
  end
end
