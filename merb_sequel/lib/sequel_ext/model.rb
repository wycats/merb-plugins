module Sequel
  class Model
    def new_record?
      self.new?
    end
  end
end