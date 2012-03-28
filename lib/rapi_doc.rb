require 'erb'
require 'fileutils'
require 'doc_util'
require 'resource_doc'
require 'rapi_config'
require 'rapi_doc/railtie' if defined?(Rails)

module RapiDoc
  class RAPIDoc

    include RapiConfig
    include FileUtils::Verbose # so that each mv/cp/mkdir gets printed and user is aware of what is happening

    # Initalize the ApiDocGenerator
    def initialize(resources)
      puts "Apidoc started..."
      @resources = resources
      generate_templates!
      move_structure!
      puts "Finished."
    end

    # Iterates over the resources creates views for them.
    # Creates an index file
    def generate_templates!
      @resources.each do |r|
        r.parse_apidoc!
        r.generate_view!(@resources, temp_dir)
      end
      generate_index!
      copy_styles!
    end

    # generate the index file for the api views
    def generate_index!
      template = ""
      @page_type2 = 'dudul'
      File.open(config_dir(:class_layout_file)).each { |line| template << line }
      parsed = ERB.new(template).result(binding)
      File.open(temp_dir("class.html"), 'w') { |file| file.write parsed }
    end

    def move_structure!
      Dir.mkdir(target_dir) if (!File.directory?(target_dir))
      # Copy the frameset and main files
      cp config_dir(:frameset_file), target_dir('index.html')
      cp config_dir(:main_file), target_dir('main.html')
      # Only want to copy over the .html files, not the .erb templates and then clean up files that are no longer needed
      html_css_files = temp_dir("*.{html,css}")
      Dir[html_css_files].each { |f| mv f, target_dir }  
    end

    def copy_styles!
      css_files = template_dir('*.css')
      Dir[css_files].each { |f| cp f, temp_dir }
    end

  end
end
