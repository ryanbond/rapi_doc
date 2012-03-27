module RapiDoc
  module RapiConfig
    BASE_DIR = 'config/rapi_doc'
    
    def config_dir
      @config_dir ||= File.join(::Rails.root.to_s, BASE_DIR)
    end

    def template_dir
      @template_dir ||= File.join(File.dirname(__FILE__), '/../templates')
    end

    FILE_LOCATIONS = {:config_file => 'config.yml', :layout_file => 'layout.html.erb', :class_layout_file => 'class_layout.html.erb', :frameset_file => 'frameset.html.erb', :main_file => 'main.html.erb'}
    FILE_LOCATIONS.each do |file_type, file_name|
      define_method(file_type) do |location_type|
        dir_location = location_type == :target ? config_dir : template_dir
        File.join(dir_location, file_name)
      end
    end
  end
end