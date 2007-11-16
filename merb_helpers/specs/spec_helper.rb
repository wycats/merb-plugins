$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'merb'
# require 'merb/test/rspec'

class FakeModel
  
  attr_accessor :vin, :make, :model
  
  def self.columns
    [FakeColumn.new(:foo, :string), 
     FakeColumn.new(:foobad, :string),
     FakeColumn.new(:desc, :string),
     FakeColumn.new(:bar, :integer), 
     FakeColumn.new(:barbad, :integer),      
     FakeColumn.new(:baz, :boolean),
     FakeColumn.new(:bazbad, :boolean),
     FakeColumn.new(:bat, :boolean),
     FakeColumn.new(:batbad, :boolean)
     ]     
  end
  
  def valid?
    false
  end
  
  def new_record?
    false
  end
  
  def errors
    FakeErrors.new(self)
  end
  
  def foo
    "foowee"
  end
  alias_method :foobad, :foo
  
  def bar
    7
  end
  alias_method :barbad, :bar
  
  def baz
    true
  end
  alias_method :bazbad, :baz
  
  def bat
    false
  end
  alias_method :batbad, :bat
  
  def nothing
    nil
  end
end

class FakeModel2 < FakeModel
  
  def foo
    "foowee2"
  end
  alias_method :foobad, :foo
  
  def bar
    "barbar"
  end
  
  def new_record?
    true
  end
  
end

class FakeErrors
  
  def initialize(model)
    @model = model
  end
  
  def on(name)
    name.to_s.include?("bad")
  end
  
end

class FakeColumn
  attr_accessor :name, :type
  
  def initialize(name, type)
    @name, @type = name, type
  end
  
end

describe "FakeBufferConsumer", :shared => true do
  before :each do
    @obj = FakeModel.new
    def _buffer(buf = "") @buffer ||= "" end    
  end
end