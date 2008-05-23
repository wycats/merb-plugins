class LaszloController < Merb::Controller
  
  def index
    laszlo("<canvas><text>Hello world</text></canvas>")
  end
  
end