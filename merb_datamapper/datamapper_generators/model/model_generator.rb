# require 'merb-core'
require "merb-gen/helpers"
require "merb-gen/base"

Merb.start %w( -e development -a runner )

class ModelGenerator < Merb::GeneratorBase
  attr_reader :model_attributes, :class_name, :model_file_name
  
  def initialize(args, runtime_args = {})
    @base =                 File.dirname(__FILE__)
    @name =                 args.shift
    @class_name =           args.shift.snake_case.to_const_string
    @model_attributes =     Hash[*(args.map{|a| a.split(":") }.flatten)]
    
    @model_file_name =      "#{@class_name.snake_case}.rb"
    super
  end
  
  def manifest
    record do |m|
      @m = m
      
      m.directory "app/models"
      
      @assigns = {  :model_file_name  => model_file_name, 
                    :model_attributes => model_attributes,
                    :class_name       => class_name
                  }
      copy_dirs
      copy_files
    end
  end
  
  protected
  def banner
    <<-EOS.split("\n").map{|x| x.strip}.join("\n")
      Creates a Datamapper Model stub..

      USAGE: #{spec.name}"
    EOS
  end
      
end