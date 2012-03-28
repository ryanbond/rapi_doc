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
      File.open(class_layout_file(:target)).each { |line| template << line }
      parsed = ERB.new(template).result(binding)
      File.open(File.join(temp_dir, "class.html"), 'w') { |file| file.write parsed }
    end

    def move_structure!
      target_folder = "#{::Rails.root.to_s}/public/apidoc/"
      Dir.mkdir(target_folder) if (!File.directory?(target_folder))

      # Copy the frameset & main files
      cp frameset_file(:target), target_folder + 'index.html'
      cp main_file(:target), target_folder + 'main.html'
      # Only want to copy over the .html files, not the .erb templates and then clean up files that are no longer needed
      html_css_files = File.join(temp_dir, "*.{html,css}")
      Dir[html_css_files].each { |f| mv f, target_folder }  
    end

    def copy_styles!
      css_files = File.join(File.dirname(__FILE__), '..', 'templates/*.css') 
      Dir[css_files].each { |f| cp f, temp_dir }
    end

    private

    def temp_dir
      @temp_dir ||= "#{Dir.mktmpdir("apidoc")}/"
    end
  end
end
