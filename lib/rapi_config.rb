module RapiDoc
  module RapiConfig
    def config_dir
      File.join(::Rails.root.to_s, 'config/rapi_doc')
    end

    def template_dir
      File.join(File.dirname(__FILE__), '/../templates')
    end

    def config_file(location)
      File.join(find_location(location), 'config.yml')
    end

    def index_layout_file(location)
      File.join(find_location(location), 'index.html.erb')
    end

    def resource_layout_file(location)
      File.join(find_location(location), 'resource.html.erb')
    end

    def find_location(location)
      location == :target ? config_dir : template_dir
    end
  end
end