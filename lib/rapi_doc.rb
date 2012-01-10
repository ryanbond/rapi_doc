require 'erb'
require 'fileutils'
require 'doc_util'
require 'resource_doc'
require 'rapi_config'
require 'rapi_doc/railtie' if defined?(Rails)

module RapiDoc
  class RAPIDoc

    include RapiConfig

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
      FileUtils.cp frameset_file(:target), target_folder + 'index.html'
      FileUtils.cp main_file(:target), target_folder + 'main.html'

      Dir.new(temp_dir).each do |d|
        if d =~ /^[a-zA-Z]+\.(html|css)$/ # Only want to copy over the .html files, not the .erb templates
          FileUtils.cp  File.join(temp_dir + d), target_folder + d
        end

        #Clean up the no longer needed files
        filepath = "#{temp_dir}/#{d}"
        File.delete(filepath) unless File.directory?(filepath)
      end
    end

    def copy_styles!
      Dir[File.join(File.dirname(__FILE__), '..', 'templates/*')].each do |f|
        if f =~ /[\/a-zA-Z\.]+\.css$/i
          FileUtils.cp f, temp_dir
        end
      end
    end

    private

    def temp_dir
      @temp_dir ||= "#{Dir.mktmpdir("apidoc")}/"
    end
  end
end
