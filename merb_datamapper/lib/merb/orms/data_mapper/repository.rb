module Merb::Orms::DataMapper::Repository
  def to_param
    key
  end
end
DataMapper::Repository.send(:include, Merb::Orms::DataMapper::Repository)