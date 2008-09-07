$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'merb-core'
require 'merb-core/test'
require 'merb-core/test/helpers'

Merb::BootLoader.before_app_loads do
  require "merb/session/active_record_session"
end

Merb.start_environment( :environment => 'test', :adapter => 'runner', 
                        :session_store => 'activerecord')

Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
end

require 'merb_activerecord'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", 
                                        :dbfile => ":memory:")

ActiveRecord::Schema.define do
  create_table :sessions do |t|
    t.column :session_id, :string
    t.column :data,       :text
    t.column :created_at, :datetime
  end
end

# Load up the shared specs from merb-core
if (gem_spec = Gem.source_index.search('merb-core').last) && 
  gem_spec.files.include?('spec/public/session/controllers/sessions.rb')
  require gem_spec.full_gem_path / 'spec/public/session/controllers/sessions.rb'
  require gem_spec.full_gem_path / 'spec/public/session/session_spec.rb' 
end

describe Merb::ActiveRecordSession do

  before do 
    @session_class = Merb::ActiveRecordSession
    @session = @session_class.generate
  end

  it_should_behave_like "All session-store backends"

  it "should have a session_store_type class attribute" do
    @session.class.session_store_type.should == :activerecord
  end

end

describe Merb::ActiveRecordSession, "mixed into Merb::Controller" do

  before(:all) { @session_class = Merb::ActiveRecordSession }

  it_should_behave_like "All session-stores mixed into Merb::Controller"

end