require 'erb'
require 'fileutils'
require_relative 'rapi_doc/doc_util'
require_relative 'rapi_doc/resource_doc'
require_relative 'rapi_doc/rapi_config'
require_relative 'rapi_doc/railtie' if defined?(Rails)

module RapiDoc
 module RAPIDoc

    include RapiConfig
    include FileUtils::Verbose # so that each mv/cp/mkdir gets printed and user is aware of what is happening

    def create_structure!
      File.directory?(config_dir) || mkdir(config_dir)
      filetypes = FILE_NAMES.keys
      filetypes.each do |file_type|
        target_file = config_dir(file_type)
        if not File.exist? target_file
          template_file = template_dir(file_type)
          cp template_file, config_dir
        end
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
    def generate_templates!(resources)
      generate_resource_templates!(resources)
      generate_resource_index!(resources)
      copy_styles!
    end

    # Moves the generated files in the temp directory to target directory
    def move_structure!
      Dir.mkdir(target_dir) if (!File.directory?(target_dir))
      # Copy the main file
      cp config_dir(:main_file), target_dir('main.html')
      # Only want to move the .html and .css files, not the .erb templates.
      html_css_files = temp_dir("*.{html,css}")
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
    def generate_resource_templates!(resources)
      resources.each do |resource|
        parsed_resource = resource.parse_apidoc!
        out_file = temp_dir(resource.name + ".html")
        File.open(out_file, 'w') { |f| f.write parsed_resource }
      end
    end

     # generate the index file for the api views
    def generate_resource_index!(resources)
      template = IO.read(config_dir(:resource_index_file))
      # evaluate this template in the context of a temp class with one instance variable - resources
      namespace = OpenStruct.new(:resources => resources)
      parsed = ERB.new(template).result(namespace.instance_eval { binding })
      File.open(temp_dir("resource_index.html"), 'w') { |file| file.write parsed }
    end

    def copy_styles!
      css_files = template_dir('*.css')
      Dir[css_files].each { |f| cp f, temp_dir }
    end

  end
end
