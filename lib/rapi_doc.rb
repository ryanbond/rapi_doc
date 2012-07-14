require 'haml'
require 'fileutils'
require_relative 'rapi_doc/resource_doc'
require_relative 'rapi_doc/rapi_config'
require_relative 'rapi_doc/railtie' if defined?(Rails)

module RapiDoc
 module RAPIDoc

    include RapiConfig
    include FileUtils::Verbose # so that each mv/cp/mkdir gets printed and user is aware of what is happening

    def create_structure!
      File.directory?(config_dir) || mkdir(config_dir)
      Dir["#{template_dir}/*.*"].each do |template_file|
        target_file = config_dir(File.basename(template_file))
        cp template_file, config_dir if not File.exist? target_file
      end
    end

    # Reads 'rake routes' output and gets the controller info
    def get_controller_info!
      controller_info = {}
      routes = Dir.chdir(::Rails.root.to_s) { `rake routes` }
      routes.split("\n").each do |entry|
        if !entry.blank?
          entry_split = entry.split
          idx = entry_split.index{|x| ['PUT', 'POST', 'DELETE', 'GET'].include?(x)}
          if idx
            method, url, controller_action = entry.split.slice(idx, 3)
            controller, action = controller_action.split('#')
            puts "For \"#{controller}\", found action \"#{action}\" with #{method} at \"#{url}\""
            controller_info[controller] ||= []
            controller_info[controller] << [action, method, url]
          end
        end
      end
      controller_info
    end

    def get_resources!
      #yml = get_config || []
      #yml.collect { |key, val| ResourceDoc.new(key, val["location"], controller_dir(val["controller_name"])) }
      controller_info = get_controller_info!
      resources = []
      controller_info.each do |controller, action_entries|
        #controller_class = controller.capitalize + 'Controller'
        controller_location = controller_dir(controller + '_controller.rb')
        controller_base_routes = action_entries.inject({}){|x,y| x[y[0]]=y[1..-1]; x}.map(&:flatten)

        # base urls differ only by the method [GET or POST]. So, any one will do.
        if !controller_base_routes.empty?
          controller_url = controller_base_routes[0][2].gsub(/\(.*\)/, '') # omit the trailing format
          #controller_methods = controller_base_routes.map { |action, method, url| method }
          if block_given?
            controller_include = yield [controller, controller_url, controller_location]
          else
            controller_include = true
          end
          resources << ResourceDoc.new(controller, controller_url, controller_location) if controller_include
        end
      end
      resources
    end

    # Generates views and their index in a temp directory
    def generate_templates!(resource_docs)
      generate_resource_templates!(resource_docs)
      copy_styles!
    end

    # Moves the generated files in the temp directory to target directory
    def move_structure!
      Dir.mkdir(target_dir) if (!File.directory?(target_dir))
      # Only want to move the .html, .css, .png and .js files, not the .haml templates.
      html_css_files = temp_dir("*.{html,css,js,png}")
      Dir[html_css_files].each { |f| mv f, target_dir }
    end

    # Removes the generated files
    def remove_structure!
      rm_rf target_dir
    end

    # Remove all files - config and generated
    def remove_all!
      remove_structure!
      rm_rf config_dir
    end

    # Creates views for the resources
    def generate_resource_templates!(resource_docs)
      class_template = IO.read(template_dir('_resource_header.html.haml'))
      method_template = IO.read(template_dir('_resource_method.html.haml'))
      resource_docs.each { |resource| resource.parse_apidoc!(class_template, method_template) }
      template = IO.read(config_dir('index.html.haml'))
      parsed = Haml::Engine.new(template).render(Object.new, :resource_docs => resource_docs)
      File.open(temp_dir("index.html"), 'w') { |file| file.write parsed }
    end

    def copy_styles!
      css_js_files = config_dir("*.{css,js,png}")
      Dir[css_js_files].each { |f| cp f, temp_dir }
    end

  end
end
