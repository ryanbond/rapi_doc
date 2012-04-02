require 'erb'
require 'fileutils'
require 'doc_util'
require 'resource_doc'
require 'rapi_config'
require 'rapi_doc/railtie' if defined?(Rails)

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

    def get_config
      config_file = config_dir(:config_file)
      begin
        yml_file = File.open(config_file)
      rescue Errno::ENOENT
        puts "Please run rake rapi_doc:setup to generate config files first and then run rapi_doc::generate again"
        nil
      else
        yml = YAML::load(yml_file)
        puts "Please specify controllers in config/rapi_doc/config.yml for which api documentation is to be generated and then run rapi_doc::generate again" if not yml
        yml
      end
    end

    def get_resources(yml)
      resources = yml.collect do |key, val|
        ResourceDoc.new(key, val["location"], val["controller_name"])
      end
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
      # Copy the frameset and main files
      cp config_dir(:frameset_file), target_dir('index.html')
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
        puts "Generated #{out_file}"
      end
    end

     # generate the index file for the api views
    def generate_resource_index!(resources)
      template = IO.read(config_dir(:class_layout_file))
      # evaluate this template in the context of a temp class with one instance variable - resources
      namespace = OpenStruct.new(:resources => resources)
      parsed = ERB.new(template).result(namespace.instance_eval { binding })
      File.open(temp_dir("class.html"), 'w') { |file| file.write parsed }
    end

    def copy_styles!
      css_files = template_dir('*.css')
      Dir[css_files].each { |f| cp f, temp_dir }
    end

  end
end
