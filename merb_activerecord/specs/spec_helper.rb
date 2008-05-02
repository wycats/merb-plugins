$TESTING = true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'merb-core'
require 'merb_activerecord'
require 'merb/test/model_helper/active_record'
