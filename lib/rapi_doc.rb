require 'erb'
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
        method, url, controller_action = entry.split.slice(-3, 3)
        controller, action = controller_action.split('#')
        puts "For \"#{controller}\", found action \"#{action}\" with #{method} at \"#{url}\""
        controller_info[controller] ||= []
        controller_info[controller] << [action, method, url]
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
        controller_base_routes = action_entries.select do |action, method, url|
          url.index('/', 1).nil?
        end
        # base urls differ only by the method [GET or POST]. So, any one will do.
        controller_url = controller_base_routes[0][2].gsub(/\(.*\)/, '') # omit the trailing format
        #controller_methods = controller_base_routes.map { |action, method, url| method }
        if block_given?
          controller_include = yield [controller, controller_url, controller_location]
        else
          controller_include = true
        end
        resources << ResourceDoc.new(controller, controller_url, controller_location) if controller_include
      end
      resources
    end

    # Generates views and their index in a temp directory
    def generate_templates!(resource_docs)
      generate_resource_templates!(resource_docs)
      generate_resource_index!(resource_docs)
      copy_styles!
    end

    # Moves the generated files in the temp directory to target directory
    def move_structure!
      Dir.mkdir(target_dir) if (!File.directory?(target_dir))
      # Only want to move the .html, .css and .js files, not the .erb templates.
      html_css_files = temp_dir("*.{html,css,js}")
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
      resources = resource_docs.collect { |resource| resource.parse_apidoc! }
      template = IO.read(config_dir('index.html.erb'))
      parsed = ERB.new(template).result(binding) # this gets evaluated against the "resources" local variable
      File.open(temp_dir("index.html"), 'w') { |file| file.write parsed }
    end

     # generate the index file for the api views
    def generate_resource_index!(resources)
      template = IO.read(config_dir('resource_index.html.erb'))
      parsed = ERB.new(template).result(binding) # this gets evaluated against the "resources" local variable
      File.open(temp_dir("resource_index.html"), 'w') { |file| file.write parsed }
    end

    def copy_styles!
      css_js_files = config_dir("*.{css,js}")
      Dir[css_js_files].each { |f| cp f, temp_dir }
    end

  end
end
