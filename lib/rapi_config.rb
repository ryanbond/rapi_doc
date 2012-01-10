module RapiDoc
  module RapiConfig
    BASE_DIR = 'config/rapi_doc'
    
    def config_dir
      File.join(::Rails.root.to_s, BASE_DIR)
    end

    def template_dir
      File.join(File.dirname(__FILE__), '/../templates')
    end

    def config_file(location)
      File.join(find_location(location), 'config.yml')
    end

    def layout_file(location)
      File.join(find_location(location), 'layout.html.erb')
    end

    def class_layout_file(location)
      File.join(find_location(location), 'class_layout.html.erb')
    end

    def frameset_file(location)
      File.join(find_location(location), 'frameset.html.erb')
    end

    def main_file(location)
      File.join(find_location(location), 'main.html.erb')
    end

    def find_location(location)
      location == :target ? config_dir : template_dir
    end
  end
end