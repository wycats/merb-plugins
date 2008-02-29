module Merb::Orms::DataMapper::Base
  def to_param
    key
  end
end
DataMapper::Base.send(:include, Merb::Orms::DataMapper::Base)