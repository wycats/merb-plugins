require "digest/md5"
require "fileutils"
require "curb"
require "zip/zip"
srand(Time.now.to_i)

class Laszlo
  def self.file_name
    Digest::MD5.hexdigest(rand(Time.now.to_i).to_s)
  end
  
  def self.app_name
    File.basename(File.expand_path(Merb.root))
  end
  
  cattr_accessor :url
end

require "haml"

module Haml
  module Filters
    module Cdata
      include Haml::Filters::Base
      
      def render(text)
        "<![CDATA[#{("\n" + text).rstrip.gsub("\n", "\n    ")}\n]]>"
      end
    end
  end
end

Merb::Config[:haml] ||= {}
Merb::Config[:haml][:filters] ||= {}
Merb::Config[:haml][:filters].merge!("cdata" => Haml::Filters::Cdata)

require "merb-laszlo/controllers"
require "merb-laszlo/helpers"