$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'merb-core'

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

class FakeModel3
  attr_accessor :foo, :bar
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

module Merb
  module Test
    module Rspec
      module ViewMatchers
        
        class HaveSelector
          def initialize(expected)
            @expected = expected
          end
    
          def matches?(stringlike)
            @document = case stringlike
            when Hpricot::Elem
              stringlike
            when StringIO
              Hpricot.parse(stringlike.string)
            else
              Hpricot.parse(stringlike)
            end
            !@document.search(@expected).empty?
          end
    
          def failure_message
            "expected following text to match selector #{@expected}:\n#{@document}"
          end

          def negative_failure_message
            "expected following text to not match selector #{@expected}:\n#{@document}"
          end
        end
  
        class MatchTag
          def initialize(name, attrs)
            @name, @attrs = name, attrs
            @content = @attrs.delete(:content)
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
            if @content
              unless target.include?(">#{@content}<")
                @errors << "Expected #{target} to include #{@content}"
              end
            end
            @errors.size == 0
          end
    
          def failure_message
            @errors[0]
          end
    
          def negative_failure_message
            "Expected not to match against <#{@name} #{@attrs.map{ |a,v| "#{a}=\"#{v}\"" }.join(" ")}> tag, but it matched"
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
  
        class HasTag
          def initialize(tag, attributes = {})
            @tag, @attributes = tag, attributes
            @id, @class = @attributes.delete(:id), @attributes.delete(:class)
          end
    
          def matches?(stringlike, &blk)
            @document = case stringlike
            when Hpricot::Elem
              stringlike
            when StringIO
              Hpricot.parse(stringlike.string)
            else
              Hpricot.parse(stringlike)
            end
      
            if block_given?
              !@document.search(selector).select do |ele|
                begin
                  blk.call(ele)
                rescue Spec::Expectations::ExpectationNotMetError
                  false
                end
              end.empty?
            else
              !@document.search(selector).empty?
            end
          end

          def selector
            @selector = "//#{@tag}#{id_selector}#{class_selector}"
            @selector << @attributes.map{|a, v| "[@#{a}=\"#{v}\"]"}.join

            @selector << @inner_has_tag.selector unless @inner_has_tag.nil?

            @selector
          end
    
          def id_selector
            "##{@id}" if @id
          end
    
          def class_selector
            ".#{@class}" if @class
          end
    
          def failure_message
            "expected following output to contain a #{tag_for_error} tag:\n#{@document}"
          end
    
          def negative_failure_message
            "expected following output to omit a #{tag_for_error} tag:\n#{@document}"
          end
    
          def tag_for_error
            "#{inner_failure_message}<#{@tag}#{id_for_error}#{class_for_error}#{attributes_for_error}>"
          end
    
          def inner_failure_message
            "#{@inner_has_tag.tag_for_error} tag within a " unless @inner_has_tag.nil?
          end
    
          def id_for_error
            " id=\"#{@id}\"" unless @id.nil?
          end

          def class_for_error
            " class=\"#{@class}\"" unless @class.nil?
          end

          def attributes_for_error
            @attributes.map{|a,v| " #{a}=\"#{v}\""}.join
          end

          def with_tag(name, attrs={})
            @inner_has_tag = HasTag.new(name, attrs)
          end
        end
  
        def match_tag(name, attrs={})
          MatchTag.new(name, attrs)
        end
        def not_match_tag(attrs)
          NotMatchTag.new(attrs)
        end
  
        def have_selector(expected)
          HaveSelector.new(expected)
        end
        alias_method :match_selector, :have_selector
  
        # rspec matcher to test for the presence of tags
        # ==== Examples
        # body.should have_tag("div")
        # => #checks for <div>
        #
        # body.should have_tag("span", :id => :notice)
        # => #checks for <span id="notice">
        #
        # body.should have_tag(:h2, :class => "bar", :id => "foo")
        # => #checks for <h1 id="foo" class="bar">
        #
        # body.should have_tag(:div, :attr => :val)
        # => #checks for <div attr="val">
        #
        # body.should have_tag(:h1, "Title String")
        # => #checks for <h1>Title String</h1>
        #
        # body.should have_tag(:h2, /subtitle/)
        # => #checks for <h2>/subtitle/</h2>
        def have_tag(tag, attributes)
          HasTag.new(tag, attributes)
        end

        alias_method :with_tag, :have_tag
        
      end
    end
  end
end

describe "FakeBufferConsumer", :shared => true do
  before :each do
    @obj = FakeModel.new
    def _buffer(buf = "") @buffer ||= "" end
    def concat(text, binding) _buffer << text end
    def capture(*args, &block)
      # get the buffer from the block's binding

      # If there is no buffer, just call the block and get the contents
      if _buffer.nil?
        block.call(*args)
      # If there is a buffer, execute the block, then extract its contents
      else
        pos = _buffer.length
        block.call(*args)

        # extract the block
        data = _buffer[pos..-1]

        # replace it in the original with empty string
        _buffer[pos..-1] = ''

        data
      end
    end
  end
end

Spec::Runner.configure do |config|
  config.include Merb::Test::Rspec::ViewMatchers
end