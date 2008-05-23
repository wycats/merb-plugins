require "pathname"
module Merb
  class Controller
  
    def laszlo(str)
      @lz_resources ||= []
      
      root, template_location = self.class._template_roots.last
      resource_dir = root / send(template_location, "resources")[0...-1]
      Merb.logger.info! "Resource dir: #{resource_dir}"
      
      zip_filename = "#{Laszlo.file_name}.zip"
      FileUtils.mkdir_p(Merb.root / "tmp")
      Zip::ZipFile.open(Merb.root / "tmp" / zip_filename, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.get_output_stream("#{action_name}.lzx") do |f|
          f.puts str
        end
        @lz_resources.each do |resource|
          filepath = resource.split("/")
          dir = filepath[1...-1].join("/").gsub(/^#{Merb.root}/, "")
          filename = filepath[-1]
          zipfile.mkdir(dir) unless zipfile.find_entry(dir) || dir.empty?
          Merb.logger.info! "Looking for #{resource_dir / resource}"
          if File.file?(resource_dir / resource)
            zipfile.add(resource, resource_dir / resource)
          elsif File.file?(root / resource)
            zipfile.add(resource, root / resource)
          end
        end
      end
      c = Curl::Easy.new
            
      c.url = "#{Laszlo.url}/file_upload.jsp"
      c.multipart_form_post = true      

      file = Curl::PostField.file("myFile", Merb.root / "tmp" / zip_filename, zip_filename)
      file.content_type = "application/zip"

      c.http_post(
        file,
        Curl::PostField.content("uid", "#{Laszlo.app_name}__#{controller_name}"))
      
      File.delete(Merb.root / "tmp" / zip_filename)
      
      if c.response_code == 200
        redirect("#{Laszlo.url}/my-apps/#{Laszlo.app_name}__#{controller_name}/#{action_name}.lzx")
      else
        raise NotAcceptable
      end
    end
    
  end
end