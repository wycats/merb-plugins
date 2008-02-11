module Merb::Test::Rspec::MarkupMatchers
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

    def matches?(stringlike, &block)
      @document = case stringlike
      when Hpricot::Elem
        stringlike
      when StringIO
        Hpricot.parse(stringlike.string)
      else
        Hpricot.parse(stringlike)
      end
      
      @document.search(selector)
      
      !@document.search(selector(&block)).empty?
    end

    def selector(&block)
      start = "//#{@tag}#{id_selector}#{class_selector}"
      start << @attributes.map{|a, v| "[@#{key}=\"#{value}\"]"}.join

      @selector << @inner_has_tag.selector if (@inner_has_tag = block.call).is_a?(HasTag) unless block.nil?

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
      @attributes.map{|a,v| " #{key}=\"#{pair}\""}.join
    end

    def with_tag(*args)
      @inner_has_tag = HasTag.new(*args)
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