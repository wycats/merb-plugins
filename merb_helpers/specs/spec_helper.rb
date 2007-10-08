$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'merb'

module TagMatchers
  class MatchTag
    def initialize(name, attrs)
      @name, @attrs = name, attrs
    end

    def matches?(target)
      @errors = []
      unless target.include?("<#{@name}")
        @errors << "Expected a <#{@name}>, but was #{target}"
      end
      @attrs.each do |attr, val|
        unless target.include?("#{attr}=\"#{val}\"")
          @errors << "Expected #{attr}=\"#{val}\", but was #{target}"
        end
      end
      @errors.size == 0
    end
    
    def failure_message
      @errors[0]
    end
  end
  
  class NotMatchTag
    def initialize(attrs)
      @attrs = attrs
    end
    
    def matches?(target)
      @errors = []
      @attrs.each do |attr, val|
        if target.include?("#{attr}=\"#{val}\"")
          @errors << "Should not include #{attr}=\"#{val}\", but was #{target}"
        end
      end
      @errors.size == 0
    end
    
    def failure_message
      @errors[0]
    end
  end
  
  def match_tag(name, attrs)
    MatchTag.new(name, attrs)
  end
  def not_match_tag(attrs)
    NotMatchTag.new(attrs)
  end
end

class FakeModel
  def self.columns
    [FakeColumn.new(:foo, :string), 
     FakeColumn.new(:foobad, :string),       
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
end

class FakeModel2 < FakeModel

  def foo
    "foowee2"
  end
  alias_method :foobad, :foo
  
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
  include TagMatchers
  
  before :each do
    @obj = FakeModel.new
    def _buffer(buf = "") @buffer ||= "" end    
  end
end