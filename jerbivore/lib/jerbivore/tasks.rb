namespace :jerbivore do
  JERBIVORE_ROOT = File.dirname(__FILE__) / '..' / '..'
  DEFAULT_GEMS = %w[Antwrap mongrel erubis json_pure mime-types mailfactory]
  
  namespace :freeze do
    def install_gem(name, gem_dir)
      require 'rubygems'
      puts "Trying to install #{name}"
      
      gems = Gem.source_index.search(name)
      raise "#{name} must be installed on your machine before I can freeze it" if gems.empty?
      current_gem = gems.last
      cp_r current_gem.full_gem_path, gem_dir / 'gems'
      cp_r current_gem.loaded_from,   gem_dir / 'specifications'

      unless current_gem.dependencies.empty?
        puts "Installing dependencies for #{name}"
        current_gem.dependencies.each { |dep| install_gem(dep.name, gem_dir) }
      end
    end
    
    #desc "Install the required gems into your app's gems directory"
    task :gems do
      gem_dir = MERB_ROOT / 'gems'
      mkdir_p gem_dir / 'gems'
      mkdir_p gem_dir / 'specifications'

      # Find all the gems we need
      gem_names = DEFAULT_GEMS
      if app_gems = Merb::Plugins.config[:jerbivore][:gems]
        gem_names += app_gems
      end
      
      # Install all the gems
      gem_names.each { |g| install_gem(g, gem_dir) } 
    end
    
    task :merb do
      unless File.exist?(MERB_ROOT / 'framework')
        Rake::Task['merb:freeze_from_svn'].invoke
      end
    end
  end

  desc "Package your application into a .war file"
  task :war => ['jerbivore:freeze:merb'] do
    require 'antwrap'
    war_file = "#{File.basename(MERB_ROOT)}.war"
    build_dir = MERB_ROOT / 'war'
    mkdir_p build_dir 
    ant = AntProject.new(:ant_home => ENV['ANT_HOME'])
    ant.war(:webxml => JERBIVORE_ROOT / 'lib' / 'java' / 'web.xml', 
            :destfile => build_dir / war_file) do |ant|
      ant.fileset :dir => 'public'
      ant.webinf :dir => MERB_ROOT, 
                 :excludes => '**/*.war, log/**/*, public/**/*, war/**/*'
      ant.lib :file => JERBIVORE_ROOT / 'lib' / 'java' / '*.jar'
    end
    cd "war" do
      sh "unzip -uo #{war_file}"
    end
  end
  
  jetty_config = MERB_ROOT / 'config' / 'jetty.xml'
  file jetty_config do
    erb = Erubis::Eruby.new(File.read(JERBIVORE_ROOT / 'jetty' / 'jetty.xml.erb'))
    File.open(jetty_config, "w") {|f| f << erb.result(binding)}
  end
  
  desc "Run your application in the Jetty servlet container"
  task :jetty => [jetty_config] do
    java_opts = "-server -Xms64m -Xmx256m" 
    cd "#{JERBIVORE_ROOT}/jetty" do
      sh "java #{java_opts} -jar #{JERBIVORE_ROOT}/jetty/start.jar #{jetty_config}"
    end  
  end
end
