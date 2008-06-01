require File.dirname(__FILE__) + '/spec_helper'

describe "merb-laszlo" do
  it "makes files for Laszlo" do
    Laszlo.url = "http://127.0.0.1:8080/lps-4.2.x"
    
    FileUtils.stub!(:mkdir_p)
    zipfile = mock("Zipfile")
    zipfile.should_receive(:get_output_stream).with("index.lzw")
    Zip::ZipFile.stub!(:open).and_yield(zipfile)
    
    curl = mock("Curl::Easy")
    curl.should_receive(:multipart_form_post=)
    curl.should_receive(:http_post)
    curl.stub!(:response_code).and_return(200)
    Curl::Easy.stub!(:new).and_return(curl)
    
    dispatch_to(LaszloController, :index).status.must == 302
  end
end