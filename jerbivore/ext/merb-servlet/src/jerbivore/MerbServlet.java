package jerbivore;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.jruby.Ruby;
import org.jruby.RubyIO;
import org.jruby.RubyModule;
import org.jruby.exceptions.RaiseException;
import org.jruby.javasupport.JavaEmbedUtils;
import org.jruby.runtime.builtin.IRubyObject;

/**
 *
 * @author dudley
 */
public class MerbServlet extends HttpServlet {
    private Ruby ruby;
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        String appRoot = getServletContext().getRealPath("/");
        try {
            ruby = createRuntime(appRoot);
        } catch (RaiseException e) {
            throw new ServletException("Failed to create a Ruby runtime", e);
        }
    }

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RubyModule handler = ruby.getClassFromPath("Jerbivore::ServletHandler");
        if (handler == null) {
            throw new ServletException("Couldn't load the Jerbivore::ServletHandler class.");
        }
        JavaEmbedUtils.invokeMethod(ruby, handler, "handle", 
            new IRubyObject[]{
                JavaEmbedUtils.javaToRuby(ruby, request),
                new RubyIO(ruby, request.getInputStream()),
                JavaEmbedUtils.javaToRuby(ruby, response),
                new RubyIO(ruby, response.getOutputStream())
            }, Object.class);
    }

    @Override
    public void destroy() {
        super.destroy();
        destroyRuby();
    }
    
    protected static Ruby createRuntime(String appRoot) {
        String merbRoot;
        if (appRoot.endsWith("/")) {
            merbRoot = appRoot + "WEB-INF";
        } else {
            merbRoot = appRoot + "/WEB-INF";
        }

        List<String> loadPaths = new ArrayList<String>();
        loadPaths.add(merbRoot);
        loadPaths.add(merbRoot + "/lib");
        loadPaths.add(merbRoot + "/framework");
        loadPaths.add(merbRoot + "/app/models");
        loadPaths.add(merbRoot + "/app/controllers");
        loadPaths.add("META-INF/jruby.home/lib/ruby/site_ruby/1.8");
        Ruby runtime = JavaEmbedUtils.initialize(loadPaths);
        return loadMerb(runtime, merbRoot);
    }
    
    protected static Ruby loadMerb(Ruby runtime, String merbRoot) {
        String merbInitScript = 
            "require 'rubygems'\n" +
            "Gem.clear_paths\n" +
            "Gem.path.unshift('"+ merbRoot + "/gems')\n" +
            "require 'merb/server'\n" +
            "merb_yml = '" + merbRoot + "/config/merb.yml'\n" +
            "options = \n" +
            "  if File.exists?(merb_yml)\n" +
            "    require 'merb/erubis_ext'\n" +
            "    Merb::Config.defaults.merge(Erubis.load_yaml_file(merb_yml))\n" +
            "  else\n" +
            "    Merb::Config.defaults\n" +
            "  end        \n" +
            "options[:merb_root] = '"+ merbRoot +"'\n" +
            "case options[:environment].to_s\n" +
            "  when 'production'\n" +
            "    options[:reloader] = options.fetch(:reloader, false)\n" +
            "    options[:exception_details] = options.fetch(:exception_details, false)\n" +
            "    options[:cache_templates] = true\n" +
            "  else\n" +
            "    options[:reloader] = options.fetch(:reloader, true)\n" +
            "    options[:exception_details] = options.fetch(:exception_details, true)\n" +
            "end\n" +
            "options[:reloader_time] ||= 0.5 if options[:reloader] == true\n" +
            "if options[:reloader]\n" +
            "  Thread.abort_on_exception = true\n" +
            "  Thread.new do\n" +
            "    loop do\n" +
            "      sleep(options[:reloader_time])\n" +
            "      Merb::Server.reload\n" +
            "    end\n" +
            "    Thread.exit\n" +
            "  end\n" +
            "end\n" +
            "Merb::Server.send :class_variable_set, :@@merb_opts, options\n" +
            "Merb::BootLoader.initialize_merb\n" +
            "Jerbivore::ServletHandler.path_prefix = Merb::Config[:path_prefix]\n";
        runtime.executeScript(merbInitScript, "MerbServlet:merbInitScript");
        return runtime;
    }
    
    protected void destroyRuby() {
        if (ruby != null) {
            JavaEmbedUtils.terminate(ruby);
        }
    }

    protected Ruby getRuby() {
        return ruby;
    }
}
