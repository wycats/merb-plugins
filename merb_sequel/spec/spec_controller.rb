class SpecController < Merb::Controller
  def set
    session[:key] = 'value'
  end
  
  def get
    session[:key]
  end
end